load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

def rules_typescript_proto_dependencies():
    """
    Installs rules_typescript_proto dependencies.

    Usage:

    # WORKSPACE
    load("@rules_typescript_proto//:index.bzl", "rules_typescript_proto_dependencies")
    rules_typescript_proto_dependencies()
    """

    yarn_install(
        name = "rules_typescript_proto_deps",
        package_json = "@rules_typescript_proto//src:package.json",
        # Don't use managed directories because these are internal to the library and the
        # dependencies shouldn't need to be installed by the user.
        symlink_node_modules = False,
        yarn_lock = "@rules_typescript_proto//src:yarn.lock",
    )
