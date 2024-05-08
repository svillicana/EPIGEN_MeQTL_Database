library(shiny)
source("resources/aux_rescources.R")

# Read tables -----------------------------------------------------------------

# Associations
top_assoc <- data.table::fread("resources/top_assoc.txt")
clump_top_assoc <- data.table::fread("resources/ld_clump_assoc.txt")

# Main  -----------------------------------------------------------------------
function(input, output) {
  
  # Helpers ---------------------------------------------------------------------
  
  observe_helpers(withMathJax = TRUE)
  
  # Reactive table ------------------------------------------------------------
  
  # Selection of data set and filters
  datasetBase <- reactive({
    df <- switch(input$dataset,
                 "Top meQTLs" = top_assoc,
                 "Clumped meQTLs" = clump_top_assoc)
    # Filter for type of association
    if(!is.null(input$type_assoc)) {
      df <- df %>%
        filter(`Cis/Trans` %in% input$type_assoc)
    }
    # Filter by chromosome
    if(!is.null(input$chr_cpg)) {
      df <- df %>%
        filter(`CpG chr` %in% input$chr_cpg)
    }
    return(df)
  })
  
  # Select columns
  datasetInput <- reactive({
    datasetBase() %>%
      select(any_of(c("CpG", "Top SNP", input$show_vars)))
  })
  
  # Render table
  output$table <- DT::renderDT({
    DT::datatable(datasetInput(),
    # Scientific notation specification
    options = list(
      search = list(regex = TRUE),
      rowCallback = DT::JS(
        "function(row, data) {",
        "for (i = 1; i < data.length; i++) {",
        "if (data[i]<0.001 && data[i] > 0){",
        "$('td:eq('+i+')', row).html(data[i].toExponential(2));",
        "}",
        "}",
        "}"),
      scrollX = TRUE)
    )
  })

  # Downloadable csv ----------------------------------------------------------
  
  output$downloadTop <- downloadHandler(
    filename <- function() {
      dataset <- ifelse(input$dataset == "Top meQTLs", "top", "clumped")
      n <- paste0(dataset, "_meQTL", ".txt")
      return(n)
    },
    content = function(file) {
      write.table(datasetInput(), file, row.names = FALSE, quote = FALSE, sep = "\t")
    }
  )
  
  # Locus plot  ---------------------------------------------------------------
  
  # Extract positions
  pos_loci <- eventReactive(input$do_plot, {
    pos_loci <- stringr::str_extract_all(input$plot_loci, pattern = "[[:digit:]]+")
    pos_loci <- as.numeric(pos_loci[[1]])
    
    # Check validity of positions
    if(length(pos_loci) != 3 || !pos_loci[1] %in% 1:22 ||
       pos_loci[2] >= pos_loci[3] ||
       pos_loci[2] < 1 || pos_loci[3] > 2.5e8) {
      pos_loci <- NA
    }
    
    return(pos_loci)
  })

  # Filter data set for plot
  plotInput <- eventReactive(pos_loci(), {
    # Check validity of position
    if(length(pos_loci()) == 0) {
      return(NA)
    }
    
    if(input$plot_feat == "CpG") {
      clump_top_assoc %>%
        subset(`CpG chr` == pos_loci()[1] &
                 `CpG pos` >= pos_loci()[2] &
                 `CpG pos` <= pos_loci()[3]) %>%
        transmute(CpG, `Top SNP`, `LD clump`, Beta, SE, P, `Cis/Trans`,
                  POS = `CpG pos`, LOGP = ifelse(P == 0, 308, -log10(P)), # Axis for Manhattan plot
                  CHR_trans = `SNP pos`, POS_trans = `SNP pos`) # Links for circos plot
    } else {
      clump_top_assoc %>%
        subset(`SNP chr` == pos_loci()[1] &
                 `SNP pos` >= pos_loci()[2] &
                 `SNP pos` <= pos_loci()[3]) %>%
        transmute(CpG, `Top SNP`, `LD clump`, Beta, SE, P, `Cis/Trans`, 
                  POS = `SNP pos`, LOGP = ifelse(P == 0, 308, -log10(P)),
                  CHR_trans = `CpG pos`, POS_trans = `CpG pos`)
    }
  })
  
  # Render plot
  output$plot_cis <- plotly::renderPlotly({
    # Validate
    validate(
      need(!is.na(pos_loci()), "Enter a valid locus.\nChromosome must be between 1 and 22, and the range positions between 1 and 2.5e8.\nDo not use separators for positions.\nE.g. 16:49879169-50479169")
    )
    p1 <- plot.locus(plotInput())
    p2 <- plot.gene(pos_loci()[1], pos_loci()[2], pos_loci()[3])
    subplot(p1, p2, nrows = 2, shareX = TRUE, titleY = TRUE) %>%
      layout(xaxis = list(range = c(pos_loci()[2], pos_loci()[3])),
             legend = list(
               # Adjust click behavior
               itemclick = "toggleothers",
               itemdoubleclick = "toggle"
             ))
  })
    
  # Circos plot ---------------------------------------------------------------
  
}
  
  
  
  
