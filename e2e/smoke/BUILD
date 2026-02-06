"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
# load("@rules_minio//minio:defs.bzl", "...")

genrule(
    name = "version",
    srcs = [],
    outs = ["version.txt"],
    cmd = "$(MINIO_MC_BIN) --version > $@",
    toolchains = ["@rules_minio//minio:resolved_toolchain"],
)

build_test(
    name = "smoke_test",
    targets = [
        # targets you add above
        ":version",
    ],
)
