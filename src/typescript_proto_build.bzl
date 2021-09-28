"""
This file primarily exposes the typescript_proto_build rule which supports:
- TypeScript generation of protobuf messages from a proto file
- TypeScript generation of services and clients using grpc-web
- TypeScript generation of services and clients using grpc-node with references to grpc
- TypeScript generation of services and clients using grpc-node with references to grpc-js

This rule should not be used directly. Use one of these instead:
- typescript_proto_library
- typescript_grpc_node_library
- typescript_grpc_web_library
"""

load("@build_bazel_rules_nodejs//:providers.bzl", "DeclarationInfo", "JSEcmaScriptModuleInfo", "JSNamedModuleInfo")
load("@rules_proto//proto:defs.bzl", "ProtoInfo")

TypescriptProtoLibraryAspect = provider(
    "establishes transitive dependencies for typescript on protobuf files",
    fields = {
        "es5_outputs": "The ES5 JS files produced directly from the src protos",
        "es6_outputs": "The ES6 JS files produced directly from the src protos",
        "dts_outputs": "Ths TS definition files produced directly from the src protos",
        "deps_es5": "The transitive ES5 JS dependencies",
        "deps_es6": "The transitive ES6 JS dependencies",
        "deps_dts": "The transitive dependencies' TS definitions",
    },
)

def _proto_path(proto):
    """
    Normalizes the path to an actual proto file path.
    """

    # The proto path is not really a file path.
    # It's the path to the proto that was seen when the descriptor file was generated.
    path = proto.path
    root = proto.root.path
    ws = proto.owner.workspace_root
    if path.startswith(root):
        path = path[len(root):]
    if path.startswith("/"):
        path = path[1:]
    if path.startswith(ws) and 0 < len(ws):
        path = path[len(ws):]
    if path.startswith("/"):
        path = path[1:]
    if path.startswith("_virtual_imports/"):
        path = path.split("/")[2:]
        path = "/".join(path)
    return path

def _get_protoc_inputs(target, ctx):
    inputs = []
    inputs += target[ProtoInfo].direct_sources
    inputs += target[ProtoInfo].transitive_descriptor_sets.to_list()
    return inputs

def _get_input_proto_names(target):
    """
    Builds a string containing all of the input proto file names separated by spaces.
    """
    proto_inputs = []
    for src in target[ProtoInfo].direct_sources:
        if src.extension != "proto":
            fail("Input must be a proto file")
        normalized_file = _proto_path(src)
        proto_inputs.append(normalized_file)
    return " ".join(proto_inputs)

def _build_protoc_command(target, ctx):
    """
    Returns the protoc command that includes all of the proper flags based on the attributes passed.
    """
    ts_flags = []
    grpc_flag = ""

    if ctx.attr.generate != "base":
        ts_flags.append("service=" + ctx.attr.generate)

    if ctx.attr.grpc_node_mode == "grpc-js":
        ts_flags.append("mode=grpc-js")
        grpc_flag = "grpc_js:"

    protoc_command = "%s" % (ctx.executable._protoc.path)

    protoc_command += " --plugin=protoc-gen-ts=%s" % (ctx.executable._ts_protoc_gen.path)

    if ctx.attr.generate == "grpc-node":
        protoc_command += " --plugin=protoc-gen-grpc=%s" % (ctx.executable._grpc_protoc_gen.path)

    protoc_output_dir = ctx.bin_dir.path + "/" + ctx.label.workspace_root
    protoc_command += " --ts_out=%s%s%s" % (",".join(ts_flags), ":" if bool(ts_flags) else "", protoc_output_dir)
    protoc_command += " --js_out=import_style=commonjs,binary:%s" % (protoc_output_dir)

    if ctx.attr.generate == "grpc-node":
        protoc_command += " --grpc_out=%s%s" % (grpc_flag, protoc_output_dir)

    descriptor_sets_paths = [desc.path for desc in target[ProtoInfo].transitive_descriptor_sets.to_list()]
    protoc_command += " --descriptor_set_in=%s" % (":".join(descriptor_sets_paths))

    protoc_command += " %s" % (_get_input_proto_names(target))

    return protoc_command

def _create_post_process_command(target, ctx, js_outputs, js_outputs_es6):
    """
    Builds a post-processing command that:
      - Updates the existing protoc output files to be UMD modules
      - Creates a new es6 file from the original protoc output
    """
    convert_commands = []
    for [output, output_es6] in zip(js_outputs, js_outputs_es6):
        file_path = "/".join([p for p in [
            ctx.workspace_name,
            ctx.label.package,
        ] if p])
        file_name = output.basename[:-len(output.extension) - 1]

        convert_command = ctx.executable._change_import_style.path
        convert_command += " --workspace_name {}".format(ctx.workspace_name)
        convert_command += " --input_base_path {}".format(file_path)
        convert_command += " --output_module_name {}".format(file_name)
        convert_command += " --input_file_path {}".format(output.path)
        convert_command += " --output_umd_path {}".format(output.path)
        convert_command += " --output_es6_path {}".format(output_es6.path)
        convert_commands.append(convert_command)

    return " && ".join(convert_commands)

