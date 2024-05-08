library(shiny)
library(DT)
library(dplyr)
library(bslib)
library(shinycssloaders)
library(shinyhelper)

# Prepare filters
col_top_assoc <- c("LD clump","CpG chr","CpG pos","SNP chr","SNP pos","A1",
                   "A2","MAF","Beta","SE","P","FDR","N","n","Effects",
                   "Cis/Trans")
def_col <- c("CpG chr", "CpG pos","Beta", "SE", "P", "FDR", "Cis/Trans")
col_skin <- c("CpG chr","CpG pos","SNP chr","SNP pos","Minor Allele",
              "Major Allele","MAF","Beta","SE","P","FDR","Cis/Trans")

# Main ------------------------------------------------------------------------

navbarPage(
  theme = bs_theme(bootswatch = "flatly", font_scale = 1.25),
  title = "EPIGEN MeQTL Database",

  # Home tab  -----------------------------------------------------------------

  tabPanel("Home", 
           layout_columns(
             includeMarkdown("home/home_main.md"),
             br(),
             flowLayout(
               card(card_header(class = "bg-secondary", "EPIC Database"), includeMarkdown("home/home_epic.md")),
               card(card_header(class = "bg-secondary", "Skin Database"), includeMarkdown("home/home_skin.md")),
               cellArgs = list(
                 style = "width: 49%;
                 min-width: 275px;
                 padding: 1%;"
               )),
             br(),
             includeMarkdown("home/home_foot.md"),
           col_widths = c(-2,8,-2))),
  
  # Tab with top associations -------------------------------------------------
  tabPanel("EPIC DB",
           sidebarLayout(
             sidebarPanel(
               # Select dataset
               selectInput("dataset", "Choose a dataset",
                           choices = c("Top meQTLs", "Clumped meQTLs")) %>%
                 helper(content = "dataset"),
               
               # Cis/Trans filter
               selectInput("type_assoc", "Filter by type of association",
                           choices = c("cis","trans"), selected = NULL, multiple= TRUE)  %>%
                 helper(content = "cistrans"),
               
               # Chr filter
               selectInput("chr_cpg", "Filter by CpG chromosome",
                           choices = c(1:22), selected = NULL, multiple= TRUE
               ),
               # Column selector
               checkboxGroupInput("show_vars", "Columns to show",
                                  col_top_assoc, selected = def_col) %>%
                 helper(content = "cols"),
               # Button
               downloadButton("downloadTop", "Download"),
               width = 2
             ),
             mainPanel(
               withSpinner(
                 dataTableOutput("table")
               ),
               width = 10
             )
           )
  ),

  # Tab with skin associations -------------------------------------------------
  tabPanel("Skin DB",
           sidebarLayout(
             sidebarPanel(
               # Cis/Trans filter
               selectInput("skin_type_assoc", "Filter by type of association",
                           choices = c("cis","trans"), selected = NULL, multiple= TRUE)  %>%
                 helper(content = "cistrans"),
               
               # Chr filter
               selectInput("skin_chr_cpg", "Filter by CpG chromosome",
                           choices = c(1:22), selected = NULL, multiple= TRUE
               ),
               # Column selector
               checkboxGroupInput("skin_show_vars", "Columns to show",
                                  col_skin, selected = def_col) %>%
                 helper(content = "skin_cols"),
               # Button
               downloadButton("skin_downloadTop", "Download"),
               hr(),
               downloadLink("skin_downloadFull", "Full FDR 5% cis results"),
               width = 2
             ),
             mainPanel(
               withSpinner(
                 dataTableOutput("skin_table")
               ),
               width = 10
             )
           )
  ),
  
  # Tab with plots ------------------------------------------------------------
  tabPanel("Visualisation",
           sidebarLayout(
             
             # Options for the plot
             sidebarPanel(
               selectInput("plot_dataset", "Choose a dataset",
                           choices = c("EPIC DB", "Skin DB")),
               radioButtons("plot_feat", "Plot position by",
                            choices = c("CpG", "SNP")),
               numericInput("plot_chr", "Chromosome", value = 16, min = 1, max = 22, step = 1),
               numericInput("plot_loci_1", "From", value = 49879169, min = 1, max = 2.5e8, step=1),
               numericInput("plot_loci_2", "to", value = 50479169, min = 1, max = 2.5e8, step=1),
               numericInput("plot_range", "Range", value = 600000, min = 1, max = 2.5e8, step=1),
               actionButton("do_plot", "Create plot"),
               width = 2
             ),
             
             # Panel with cis/trans plot
             mainPanel(
               withSpinner(
                 plotly::plotlyOutput("plot_cis",
                                      height = "600px"))
             )
           )
  )
)

