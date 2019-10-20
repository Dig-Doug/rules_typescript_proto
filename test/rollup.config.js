const commonjs = require('rollup-plugin-commonjs');

module.exports = {
  plugins: [
    commonjs({
      extensions: ['.js', '.mjs'],
    }),
  ],
};
