library(data.table)

# Load data
DT <- ensembldb::transcripts(EnsDb.Hsapiens.v75::EnsDb.Hsapiens.v75)
DT <- as.data.table(DT)

# Save index
DT[,index:=1:nrow(DT)]

# Protein-coding genes
DT[,protein_coding:=tx_biotype=="protein_coding"]

# Order data
setorder(DT, gene_id, -protein_coding, -width, index)

# Filter autosomes
DT <- DT[seqnames %in% 1:22]

# Select a unique transcript by gene
DT_filter <- DT[DT[, .I[1], gene_id]$V1]
setorder(DT_filter,index)

# Save
fwrite(DT_filter[,.(tx_id,gene_id,index)], file = "resources/EnsDb.Hsapiens.v75_toptx_chr1-22.txt", quote = F, sep = "\t")
