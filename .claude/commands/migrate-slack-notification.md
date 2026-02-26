You are helping migrate a Slack notification from the `aprd` app (Elixir, this repo) to the `pulse` app (Rails, located at `~/Developer/pulse`).

All work happens in `~/Developer/pulse`. Do not modify any files in the aprd repo.

## Task

The following is a migration ticket. Parse it and implement the Slack notification in Pulse.

$ARGUMENTS

---

## Before you start: read these files first

Read all of them in parallel before writing any code:

- `../pulse/app/workers/rabbit_orders_worker.rb` — to see the existing slack handlers chain
- `../pulse/app/services/slack_commerce_order_submitted_service.rb` — full example with SlackHelper, GravityV1 lookups, build_blocks pattern, seller/buyer URLs, section fields, line items, and theme-scoped subscriptions
- `../pulse/app/services/slack_commerce_tax_mismatch_error_service.rb` — simpler example with no Gravity lookups
- `../pulse/app/helpers/slack_helper.rb` — shared helpers used by all services
- `../pulse/spec/services/slack_commerce_order_submitted_service_spec.rb` — spec pattern to follow

These files contain everything you need to implement any migration ticket. Do not use Explore agents or search the codebase beyond these reads.

---

## How to parse the ticket

| Ticket field | Maps to |
|---|---|
| `event["properties"]["foo"]` | `event[:properties][:foo]` (payload uses symbolized keys) |
| `event["properties"]["order"]["id"]` | `event[:properties][:order][:id]` |
| Topic | `SlackSubscription` topic + `queue_definition` in worker (already `"commerce"` for most) |
| Routing Key | `SlackSubscription` routing_key + `elsif` branch in worker |
| Slack Channels | Informational only — subscriptions are created manually in DB, not in code |

---

## Known patterns — use these directly, do not re-investigate

### SlackHelper

All services extend the shared `SlackHelper` module (`app/helpers/slack_helper.rb`):

```ruby
class SlackCommerce<Name>Service
  extend SlackHelper
  # ...
end
```

This gives access to:
- `get_participant(id, type)` — calls `GravityV1.get_user` for type "user", `GravityV1.get_partner` otherwise
- `format_price(price, currency = "USD", symbol = true)` — formats via Money gem, returns "N/A" for nil price
- `cleanup_name(full_name)` — returns first word of name, or ""

### GravityV1 lookups

```ruby
seller = get_participant(seller_id, seller_type)
seller_name       = seller[:name]
seller_admin_name = seller.dig(:admin, :name) || "N/A"

buyer = get_participant(buyer_id, buyer_type)
buyer_name = cleanup_name(buyer[:name])

artwork = GravityV1.get_artwork(artwork_id)
available_purchase_modes = if artwork[:ecommerce] && artwork[:offer]
  "BNMO"
elsif artwork[:ecommerce]
  "BN"
elsif artwork[:offer]
  "MO"
else
  "!?"
end
```

### URL helpers

```ruby
order_url         = "#{Pulse.config.exchange_url}/admin/orders/#{order_id}"
seller_orders_url = "#{Pulse.config.exchange_url}/admin/orders?q%5Bseller_id_eq%5D=#{seller_id}&scope=all"
buyer_orders_url  = "#{Pulse.config.exchange_url}/admin/orders?q%5Bbuyer_id_eq%5D=#{buyer_id}&scope=all"
user_admin_url    = "#{Pulse.config.admin_url}/users/#{user_id}"
artwork_link      = "#{Pulse.config.force_url}/artwork/#{artwork_id}"
arta_url          = "https://dashboard.arta.io/org/ARTSY/requests/#{external_id}"
stripe_search_url = "https://dashboard.stripe.com/search?query=#{order_id}"
approve_url       = "#{Pulse.config.exchange_url}/admin/orders/#{order_id}/fraud_reviews/new"
flag_fraud_url    = "#{Pulse.config.exchange_url}/admin/orders/#{order_id}/fraud_reviews/new?fraud_review[flagged_as_fraud]=true"
```

### Purchase method (buy/offer/inquiry offer)

Inline this directly — do not extract to a method:

```ruby
is_inquiry_order = event[:properties][:impulse_conversation_id].present?
purchase_method = if order_mode == "offer" && is_inquiry_order
  "Inquiry Offer :cashmoney:"
else
  order_mode.capitalize
end
```

