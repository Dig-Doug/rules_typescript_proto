load("//src:typescript_proto_library.bzl", "typescript_proto_build")

def typescript_grpc_web_library(name, proto):
    typescript_proto_build(
        name = name,
        proto = proto,

        generate = "grpc-web",
    )
