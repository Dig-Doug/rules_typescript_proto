# Migrating from ts-protoc-gen

Do the following:

- Update to `rules_node` version `0.38.3` or later
- Add `rules_proto` to your project as a dependency. See the getting started docs for more information.
- Replace `ts-proto-gen` in your `WORKSPACE` with the following:
```python
# Before:
http_archive(
    name = "ts_protoc_gen",
    sha256 = "355bd8e7a3d4889a3fb222366ac3427229acc968455670378f8ffe1b4bfc5a95",
    strip_prefix = "ts-protoc-gen-14d69f6203c291f15017a8c0abbb1d4b52b00b64",
    urls = ["https://github.com/improbable-eng/ts-protoc-gen/archive/14d69f6203c291f15017a8c0abbb1d4b52b00b64.zip"],
)

load("@ts_protoc_gen//:defs.bzl", "typescript_proto_dependencies")

typescript_proto_dependencies()

# After:
http_archive(
    name = "rules_typescript_proto",
    # TODO: Update these values to the latest version
    sha256 = "3ef93812b7c8589a5e7fbc7e9a8c1b2f9a982320f3e96443f8bcdd76b3ef6bc0",
    strip_prefix = "rules_typescript_proto-88de411e84ca05133f584633871f1f417a52095e",
    urls = [
        "https://github.com/Dig-Doug/rules_typescript_proto/archive/88de411e84ca05133f584633871f1f417a52095e.tar.gz",
    ],
)

load("@rules_typescript_proto//:index.bzl", "rules_typescript_proto_dependencies")

rules_typescript_proto_dependencies()
```
- Update all of your `BUILD` files to reference this project, e.g.
```python
# Before:
load("@ts_protoc_gen//:defs.bzl", "typescript_proto_library")

# After:
load("@rules_typescript_proto//:index.bzl", "typescript_proto_library")
```

