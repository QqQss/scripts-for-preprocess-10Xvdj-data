######################## 0. aggragate all CR-VDJ outputs
Rscript scripts/10x_vdj_aggr.R  lists/cellranger_vdj_out.list   data/panC.vdj.filtered_contig_annotations.txt.gz

######################## 1. VDJ tidy
perl  scripts/10x_vdj_format.pl   data/panC.vdj.filtered_contig_annotations.txt.gz   lists/lib2patient.txt   >data/panC.VDJ.format.txt

######################## 2. Find Pair Combination
perl  scripts/vdj2pair.pl   data/panC.VDJ.format.txt  >data/panC.VDJpair.txt

##### search public TCR
### same identifier 
cut -f 1,5 data/panC.VDJpair.txt  |sed 1d |sort -u  >data/tmp_pub_ide
awk1 data/tmp_pub_ide  |sort |uniq -c |awk '{print $1"\t"$2}' | sort -k1,1nr | awk '$1>1' 

### same cdr3pep
cut -f 2,5 data/panC.VDJpair.txt  |sed 1d |sort -u  >data/tmp_pub_cdr3
awk1 data/tmp_pub_cdr3 |sort |uniq -c |awk '{print $1"\t"$2}' | sort -k1,1nr | awk '$1>1' 


######################## 3. Define CloneType
###### strict version
perl scripts/pair2clone_strict.pl  data/panC.VDJpair.txt   >data/panC.VDJclone.txt
# add CloneType to vdj.format
perl scripts/vdj_add_clone.pl  data/panC.VDJ.format.txt  data/panC.VDJclone.txt >data/panC.VDJ.format.addClone.txt

######################## 4. Annotation and filteration (optional)
## keep CD4/CD8 cells only and add 'stype' annotation
perl  scripts/vdj_annot_info.pl   data/panC.VDJ.format.addClone.txt   lists/CD4CD8_info.txt  >data/panC.VDJ.format.addClone.annot_T_CD4CD8.txt
## filter out CD4/8 shared clones
Rscript scripts/panC_rm_CD48sh.R data/panC.VDJ.format.addClone.annot_T_CD4CD8.txt  data/panC.VDJ.format.addClone.annot_T_CD4CD8




