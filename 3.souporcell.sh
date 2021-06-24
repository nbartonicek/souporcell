#!/bin/bash
#$ -j y
#$ -N soup$2
#$ -l mem_requested=140G,tmp_requested=140G,tmpfree=140G
#$ -q all.q
#$ -P TumourProgression

cat /tmp/prolog_exec_"$JOB_ID"_"$SGE_TASK_ID".log

echo "JOB: $JOB_ID TASK: $SGE_TASK_ID"
echo "$HOSTNAME $tmp_requested $TMPDIR"

projectname=$1
run=$2
outDir=$3
bamDir=$4
annotationDir=$5
sampleNum=$6

#souporcell path
souporcell="/share/ScratchGeneral/nenbar/local/sing2/souporcell.sif"

#cp all the information
#into the local directory structure
singularity exec --bind $bamDir:/bamDir,$outDir:/outDir,$annotationDir:/annotationDir $souporcell souporcell_pipeline.py -b /outDir/barcodes.tsv --common_variants /annotationDir/common_variants_grch38.vcf -i /bamDir/possorted_genome_bam.bam -f /annotationDir/refdata-cellranger-GRCh38-3.0.0/fasta/genome.fa -t 16 -o /outDir -k $sampleNum 