### Stripe payment info

Pulse has `StripePaymentService` (`app/services/stripe_payment_service.rb`) for fetching payment risk data:

```ruby
# For credit card payments:
info = StripePaymentService.payment_info(external_id, external_type)
# Returns: { risk_level:, liability_shift:, card_country:, cvc_check:, zip_check:, billing_state: }
# Returns nil on error

# For ACH / us_bank_account:
info = StripePaymentService.payment_info_ach(external_id, external_type)
# Returns: { risk_level: }
# Returns nil on error
```

Check/boolean formatting for Stripe fields:
```ruby
def format_check(value)
  case value
  when "pass" then ":white_check_mark:"
  when nil    then ":question:"
  else             ":x:"
  end
end

def format_boolean(value)
  value ? ":white_check_mark:" : ":x:"
end
```

### Section with fields (order details block)

```ruby
order_section = Slack::BlockKit::Layout::Section.new
order_section.fields = [
  Slack::BlockKit::Composition::Mrkdwn.new(text: "*<#{order_url}|#{order_code}>*\n*<#{seller_orders_url}|#{seller_name}>*"),
  Slack::BlockKit::Composition::Mrkdwn.new(text: " "),   # spacer to align two-column layout
  Slack::BlockKit::Composition::Mrkdwn.new(text: "*Purchase Method*\n#{purchase_method}"),
  Slack::BlockKit::Composition::Mrkdwn.new(text: "*Buyer*\n<#{buyer_orders_url}|#{buyer_name}>"),
  Slack::BlockKit::Composition::Mrkdwn.new(text: "*Buyer Paid*\n#{format_price(paid_amount, currency_code)}"),
  Slack::BlockKit::Composition::Mrkdwn.new(text: "*Admin*\n#{seller_admin_name}"),
  (Slack::BlockKit::Composition::Mrkdwn.new(text: "*List Price*\n#{format_price(list_price, currency_code)}") if order_mode == "offer")
].compact
```

### Actions block (buttons)

```ruby
b.actions do |a|
  a.button(text: "Approve", action_id: "approve_order", style: "primary", url: approve_url)
  a.button(text: "Flag as Fraud", action_id: "flag_as_fraud", style: "danger", url: flag_fraud_url)
end
```

### SlackSubscription theme scopes

Defined on the model — use them directly:

```ruby
SlackSubscription.where(topic: "commerce", routing_key: "order.submitted").default_theme  # theme IS NULL or ""
SlackSubscription.where(topic: "commerce", routing_key: "order.submitted").high_risk_theme # theme = "high_risk"
SlackSubscription.where(topic: "commerce", routing_key: "order.submitted").dispute_theme   # theme = "dispute"
SlackSubscription.where(topic: "commerce", routing_key: "order.submitted").fraud_theme     # theme = "fraud"
```

If the scope isn't defined yet on the model, add it to `../pulse/app/models/slack_subscription.rb`:
```ruby
scope :fraud_theme, -> { where(theme: "fraud") }
```

### unfurl_links

Match what APRd sends — check the APRd view for the routing key being migrated. Common values:
- `order.submitted` → `unfurl_links: true`
- `order.approved` → `unfurl_links: true`
- `transaction.created` → `unfurl_links: false`
- Most other services → `unfurl_links: false`

---

## What to implement

### 1. Service file

**Path:** `../pulse/app/services/slack_commerce_<descriptive_name>_service.rb`

Name the class `SlackCommerce<DescriptiveName>Service`. Derive the name from the routing key or event description (e.g., `shippingquoterequest.disqualified` → `SlackCommerceArtaShippingQuoteDisqualifiedService`).

**Key rules:**
- `extend SlackHelper` at the top of the class
- Links use `<url|display_text>` Slack mrkdwn format
- Always `as_user: true`
- Always `blocks: blocks.to_json` (not the raw object)
- Match APRd's `unfurl_links` value for the routing key

### 2. Spec file

**Path:** `../pulse/spec/services/slack_commerce_<descriptive_name>_service_spec.rb`

**Note on block structure in specs:** The blocks are serialized to JSON via `.to_json`, so string keys (`"type"`, `"text"`, etc.) are used in the expected value.

