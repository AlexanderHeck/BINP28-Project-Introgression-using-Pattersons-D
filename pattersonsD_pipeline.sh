#!/bin/bash

# First we extract only the GQ scores for all individuals
cat Data/ProjTaxa.vcf | grep -v '^#' | cut -f 10-25 | tr '\t' '\n' | cut -d ':' -f 4 | grep -v '\.'> Data/GQ_ProjTaxa.txt
echo "GQ successfully extracted..."

# Then the depth of coverage per site accross individuals is extracted
vcftools --vcf Data/ProjTaxa.vcf --site-mean-depth --out Data/vcfdepth
echo "Mean coverage successfully extracted..."

# Then we execute the R script filtering_hist.R to plot the depth and GQ
Rscript filtering_hist.R

# Now vcftools is used to do the filtering and create two new files one for each chromosome
vcftools --vcf Data/ProjTaxa.vcf --minGQ 20 --minDP 5 --maxDP 27  --chr chr5 --recode --out Data/chr5_filtered
echo "Chr5 filtered..."
vcftools --vcf Data/ProjTaxa.vcf --minGQ 20 --minDP 5 --maxDP 27  --chr chrZ --recode --out Data/chrZ_filtered
echo "ChrZ filtered..."


# Dsuite needs a SETS.txt file containing the 3 species and the outgroup, created in the following
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
echo "SETS.txt created..."

# Finally Dsuite is run for each chromosome creating a directory for each
echo "Starting Dsuite..."
~/bin/Dsuite/Build/Dsuite Dtrios Data/chr5_filtered.recode.vcf Data/SETS.txt -o Output/chr5
~/bin/Dsuite/Build/Dsuite Dtrios Data/chrZ_filtered.recode.vcf Data/SETS.txt -o Output/chrZ
