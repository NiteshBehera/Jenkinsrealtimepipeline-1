#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2022-06-27 11:07:18 +0100 (Mon, 27 Jun 2022)
#
#  https://github.com/HariSekhon/Jenkins
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

# https://github.com/HariSekhon/Jenkins/blob/master/vars/download.sh

# Downloads and replaces existing groovy files in the local directory with the latest function/pipeline files from HariSekhon/Jenkins if they exist upstream
#
# This allows one to maintain a local private copy of select functions, and get any updates periodically if wanted
#
# This is not as automated as running a direct fork which has 1 button sync and 1 button Pull Requests
# - you will need to git diff and commit yourself, and also correct any divergence by hand, but this was requested by one client for more control
#
# Usage:
#
#   cd to your repos library repo's vars/ directory, then run:
#
#       cd vars/
#
#       curl -f https://raw.githubusercontent.com/HariSekhon/Jenkins/master/vars/download.sh > download.sh && chmod +x download.sh
#
# Download or update any number of functions you want, given as their groovy filenames as you see in the HariSekhon/Jenkins repo::
#
#       ./download.sh argoDeploy.groovy
#
# Or run without any args to search for every *.groovy file in the local directory under vars/ and, if available in HariSekhon/Jenkins repo, overwrite it with the latest version from GitHub
#
#       ./download.sh

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$srcdir"

url="https://raw.githubusercontent.com/HariSekhon/Jenkins/master/vars"

tmp="$(mktemp)"

unalias mv &>/dev/null || :

filelist=("$@")
if [ $# -eq 0 ]; then
    filelist=(*.groovy)
fi

for filename in "${filelist[@]}"; do
    if curl -sf "$url/$filename" > "$tmp" ||
       curl -sf "$url/$filename.groovy" > "$tmp"; then
        {
            echo "// copied from $url/${filename%.groovy}.groovy"
            echo
            #sed 's|//.*|| ; /^[[:space:]]*$/d' "$tmp"
            cat "$tmp"
        } > "$filename"
        echo "Downloaded $filename"
    fi
done
