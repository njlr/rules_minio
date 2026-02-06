"""This module implements the language-specific toolchain rule.
"""

MinioInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "mc": "mc executable",
    },
)

def _minio_toolchain_impl(ctx):
    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "MINIO_MC_BIN": ctx.executable.mc.path,
    })
    default = DefaultInfo(
        files = depset([ctx.executable.mc]),
        runfiles = ctx.runfiles(files = [ctx.executable.mc]),
    )
    minioinfo = MinioInfo(
        mc = ctx.executable.mc,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        minioinfo = minioinfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

minio_toolchain = rule(
    implementation = _minio_toolchain_impl,
    attrs = {
        "mc": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = """Defines a minio runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
