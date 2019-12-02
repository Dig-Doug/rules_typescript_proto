const commonjs = require('rollup-plugin-commonjs');
const nodeRequire = require('rollup-plugin-node-resolve');

module.exports = {
  plugins: [
    nodeRequire(),
    commonjs({
      // Temporary fix until https://github.com/improbable-eng/grpc-web/issues/369 is resolved.
      namedExports: {
        './node_modules/@improbable-eng/grpc-web/dist/grpc-web-client.js': [
          'grpc',
        ],
      }
    }),
  ],
};
