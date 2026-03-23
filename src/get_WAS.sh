#!/bin/bash

# Check input arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 INPUT.bam OUTPUT_TSV NUM_THREADS"
    exit 1
fi

# Assign input arguments
INPUT_BAM=$1
OUTPUT_TSV=$2
NUM_THREADS=$3

# Print header
echo -e "# Read Name\tMQ (Mapping Quality)\tAS (Alignment Score)\tms (Matching Bases)\tNM (Edit Distance)\tde (Per-base Divergence)\tL (Read Length)" > "$OUTPUT_TSV"

# Process BAM file in parallel
samtools view -@ "$NUM_THREADS" -F 256 -F 2048 "$INPUT_BAM" | awk '
BEGIN { OFS="\t"; }
{
    read_name = $1;
    MQ = $5;
    AS = match($0, /AS:i:([0-9]+)/, a) ? a[1] : 0;
    ms = match($0, /ms:i:([0-9]+)/, a) ? a[1] : 0;
    NM = match($0, /NM:i:([0-9]+)/, a) ? a[1] : 1;
    de = match($0, /de:f:([0-9.]+)/, a) ? a[1] : 0;
    L = length($10);

    print read_name, MQ, AS, ms, NM, de, L;
}' >> "$OUTPUT_TSV"

echo "Done! Output saved to $OUTPUT_TSV"

