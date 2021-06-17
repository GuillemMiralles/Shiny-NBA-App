
#################################################################################################################
#------------------------------------------------ UI -----------------------------------------------------------#
#################################################################################################################


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

ui <- dashboardPage(
  dashboardHeader(title= tags$img(src='LOGO_F.png',height='50',width='220')),
  dashboardSidebar(
    sidebarMenu(
      uiOutput('id_season'),
      menuItem("Estadísticas NBA", tabName = "p1", icon=icon("table"),
               menuSubItem("Jugadores", tabName = "player"),
               menuSubItem("Equipo", tabName = "team")),
      
      menuItem("Estadísticas avanzadas", tabName = "p3", icon=icon("bar-chart-o"),
               menuSubItem('Por equipos',tabName = 'p3_eq'),
               menuSubItem('Por jugadores',tabName='p3_j'),
               menuSubItem('Lanzamientos',tabName = 'p3_sht')),
              
      
      menuItem("Predicciones", tabName = "p2", icon=icon("dashboard"),selectInput('anyo_mod','Seleccione la temporada',
                                                                                  choices = c('2015','2016','2017')),
               menuSubItem("Modelo 1", tabName = "m1"),
               menuSubItem("Modelo 2", tabName = "m2"),
               menuSubItem("Año 2021", tabName = "m3")),
    
     menuItem("Salario Medio", tabName = "salary", icon=icon('money')))
    
  ),
  dashboardBody(tabItems(
    tabItem('player',h2("Estadísticas de los jugadores de la NBA en la temporada seleccionada:"),
            DT::DTOutput('tabla_temporada'),
            ),
    
    tabItem('team',h2('Estadísticas de los equipos'),
            h5('Los datos de las estadísticas de equipos están disponibles a partir de la temporada 1997'),
            DT::DTOutput('tabla_temporada_eq')),
    
    
    tabItem('p3_eq',h2('Estadísticas avanzadas de los equipos'),
            h5('En estos gráficos podemos ver los puntos anotados por cada 100 posesiones del equipo, y los puntos recibidos por cada 100
               posesiones. Los colores representan si el equipo entra en los playoffs o no. De forma que cuando más a la derecha en el eje X
               y más abajo en el Y, el equipo tiene unas mejores estadísticas.'),
            plotOutput('ggplot1')%>%withSpinner(),
            plotlyOutput('plotly2')),
    
    tabItem('p3_j',h2('Estadísticas avanzadas de los jugadores'),
            h5('En estos gráficos podemos ver el ratio de asistencias y pérdidas de los jugadores de la NBA. Esta es una forma de ver que capacidad tiene el 
               jugador de crear ocasiones sin perder balones. De forma que cuando más a la derecha en el eje X
               y más abajo en el Y, el jugador tiene unas mejores estadísticas. En el primer gráfico cortamos a partir de 250 asistencias para
               poder ver los mejores jugadores.'),
            plotOutput('ggplot2')%>%withSpinner(),
            plotlyOutput('plotly3')),
    
    tabItem('p3_sht',h2('Tiros encestados y fallados'),
            h5('Podemos ver los tiros encestados y fallados, y las zonas desde donde se hace el lanzamiento por los mejores jugadores de los 
               últimos años'),
            uiOutput('id_player'),
            uiOutput('id_season_shots'),
            plotOutput("plot_shots",height = 750,width =1100)),
    

    tabItem('m1',h2('Modelo 1'),
            h5('Este modelo está elaborado con los datos de la temporada para la cual se votará el mejor quinteto.
               Por ejemplo, viendo los datos que ha hecho el jugador en la temporada 2015, el modelo estima que jugadores
               tienen mayor probabilidad de entrar al quinteto al final de temporada en ese mismo año.'),
            plotlyOutput('mo1',height = "auto")%>%withSpinner(),
            sliderInput("num_j_m1","Número de jugadores",
                        min = 1, max = 40, value = 15))
    ,
    tabItem('m2',h2('Modelo 2'),
            h5('Este modelo está elaborado con los datos de la temporada anterior a la votación del mejor quinteto. 
               Por ejemplo, viendo los datos que ha hecho el jugador en la temporada 2014, el modelo estima que jugadores 
               tienen mayor probabilidad de entrar al quinteto del año siguiente, 2015.'),
            plotlyOutput('mo2',height = "auto")%>%withSpinner(),
            sliderInput("num_j_m2","Número de jugadores",
                        min = 1, max = 40, value = 15)),
    
    tabItem('m3',h2('Modelo para el próximo año'),
            h5('Este modelo hace una predicción del próximo quinteto de la NBA con los datos actuales (aún no conocemos
               el resultado).'),
            plotlyOutput('mo3',height = "auto")%>%withSpinner(),
            sliderInput("num_j_m3","Número de jugadores",
                        min = 1, max = 40, value = 15)),
    
    tabItem('salary',h2("Salarios en la NBA"),h5("Esta gráfica representa la evolución de la media de dinero destinado por 
                                                 los equipos al salario de los jugadores"),
            plotlyOutput('salaries',height = "auto")%>% withSpinner())
    
  )),
  tags$head(
  tags$style(HTML('
.skin-blue .main-header .logo{
background-color: white;
color: #201545;
}
.skin-blue .main-header .navbar {
background-color: #201545;
}
.skin-blue .main-sidebar{
background-color: #201545;
}
.skin-blue .sidebar-menu>li.active>a{
background: #201545;
}
'))
)

)
             
             