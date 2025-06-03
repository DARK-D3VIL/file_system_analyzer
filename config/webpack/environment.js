const { environment } = require('@rails/webpacker')

const babelLoader = environment.loaders.get('babel')
const options = babelLoader.use[0].options

options.plugins = [
  ...(options.plugins || []),
  '@babel/plugin-proposal-optional-chaining',
  '@babel/plugin-proposal-nullish-coalescing-operator',
  '@babel/plugin-proposal-logical-assignment-operators'
]

module.exports = environment
