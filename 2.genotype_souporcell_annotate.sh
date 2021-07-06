#!/bin/bash

module load centos6.10/gi/gcc/4.8.2
module load centos6.10/gi/picard-tools/1.138
module load centos6.10/gi/plink/prebuilt/1.07
module load centos6.10/gi/plink/prebuilt/1.90beta_3g
module load centos6.10/gi/novosort/precompiled/1.03.08
module load centos7.8/phuluu/vcftools/0.1.16
module load centos6.10/gi/bedtools/2.22.0

#raw files directory
homedir="/share/ScratchGeneral/nenbar"
projectDir="$homedir/projects/CITE"
scriptsPath=$projectDir"/scripts/souporcell_pipeline/github"
logDir=$scriptsPath"/logs"
mkdir -p $logDir

#load in the sample and array information
projectname=$1
run=$2
runDir=$3
annotation=$4
samples=$5

#this is the most common place for errors
bamDir=$runDir/$run/$run"/outs/count"
annotationDir=$projectDir/"genotyping/annotation"
sampleNames=`echo $samples | tr "," "_"`
sampleArray=($(echo "$samples" | tr ',' '\n'))
arrayDir=$projectDir"/raw_files/genotyping/$annotation/"
genotypeDir=$projectDir/"genotyping/$projectname/$run"
outDir=$projectDir"/project_results/souporcell/$projectname/$run"
step1Dir=$genotypeDir/step1
step2Dir=$genotypeDir/step2
finalVCF=$step2Dir"/"$sampleNames".b38.vcf"

############ CHECK FOR INPUTS
#make sure that the directory structure reflects the sample file
if [ ! -f "$bamDir/possorted_genome_bam.bam" ]; then echo "possorted_genome_bam.bam not found, check runDir column and bamDir variable, or file permissions";fi
if [ ! -f "$bamDir/filtered_feature_bc_matrix/barcodes.tsv.gz" ]; then echo "filtered_feature_bc_matrix/barcodes.tsv.gz not found in $bamDir directory, check runDir column and bamDir variable, or file permissions";fi

#check that the SNP annotation is available, if not, download the file
if [ ! -f "$annotationDir/common_variants_grch38.vcf" ]; then echo "downloading the annotation file";
	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=13aebUpEKrtjliyT9rYzRijtkNJVUk5F_' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=13aebUpEKrtjliyT9rYzRijtkNJVUk5F_" -O $annotationDir/common_variants_grch38.vcf && rm -rf /tmp/cookies.txt
fi

#to-do: check that Axiom chip annotation is in the right directory


#to-do: check that Axiom raw data is in the right directory



############ IMPORTANT: genotyping will not overwrite existing files/directories
#If rerunning it is important to either remove the already existing directories 
#or to tweak paramaters of each axiom analysis point
#for now it's the first option - quick and dirty

rm -rf $step1Dir
rm -rf $step2Dir

mkdir -p $annotationDir
mkdir -p $genotypeDir
mkdir -p $step1Dir
mkdir -p $step2Dir
mkdir -p $outDir


########### 1. genotyping 

##perform genotyping only if annotation available

