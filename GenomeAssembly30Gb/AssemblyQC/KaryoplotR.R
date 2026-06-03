### This script was written using Claude (Sonnet 4.6) with additions by me #######

## This script plots contigs >1Mb and produces a karyotypeR-style plot showing sequencing depth across all large contigs in the assembly. 

# BiocManager::install("karyoploteR")
library(karyoploteR)

# ── Files ──────────────────────────────────────────────────────────────────────
genome_file   <- "genome_file.txt"  # 2-col TSV: seqname  length  (from samtools faidx | cut)
coverage_file <- "coverage.bed"     # 4-col BED: chrom  start  end  depth  (bamtocov)

# ── Genome ─────────────────────────────────────────────────────────────────────
genome <- read.table(genome_file, col.names = c("chr", "end"),
                     stringsAsFactors = FALSE)
genome$start <- 1L
genome <- genome[, c("chr", "start", "end")]  # karyoploteR requires chr/start/end order
genome_plot <- genome[genome$end >= 1e6, ]    # contigs >1 Mb for plotting only

# ── Coverage ───────────────────────────────────────────────────────────────────
# Strip NUL bytes then drop any lines split by a NUL (fewer than 4 fields)
raw   <- readBin(coverage_file, "raw", n = file.info(coverage_file)$size)
raw   <- raw[raw != as.raw(0x00)]
lines <- readLines(textConnection(rawToChar(raw)))
lines <- lines[lengths(strsplit(lines, "\t")) == 4L]
cov   <- read.table(textConnection(paste(lines, collapse = "\n")),
                    col.names  = c("chr", "start", "end", "depth"),
                    colClasses = c("character", "integer", "integer", "numeric"),
                    quote = "", comment.char = "")
cov <- cov[cov$chr %in% genome$chr & cov$end > cov$start, ]  # drop absent contigs and zero-length sentinel rows

# Bin into 100 kb windows for faster plotting (avg depth preserved)
bin_coverage <- function(cov, binsize = 100000) {
 cov$bin <- paste0(cov$chr, "_", floor((cov$start + cov$end) / 2 / binsize))
 agg <- aggregate(depth ~ chr + bin, data = cov, FUN = mean)
 agg$start <- as.integer(sub(".*_", "", agg$bin)) * binsize
  agg$end   <- agg$start + binsize
  agg[, c("chr", "start", "end", "depth")]}

cov_bin <- bin_coverage(cov, binsize = 10000)
cov_bin <- cov_bin[cov_bin$end <= genome$end[match(cov_bin$chr, genome$chr)], ]

# If I don't want to bin larger and just keep 10kb use this below
#cov_bin <- cov

# BED is 0-based half-open -> shift start to 1-based for GRanges
# ── Stats ──────────────────────────────────────────────────────────────────────
mean_cov <- mean(cov_bin$depth, na.rm = TRUE)
#ymax     <- quantile(cov_bin$depth, 0.999, na.rm = TRUE) * 1.05  # cap at 99th percentile of binned data
ymax <- 70 # i tried this but none is more than 66 so..
cat(sprintf("Mean: %.1fx   99th pct: %.1fx\n", mean_cov, ymax / 1.05))

# Winsorise depth to ymax so outliers plot as flat top rather than jagged spikes
cov_bin$depth <- pmin(cov_bin$depth, ymax)

cov_gr <- makeGRangesFromDataFrame(
  data.frame(seqnames = cov_bin$chr, start = cov_bin$start + 1L,
             end = cov_bin$end, depth = cov_bin$depth),
  keep.extra.columns = TRUE
)

# ── Plot ───────────────────────────────────────────────────────────────────────
pp <- getDefaultPlotParams(plot.type = 4)
pp$leftmargin <- 0.12; pp$topmargin <- 20; pp$bottommargin <- 20
pp$ideogramheight <- 8; pp$data1inmargin <- 8; pp$data1outmargin <- 0

pdf("coverage_karyoplot_large_contigs.pdf", width = 30, height = 20)

kp <- plotKaryotype(genome = genome_plot, plot.type = 1, plot.params = pp,
                    chromosomes = "all",
                    labels.plotter = NULL,
                    cex.main = 6,
                    main = "ONT coverage - 10 kb windows, 8 kb step")

kpAddChromosomeNames(kp, srt = 45, cex = 0.9)
mtext("Contig", side = 1, line = 3, cex = 1.6)
mtext("Coverage (x)", side = 2, line = 0.2, cex = 1.6)

# Grey background across full contig
kpRect(kp,
       chr    = genome_plot$chr,
       x0     = 1L, x1 = genome_plot$end,
       y0     = 0,  y1 = 1,
       col    = adjustcolor("grey60", alpha.f = 0.5),
       border = NA)

# Highlight low coverage regions (<10x) in white
low_cov <- cov_gr[cov_gr$depth < 10]
if (length(low_cov) > 0) {
  kpRect(kp,
         data   = low_cov,
         y0     = 0, y1 = 1,
         col    = "white",
         border = NA)
}

# Coverage bars
kpBars(kp, data = cov_gr, y1 = cov_gr$depth, ymin = 0, ymax = ymax,
       col = adjustcolor("steelblue", alpha.f = 0.6), border = NA)


kpAxis(kp, ymin = 0, ymax = ymax, numticks = 1, cex = 1.5, label.margin = 0.01)

# Mean line - vectorised over all contigs
kpSegments(kp,
           chr  = genome_plot$chr,
           x0   = 1L,          x1   = genome_plot$end,
           y0   = mean_cov,    y1   = mean_cov,
           ymin = 0,           ymax = ymax,
           col  = "firebrick", lwd  = 1.2, lty  = 2)

legend("topright",
       legend = c("Coverage", sprintf("Mean (%.1fx)", mean_cov), "Low coverage (<10x)"),
       col    = c(adjustcolor("steelblue", alpha.f = 0.6), "firebrick", "white"),
       lty    = c(1, 2, 1),
       lwd    = c(6, 1.5, 6),
       bty    = "n", cex = 0.8)

dev.off()
cat("Saved: coverage_karyoplot_large_contigs.pdf\n")
