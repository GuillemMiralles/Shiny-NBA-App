

############################################ APLICACIÓN #############################################################

# Aplicacció carregada a: https://guillemmiralles.shinyapps.io/5_42/


# Especificamos las librerías necesarias en esta lista

library(shiny)
library(shinythemes)
library(shinyalert)
library(shinycssloaders)
library(readr)
library(shinydashboard)
library(plotly)
library(dplyr)
library(DT)
library(lubridate)
library(ggplot2)
library(ggrepel)
library(htmltools)
library(rmarkdown)
library(jsonlite)


source("ui.R", encoding = "UTF-8")
source("server.R", encoding = "UTF-8")

shinyApp(ui, server)

