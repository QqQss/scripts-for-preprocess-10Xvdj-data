# scripts-for-preprocess-10Xvdj-data

**Scripts for preprocess 10X VDJ data**

**Details see 'Method' section in our published paper:**

For 10x data, Cell Ranger (version 3.0, 10x Genomics Inc) was applied to assemble the single TCR chains. Further, to minimize the noise, the preliminarily assembled TCR chains were processed using the following pipeline: 1) Only those assembled chains that were highly confident, of full-length, productive, and with a valid cell barcode and an unambiguous chain type (alpha/beta/gamma/delta) assignment were qualified and kept. 2) If a cell had at least one pair of qualified alpha and beta chains, this cell was annotated as an alpha/beta T cell. If a cell had at least one pair of qualified gamma and delta chains, this cell was annotated as a gamma/delta T cell. If a cell had both qualified alpha/beta pair(s) and gamma/delta pair(s), this cell was annotated using the TCR pair with the highest UMI counts. 3) If a cell had more than one qualified chain of the same chain type, only the two chains with the highest UMI counts were kept, and the one with the higher UMI count was determined as the dominant chain. 4) For each patient, cells with identical dominant alpha/beta chains (or gamma/delta chains) were considered to originate from the same clonal expansion, therefore they were assigned the same clonotype ID. 

In a few cases, CD4+ and CD8+ T cells shared the same clonotype. To reduce noise and confusion, for each clonotype with both CD4+ T cells and CD8+ T cells, we calculated the cell number ratio between CD4+ T cells and CD8+ T cells, then we removed cells using the following criteria: 1) if the ratio > 5, the CD8+ T cells were removed; 2) if the ratio < 0.2, the CD4+ T cells were removed; 3) otherwise, both CD4+ T cells and CD8+ T cells were removed.


**Citation:**
Pan-cancer single-cell landscape of tumor-infiltrating T cells
Science, 374 (6574), abe6474. DOI: 10.1126/science.abe6474
