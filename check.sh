#!/bin/bash

INPUT_FILE="links.txt"
OUTPUT_FILE="active_links.txt"
TIMEOUT=2

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: '$INPUT_FILE' not found!"
    exit 1
fi

# Clear or create the output file
> "$OUTPUT_FILE"

echo "Testing links for network activity..."

# Clean the inputs on the fly to test the base domains
while read -r line; do
    # Skip empty lines or comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Extract clean domain for curl testing
    domain=$(echo "$line" | awk '{
        gsub(/^https?:\/\//, "");
        gsub(/^www\./, "");
        split($0, a, "[\/:]");
        print a[1];
    }')

    echo -n "Checking $domain... "
    if curl -s --connect-timeout $TIMEOUT --head "https://$domain" > /dev/null 2>&1 || \
       curl -s --connect-timeout $TIMEOUT --head "http://$domain" > /dev/null 2>&1; then
        echo "ACTIVE"
        # Save the original line (or domain) to the active list
        echo "$line" >> "$OUTPUT_FILE"
    else
        echo "DOWN (Skipped)"
    fi
done < "$INPUT_FILE"

echo "Done! Active links saved to '$OUTPUT_FILE'."
