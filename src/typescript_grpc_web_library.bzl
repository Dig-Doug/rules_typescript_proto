load("//src:typescript_proto_build.bzl", "typescript_proto_build")

def typescript_grpc_web_library(name, proto, **kwargs):
    typescript_proto_build(
        name = name,
        proto = proto,

        generate = "grpc-web",
        **kwargs
    )
