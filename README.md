# Souporcell and Axiom arrays demux

This site contains scripts for demultiplexing single-cell data with Souporcell, using genotyping information from Axiom arrays. 

Requirements:
## 1. Souporcell (requires Singularity > v.3.0)

`singularity pull shub://wheaton5/souporcell`

## 2. Affymetrix Analysis Power Tools (APT)
- Thermofisher/Affymetrix tool suite for analysis of axiom data
- available from dropbox
- update from ThermoFisher web site (difficult to find, must have an account)

`wget https://www.dropbox.com/home/SwarbrickLab%20Team%20Folder/Single%20Cell%20Projects/demultiplexing/APT_2.10.2.2_Linux_64_bitx86_binaries.zip`

`unzip APT_2.10.2.2_Linux_64_bitx86_binaries.zip`

`cp apt-2.10.2.2-x86_64-intel-linux/bin/* ~/local/bin`

## 3. appropriate Axiom annotation files




## 4. Tools for analysis of Axiom data 
-available as modules on the Garvan cluster, no need to install

#### -gcc >v.4.8.2
#### -picard-tools >v1.138
#### -plink/prebuilt >v1.07
#### -plink/prebuilt >v1.90beta_3g
#### -vcftools >v0.1.16
#### -bedtools >v2.22.0

## 5. appropriate Axiom annotation files




## 3. Samplesheet in csv format with information on: 
#### i Project name
#### ii Run
#### iii Location of Cellranger Bam file (possorted.bam)
#### iv Location of Axiom array data
#### v Sample IDs (as many as you have per run, below is an example for 3)

| projectname | run | runDir | annotation | S1 | S2 | S3 |
| ----------- | --- | ------ | ---------- | -- | -- | -- |
| neomet_01  | Neomet_Pool1 | /share/ScratchGeneral/niaden/NeoMet_Nov2020/Pool1 | HAR8323_UKB_2020_RESULTS | 4583 | 4613 | 4622 |

Please keep the headers as in the table above, with sample columns as S1..Sn where n is the number of samples

## 4. Starter scripts:
#### 1.start_pipeline.py that reads the csv file with runs and starts for each:
#### 2.genotype_souporcell_annotate.sh that for each run starts jobs for genotyping analysis, souporcell demux, and annotation of demuxed samples based on genotype
#### 3.souporcell.sh that sets parameters for souporcell analysis (memory, directory structure)
#### 4.annotate.py that annotates the souporcell results in clusters.tsv into clusters_annotated.tsv, based on information in cluster_genotypes.vcf and sample information in the file ending with b38.vcf from the genotyping analysis.
