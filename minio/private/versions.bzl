"""Mirror of release info

TODO: generate this file from GitHub API"""

# https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2025-08-13T08-35-41Z

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "RELEASE.2025-08-13T08-35-41Z": {
        "x86_64-apple-darwin": "sha384-GHqlUhQn57CuAySBJy5xEaSoT+bb3t9f2V0PuSBIz34KNdUP/A/2YbyV8MJ5xd3m",
        "aarch64-apple-darwin": "sha384-rR4NfoOlKCJHLuecjvOeS9HAvx86+/dKqaZalhFt4VPSey9K9m67gOanguaLEmAW",
        "x86_64-pc-windows-msvc": "sha384-w5C+YnRZAw1I7TRbz1lbAO3cWqDEf9S4Q5yWdr9+ELE7q5fTakCKiR+G34xSeJy1",
        "x86_64-unknown-linux-gnu": "sha384-C7ARy1e2mFkEa4E+N2w0LOyYFz3z9pwF/IuPHMY3VOxh13U/bkNoCJBx9HqFXM0T",
    },
}