```ruby
require "rails_helper"

RSpec.describe SlackCommerce<Name>Service, type: :service do
  describe ".send_message" do
    let(:event) do
      {
        properties: {
          # mirror the ticket's DATA EXTRACTION fields, using symbolized keys
        }
      }
    end

    let(:subscription) { double(channel_id: "C12345") }
    let(:slack_client) { instance_double(Slack::Web::Client) }

    before do
      allow(SlackSubscription).to receive(:where).with(topic: "commerce", routing_key: "<routing_key>").and_return([subscription])
      allow(Slack::Web::Client).to receive(:new).and_return(slack_client)
      allow(slack_client).to receive(:chat_postMessage)
      allow(Pulse.config).to receive(:exchange_url).and_return("https://exchange-staging.artsy.net")
    end

    it "sends a message to subscribed channels" do
      expect(slack_client).to receive(:chat_postMessage).once
      described_class.send_message(event)
    end

    it "formats the Slack message with correct blocks structure" do
      expect(slack_client).to receive(:chat_postMessage).with(
        channel: "C12345",
        blocks: [
          { "type" => "section", "text" => { "type" => "mrkdwn", "text" => "..." } },
          { "type" => "divider" },
          { "type" => "section", "fields" => [ { "type" => "mrkdwn", "text" => "..." }, ... ] }
        ].to_json,
        as_user: true,
        unfurl_links: false
      ).once
      described_class.send_message(event)
    end

    it "queries subscriptions with correct topic and routing key" do
      expect(SlackSubscription).to receive(:where).with(topic: "commerce", routing_key: "<routing_key>").and_return([subscription])
      described_class.send_message(event)
    end

    # If the ticket notes a field "may be null", add:
    context "when <field> is nil" do
      # override event with nil value
      it "shows N/A for the <field>" do
        expect(slack_client).to receive(:chat_postMessage) do |args|
          expect(args[:blocks]).to include("N/A")
        end
        described_class.send_message(event)
      end
    end
  end
end
```

### 3. Worker routing

**File:** `../pulse/app/workers/rabbit_orders_worker.rb`

Find the "slack handlers" comment section and add an `elsif` branch, keeping the chain in alphabetical order by routing key:

```ruby
elsif delivery_info.routing_key == "<routing_key_from_ticket>"
  SlackCommerce<Name>Service.delay.send_message(payload)
```

### 4. Worker spec

**File:** `../pulse/spec/workers/rabbit_orders_worker_spec.rb`

Two places need updating:

**a) Stub the service in the existing handler-selection context.**

Find the `context "<routing_key>"` block in the "event handler selection" section and add a `before` block. The shared example runs inline with a minimal payload (no `mode`, no seller/buyer), so the service must be stubbed to avoid a crash:

```ruby
context "order.fulfilled" do
  let(:routing_key) { "order.fulfilled" }
  let(:message) { order_message }
  let(:expected_handlers) { [OrderFulfilledHandler] }

  before do
    # skip the slack handler since we're not testing it here
    allow(SlackCommerce<Name>Service).to receive_message_chain(:delay, :send_message)
  end

  it_behaves_like "selects the expected handlers"
end
```

**b) Add a slack message test in the `describe "slack messages"` section**, in alphabetical order by routing key, following the pattern of adjacent entries:

```ruby
describe "order.fulfilled" do
  let(:routing_key) { "order.fulfilled" }

  before do
    # skip the email handler since we're not testing it here
    allow(OrderFulfilledHandler).to receive_message_chain(:delay, :process)
  end

  it "sends a slack message" do
    message = {
      verb: "fulfilled",
      object: {id: "order123", root_type: "Order"},
      properties: {
        # include all fields the service reads
        code: "ORD123",
        mode: "buy",
        currency_code: "USD",
        buyer_total_cents: 100000,
        total_list_price_cents: 120000,
        seller_id: "seller123",
        seller_type: "gallery",
        buyer_id: "buyer123",
        buyer_type: "user",
        line_items: [{artwork_id: "artwork-id"}]
      }
    }
    expect(Slack::Web::Client).to receive(:new).and_return(double(chat_postMessage: nil))
    described_class.new.work_with_params(JSON.generate(message), delivery_info, {})
  end
end
```

---

## What NOT to do

- Do not create DB seeds or migrations for `SlackSubscription` records — those are created manually
- Do not modify any files in the `aprd` repo
- Do not add the routing key to `select_handler_for_event` (that's for email/push handlers, not Slack)
- Do not search the aprd codebase — the ticket already captures what you need from it
