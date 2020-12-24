load("//src:typescript_proto_library.bzl", "typescript_proto_build")

def typescript_grpc_node_library(name, proto, mode = ""):
    typescript_proto_build(
        name = name,
        proto = proto,

        generate = "grpc-node",
        mode = mode,
    )
