#!/bin/bash

# Configuration
INPUT_FILE="active_links.txt"
OUTPUT_FILE="hosts"
GITHUB_USER="ikaldiaz"
REPO_NAME="customblocklist"
BRANCH_NAME="main"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: '$INPUT_FILE' not found! Run ./check-links.sh first."
    exit 1
fi

echo "Generating blocklist from active links..."

# Extract unique domains from the active list
TEMPORARY_DOMAINS=$(awk '{
    gsub(/^https?:\/\//, "");
    gsub(/^www\./, "");
    split($0, a, "[\/:]");
    print a[1];
}' "$INPUT_FILE" | grep -v '^$' | sort -u)

DOMAIN_COUNT=$(echo "$TEMPORARY_DOMAINS" | wc -l)
CURRENT_DATE=$(date -u +"%d %b %Y %H:%M:%S (UTC) (generated)")

# Write the header
cat << EOF > "$OUTPUT_FILE"
# Title: Custom Ikal BlockList
#
# This hosts file is a merged collection of hosts from reputable sources,
# with a dash of crowd sourcing via GitHub
#
# Date: $CURRENT_DATE
# Number of unique domains: $(printf "%'d" $DOMAIN_COUNT)
#
# Fetch the latest version of this file: https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/$BRANCH_NAME/hosts
# Project home page: https://github.com/$GITHUB_USER/$REPO_NAME

EOF

# Append the domains
echo "$TEMPORARY_DOMAINS" | awk '{print "0.0.0.0 " $1}' >> "$OUTPUT_FILE"

echo "Done! Blocklist updated with $DOMAIN_COUNT active domains."

git add .
git commit -m "Update blocklist domains"
git push
