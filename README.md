# Chromosomal signatures of introgression using Pattersons D #

All commands executed for this analysis except for program installations and setting up the environment can also be executed using the script pattersonsD_pipeline.sh. To run the whole analysis you need to have the input VCF ProjTaxa.vcf, the R script filtering_hist.R, and installed vcftools and Dsuite as below.

## Setting up the work environment ##
As a first step and to ensure reproducibility we set up our environment and folder structure.
```bash
conda create -n introgression_project python=3.12.3
conda activate introgression_project
mkdir Binp28_Project
cd Binp28_Project
mkdir Data
mkdir Output
```
In Binp28_Project, we save the scripts (pattersonsD_pipeline.sh and filtering_hist.R). In Data we save ProjTaxa.vcf.

If not done already we also make both scripts executable by:
```bash
chmod +x filtering_hist.R
chmod +x pattersonsD_pipeline.sh
```
After setup the file structure should look like this:
```bash
tree
.
├── Data
│   └── ProjTaxa.vcf
├── Output
├── filtering_hist.R
└── pattersonsD_pipeline.sh
```
## Pre processing the input vcf file using vcftools ##
Here we are using vcftools to filter out low quality SNPs before subsequent analysis.

### Installing vcftools ###
VCF tools was installed acording to their GitHub repository, accessible under: https://github.com/vcftools/vcftools
```bash
cd ~/bin
git clone https://github.com/vcftools/vcftools.git
cd vcftools
./autogen.sh
./configure
make
sudo make install
```

### Filtering out SNPs ###
The vcf file was filtered based off site quality and depth of coverage, by first gaining an overview over the data and then determining a suitable cutoff point that filters out the poorest quality data.
1. Quality:
   ```bash
   # first we extract only the GQ scores for all individuals  
   cat Data/ProjTaxa.vcf | grep -v '^#' | cut -f 10-25 | tr '\t' '\n' | cut -d ':' -f 4 | grep -v '\.'> Data/GQ_ProjTaxa.txt
   ```
   We use this file to plot a simple histogram in R:

   ```R
   # Plotting a simple histogram with the obtained GQ scores
   GQ <- read.delim("Data/GQ_ProjTaxa.txt")
   png(filename = "Output/GQ_hist.png")
   hist(GQ$X0, main = "Quality per site", xlab = "Quality")
   dev.off()
   ```
   Due to the distribution of data, a minQC of 20 is most apporpriate.

2. Depth of coverage:  
   ```bash
   # Then the depth of coverage per site accross individuals is extracted
   vcftools --vcf Data/ProjTaxa.vcf --site-mean-depth --out Data/vcfdepth
   ```
   Afterwards R is used to plot a simple histogram of that data.

   ```R
   # Plotting a simple histogram with the mean depth per site
   mean_depth <- read.delim("Data/vcfdepth.ldepth.mean")
   print(paste("Mean depth per site:", mean(mean_depth$MEAN_DEPTH)))
   png(filename = "Output/depth_hist.png")
   hist(mean_depth$MEAN_DEPTH, xlim = c(0,50), breaks = 1000, main = "Mean depth per site", xlab = "Mean depth")
   dev.off()
   ```
   Due to the distribution of data, a minimum depth of 5 and a maximum depth of 3x mean = 27 is most apporpriate.


Finally the filtering is done using vcftools and the vcf file is split according to choromosome:

```bash
vcftools --vcf Data/ProjTaxa.vcf --minGQ 20 --minDP 5 --maxDP 27  --chr chr5 --recode --out Data/chr5_filtered
vcftools --vcf Data/ProjTaxa.vcf --minGQ 20 --minDP 5 --maxDP 27  --chr chrZ --recode --out Data/chrZ_filtered
```


## Analysing introgression using Dsuite ##
To calculate Pattersons D-statistic, we used Dsuite, a commonly used bioinformatics tool for that exact purpose. Accessible on GitHub under https://github.com/millanek/Dsuite?tab=readme-ov-file

### Installing Dsuite ###
Dsuite was installed according to instructions on their GitHub page.
```bash
cd ~/bin
git clone https://github.com/millanek/Dsuite.git
cd Dsuite
make
```

### Running the analysis ###
To run Dsuite needs two file: the input vcf file and a population/species map called SETS.txt. Our SETS.txt file was created and looked as follows:
```bash
printf "\
8N05240\tSpecies1\n\
8N05890\tSpecies1\n\
8N06612\tSpecies1\n\
8N73248\tSpecies1\n\
8N73604\tSpecies1\n\
K006\tSpecies2\n\
K010\tSpecies2\n\
K011\tSpecies2\n\
K015\tSpecies2\n\
K019\tSpecies2\n\
Lesina_280\tSpecies3\n\
Lesina_281\tSpecies3\n\
Lesina_282\tSpecies3\n\
Lesina_285\tSpecies3\n\
Lesina_286\tSpecies3\n\
Naxos2\tOutgroup" > Data/SETS.txt
```

Next we tun the Dtrios program from Dsuite, once for each chromosome.
```bash
~/bin/Dsuite/Build/Dsuite Dtrios Data/chr5_filtered.recode.vcf Data/SETS.txt -o Output/chr5
~/bin/Dsuite/Build/Dsuite Dtrios Data/chrZ_filtered.recode.vcf Data/SETS.txt -o Output/chrZ
```