const commonjs = require('rollup-plugin-commonjs');
const nodeRequire = require('rollup-plugin-node-resolve');

module.exports = {
  plugins: [
    nodeRequire(),
    commonjs({
      // Temporary fix until https://github.com/improbable-eng/grpc-web/issues/369 is resolved.
      namedExports: {
        '@improbable-eng/grpc-web': [
          'grpc',
        ],
      }
    }),
  ],
};
