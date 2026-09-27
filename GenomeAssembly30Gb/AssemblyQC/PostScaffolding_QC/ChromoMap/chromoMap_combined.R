#!/usr/bin/env Rscript
# ChromoMap visualization of telomere positions - Combined haplotype plot
# Displays scaffolds interleaved: scaffold1_hap1, scaffold1_hap2, scaffold2_hap1, scaffold2_hap2...
# Uses ploidy=2 to show both haplotypes side by side per chromosome

# ============================================================
# Install required packages if not already installed
# ============================================================
if (!requireNamespace("chromoMap", quietly = TRUE)) {
  install.packages("chromoMap", repos = "https://cran.r-project.org")
}
if (!requireNamespace("htmlwidgets", quietly = TRUE)) {
  install.packages("htmlwidgets", repos = "https://cran.r-project.org")
}
if (!requireNamespace("webshot", quietly = TRUE)) {
  install.packages("webshot", repos = "https://cran.r-project.org")
  webshot::install_phantomjs()
}
library(chromoMap)
library(htmlwidgets)
library(webshot)

# ============================================================
# INPUT FILES
# ============================================================
chrom_file <- "~/Desktop/ChromMap/chrom_sizes_3ddna_v2_20260829.txt"
anno_file  <- "~/Desktop/ChromMap/telomere_annotation_3ddna_v2_20260829.txt"
output_dir <- "~/Desktop/ChromMap"

# ============================================================
# STEP 1 — Read chromosome sizes
# ============================================================
chroms <- read.table(chrom_file, header=FALSE, sep="\t",
                     col.names=c("name", "start", "end"))

# Split into hap1 and hap2
hap1_chroms <- chroms[grepl("_hap1", chroms$name), ]
hap2_chroms <- chroms[grepl("_hap2", chroms$name), ]

# Only keep chromosome-scale scaffolds (>9Mb)
hap1_chroms <- hap1_chroms[hap1_chroms$end > 9000000, ]
hap2_chroms <- hap2_chroms[hap2_chroms$end > 9000000, ]

# Extract scaffold number from name for sorting
# e.g. scaffold1_hap1 -> 1
#get_scaffold_num <- function(name) {
#  as.integer(gsub("scaffold(\\d+)_hap[12]", "\\1", name))
#}

# Sort both by scaffold number
#hap1_chroms$num <- get_scaffold_num(hap1_chroms$name)
#hap2_chroms$num <- get_scaffold_num(hap2_chroms$name)
#hap1_chroms <- hap1_chroms[order(hap1_chroms$num), ]
#hap2_chroms <- hap2_chroms[order(hap2_chroms$num), ]

get_chr_num <- function(name) {
  as.integer(gsub(".*?(\\d+)_hap[12]", "\\1", name))
}

hap1_chroms$num <- get_chr_num(hap1_chroms$name)
hap2_chroms$num <- get_chr_num(hap2_chroms$name)
hap1_chroms <- hap1_chroms[order(hap1_chroms$num), ]
hap2_chroms <- hap2_chroms[order(hap2_chroms$num), ]

# Keep only scaffolds that exist in both haplotypes
common_nums <- intersect(hap1_chroms$num, hap2_chroms$num)
hap1_chroms <- hap1_chroms[hap1_chroms$num %in% common_nums, ]
hap2_chroms <- hap2_chroms[hap2_chroms$num %in% common_nums, ]

# Remove helper column
hap1_chroms$num <- NULL
hap2_chroms$num <- NULL

cat(sprintf("Chromosome-scale scaffolds: %d hap1, %d hap2\n",
            nrow(hap1_chroms), nrow(hap2_chroms)))

# ============================================================
# STEP 2 — Read telomere annotations
# ============================================================
anno <- read.table(anno_file, header=TRUE, sep="\t")

# Split by haplotype and filter to chromosome-scale only
anno_hap1 <- anno[anno$chrom %in% hap1_chroms$name, ]
anno_hap2 <- anno[anno$chrom %in% hap2_chroms$name, ]

cat(sprintf("Telomere annotations: %d hap1, %d hap2\n",
            nrow(anno_hap1), nrow(anno_hap2)))

# ============================================================
# STEP 3 — Write temporary files
# chromoMap ploidy=2 requires two separate chrom files
# and two separate annotation files
# ============================================================
hap1_chrom_file <- file.path(output_dir, "hap1_chroms_tmp.txt")
hap2_chrom_file <- file.path(output_dir, "hap2_chroms_tmp.txt")
hap1_anno_file  <- file.path(output_dir, "hap1_anno_tmp.txt")
hap2_anno_file  <- file.path(output_dir, "hap2_anno_tmp.txt")

write.table(hap1_chroms, hap1_chrom_file, sep="\t", quote=FALSE,
            row.names=FALSE, col.names=FALSE)
write.table(hap2_chroms, hap2_chrom_file, sep="\t", quote=FALSE,
            row.names=FALSE, col.names=FALSE)
write.table(anno_hap1[, c("name","chrom","start","end","type")],
            hap1_anno_file, sep="\t", quote=FALSE,
            row.names=FALSE, col.names=FALSE)
write.table(anno_hap2[, c("name","chrom","start","end","type")],
            hap2_anno_file, sep="\t", quote=FALSE,
            row.names=FALSE, col.names=FALSE)

# ============================================================
# STEP 4 — Generate combined chromoMap plot using ploidy=2
# ploidy=2 displays both haplotypes side by side for each
# chromosome — hap1 on left, hap2 on right
# ============================================================
cat("Generating combined haplotype telomere plot...\n")

p <- chromoMap(
  ch.files  = c(hap1_chrom_file, hap2_chrom_file),
  data.files = c(hap1_anno_file, hap2_anno_file),
  ploidy = 2,
  canvas_width = 1400,
  canvas_height = 1400,
  chr_color = c('#EAD9F5', '#C8F0D8'),
  chr_length = 5,
  chr_width = 12,
  ch_gap = 4,
  left_margin = 200,
  data_based_color_map = TRUE,
  data_type = "categorical",
  data_colors = list(
    c("#E74C3C", "#E74C3C"),
    c("#E74C3C", "#E74C3C")
  ),
  legend = TRUE,
  lg_x = 20,
  lg_y = 20,
  title = "Telomere Positions- post edits"
)

# Display in RStudio viewer
print(p)

# Save as HTML
html_file <- file.path(output_dir, "ChromMap_post_edits.html")
saveWidget(p, html_file, selfcontained=TRUE)
cat(sprintf("HTML saved to: %s\n", html_file))

# Convert HTML to high resolution PNG (zoom=2 doubles resolution)
png_file <- file.path(output_dir, "combined_telomeres.3ddna.png")
webshot(html_file,
        png_file,
        vwidth = 1200,
        vheight = 1200,
        zoom = 2)
cat(sprintf("PNG saved to: %s\n", png_file))

# Clean up temp files
file.remove(hap1_chrom_file, hap2_chrom_file,
            hap1_anno_file, hap2_anno_file)

cat("\nDone! Output files:\n")
cat(sprintf("  %s/combined_telomeres.html -- interactive plot\n", output_dir))
cat(sprintf("  %s/combined_telomeres.png  -- high resolution PNG (2400x1800px)\n", output_dir))
