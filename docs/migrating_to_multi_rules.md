# Migrating to multi_rules

Previously, the `typescript_proto_library` rule would also build grpc-web outputs automatically.

This is now split into multiple rules to align with other languages:
- `typescript_proto_library` for outputting protobuf messages files (_pb.d.ts, _pb.js)
- `typescript_grpc_node_library` for outputting protobuf service and client files (_grpc_pb.d.ts, _grpc_pb.js); supports both grpc and grpc-js requires
- `typescript_grpc_web_library` for outputting protobuf messages files (_pb_service.d.ts, _pb_service.js)

To keep the same behavior, add to your definition:
```python
# Before:
typescript_proto_library(
    name = "test_ts_proto",
    proto = ":test_proto",
)

# After:
typescript_proto_library(
    name = "test_ts_proto",
    proto = ":test_proto",
)
typescript_grpc_web_library(
    name = "test_ts_grpc_web",
    proto = ":test_proto",
)
```
