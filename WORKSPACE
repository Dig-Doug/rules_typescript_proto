workspace(
    name = "rules_typescript_proto",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "2b2004784358655f334925e7eadc7ba80f701144363df949b3293e1ae7a2fb7b",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.4.0/rules_nodejs-5.4.0.tar.gz"],
)

http_archive(
    name = "rules_nodejs",
    sha256 = "33e309ba281fc73626a356a839bf5e5279360e7a2caea419c45c8017b5b3f7e2",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.7.0/rules_nodejs-core-5.7.0.tar.gz"],
)

load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "f2dcd210c7095febe54b804bb1cd3a58fe8435a909db2ec04e31542631cf715c",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.31.0/rules_go-v0.31.0.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.31.0/rules_go-v0.31.0.zip",
    ],
)

http_archive(
    name = "rules_proto",
    sha256 = "e017528fd1c91c5a33f15493e3a398181a9e821a804eb7ff5acdd1d2d6c2b18d",
    strip_prefix = "rules_proto-4.0.0-3.20.0",
    urls = [
        "https://github.com/bazelbuild/rules_proto/archive/refs/tags/4.0.0-3.20.0.tar.gz",
    ],
)

http_archive(
    name = "io_bazel_rules_webtesting",
    sha256 = "e9abb7658b6a129740c0b3ef6f5a2370864e102a5ba5ffca2cea565829ed825a",
    urls = [
        "https://github.com/bazelbuild/rules_webtesting/releases/download/0.3.5/rules_webtesting.tar.gz",
    ],
)

http_archive(
    name = "aspect_rules_ts",
    sha256 = "6ad28b5bac2bb5a74e737925fbc3f62ce1edabe5a48d61a9980c491ef4cedfb7",
    strip_prefix = "rules_ts-2.1.1",
    url = "https://github.com/aspect-build/rules_ts/releases/download/v2.1.1/rules_ts-v2.1.1.tar.gz",
)

http_archive(
    name = "aspect_rules_js",
    sha256 = "630a71aba66c4023a5b16ab3efafaeed8b1a2865ccd168a34611eb73876b3fc4",
    strip_prefix = "rules_js-1.37.1",
    url = "https://github.com/aspect-build/rules_js/releases/download/v1.37.1/rules_js-v1.37.1.tar.gz",
)

http_archive(
    name = "aspect_rules_jasmine",
    sha256 = "4c16ef202d1e53fd880e8ecc9e0796802201ea9c89fa32f52d5d633fff858cac",
    strip_prefix = "rules_jasmine-1.1.1",
    url = "https://github.com/aspect-build/rules_jasmine/releases/download/v1.1.1/rules_jasmine-v1.1.1.tar.gz",
)

http_archive(
    name = "aspect_rules_rollup",
    sha256 = "a0433a0b0206a45d362749d71bc1e4e0dacf5ca2a572b059328f9753392bca80",
    strip_prefix = "rules_rollup-1.0.0",
    url = "https://github.com/aspect-build/rules_rollup/releases/download/v1.0.0/rules_rollup-v1.0.0.tar.gz",
)

load("@aspect_rules_jasmine//jasmine:dependencies.bzl", "rules_jasmine_dependencies")
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")
load("@aspect_rules_rollup//rollup:dependencies.bzl", "rules_rollup_dependencies")
load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_dependencies")

rules_js_dependencies()

rules_ts_dependencies(
    ts_version_from = "//:package.json",
)

rules_jasmine_dependencies()

rules_rollup_dependencies()

load("@build_bazel_rules_nodejs//:index.bzl", "check_build_bazel_rules_nodejs_version", "node_repositories")

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.18")

# Test that check_build_bazel_rules_nodejs_version works as expected
check_build_bazel_rules_nodejs_version(minimum_version_string = "4.4.0")

node_repositories()

load("@aspect_rules_js//npm:repositories.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    data = [
        "@//:package.json",
    ],
    pnpm_lock = "//:pnpm-lock.yaml",
    yarn_lock = "//:yarn.lock",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

load("@io_bazel_rules_webtesting//web:repositories.bzl", "web_test_repositories")

web_test_repositories()

load("@io_bazel_rules_webtesting//web/versioned:browsers-0.3.3.bzl", "browser_repositories")

browser_repositories(chromium = True)

load("@rules_typescript_proto//:index.bzl", "rules_typescript_proto_dependencies")

rules_typescript_proto_dependencies()
