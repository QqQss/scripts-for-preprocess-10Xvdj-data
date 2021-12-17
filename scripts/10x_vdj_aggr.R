### modified from zhenglt, 20190807
library(plyr)

args = commandArgs(T)
if(length(args) != 2 ){
	write("\nUsage:",stdout())
	write("\tRscript  10x_vdj_aggr.R   <vdj_file.list>   <Out.aggrated.txt>",stdout())
	write("\n",stdout())
	q(status=1)
}

in.table = read.table(args[1], header=T, stringsAsFactors=F, sep="\t")
#colnames(a.table) = c("library_id", "suffix", "file")

process.it = function(aid, aidx, afile)
{
    if(is.na(afile) || !file.exists(afile)){ return(NULL) }
    .i.table = read.csv(afile, header=T, stringsAsFactors=F, sep=",")
    
	m = regexec("^(.+?)-\\d", .i.table$barcode, perl=T)
    barcode.seq = regmatches(.i.table$barcode, m)
    .i.table$barcode = sprintf("%s-%s", sapply(barcode.seq,"[",2), aidx)   ### extract barcode sequences, and then reassign suffix.  eg: XXX-1 to XXX-aidx

    mm = regexec("^(.+?)-(\\d)_(.+)$", .i.table$contig_id, perl=T)
    contig.seq = regmatches(.i.table$contig_id, mm)
	.i.table$contig_id  = sprintf("%s-%s_%s", sapply(contig.seq,"[",2), aidx, sapply(contig.seq,"[",3))    ### extract barcode sequences, and then reassign suffix.  eg: XXX-1 to XXX-aidx
    
	.i.table$library.id = aid
    return(.i.table)
}

out.table = ldply(seq_len(nrow(in.table)), function(i){ process.it(in.table$library_id[i], in.table$suffix[i], in.table$file[i]) })
write.table(out.table, args[2], row.names=F, sep="\t", quote=F)


