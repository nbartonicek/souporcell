import pandas as pd 
import numpy as np 
import os

#this script imports information about the project name, run ID, directory of the bam file
#location of the axiom genotyping array as well as sample IDs 
#and starts souporcell analysis

df = pd.read_csv("samples.csv", dtype=str) 

for index,row in df.iterrows():
	projectname=row['projectname']
	run=row['run']
	runDir=row['runDir']
	genotype_array=row['genotype_array']
#find the number of samples despite the comma placement
	columnNames=df.columns.astype(str)
	unnamed=list(filter(lambda x:'Unnamed' in x,columnNames))
	nSamples=len(df.columns)-4-len(unnamed)
#add each sample per run to sample list 
	total=""
	for nCol in range(1,nSamples+1):
		columnName='S'+str(nCol)
		#check for empty
		if not pd.isna(row[columnName]):
			Si=str(row[columnName])
			if nCol == 1:
				total = Si
			else:
				total = total+","+Si
	print(total)
	os.system("bash 2.genotype_souporcell_annotate.sh "+projectname+" "+run+" "+runDir+" "+genotype_array+" "+total)
