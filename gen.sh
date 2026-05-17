#!/bin/bash

# Configuration
INPUT_FILE="links.txt"
OUTPUT_FILE="hosts"
GITHUB_USER="ikaldiaz"
REPO_NAME="customblocklist"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

echo "Processing domains..."

# 1. Clean and extract unique domains
# - Removes 'http://', 'https://', 'www.', and trailing paths/slashes
# - Removes empty lines and lines starting with '#'
# - Sorts and filters for unique domains
TEMPORARY_DOMAINS=$(awk '{
    # Remove protocol
    gsub(/^https?:\/\//, "");
    # Remove www. prefix if present (optional, standard for dns blocklists)
    gsub(/^www\./, "");
    # Remove paths, queries, or ports (everything after the first / or :)
    split($0, a, "[\/:]");
    print a[1];
}' "$INPUT_FILE" | grep -v '^$' | grep -v '^#' | sort -u)

# Count unique domains
DOMAIN_COUNT=$(echo "$TEMPORARY_DOMAINS" | wc -l)
# Format the current date exactly like your example
CURRENT_DATE=$(date -u +"%d %b %Y %H:%M:%S (UTC) (generated)")

echo "Found $DOMAIN_COUNT unique domains. Generating header..."

# 2. Write the header to the output file
cat << EOF > "$OUTPUT_FILE"
# Title: Custom Ikal BlockList
#
# This hosts file is a merged collection of hosts from reputable sources,
# with a dash of crowd sourcing via GitHub
#
# Date: $CURRENT_DATE
# Number of unique domains: $(printf "%'d" $DOMAIN_COUNT)
#
# Fetch the latest version of this file: https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/master/hosts
# Project home page: https://github.com/$GITHUB_USER/$REPO_NAME

EOF

# 3. Append the domains prefixed with 0.0.0.0
echo "$TEMPORARY_DOMAINS" | awk '{print "0.0.0.0 " $1}' >> "$OUTPUT_FILE"

echo "Done! Blocklist saved to '$OUTPUT_FILE'."
