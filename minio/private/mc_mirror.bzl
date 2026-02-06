"Executable rule to mirror artifacts to an S3 bucket"

_DOC = """\
Executable rule to mirror files to an S3 bucket.

Intended for use with `bazel run`, and with Aspect's Continuous Delivery feature.
"""

_ATTRS = {
    "dir": attr.label(
        doc = "Directory to copy to the S3 bucket",
        mandatory = True,
        allow_single_file = True,
    ),
    "bucket": attr.string(
        doc = "S3 path to copy to",
    ),
    "bucket_file": attr.label(
        doc = "File containing a single line: the S3 path to copy to. Useful because the file content may be stamped.",
        allow_single_file = True,
    ),
    "alias": attr.string(
        doc = "Name of the Minio configuration alias to use",
        mandatory = True,
    ),
    "quiet": attr.bool(
        doc = "Quiet mc output",
        default = True,
    ),
    "overwrite": attr.bool(
        doc = "Overwrite object(s) on target if it differs from source",
    ),
    "remove": attr.bool(
        doc = "Remove extraneous object(s) on target",
    ),
    "skip_errors": attr.bool(
        doc = "Skip any errors when mirroring",
    ),
    "disable_multipart": attr.bool(
        doc = "Disable multipart upload feature",
    ),
    "retry": attr.bool(
        doc = "If specified, will enable retrying on a per object basis if errors occur",
    ),
    "checksum": attr.string(
        doc = "Add checksum to uploaded object. Values: CRC64NVME, CRC32, CRC32C, SHA1 or SHA256. Requires server trailing headers (AWS, MinIO)",
    ),
    "mc_flags": attr.string_list(
        doc = "Additional flags to pass to the `mc mirror` command",
        default = [],
    ),
    "mc": attr.label(
        doc = "Minio Client",
    ),
    "_script_template": attr.label(
        default = Label("//minio/private:mc_mirror.sh.tpl"),
        allow_single_file = True,
    ),
}

def _mc_mirror_impl(ctx):
    minio_toolchain = ctx.toolchains["//minio:toolchain_type"]

    if ctx.attr.mc:
        mc_tool_path = ctx.attr.mc[DefaultInfo].default_runfiles.files.to_list()[0].short_path
        mc_runfiles = ctx.attr.mc[DefaultInfo].default_runfiles
    else:
        mc_tool_path = minio_toolchain.minioinfo.mc.short_path
        mc_runfiles = minio_toolchain.default.default_runfiles

    executable = ctx.actions.declare_file("{}/mc_mirror.sh".format(ctx.label.name))
    runfiles = [executable] + ctx.files.dir

    flags = []

    if ctx.attr.quiet:
        flags.append("--quiet")

    if ctx.attr.overwrite:
        flags.append("--overwrite")

    if ctx.attr.remove:
        flags.append("--remove")

    if ctx.attr.skip_errors:
        flags.append("--skip-errors")

    if ctx.attr.disable_multipart:
        flags.append("--disable-multipart")

    if ctx.attr.retry:
        flags.append("--retry")

    if ctx.attr.checksum:
        flags.append("--checksum " + ctx.attr.checksum)

    for flag in ctx.attr.mc_flags:
        flags.append(flag)

    if int(bool(ctx.attr.bucket)) + int(bool(ctx.attr.bucket_file)) != 1:
        fail("Exactly one of 'bucket', 'bucket_file' must be set")

    if ctx.attr.bucket_file:
        runfiles.append(ctx.file.bucket_file)

    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = executable,
        is_executable = True,
        substitutions = {
            "{MC}": mc_tool_path,
            "{ALIAS}": ctx.attr.alias,
            "{DIR}": ctx.file.dir.short_path,
            "{BUCKET}": ctx.attr.bucket,
            "{BUCKET_FILE}": ctx.file.bucket_file.short_path if ctx.file.bucket_file else "",
            "{FLAGS}": " ".join(flags),
        },
    )

    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(files = runfiles).merge(mc_runfiles),
    )]

mc_mirror = rule(
    implementation = _mc_mirror_impl,
    executable = True,
    attrs = _ATTRS,
    doc = _DOC,
    toolchains = [
        "//minio:toolchain_type",
    ],
)
