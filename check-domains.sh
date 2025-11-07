#!/bin/bash

######################################
# CONFIGURATION
######################################
DOMAIN_ENDING=".ai"       # Domain extension (e.g., .dk, .com, .net, .ai)
SLEEP_TIME=1              # Seconds to wait between WHOIS lookups
MIN_LENGTH=1              # Minimum domain length
MAX_LENGTH=2              # Maximum domain length
######################################

letters=({a..z} {0..9})
output_free="free_domains_${MIN_LENGTH}-${MAX_LENGTH}char.txt"
output_taken="taken_domains_${MIN_LENGTH}-${MAX_LENGTH}char.txt"

> "$output_free"
> "$output_taken"

check_domain() {
	domain="$1$DOMAIN_ENDING"

	# Check DNS first (A and MX)
	if dig +short "$domain" A | grep -q . || dig +short "$domain" MX | grep -q .; then
		echo "[TAKEN - DNS] $domain"
		echo "$domain" >> "$output_taken"
		return
	fi

	# If no DNS, fallback to WHOIS
	result=$(whois "$domain" 2>/dev/null)

	if echo "$result" | grep -qiE "No entries found for the selected source|No entries|No match|Domain not found|No match for domain|No match for"; then
		echo "[FREE]  $domain"
		echo "$domain" >> "$output_free"
	else
		echo "[TAKEN - WHOIS] $domain"
		echo "$domain" >> "$output_taken"
	fi

	if [ "$used_whois" = true ]; then
		sleep "$SLEEP_TIME"
	fi
}

generate_domains() {
	for ((len=MIN_LENGTH; len<=MAX_LENGTH; len++)); do
		echo "Checking $len-character domains..."
		generate_combinations "" $len
	done
}

generate_combinations() {
	local prefix=$1
	local remaining=$2

	if (( remaining == 0 )); then
		check_domain "$prefix"
		return
	fi

	for ch in "${letters[@]}"; do
		generate_combinations "$prefix$ch" $((remaining - 1))
	done
}

generate_domains

echo "Done. Free domains saved in $output_free, taken domains in $output_taken."
