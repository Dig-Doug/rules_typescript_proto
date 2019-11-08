load("//src:typescript_proto_library.bzl", _typescript_proto_library = "typescript_proto_library")

def typescript_grpc_node_library(name, proto):
    _typescript_proto_library(
        name = name,
        proto = proto,
        generate = "grpc-node",
    )
