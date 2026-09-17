# Get the arguments from slurm ----
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  stop(
    "Usage: Rscript liftover.R <working_dir> <cohort> <phenotype>",
    call. = FALSE
  )
}

wd <- args[1]
cohort <- args[2]
pheno <- args[3]

setwd(wd)

# Set the PGS variable name ----
var_name <- paste0(pheno, "_pgs")

# Read the score files ----
files <- list.files("results/per_chromosome", pattern = "\\.sscore$", full.names = TRUE)
lst <- lapply(files, read.table, header = TRUE, comment.char = "", check.names = FALSE)
pgs <- Reduce(function(x, y) merge(x, y, by = "#IID"), lst)
pgs[,var_name] <- rowSums(pgs[, -1])

pgs <- pgs[,c("#IID", var_name)]
names(pgs)[names(pgs) == "#IID"] <- "id"

# Save the results ----
file_path <- paste0("results/", cohort, "_", var_name, ".txt")
write.table(pgs, file_path, quote = FALSE, row.names = FALSE, sep = "\t")
