library(testthat)
library(DT)
library(dplyr)
library(bslib)
library(shinycssloaders)
library(shinyhelper)

testServer(expr = {

  # Test on EPIC BD ------------------------------------------------------------
  session$setInputs(dataset = "Clumped meQTLs")
  session$setInputs(type_assoc = "trans")
  session$setInputs(chr_cpg = "22")
  session$setInputs(show_vars = c("n", "Effects"))
  
  # Verify `datasetInput()`
  expect_equal(datasetInput(), data.table::fread("tests/testthat/epic_db.compare.csv"),
               expected.label = "epicdb_trans_chr22")
  
  # Test on Skin DB ------------------------------------------------------------
  session$setInputs(skin_type_assoc = "trans")
  session$setInputs(skin_chr_cpg = "10")
  session$setInputs(skin_show_vars = c("SNP chr", "Cis/Trans"))
  
  # Verify `skin_datasetInput()`
  expect_equal(skin_datasetInput(), data.table::fread("tests/testthat/skin_db.compare.csv"),
               expected.label = "skin_db_trans_chr10")
  
  # Test on Visualisation ------------------------------------------------------
  session$setInputs(plot_feat = "SNP")
  session$setInputs(plot_loci_1 = 50079169)
  session$setInputs(plot_loci_2 = 50279169)
  session$setInputs(plot_range = 250000)
  
  session$setInputs(do_plot=1)
  #app$expect_values()
})


