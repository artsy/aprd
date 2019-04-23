const path = require("path")
const glob = require("glob")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const UglifyJsPlugin = require("uglifyjs-webpack-plugin")
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin")
const CopyWebpackPlugin = require("copy-webpack-plugin")

module.exports = (env, options) => ({
  optimization: {
    minimizer: [new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }), new OptimizeCSSAssetsPlugin({})]
  },
  entry: "./src/app.js",
  output: {
    filename: "app.js",
    path: path.resolve(__dirname, "../priv/static/js")
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.(html|svelte)$/,
        exclude: /node_modules/,
        use: {
          loader: "svelte-loader",
          options: {
            emitCss: true,
            customElement: true
          }
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"]
      }
    ]
  },
  plugins: [new MiniCssExtractPlugin({ filename: "../css/app.css" }), new CopyWebpackPlugin([{ from: "static/", to: "../" }])]
})
