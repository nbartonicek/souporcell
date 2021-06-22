import pandas as pd 
import numpy as np 

import os

#this is a modification of the previous script that recognises the number of 
#samples and 
#import information about the project ID, samples, array 
df = pd.read_csv("neomet_02.csv") 

for index,row in df.iterrows():
	projectname=row['projectname']
	run=row['run']
	runDir=row['runDir']
	annotation=row['annotation']
	S1=str(int(row['S1']))
	S2=str(int(row['S2']))
	total=S1+","+S2
	if df.shape[1]>6:
		if not pd.isna(row['S3']):
			S3=str(int(row['S3']))
			total=total+","+S3
	if df.shape[1]>7:
		if not pd.isna(row['S4']):
			S4=str(int(row['S4']))
			total=total+","+S4
	if df.shape[1]>8:
		if not pd.isna(row['S5']):
			S5=str(int(row['S5']))
			total=total+","+S5
	if df.shape[1]>9:
		if not pd.isna(row['S6']):
			S6=str(int(row['S6']))
			total=total+","+S6
	print(total)
	os.system("bash genotype_souporcell_annotate_samplenum_neomet_02.sh "+projectname+" "+run+" "+runDir+" "+annotation+" "+total)
