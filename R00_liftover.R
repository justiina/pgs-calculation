# Install and load packages ----

required_packages <- c(
  "GenomicRanges",
  "rtracklayer"
)

# Install missing packages
missing_packages <- required_packages[
  !sapply(required_packages, requireNamespace, quietly = TRUE)
]

if (length(missing_packages) > 0) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  
  BiocManager::install(missing_packages, ask = FALSE, update = FALSE)
}

# Load packages
library(GenomicRanges)
library(rtracklayer)

# Get the arguments from slurm ----
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop(
    "Usage: Rscript liftover.R <working_dir> <weights_file>",
    call. = FALSE
  )
}

wd <- args[1]
weights_file <- args[2]

setwd(wd)

# Read the weights data ----
weights <- read.table(weights_file, header = T)

# Create genomic coordinates
gr <- GRanges(
  seqnames = paste0("chr", weights$chr_name),
  ranges = IRanges(
    start = weights$chr_position,
    end = weights$chr_position
  )
)

# Read in the chain file ----
chain <- import.chain("data/hg19ToHg38.over.chain")

# Run liftover ----
gr38 <- liftOver(gr, chain)

# Create hg38 weights file ----
# take unique variants
keep <- lengths(gr38) == 1
cat("Number of unique variants:", sum(keep), "\n")
cat("Number of duplicated variants (excluded):", sum(!keep),"\n")

# prepare the table
gr38_uniq <- unlist(gr38[keep])

weights38 <- weights[keep, ]
weights38$chr_name <- gsub("^chr", "", as.character(seqnames(gr38_uniq)))
weights38$chr_position <- start(gr38_uniq)

#check
cat("Dimensions of hg38 weights:", dim(weights38), "\n")
cat("First 6 rows:\n")
print(head(weights38))

# Save the lifted weights data ----
file_name <- file.path(
  dirname(weights_file),
  paste0("hg38_",basename(weights_file)))

gz_con <- gzfile(file_name, "w")

write.table(
  weights38,
  file = gz_con,
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

close(gz_con)