def _get_path_relative_to_build(ctx, src):
    """
    Gets the path of a file relative to where the build file is. This is required to handle cases where there are
    directories without BUILD files inside of them. E.g.

    dir/
      BUILD.bazel
      api1/
        api1.proto
    """
    num_dirs = ctx.build_file_path.count("/")
    index_of_dir = 0
    num_dirs_seen = 0
    last_dir_index = 0
    for i in range(0, len(src.short_path)):
        if src.short_path[i] == "/":
            num_dirs_seen += 1
            last_dir_index = i
            if num_dirs_seen == num_dirs:
                index_of_dir = i
    return src.short_path[index_of_dir + 1:last_dir_index + 1]

def _get_outputs(target, ctx):
    """
    Calculates all of the files that will be generated by the aspect.
    """
    js_outputs = []
    js_outputs_es6 = []
    dts_outputs = []

    js_file_suffixes = []
    mjs_file_suffixes = []
    ts_file_suffixes = []

    if ctx.attr.generate == "base":
        js_file_suffixes.append("_pb.js")
        mjs_file_suffixes.append("_pb.mjs")
        ts_file_suffixes.append("_pb.d.ts")
    if ctx.attr.generate == "grpc-node":
        js_file_suffixes.append("_grpc_pb.js")
        mjs_file_suffixes.append("_grpc_pb.mjs")
        ts_file_suffixes.append("_grpc_pb.d.ts")
    if ctx.attr.generate == "grpc-web":
        js_file_suffixes.append("_pb_service.js")
        mjs_file_suffixes.append("_pb_service.mjs")
        ts_file_suffixes.append("_pb_service.d.ts")

    for src in target[ProtoInfo].direct_sources:
        relative_path = _get_path_relative_to_build(ctx, src)

        # workspace_root is empty for our local workspace, or external/other_workspace
        # for @other_workspace//
        if ctx.label.workspace_root == "":
            file_name = src.basename[:-len(src.extension) - 1]
        else:
            relative_path = ""
            file_name = _proto_path(src)[:-len(src.extension) - 1]

        for f in js_file_suffixes:
            output = ctx.actions.declare_file(relative_path + file_name + f)
            js_outputs.append(output)

        for f in mjs_file_suffixes:
            output_es6 = ctx.actions.declare_file(relative_path + file_name + f)
            js_outputs_es6.append(output_es6)

        for f in ts_file_suffixes:
            output = ctx.actions.declare_file(relative_path + file_name + f)
            dts_outputs.append(output)

    return [js_outputs, js_outputs_es6, dts_outputs]

def typescript_proto_library_aspect_(target, ctx):
    """
    A bazel aspect that is applied on every proto_library rule on the transitive set of dependencies
    of a typescript_proto_library rule.

    Handles running protoc to produce the generated JS and TS files.
    """
    if ctx.attr.grpc_node_mode == "grpc-js" and ctx.attr.generate != "grpc-node":
        fail("Mode must only be used with grpc-node rule")

    [js_outputs, js_outputs_es6, dts_outputs] = _get_outputs(target, ctx)
    protoc_outputs = dts_outputs + js_outputs + js_outputs_es6

    all_commands = [
        _build_protoc_command(target, ctx),
        _create_post_process_command(target, ctx, js_outputs, js_outputs_es6),
    ]

    tools = []
    tools.extend(ctx.files._protoc)
    tools.extend(ctx.files._ts_protoc_gen)
    tools.extend(ctx.files._grpc_protoc_gen)
    tools.extend(ctx.files._change_import_style)

    mode = (" " + ctx.attr.grpc_node_mode) if bool(ctx.attr.grpc_node_mode) else ""

    ctx.actions.run_shell(
        inputs = depset(_get_protoc_inputs(target, ctx)),
        outputs = protoc_outputs,
        progress_message = "Creating Typescript pb %s%s files %s" % (ctx.attr.generate, mode, ctx.label),
        command = " && ".join(all_commands),
        tools = depset(tools),
    )

    dts_outputs = depset(dts_outputs)
    es5_outputs = depset(js_outputs)
    es6_outputs = depset(js_outputs_es6)
    deps_dts = []
    deps_es5 = []
    deps_es6 = []

    for dep in ctx.rule.attr.deps:
        aspect_data = dep[TypescriptProtoLibraryAspect]
        deps_dts.append(aspect_data.dts_outputs)
        deps_dts.append(aspect_data.deps_dts)
        deps_es5.append(aspect_data.es5_outputs)
        deps_es5.append(aspect_data.deps_es5)
        deps_es6.append(aspect_data.es6_outputs)
        deps_es6.append(aspect_data.deps_es6)

    return [TypescriptProtoLibraryAspect(
        dts_outputs = dts_outputs,
        es5_outputs = es5_outputs,
        es6_outputs = es6_outputs,
        deps_dts = depset(transitive = deps_dts),
        deps_es5 = depset(transitive = deps_es5),
        deps_es6 = depset(transitive = deps_es6),
    )]

