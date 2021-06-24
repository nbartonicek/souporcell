# Souporcell and Axiom arrays demux

This site contains scripts for demultiplexing single-cell data with Souporcell, using genotyping information from Axiom arrays. 

Requirements:
## 1. Souporcell (requires Singularity > v.3.0)

`singularity pull shub://wheaton5/souporcell`

## 2. Affymetrix Analysis Power Tools (APT)
- Thermofisher/Affymetrix tool suite for analysis of axiom data
- available from Swarbrick lab dropbox
- update from ThermoFisher web site (difficult to find, must have an account)

download from https://www.dropbox.com/home/SwarbrickLab%20Team%20Folder/Single%20Cell%20Projects/demultiplexing/APT_2.10.2.2_Linux_64_bitx86_binaries.zip

`unzip APT_2.10.2.2_Linux_64_bitx86_binaries.zip`

`cp apt-2.10.2.2-x86_64-intel-linux/bin/* ~/local/bin`

## 3. Axiom annotation files

Currently two available:

-download the annotation.tar.gz with all required files from Swarbrick lab dropbox into your project directory, genotyping folder

-alternatively, download UKB_WCSG and PMDA.r7 annotation, available from Thermofisher pages

download https://www.dropbox.com/home/SwarbrickLab%20Team%20Folder/Single%20Cell%20Projects/demultiplexing/annotation.tar.gz

`cd genotyping`

`tar -xvf annotation.tar.gz`

## 4. raw Axiom genotyping data

-collection of CEL files and annotations, requires CEL files with sample names in them, table_rpt.txt

-place into your project directory under raw_data/genotype/"annotation" where "annotation" is the 4th column in your samplesheet

## 5. Tools for analysis of Axiom data 
-available as modules on the Garvan cluster, no need to install:

gcc >v.4.8.2

picard-tools >v1.138

plink/prebuilt >v1.07

plink/prebuilt >v1.90beta_3g

vcftools >v0.1.16

bedtools >v2.22.0

## 6. Samplesheet in csv format with information on: 
#### i project_name 
-preferably something related to biology or person
#### ii run
#### iii runDir: location of directory with all the runs from sequencing
-must contain downstream Cellranger Bam file (possorted.bam) and folder with filtered_feature_bc_matrix/barcodes.tsv.gz in the following manner

-runDir/run/run/outs/count/possorted_genome_bam.bam

-runDir/run/run/outs/count/filtered_feature_bc_matrix/barcodes.tsv.gz

#### iv Name of Axiom array data (enter NONE or NA if no genotyping information)

-expected to be in your project directory, folder raw_files/genotyping

#### v Sample IDs (as many as you have per run, below is an example for 3)

| projectname | run | runDir | annotation | S1 | S2 | S3 |
| ----------- | --- | ------ | ---------- | -- | -- | -- |
| Eva_PCa_01  | PCa1 | /directflow/GWCCGPipeline/projects/bioinformatics/R_200416_EVAAPO_INT_10X/200626_A00152_0271_BHFHVNDSXY/GE | HAR8323_UKB_2020_RESULTS | 20384 | 19616 | 20216 |

Please keep the headers as in the table above, with sample columns as S1..Sn where n is the number of samples

#### examples of sample files for multiple runs: samples.csv and runs without genotyping: samples_no_genotype.csv

## 4. Starter scripts:
#### 1.start_pipeline.py that reads the csv file with runs and starts for each:
#### 2.genotype_souporcell_annotate.sh that for each run starts jobs for genotyping analysis, souporcell demux, and annotation of demuxed samples based on genotype
#### 3.souporcell.sh that sets parameters for souporcell analysis (memory, directory structure)
#### 4.annotate.py that annotates the souporcell results in clusters.tsv into clusters_annotated.tsv, based on information in cluster_genotypes.vcf and sample information in the file ending with b38.vcf from the genotyping analysis.
