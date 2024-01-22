#!/bin/bash

# Check if an IP address is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <ip_address>"
    exit 1
fi

# Get the IP address from the command line argument
target_ip="$1"

# Define the output file
output_file="scan_results.txt"

# Run RustScan to find open ports
echo "Running RustScan..."
sudo docker run -it --rm --name rustscan rustscan/rustscan:latest --ulimit 10000 -- -a "$target_ip" | tee "$output_file"

# Extract open ports from RustScan results
open_ports=$(grep -oP '\d{1,5}/open' "$output_file" | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

# Check if open ports were found
if [ -z "$open_ports" ]; then
    echo "No open ports found. Exiting."
    exit 0
fi

# Run Nmap for more extensive scanning on open ports
echo "Running Nmap on open ports: $open_ports"
nmap -p "$open_ports" -sC -sV -oN "$output_file" "$target_ip"

echo "Scan completed. Results saved to $output_file."
