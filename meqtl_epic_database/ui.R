library(shiny)
library(dplyr)
library(bslib)
library(shinycssloaders)
library(shinyhelper)
 
# Prepare filters
col_top_assoc <- c("LD clump","CpG chr","CpG pos","SNP chr","SNP pos","A1",
                   "A2","MAF","Beta","SE","P","FDR","N","n","Effects",
                   "Cis/Trans")
def_col <- c("CpG chr", "CpG pos","Beta", "SE", "P", "FDR", "Cis/Trans")

# Main ------------------------------------------------------------------------

navbarPage(
  theme = bs_theme(bootswatch = "yeti", font_scale = 1.25),
  title = "MeQTL EPIC Database",

  # Home tab  -----------------------------------------------------------------
  tabPanel("Home",
           fluidRow(
             column(2),
             column(8, includeMarkdown("home.md")),
             column(2)
           )),
  
  # Tab with top associations -------------------------------------------------
  tabPanel("MeQTLs",
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
                 DT::dataTableOutput("table")
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
               radioButtons("plot_feat", "Plot position by",
                            choices = c("CpG", "SNP")),
               textInput("plot_loci", "Region to plot",
                         value = "16:49879169-50479169",
                         placeholder = "chr:pos1-pos2"),
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