typescript_proto_library_aspect = aspect(
    implementation = typescript_proto_library_aspect_,
    attr_aspects = ["deps"],
    attrs = {
        # See matching rule docs for typescript_proto_library for brief documentation
        "generate": attr.string(
            mandatory = False,
            default = "base",
            values = [
                "base",
                "grpc-node",
                "grpc-web",
            ],
        ),
        "grpc_node_mode": attr.string(
            mandatory = False,
            default = "",
            values = [
                "",
                "grpc-js",
            ],
        ),
        "_ts_protoc_gen": attr.label(
            allow_files = True,
            executable = True,
            cfg = "host",
            default = Label("@rules_typescript_proto_deps//ts-protoc-gen/bin:protoc-gen-ts"),
        ),
        "_grpc_protoc_gen": attr.label(
            allow_files = True,
            executable = True,
            cfg = "host",
            default = Label("@rules_typescript_proto_deps//grpc-tools/bin:grpc_tools_node_protoc_plugin"),
        ),
        "_protoc": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "host",
            default = Label("@com_google_protobuf//:protoc"),
        ),
        "_change_import_style": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//src:change_import_style"),
        ),
    },
)

def _typescript_proto_library_impl(ctx):
    """
    Handles converting the aspect output into a provider compatible with the rules_typescript rules.
    """
    aspect_data = ctx.attr.proto[TypescriptProtoLibraryAspect]
    dts_outputs = aspect_data.dts_outputs
    transitive_declarations = depset(transitive = [dts_outputs, aspect_data.deps_dts])
    es5_outputs = aspect_data.es5_outputs
    es6_outputs = aspect_data.es6_outputs
    outputs = depset(transitive = [es5_outputs, es6_outputs, dts_outputs])

    es5_srcs = depset(transitive = [es5_outputs, aspect_data.deps_es5])
    es6_srcs = depset(transitive = [es6_outputs, aspect_data.deps_es6])
    return struct(
        typescript = struct(
            declarations = dts_outputs,
            transitive_declarations = transitive_declarations,
            es5_sources = es5_srcs,
            es6_sources = es6_srcs,
            transitive_es5_sources = es5_srcs,
            transitive_es6_sources = es6_srcs,
        ),
        providers = [
            DefaultInfo(files = outputs),
            DeclarationInfo(
                declarations = dts_outputs,
                transitive_declarations = transitive_declarations,
                type_blocklisted_declarations = depset([]),
            ),
            JSNamedModuleInfo(
                direct_sources = es5_srcs,
                sources = es5_srcs,
            ),
            JSEcmaScriptModuleInfo(
                direct_sources = es6_srcs,
                sources = es6_srcs,
            ),
        ],
    )

typescript_proto_build = rule(
    attrs = {
        "proto": attr.label(
            doc = "the protobuf file that should be processed",
            mandatory = True,
            allow_single_file = True,
            providers = [ProtoInfo],
            aspects = [typescript_proto_library_aspect],
        ),
        "generate": attr.string(
            doc = "which format to output, with 'base' being the protobuf messages",
            mandatory = False,
            default = "base",
            values = [
                "base",
                "grpc-node",
                "grpc-web",
            ],
        ),
        "grpc_node_mode": attr.string(
            doc = "when using grpc-node, either the grpc library can be referenced (default) or grpc-js",
            mandatory = False,
            default = "",
            values = [
                "",
                "grpc-js",
            ],
        ),
        "_ts_protoc_gen": attr.label(
            allow_files = True,
            executable = True,
            cfg = "host",
            default = Label("@rules_typescript_proto_deps//ts-protoc-gen/bin:protoc-gen-ts"),
        ),
        "_grpc_protoc_gen": attr.label(
            allow_files = True,
            executable = True,
            cfg = "host",
            default = Label("@rules_typescript_proto_deps//grpc-tools/bin:grpc_tools_node_protoc_plugin"),
        ),
        "_protoc": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "host",
            default = Label("@com_google_protobuf//:protoc"),
        ),
    },
    implementation = _typescript_proto_library_impl,
)
