#!/bin/bash

# script that calculate genotype profiles in oder to make a SFS plot out of it
# Errbii M 2024
# This script is inspired by Pop-Con: a tool to visualize genotype profiles on Site Frequency Spectrum from populational genomics data
# originally written by Yoann Anselmetti

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 N INPUT OUTPUT"
  exit 1
fi

# Assign command-line arguments to variables
N=$1
INPUT=$2
OUTPUT=$3

# Main command
paste <(bcftools query -f '[\t%GT]\n' "$INPUT" | cut -f2- | tr "|" "/" | sort | uniq -c | sort -nr | sed 's/^[ \t]*//' | tr " " "\t") \
      <(bcftools query -f '[\t%GT]\n' "$INPUT" | cut -f2- | tr "|" "/" | sort | uniq -c | sort -nr | sed 's/^[ \t]*//' | tr " " "\t" | cut -f2- | awk -F1 '{print NF-1}') \
      | sort -k$((N+2)),$((N+2)) -k1,1nr \
      | awk -v N="$N" '{printf "%s\t",$1; for(i=2;i<16;i++) printf "%s,",$i; printf "%s\t%s\n",$(N+1),$(N+2)}' \
      > "$OUTPUT".txt

