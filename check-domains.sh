#!/bin/bash

# Check available .dk domains with 1, 2, or 3 characters (letters/numbers)

letters=({a..z} {0..9})
output_free="free_domains.txt"
output_taken="taken_domains.txt"

> "$output_free"
> "$output_taken"

check_domain() {
	domain="$1.dk"
	if whois "$domain" | grep -q "No entries found"; then
		echo "$domain" | tee -a "$output_free"
	else
		echo "$domain" | tee -a "$output_taken"
	fi
}

for a in "${letters[@]}"; do
	check_domain "$a"
done

for a in "${letters[@]}"; do
	for b in "${letters[@]}"; do
		check_domain "$a$b"
	done
done

for a in "${letters[@]}"; do
	for b in "${letters[@]}"; do
		for c in "${letters[@]}"; do
			check_domain "$a$b$c"
		done
	done
done

echo "Done. Free domains saved in $output_free, taken domains in $output_taken."