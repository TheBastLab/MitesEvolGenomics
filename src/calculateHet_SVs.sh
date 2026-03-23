#!/bin/bash

# Check if a VCF file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input.vcf.gz>"
    exit 1
fi

VCF=$1

# Check if bcftools is installed
if ! command -v bcftools &> /dev/null; then
    echo "Error: bcftools not found. Please install it first."
    exit 1
fi

# Extract sample names
SAMPLES=$(bcftools query -l "$VCF")

# Print header
echo -e "Sample\tHeterozygous\tHomozygous\tHeterozygosity_Rate"

# Process VCF file and count genotypes per individual
bcftools query -f '[\t%GT]\n' "$VCF" | awk -v samples="$SAMPLES" '
BEGIN {
    split(samples, sample_names, "\n")
}
{
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^\.$/) continue  # Skip missing genotypes
        gsub("\\|", "/", $i)  # Convert phased "|" to unphased "/"

        # Count homozygous sites (0/0 or 1/1)
        if ($i == "0/0" || $i == "1/1") {
            homozygous[i]++
        }
        # Count heterozygous sites (0/1 or 1/0)
        else if ($i == "0/1" || $i == "1/0") {
            heterozygous[i]++
        }
    }
}
END {
    for (i = 1; i <= length(sample_names); i++) {
        het = heterozygous[i] + 0  # Ensure undefined values default to 0
        hom = homozygous[i] + 0
        total = het + hom
        rate = (total > 0) ? het / total : "NA"
        print sample_names[i] "\t" het "\t" hom "\t" rate
    }
}'

