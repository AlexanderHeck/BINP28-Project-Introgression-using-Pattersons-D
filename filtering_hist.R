#!/usr/bin/Rscript

# Reading input files
GQ <- read.delim("Data/GQ_ProjTaxa.txt")
mean_depth <- read.delim("Data/vcfdepth.ldepth.mean")
head(GQ)
head(mean_depth)

# Plotting a simple histogram with the obtained GQ scores
png(filename = "Output/GQ_hist.png")
hist(GQ$X0, main = "Quality per site", xlab = "Quality")
dev.off()
print("Quality plot created successfully...")

# Calculating the mean depth per site
print(paste("Mean depth per site:", mean(mean_depth$MEAN_DEPTH)))

# Plotting a simple histogram with the mean depth per site
png(filename = "Output/depth_hist.png")
hist(mean_depth$MEAN_DEPTH, xlim = c(0,50), breaks = 1000, main = "Mean depth per site", xlab = "Mean depth")
dev.off()
print("Mean depth plot successfully created...")
