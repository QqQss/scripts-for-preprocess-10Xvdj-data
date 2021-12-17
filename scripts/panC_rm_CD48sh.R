args = commandArgs(T)
if(length(args) != 2 ){
        write("\nUsage:",stdout())
        write("\tRscript  panC_rm_CD48sh.R  <panC.VDJ.format.addClone.annot_CD48.txt>  <Outpre>",stdout())
        write("\n",stdout())
        q(status=1)
}

suppressPackageStartupMessages({
library("plyr")
library("dplyr")
library("data.table")
})
options(stringsAsFactors=F)

out.ext.tb = read.table(args[1],header=T,stringsAsFactors=F,sep="\t")
out.ext.tb = as.data.table(out.ext.tb)
out.ext.tb = out.ext.tb[cloneID!="-" & (stype=="CD8" | stype=="CD4"),]


### update clone size
stat.clone.freq = out.ext.tb[,.N,by="cloneID"]
out.ext.tb$cloneSize = stat.clone.freq[match(out.ext.tb$cloneID,stat.clone.freq$cloneID),][["N"]]
out.ext.tb[,cloneID:=sprintf("%s:%d",gsub(":\\d+$","",cloneID),cloneSize)]
out.ext.tb = out.ext.tb[order(-cloneSize, cloneID),]

saveRDS(out.ext.tb,file=sprintf("%s.rds", args[2]))

#### filter CD4 & CD8 sharing
dist.stype = out.ext.tb[,table(cloneID,stype)]
f.stype.shared = rowSums(dist.stype[,1:2]>0)>1
f.stype.shared.order = order(-apply(dist.stype[f.stype.shared,],1,max))
stype.share.tb = dist.stype[f.stype.shared,][f.stype.shared.order,]

f.lowRatio = apply(stype.share.tb,1,function(x){ max(x)/min(x) < 5 })
toRm = stype.share.tb[f.lowRatio,]
toCh = stype.share.tb[!f.lowRatio,]
toCh.CD8 = toCh[ toCh[,"CD4"] > toCh[,"CD8"],]
toCh.CD4 = toCh[ toCh[,"CD8"] > toCh[,"CD4"],]

out.ext.flt.tb = out.ext.tb[!cloneID %in% rownames(toRm),]
out.ext.flt.tb = out.ext.flt.tb[!(cloneID %in% rownames(toCh.CD8) & stype=="CD8" ),]
out.ext.flt.tb = out.ext.flt.tb[!(cloneID %in% rownames(toCh.CD4) & stype=="CD4" ),]

### update clone size
stat.clone.freq.flt = out.ext.flt.tb[,.N,by="cloneID"]
out.ext.flt.tb$cloneSize = stat.clone.freq.flt[match(out.ext.flt.tb$cloneID,stat.clone.freq.flt$cloneID),][["N"]]
out.ext.flt.tb[,cloneID:=sprintf("%s:%d",gsub(":\\d+$","",cloneID),cloneSize)]
out.ext.flt.tb = out.ext.flt.tb[order(-cloneSize,cloneID),]

saveRDS(out.ext.flt.tb,file=sprintf("%s.flt.rds", args[2]))





