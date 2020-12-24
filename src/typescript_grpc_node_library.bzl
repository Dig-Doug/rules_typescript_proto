load("//src:typescript_proto_build.bzl", "typescript_proto_build")

def typescript_grpc_node_library(name, proto, use_grpc_js = False):
    typescript_proto_build(
        name = name,
        proto = proto,

        generate = "grpc-node",
        grpc_node_mode = "grpc-js" if use_grpc_js else "",
    )
