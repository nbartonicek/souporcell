import numpy as np
import matplotlib.pyplot as plt
import vireoSNP
import pandas as pd 
import os
import re
import sys

#>>> inDir="/share/ScratchGeneral/nenbar/projects/CITE/scripts/souporcell/4513_4530_commonvariants_1x"
inDir="/share/ScratchGeneral/nenbar/projects/CITE/project_results/souporcell/TNBC/TNBC_003"
#>>> finalVcf="/share/ScratchGeneral/nenbar/projects/CITE/scripts/souporcell/4513_4530_Blood.b38.vcf"
finalVcf="/share/ScratchGeneral/nenbar/projects/CITE/genotyping/TNBC/TNBC_003/step2/4744_4419_3960.b38.vcf"
#read arguments to the script
inDir = sys.argv[1]
finalVcf = sys.argv[2]

GT_tag0 = 'GT' # common ones: GT, GP, PL
vcf_dat0 = vireoSNP.vcf.load_VCF(inDir+"/cluster_genotypes.vcf",
                                 biallelic_only=True, sparse=False, 
                                 format_list=[GT_tag0])

GPb0_var_ids = np.array(vcf_dat0['variants'])
GPb0_donor_ids = np.array(vcf_dat0['samples'])
GPb0_tensor = vireoSNP.vcf.parse_donor_GPb(vcf_dat0['GenoINFO'][GT_tag0], GT_tag0)

GT_tag1 = 'GT' # common ones: GT, GP, PL
vcf_dat1 = vireoSNP.vcf.load_VCF(finalVcf,
                                 biallelic_only=True, sparse=False, 
                                 format_list=[GT_tag1])
GPb1_var_ids = np.array(vcf_dat1['variants'])
GPb1_donor_ids = np.array(vcf_dat1['samples'])
GPb1_tensor = vireoSNP.vcf.parse_donor_GPb(vcf_dat1['GenoINFO'][GT_tag1], GT_tag1)
GPb1_tensor.shape


mm_idx = vireoSNP.base.match(GPb1_var_ids, GPb0_var_ids)
mm_idx = mm_idx.astype(float)
idx1 = np.where(mm_idx == mm_idx)[0] #remove None for unmatched
idx2 = mm_idx[idx1].astype(int)

GPb1_var_ids_use = GPb1_var_ids[idx1]
GPb0_var_ids_use = GPb0_var_ids[idx2]

GPb1_tensor_use = GPb1_tensor[idx1]
GPb0_tensor_use = GPb0_tensor[idx2]

idx0, idx1, GPb_diff = vireoSNP.base.optimal_match(GPb0_tensor_use, GPb1_tensor_use, 
                                                   axis=1, return_delta=True)

#modify naming of the samples
ids_trimmed = [re.sub(r'.CEL', '', id) for id in GPb1_donor_ids]
ids_trimmed = [re.sub(r'_Blood.*', '', id) for id in ids_trimmed]
ids_trimmed = [re.sub(r'_Tumou.*', '', id) for id in ids_trimmed]
ids_trimmed = [re.sub(r'_\d$', '', id) for id in ids_trimmed]
ids_trimmed = [re.sub(r'.*_', '', id) for id in ids_trimmed]
dictionary = dict(zip(GPb0_donor_ids, ids_trimmed))

#load in the cluster file
df = pd.read_table(inDir+"/clusters.tsv") 
dfNew = df.replace({"assignment": dictionary}) 

#write it out
print(inDir)
dfNew.to_csv(inDir+"/clusters_annotated.tsv",sep='\t',index=False,header=True)