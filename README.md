# rules_typescript_proto
![](https://github.com/Dig-Doug/rules_typescript_proto/workflows/ci/badge.svg)

Bazel rules for generating TypeScript declarations for JavaScript protocol buffers using the 
[ts-protoc-gen](https://github.com/improbable-eng/ts-protoc-gen) protoc plugin. These rules can also
generate service definitions for use by [grpc-web](https://github.com/improbable-eng/grpc-web) or
[grpc-node](https://github.com/grpc/grpc-node).

## Getting Started

> If you're migrating from the ts-protoc-gen rules, see [here](docs/migrating_from_ts_protoc_gen.md) for a migration guide

> If you're upgrading from a previous version and experiencing issues with missing `_pb_service.d.ts` files, see
> [here](docs/migrating_to_multi_rules.md) for a migration guide.

Before you can use `rules_typescript_proto`, you must first setup:

- [rules_proto](https://github.com/bazelbuild/rules_proto)
- [rules_nodejs](https://github.com/bazelbuild/rules_nodejs)

Once those are setup, add the following to your workspace:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# TODO: Setup rules_proto
# TODO: Setup rules_nodejs

http_archive(
    name = "rules_typescript_proto",
    sha256 = "cca55a4a8eb8489e8c8341355d9e69937685d831792d71c3051170e1c040d310",
    strip_prefix = "rules_typescript_proto-0.0.6",
    urls = [
        "https://github.com/Dig-Doug/rules_typescript_proto/archive/0.0.6.tar.gz",
    ],
)

load("@rules_typescript_proto//:index.bzl", "rules_typescript_proto_dependencies")

rules_typescript_proto_dependencies()
```

Then, in your `BUILD` file:

```python
load("@rules_typescript_proto//:index.bzl", "typescript_proto_library")

proto_library(
  name = "test_proto",
  srcs = [
    "test.proto",
  ],
)

typescript_proto_library(
  name = "test_ts_proto",
  proto = ":test_proto",
)
```

You can now use the `test_ts_proto` target as a `dep` in other `ts_library` targets. However, you 
will need to include the following dependencies at runtime yourself:

- `google-protobuf`
- `@improbable-eng/grpc-web`
- `browser-headers`

For generating grpc output files, you'll also need the following in your `BUILD` file:
```python
# For grpc-web support use:
typescript_grpc_web_library(
  name = "test_ts_grpc_web",
  proto = ":test_proto",
)

# For grpc-node support use:
typescript_grpc_node_library(
  name = "test_ts_grpc_node",
  proto = ":test_proto",
)

# For grpc-node support with grpc-js use:
typescript_grpc_node_library(
  name = "test_ts_grpc_node_grpc_js",
  proto = ":test_proto",
  mode = "grpc-js",
)
```

See `//test:pizza_service_proto_test_suite` and `//test:grpc_node_test` for examples.

## IDE Code Completion

To get code completion working for the generated protos in your IDE, add the following to your
`tsconfig.json`:

```js
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      // Replace <workspace-name> with the name of your workspace
      "<workspace-name>/*": [
        "*", // Enables absolute paths for src files in your project
        "bazel-bin/*" // Enables referencing generate protos with absolute paths
      ]
    }
  }
}
```

> NOTE: This has only been tested in IntelliJ and VSCode with the bazel plugin
> NOTE: This assumes a default `--symlink_prefix` value.

## Contributing

Contributions are welcome!
