#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

bucket={BUCKET}
bucket_file={BUCKET_FILE}

if [[ -z "$bucket" ]]; then
    if [[ -f "$bucket_file" ]]; then
        bucket=$(<"$bucket_file")
    else
        echo "Error: `bucket` is not set and `bucket_file` ($bucket_file) does not exist." >&2
        exit 1
    fi
fi

{MC} mirror {FLAGS} "$@" {DIR} {ALIAS}/$bucket
