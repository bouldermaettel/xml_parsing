# Load the library xml2

packagesToLoad <- c('xml2', 'tidyverse', 'openxlsx', 'reticulate')
sapply(packagesToLoad, function(x) {require(x,character.only=TRUE)} )
use_python("venv")

force_bind <- function(df1, df2) {
    colnames(df2) <- colnames(df1)
    bind_rows(df1, df2)
}

wb <- openxlsx::createWorkbook()

anwender_files <- list.files(path = './anwender/')
hersteller_files <- list.files(path = './hersteller/')

folder_path <- './anwender/'

extract_xml <- function (folder_path) {

 files <- list.files(path = folder_path)

  for (z in seq(along = files)) {
   file_path <- paste0(folder_path, files[z])

  read_file <- read_xml(file_path) %>% as_list()
  xml_df <- tibble::as_tibble(read_file) %>% tidyr::unnest_longer(incident)

  lp_longer <- xml_df %>% unnest_longer(incident, names_repair = "universal")

  new_colnames <- lp_longer[["incident_id...3"]]

  new_df <- data.frame(t(lp_longer[["incident"]]))

  colnames(new_df) <- new_colnames

   new_row <- NA
  # interate over df and unnest columns:
  for (i in 1:ncol(new_df)) {
   new_column <- new_df[1, i] %>% unlist()
   if (is.null(new_column)) {
    new_column <- NA
   }
   if (i == 1) {
    new_row <- as.data.frame(t(as.matrix(unname(new_column))))
    colnames(new_row) <- names(new_column)
   } else {
    df_temp <- as.data.frame(t(as.matrix(unname(new_column))))
    colnames(df_temp) <- names(new_column)
    new_row <- bind_cols(new_row, df_temp)
    }
   }

   if (z == 1) {
    final_df <- new_row
   } else {
   final_df <- force_bind(final_df, new_row)
   }
  }
 return(final_df)
 }

df_anwender <- extract_xml(folder_path = './anwender/')
openxlsx::addWorksheet(wb, sheetName = 'xml_anwender')
openxlsx::writeData(wb, sheet = 'xml_anwender', x = df_anwender, startCol = 1, startRow = 1)

df_hersteller <- extract_xml(folder_path = './hersteller/')
openxlsx::addWorksheet(wb, sheetName = 'xml_hersteller')
openxlsx::writeData(wb, sheet = 'xml_hersteller', x = df_hersteller, startCol = 1, startRow = 1)
openxlsx::saveWorkbook(wb, file = 'xml_test.xlsx', overwrite = TRUE)

