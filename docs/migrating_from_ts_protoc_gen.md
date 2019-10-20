# Migrating from ts-protoc-gen

Do the following:

- Update to `rules_node` version `0.38.3` or later
- Add `rules_proto` as a dependency. See the getting started docs for more information.
- Replace the `http_archive` for `ts-protoc-gen` with one for this project, e.g.
```python
# Before:
http_archive(
    name = "ts_protoc_gen",
    sha256 = "355bd8e7a3d4889a3fb222366ac3427229acc968455670378f8ffe1b4bfc5a95",
    strip_prefix = "ts-protoc-gen-14d69f6203c291f15017a8c0abbb1d4b52b00b64",
    urls = ["https://github.com/improbable-eng/ts-protoc-gen/archive/14d69f6203c291f15017a8c0abbb1d4b52b00b64.zip"],
)

# After:
http_archive(
    name = "rules_typescript_proto",
    # NOTE: Update these values to the latest version
    sha256 = "TODO",
    strip_prefix = "rules_typescript_proto-TODO",
    urls = ["https://github.com/Dig-Doug/rules_typescript_proto/archive/TODO.tar.gz"],
)
```
- Update all imports to reference this project, e.g.
```python
# Before:
load("@ts_protoc_gen//:defs.bzl", "typescript_proto_library")

# After:
load("@rules_typescript_proto//:index.bzl", "typescript_proto_library")
```

