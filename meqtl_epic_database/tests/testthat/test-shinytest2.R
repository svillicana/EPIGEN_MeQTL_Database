library(shinytest2)

test_that("{shinytest2} recording: meqtl_epic_database", {
  app <- AppDriver$new()
  
  # Test on EPIC BD ------------------------------------------------------------
  app$set_inputs(dataset = "Clumped meQTLs")
  app$set_inputs(type_assoc = "trans")
  app$set_inputs(chr_cpg = "22")
  app$set_inputs(show_vars = c("n", "Effects"))
  
  # Verify `datasetInput()`
  epic_db <- app$get_value(export = "epic_db")
  expect_equal(epic_db, fread("epic_db.compare.csv"),
               expected.label = "epicdb_trans_chr22")
  
  # Test on Skin DB ------------------------------------------------------------
  app$set_inputs(skin_type_assoc = "trans")
  app$set_inputs(skin_chr_cpg = "10")
  app$set_inputs(skin_show_vars = c("SNP chr", "Cis/Trans"))

  # Verify `skin_datasetInput()`
  skin_db <- app$get_value(export = "skin_db")
  expect_equal(skin_db, fread("skin_db.compare.csv"),
               expected.label = "skin_db_trans_chr10")
  
  # Test on Visualisation ------------------------------------------------------
  app$set_inputs(plot_feat = "SNP")
  app$set_inputs(plot_loci_1 = 50079169)
  app$set_inputs(plot_loci_2 = 50279169)
  app$set_inputs(plot_range = 250000)
  
  app$click("do_plot")
  #app$expect_values()
})
