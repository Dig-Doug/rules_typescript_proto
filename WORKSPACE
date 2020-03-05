workspace(
    name = "rules_typescript_proto",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_proto",
    sha256 = "4d421d51f9ecfe9bf96ab23b55c6f2b809cbaf0eea24952683e397decfbd0dd0",
    strip_prefix = "rules_proto-f6b8d89b90a7956f6782a4a3609b2f0eee3ce965",
    urls = [
        "https://github.com/bazelbuild/rules_proto/archive/f6b8d89b90a7956f6782a4a3609b2f0eee3ce965.tar.gz",
    ],
)

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "b6670f9f43faa66e3009488bbd909bc7bc46a5a9661a33f6bc578068d1837f37",
    urls = [
        "https://github.com/bazelbuild/rules_nodejs/releases/download/1.3.0/rules_nodejs-1.3.0.tar.gz",
    ],
)

http_archive(
    name = "io_bazel_rules_closure",
    sha256 = "fecda06179906857ac79af6500124bf03fe1630fd1b3d4dcf6c65346b9c0725d",
    strip_prefix = "rules_closure-03110588392d8c6c05b99c08a6f1c2121604ca27",
    urls = [
        "https://github.com/bazelbuild/rules_closure/archive/03110588392d8c6c05b99c08a6f1c2121604ca27.zip",
    ],
)

load("@io_bazel_rules_closure//closure:defs.bzl", "closure_repositories")

closure_repositories()

http_archive(
    name = "com_github_grpc_grpc_web",
    sha256 = "04460e28ffa80bfc797a8758da10ba40107347ef0af8e9cc065ade10398da4bb",
    strip_prefix = "grpc-web-1.0.7",
    urls = [
        "https://github.com/grpc/grpc-web/archive/1.0.7.tar.gz",
    ],
)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

yarn_install(
    name = "npm",
    package_json = "//:package.json",
    yarn_lock = "//:yarn.lock",
)

load("@npm//:install_bazel_dependencies.bzl", "install_bazel_dependencies")

install_bazel_dependencies()

load("@npm_bazel_karma//:package.bzl", "npm_bazel_karma_dependencies")

npm_bazel_karma_dependencies()

load("@io_bazel_rules_webtesting//web:repositories.bzl", "web_test_repositories")

web_test_repositories()

load("@io_bazel_rules_webtesting//web/versioned:browsers-0.3.2.bzl", "browser_repositories")

browser_repositories(chromium = True)

load("@npm_bazel_typescript//:index.bzl", "ts_setup_workspace")

ts_setup_workspace()

load("@rules_typescript_proto//:index.bzl", "rules_typescript_proto_dependencies")

rules_typescript_proto_dependencies()
