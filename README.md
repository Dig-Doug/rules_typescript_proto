# rules_typescript_proto
![](https://github.com/Dig-Doug/rules_typescript_proto/workflows/ci/badge.svg)

Bazel rules for generating TypeScript declarations for JavaScript protocol buffers using the 
[ts-protoc-gen](https://github.com/improbable-eng/ts-protoc-gen) protoc plugin. These rules can also
generate service definitions for use by [grpc-web](https://github.com/improbable-eng/grpc-web).

## Getting Started

> If you're migrating from the ts-protoc-gen rules, see [here](docs/migrating_from_ts_protoc_gen.md) for a migration guide

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
    sha256 = "1bb09f1c90d34153bf2ff06addf8ace0d02ab6ed14aa1978dc491d22f2a31b42",
    strip_prefix = "rules_typescript_proto-0.0.1",
    urls = [
	"https://github.com/Dig-Doug/rules_typescript_proto/archive/0.0.1.tar.gz",
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

See `//test:pizza_service_proto_test_suite` for an example.

## IDE Code Completion

To get code completion working for the generated protos in your IDE, add the following to your
`tsconfig.json`:

```json
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

> NOTE: This has only been tested in IntelliJ with the bazel plugin

## Contributing

Contributions are welcome!
