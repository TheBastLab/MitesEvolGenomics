#!/bin/bash

# This script processes each .bed file to:
# - Sort windows within each chromosome by size (descending)
# - Assign ranked window names like chr1_1, chr1_2, etc.

for i in *.bed; do
  b=$(echo "${i}" | sed 's/.bed//g')

  awk '
  {
    chr = $1
    size = $4
    key = chr "_" NR
    data[key] = $0
    sizes[key] = size
    chr_list[chr] = 1
    key_list[chr, count[chr]] = key
    count[chr]++
  }
  END {
    for (chr in chr_list) {
      # collect keys for sorting
      n = count[chr]
      for (i = 0; i < n; i++) {
        keys[i] = key_list[chr, i]
      }

      # simple bubble sort on sizes[key]
      for (i = 0; i < n - 1; i++) {
        for (j = i + 1; j < n; j++) {
          if (sizes[keys[i]] < sizes[keys[j]]) {
            tmp = keys[i]; keys[i] = keys[j]; keys[j] = tmp
          }
        }
      }

      # print sorted entries with new window names
      for (i = 0; i < n; i++) {
        key = keys[i]
        print data[key] "\t" chr "_" (i+1)
      }
    }
  }
  ' "${i}" > "${b}.forR.bed"

  echo "Processed ${i} -> ${b}.forR.bed"
done
