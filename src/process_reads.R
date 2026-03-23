# Load required library
library(dplyr)

# Define function to compute WAS
compute_WAS <- function(df) {
  df %>%
    mutate(WAS = (2 * (AS + ms)) / (NM + (de * L) + 1) * log(MQ + 1))
}

# Get list of all TSV files
files <- list.files(pattern = "*.tsv")

# Identify haplotype pairs (hap1 & hap2)
hap1_files <- files[grepl("hap1.tsv$", files)]
hap2_files <- files[grepl("hap2.tsv$", files)]

# Process each sample
for (hap1_file in hap1_files) {
  hap2_file <- gsub("hap1.tsv$", "hap2.tsv", hap1_file)  # Find corresponding hap2 file

  if (!hap2_file %in% hap2_files) next  # Skip if no matching hap2 file

  # Extract sample name
  sample_name <- gsub(".hap1.tsv$", "", hap1_file)

  # Read data while skipping the first line
  hap1 <- read.table(hap1_file, header = FALSE, sep = "\t", comment.char = "#")
  hap2 <- read.table(hap2_file, header = FALSE, sep = "\t", comment.char = "#")

  # Assign proper column names
  colnames(hap1) <- colnames(hap2) <- c("Read.Name", "MQ", "AS", "ms", "NM", "de", "L")

  # Compute WAS
  hap1 <- compute_WAS(hap1)
  hap2 <- compute_WAS(hap2)

  # Merge by read name
  merged <- merge(hap1, hap2, by = "Read.Name", suffixes = c("_hap1", "_hap2"))

  # Compare WAS scores
  hap1_better <- merged$WAS_hap1 > merged$WAS_hap2
  hap2_better <- merged$WAS_hap2 > merged$WAS_hap1
  equal_was <- merged$WAS_hap1 == merged$WAS_hap2  # Ambiguous reads

  # Save reads mapping better to hap1
  write.table(merged$Read.Name[hap1_better | equal_was],
              paste0(sample_name, ".hap1.txt"), row.names = FALSE, col.names = FALSE, quote = FALSE)

  # Save reads mapping better to hap2
  write.table(merged$Read.Name[hap2_better | equal_was],
              paste0(sample_name, ".hap2.txt"), row.names = FALSE, col.names = FALSE, quote = FALSE)

  cat("Processed:", sample_name, "\n")
}

cat("All samples processed!\n")
