library(biovizBase)
library(dplyr)
library(plotly)

# Prepare gene annotations ----------------------------------------------------
toptx <- data.table::fread("resources/EnsDb.Hsapiens.v75_toptx_chr1-22.txt",
                           select = c("tx_id")) # List of single transcripts per gene
edb <- ensembldb::addFilter(EnsDb.Hsapiens.v75::EnsDb.Hsapiens.v75,
                            AnnotationFilter::TxIdFilter(toptx$tx_id)) # Filter Ensembl hg19 v75 to include a single transcript per gene

# Auxiliary function ----------------------------------------------------------

# Manhattan plot
plot.locus <- function(DF) {
  plot_ly(data = DF, type = 'scatter', mode = 'markers', colors = "Set1") %>%
    add_trace(x = ~POS, y = ~LOGP, color = ~`Cis/Trans`,
              # Hover text:
              text = ~paste("CpG:", CpG, "<br>SNP:", `SNP`,
                            "<br>Beta:", `Beta`, "<br>SE:", `SE`, "<br>P:", `P`),
              alpha = 0.8, marker = list(size = 8)) %>%
    layout(xaxis = list(title = ""),
           yaxis = list(title = "−log<sub>10</sub>(<i>P</i>)"))
}

# Locus plot
plot.gene <- function(chr, pos1, pos2) {
  # Region to plot
  which <- GenomicRanges::GRanges(chr,
                                  IRanges::IRanges(pos1, pos2))
  
  # Arguments for plotting
  rect.h <- 0.25 # CDS rectangle height
  es <- (pos2-pos1)/1000 * 20 # Adding buffer between genes to avoid overlap
  columns <- c("tx_id", "gene_id", "gene_name", "tx_biotype") # Info to keep
  
  # Arguments of layout plot
  layout.args <- list(xaxis = list(title = paste("Chromosome", chr, "(Mb)")),
                      yaxis = list(title = "Genes",
                                   showticklabels = FALSE,
                                   showgrid = FALSE,
                                   ticks = "",
                                   autorange = "reversed",
                                   zeroline = FALSE))
  
  # Extract data from EnsDB object
  gr <- crunch(edb, which, columns = columns,
               truncate.gaps = FALSE, ratio = 0.0025) 
  if(S4Vectors::isEmpty(gr)){ # If no genes in region return empty plot
    layout.args$p <- plot_ly()
    p <- do.call(layout, layout.args)
    return(p)
  }
  
  # Interval partitioning
  gr <- addStepping(gr, group.name = "tx_id",
                    group.selfish = FALSE, extend.size = es)
  
  exonic <- gr[S4Vectors::values(gr)[["type"]] %in% c("utr", "cds", "exon")] # Exonic regions
  gaps <- getGaps(exonic, group.name = "tx_id") # Generate gaps between exonic regions
  
  df.exonic <- mold(exonic) # Convert GR to DF
  df.gaps <- mold(gaps) # Convert GR to DF
  
  # Prepare coordinates of exonic regions rectangles
  df.exonic <- df.exonic %>% 
    tibble::rownames_to_column(var = "group") %>%
    tidyr::pivot_longer(cols = start:end,
                        names_to = "region",
                        values_to = "x") %>%
    tidyr::uncount(2) %>%
    mutate(y = stepping + rect.h/2*rep(c(-1,1,1,-1), 
                                       times = length(stepping)/4))
  
  # Prepare coordinates of gaps
  df.gaps <- df.gaps %>% 
    tibble::rownames_to_column(var = "group") %>%
    tidyr::pivot_longer(cols = start:end,
                        names_to = "region",
                        values_to = "x") %>%
    rename(y = stepping.1)
  
  # Merge exonic and gaps
  df.seq <- bind_rows(df.exonic, df.gaps)
 
  # Plot genes
  layout.args$p <- df.seq %>%
    group_by(type, group) %>% # Plot in groups
    plot_ly(x = ~x, y = ~y, color = ~tx_biotype, # Coordinates of rectangles
            text = ~paste(paste0("<b><i>", gene_name, "</b></i>"),
                          "<br>Strand:", strand,
                          "<br>Gene ID:", gene_id,
                          "<br>Transcript ID:", tx_id),
            alpha = 1, colors = "viridis") %>% 
    add_polygons(line = list(width = 1), # Fill rectangles
                 hoveron = "points",
                 hoverinfo = "text") 
  
  # Return
  p <- do.call(layout, layout.args)
  return(p)
}

