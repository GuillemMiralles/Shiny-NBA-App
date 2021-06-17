
#################################################################################################################
#---------------------------------------------- SERVER ---------------------------------------------------------#
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

server <- function(input, output) {
  
  ############################### CARGA DE DATOS ################################
  df_ss <- read_csv('./data/Seasons_Stats.csv')
  df_p <- read_csv('./data/playerstotals.csv')
  df_t <- read_csv('./data/teams.csv')
  df_ad <- read_csv('./data/teamsadvanced.csv')
  dbsal <- read_csv('./data/dbsal.csv')
  load("nba_shots.RData")
  
  df_mod1 <- read_csv('./data/mod1.csv')
  df_mod2 <- read_csv('./data/mod2.csv')
  df_mod3 <- read_csv('./data/data21.csv')

  
  ############################### PAGINA 1 ########################################

  output$id_season <- renderUI({selectInput('season','Seleccione la temporada',
                                               choices = unique(df_ad %>% dplyr::select(yearSeason)))})
  
  
 ################################## SUBPÁGINA 1.1 ##################################
  
  
  output$tabla_temporada <- DT::renderDataTable({
    df_p %>% subset(yearSeason==input$season)  %>%
      dplyr::select(namePlayer,slugPosition, agePlayer,slugTeamBREF,
                    minutesTotals,trbTotals,astTotals,ptsTotals,
                    blkTotals,stlTotals)
    
  })

  ########################## SUBPÁGINA 1.2 ################################################

  ids <- c()
  output$tabla_temporada_eq <- DT::renderDataTable({
    observeEvent(input$season, {
      
      if (input$season < 1997){
        id <- showNotification(paste("Seleccione un dataframe a partir de la temporada 1997"), duration = 30,
                               type = 'error',closeButton=TRUE)
        ids <- c(ids, id)}
    })
    
    observeEvent(input$season, {
      
      if (input$season > 1996){
        while (length(ids) > 0){
          removeNotification(ids[1])
          ids <- ids[-1]}}
      
    })
      
      df_t %>% subset(yearSeason==input$season)  %>%
        dplyr::select(yearSeason,nameTeam,winsRank,pctWins,pts,plusminus,plusminusRank)
  })
  
  ###################### SUBPÁGINA 2.1 ##################################################

  output$ggplot1 <- renderPlot({
    df_ad <- df_ad %>% subset(yearSeason==input$season)
    
    ggplot(data = df_ad, aes(ortgTeamMisc, drtgTeamMisc)) +
    geom_point(color = 'black') +
    theme_bw() + 
    geom_label_repel(aes(label = nameTeam,
                         fill = factor(isPlayoffTeam)), 
                     color = 'white',
                     size = 3.5) + xlab("Puntos anotados cada 100 posesiones") + ylab ("Puntos recibidos cada 100 posesiones")+
    labs(title = "Métricas avanzadas en la NBA",
         subtitle = "Puntos Anotados VS Recibidos cada 100 posesiones",
         caption  = "Source: Rstats",
         x        = "Puntos anotados/100 posesiones",
         y        = "Puntos recibidos/100 posesiones",
         fill     = "Playoffs")})
  
  output$plotly2 <- renderPlotly({
    df_ad <- df_ad %>% subset(yearSeason==input$season)
    pal <- c('red','blue')
    plot_ly(data = df_ad, x = ~ortgTeamMisc, y = ~drtgTeamMisc, color = ~isPlayoffTeam,
            size = 16, colors = pal,
            text = ~paste("Net rating: ", nrtgTeamMisc, 'Equipo:', nameTeam))
    
  })
  
  
  ###################### SUBPÁGINA 2.2  ##################################################
  
  output$ggplot2 <- renderPlot({
    df_p <- df_p %>% subset(yearSeason==input$season) 
  ggplot(data = df_p %>% subset(astTotals>250),mapping =  aes(astTotals, tovTotals)) +
    geom_point(color = 'red') +
    geom_label_repel(aes(label = namePlayer,
                         fill = factor(slugPosition)), 
                     color = 'white',
                     size = 3.5) + theme_bw() + xlab("Asistencias Totales") + ylab ("Pérdidas Totales")+
    labs(title = "Métricas avanzadas en la NBA",
         subtitle = "Asistencias vs Pérdidas por posición",
         caption  = "Source: Rstats",
         x        = "Asistencias Totales",
         y        = "Pérdidas Totales",
         fill     = "Posición")
  })
  
  output$plotly3 <- renderPlotly({
    df_p<- df_p %>% subset(yearSeason==input$season) 
    plot_ly(data = df_p, x = ~astTotals, y = ~tovTotals, color = ~minutesTotals,
          size = 16,
          text = ~paste( 'Player:', namePlayer))
  })
  
  ###################### SUBPÁGINA 2.3  ##################################################
  
  output$id_player <- renderUI({selectInput('shot_player','Selecciona un jugador',
                                            choices = unique(nba_shots %>% dplyr::select(player_name)))})
  
  output$id_season_shots <- renderUI({selectInput('shot_season','Selecciona una temporada',
                                            choices = unique(nba_shots %>% dplyr::select(season)))})

  output$plot_shots <- renderPlot({
    
    source("helpers.R")
    
    gg_court = make_court()
    
    player_data = filter(nba_shots, player_name == input$shot_player, season == input$shot_season)
    
    gg_court + geom_point(data = player_data, alpha = 0.65, size = 2.3,
                          aes(loc_x, loc_y, color = shot_made_flag)) +
      scale_color_manual("", values = c(made = "blue", missed = "orange"))
    
  })
  
  ###################### SUBPÁGINA 3.1  ##################################################

  
  output$mo1 <- renderPlotly({
    num <- input$num_j_m1
    df_mod1 <-df_mod1 %>% subset(Year==input$anyo_mod)
    plotly_mod1 <-  df_mod1[1:num,] %>%  
      ggplot(mapping = aes(x=reorder(Player,probs),y=probs,fill = quinteto)) +
      
      geom_bar(stat = "identity")+
      theme_bw() +theme(axis.text.x=element_text(angle=90))+
      labs(title = "Predicción mejor quineto",x = "Jugadores",
           y= "Probabilidad",fill = "Entró en el quinteto? (1-SI, 0-NO)") + coord_cartesian(ylim = c(0,100))
  
  ggplotly(plotly_mod1)
  
  })
  
  
  ###################### SUBPÁGINA 3.2 ##################################################
  
  output$mo2 <-renderPlotly({
    num <- input$num_j_m2
    df_mod2 <- df_mod2 %>% subset(Year==input$anyo_mod)
    plotly_mod2 <-  df_mod2[1:num,] %>% 
      ggplot(mapping = aes(x=reorder(Player,probs),y=probs,fill = quinteto)) +
      
      geom_bar(stat = "identity")+
      theme_bw() +theme(axis.text.x=element_text(angle=90))+
      labs(title = "Predicción mejor quinteto",x = "Jugadores",
           y= "Probabilidad",fill = "Entró en el quinteto? (1-SI, 0-NO)") + coord_cartesian(ylim = c(0,100))
    
    ggplotly(plotly_mod2)

  })
  
  ###################### SUBPÁGINA 3.3 ##################################################
 
  output$mo3 <-renderPlotly({
    num <- input$num_j_m3

    plotly_mod3 <-  df_mod3[1:num,] %>% 
      ggplot(mapping = aes(x=reorder(Player,probs),y=probs)) +
      
      geom_bar(stat = "identity",fill='indianred3')+
      theme_bw() +theme(axis.text.x=element_text(angle=90))+
      labs(title = "Predicción mejor quinteto",x = "Jugadores",
           y= "Probabilidad") + coord_cartesian(ylim = c(0,100))
    
    ggplotly(plotly_mod3)
    
  })
  
  #######################    PÁGINA 4     ###########################################
  
  output$salaries<- renderPlotly({
    ggplotly(
      ggplot( data = dbsal, aes(season, sal_seson, group = 1)) + 
        geom_line(col="dodgerblue3") +
        geom_point(col="midnightblue")+
        labs(title="Salario NBA por Temporada", 
             subtitle="Total") + 
        theme(axis.text.x = element_text(angle=90, vjust=0.6)))
    
  })

}