if [[ $annotation != +(NA|NONE|na|none) ]]; then 

	(echo cel_files; ls -1 $arrayDir/*.CEL) > $step1Dir/"cel_list1.txt"

	############### remove the samples that have failed - with a DQC value less than the default DQC threshold of 0.82
	sampleFile=`ls $arrayDir | grep table_rpt.txt`
	more $arrayDir$sampleFile | grep "Fail" | cut -f1 | grep "CEL" >$step1Dir/"failed.txt"

	(echo cel_files; grep $step1Dir/"cel_list1.txt" -v -f $step1Dir/"failed.txt" | grep ${sampleArray[@]/#/-e }) >$step1Dir/"cel_list2.txt"
	#(echo cel_files; grep $step1Dir/"cel_list1.txt" -v -f $step1Dir/"failed.txt" | grep "_$sample1\|_$sample2") >$step1Dir/"cel_list2.txt"

	#the resulting samples should be here:
	cat $step1Dir/"cel_list2.txt"

	#For pipeline: add check that all the samples are indeed inside

	############### run apt-genotype-axiom

	if [[ $annotation == *"UKB"* ]]
	then
		genotypeLine="apt-genotype-axiom --log-file $step1Dir/"apt-genotype-axiom.log" --arg-file $annotationDir/"Axiom_UKB_WCSG.r5.apt-genotype-axiom.AxiomCN_GT1.apt2.xml" --analysis-files-path $annotationDir --out-dir $step1Dir --dual-channel-normalization true --cel-files $step1Dir/"cel_list2.txt" --summaries --write-models --batch-folder $step1Dir"
	elif [[ $annotation == *"PMDA"* ]]
	then 
		genotypeLine="apt-genotype-axiom --log-file $step1Dir/"apt-genotype-axiom.log" --arg-file $annotationDir/"Axiom_PMDA.r7.apt-genotype-axiom.AxiomCN_GT1.apt2.xml" --analysis-files-path $annotationDir --out-dir $step1Dir --dual-channel-normalization true --cel-files $step1Dir/"cel_list2.txt" --summaries --write-models --batch-folder $step1Dir"
	else
		echo "Annotation not found";
		break
	fi
	qsub -q all.q -b y -j y -N genotypeStep1$run -wd $logDir -pe smp 10 -V $genotypeLine

	############### run the command line version of SNPolisher

	psmetricsLine="ps-metrics --posterior-file $step1Dir/AxiomGT1.snp-posteriors.txt --call-file $step1Dir/AxiomGT1.calls.txt --metrics-file $step1Dir/SNPolisher/metrics.txt" 

	psclassLine="ps-classification --species-type human --metrics-file $step1Dir/SNPolisher/metrics.txt --output-dir $step1Dir/SNPolisher --ps2snp-file $annotationDir/Axiom_UKB_WCSG.r5.ps2snp_map.ps"

	otvLine="otv-caller --pid-file $step1Dir/SNPolisher/Recommended.ps --batch-folder $step1Dir --output-dir $step1Dir/OTV"

	qsub -q all.q -b y -j y -N genotypeStep2$run -hold_jid genotypeStep1$run -wd $logDir -pe smp 10 -V $psmetricsLine

	qsub -q all.q -b y -j y -N genotypeStep3$run -hold_jid genotypeStep2$run -wd $logDir -pe smp 10 -V $psclassLine

	qsub -q all.q -b y -j y -N genotypeStep4$run -hold_jid genotypeStep3$run -wd $logDir -pe smp 20 -V $otvLine

	#if this succeeded, there should be files in the OTV folder: $step1Dir/OTV
	#the SNPs that are to be kept are in file $step1Dir/OTV/OTV.keep.ps
	#wc -l $step1Dir/OTV/OTV.keep.ps


	############### create vcf and convert from hg19 to b38
	# fetch sqlite annotation from https://www.thermofisher.com/order/catalog/product/901153?SID=srch-srp-901153 
	# WARNING: it will throw an error if the file already exits
	prepareDirLine="cp -R $step1Dir/AxiomAnalysisSuiteData $step1Dir/OTV"
	qsub -q all.q -b y -j y -N genotypeStep5$run -hold_jid genotypeStep4$run -wd $logDir -pe smp 1 -V $prepareDirLine

	runPolisherLine="/share/ScratchGeneral/nenbar/local/lib/apt-2.10.2.2-x86_64-intel-linux/bin/apt-format-result --batch-folder $step1Dir/OTV --snp-list-file $step1Dir/OTV/OTV.keep.ps --annotation-file $annotationDir/Axiom_UKB_WCSG.na35.annot.db --export-vcf-file $step2Dir"/"$sampleNames".b37.vcf""
	qsub -q all.q -b y -j y -N genotypeStep6$run -hold_jid genotypeStep5$run -wd $logDir -pe smp 1 -V $runPolisherLine

	#java -jar /share/ClusterShare/software/contrib/gi/picard-tools/1.138/picard.jar CreateSequenceDictionary R=/share/ClusterShare/biodata/contrib/nenbar/genomes/human/hg38/hg38.fa O=/share/ClusterShare/biodata/contrib/nenbar/genomes/human/hg38/hg38.dict
	cleanVCFLine="more $step2Dir"/"$sampleNames".b37.vcf" | grep -v UNKNOWNPOSITION | awk 'NR>3' >$step2Dir"/"$sampleNames".b37.clean.vcf""
	qsub -q all.q -b y -j y -N genotypeStep7$run -hold_jid genotypeStep6$run -wd $logDir -pe smp 1 -V $cleanVCFLine

	#watch out this step needs a bit more memory
	liftoverLine="java -jar ~/local/bin/picard.jar LiftoverVcf I=$step2Dir"/"$sampleNames".b37.clean.vcf" O=$step2Dir"/"$sampleNames".hg38.vcf" CHAIN=$annotationDir"/b37ToHg38.over.chain" REJECT=$annotationDir"/rejected_variants.vcf" R=/share/ClusterShare/biodata/contrib/nenbar/genomes/human/hg38/hg38.fa"
	qsub -q all.q -b y -j y -N genotypeStep8$run -hold_jid genotypeStep7$run -wd $logDir -pe smp 5 -V $liftoverLine

	hg38toB38Line="more $step2Dir"/"$sampleNames".hg38.vcf" | sed s/chr// | awk 'NR>3' > $finalVCF"
	qsub -q all.q -b y -j y -N genotypeStep9$run -hold_jid genotypeStep8$run -wd $logDir -pe smp 1 -V $hg38toB38Line


	#if this succeeded, there should be file $step2Dir"/"$projectname".b38.vcf". that will be used for imputation and further analysis
	#wc -l $finalVCF;
fi

############# 2. souporcell 

#prepare barcodes for the analysis
gunzip -c $bamDir/filtered_feature_bc_matrix/barcodes.tsv.gz >$outDir/barcodes.tsv

#pass arguments to the souporcell script
#projectname
#run
#step2Dir
#outDir
#bamDir
#annotationDir
#number of samples

qsub -N souporcellStep1$run -q long.q -wd $logDir -pe smp 1 -P TumourProgression $scriptsPath/3.souporcell.sh $projectname $run $outDir $bamDir $annotationDir ${#sampleArray[@]}

########### 3. annotate 

#annotate the output with python script
#modify the outfile so that it has real info
if [[ $annotation != +(NA|NONE|na|none) ]]; then 

	annotateLine="python $scriptsPath/4.annotate.py $outDir $finalVCF"
	qsub -q all.q -b y -j y -N annotate2$run -hold_jid souporcellStep1$run -wd $logDir -pe smp 1 -V $annotateLine

fi
  


