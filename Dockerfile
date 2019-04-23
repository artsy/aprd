FROM bitwalker/alpine-elixir-phoenix:latest

ARG SECRET_KEY_BASE

RUN apk add yarn

RUN mkdir /app
ADD . /app
WORKDIR /app

# Set exposed ports
EXPOSE 8080
ENV PORT=8080 MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    yarn install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

CMD ["mix", "phx.server"]
