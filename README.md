# Souporcell and Axiom arrays demux

This site contains scripts for demultiplexing single-cell data with Souporcell, using genotyping information from Axiom arrays. 

Requirements:
1. Souporcell (requires Singularity > v.3.0)

`singularity pull shub://wheaton5/souporcell`

2. Tools for analysis of Axiom data

gcc >v.4.8.2
picard-tools >v1.138
plink/prebuilt >v1.07
plink/prebuilt >v1.90beta_3g
novosort >v1.03.08
vcftools >v0.1.16
bedtools >v2.22.0

3. Samplesheet with information on 
i Project name
ii Run
iii location of Cellranger Bam file (possorted.bam)
iv location of Axiom array data
v sample IDs
