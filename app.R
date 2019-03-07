#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(scales)
library(tm)
library(wordcloud)
library(SnowballC)
library(rvest)
library(dplyr)
library(reshape2)
library(pander)
library(xlsx)
library(ggplot2)
library(DT)
library(shinydashboard)

degrom <- read.csv("degrom.csv")
kershaw <- read.csv("kershaw.csv")
shoemaker <- read.csv("shoemaker.csv")
# Define UI for application that draws a histogram
ui <- fluidPage(
  # tags$head(includeScript("www/google-analytics.js")),
  pageWithSidebar(
  headerPanel('Baseball Pitch Analysis'),
   
   # Sidebar with a slider input for number of bins 
      sidebarPanel(
        fileInput("file", label = h3("Upload Pitching Data Here:",multiple = FALSE,accept = NULL,width=NULL),
                  accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv','.xlsx')),
        #selectInput("type", "Type",choices = names(df),selected = names(df)),
        selectInput("datasetten", "Choose Sample Pitching Dataset:", 
                    choices = c("James Degrom", "Clayton Kershaw","Matt Shoemaker"),selected = "James Degrom"),
        br(),
        br(),
        downloadButton("downloadpitch","Downaload Pitching Dataset"),
        br(),
        br(),
        hr(),
         actionButton(inputId = "update" ,label = "Create Pitch Plot")
         ),
      
      # Show a plot of the generated distribution
      mainPanel(tabsetPanel(
        tabPanel("Baseball Pitch Data",tableOutput('table')),
        tabPanel(title = "Baseball Pitch Type Plot",plotOutput("pitchplot")),
        tabPanel(title = "Baseball Pitch Speed Plot",plotOutput("pitchplot2"))
        
      ))
   )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  
  
  pitch_data <- reactive({ 
    req(input$file) ## ?req #  require that the input is available
    
    inFile <- input$file 
    
    
    df <- read.csv(inFile$datapath)
    
    updateSelectInput(session, inputId = 'type', label = 'Type',
                      choices = names(df), selected = names(df))
    
    # updateSelectInput(session, inputId = 'type', label = 'Type',
    #                   choices = c("Pitch Type"= pitch_type, "Pitch Speed"=start_speed), selected = start_speed)
    # 
    return(df)
    
  })
  
  # reactive(
  #   updateSelectInput(session, inputId = 'type', label = 'Type',
  #                     choices = names(value), selected = names(value))
  # )

  value <- reactive(
    
    value <- pitch_data()
    

  )
  
  ## Table Data Code
  output$table <- renderTable({
    req(input$file)
    inFile <- input$file
    if (is.null(inFile))
      return("Please Upload File")
    # datasetInput()
    read.csv(inFile$datapath)
    
  })
  
   

     observeEvent(input$update,{output$pitchplot <- renderPlot({
   
       withProgress(message = 'Creating Pitch Type Plot',
                    value = 0, {
                      for (i in 1:3) {
                        incProgress(1/3)
                        Sys.sleep(0.25)
                      }
                    },env = parent.frame(n=1))
       
      # generate bins based on input$bins from ui.R
    p <- ggplot(value(), aes(px, pz,color=pitch_type))+ geom_point(size = 10, alpha = .65)+ scale_x_continuous(limits = c(-3,3)) + scale_y_continuous(limits = c(0,5)) + annotate("rect", xmin = -1, xmax = 1, ymin = 1.5, ymax = 3.5, color = "black", alpha = 0) + labs( title = "Baseball Pitch Type Analysis") + ylab("Horizontal Location (ft.)") + xlab("Vertical Location (ft): Catcher's View") + labs(color = "Pitch Type")+ geom_point(size = 10, alpha = .65) + theme(axis.title = element_text(size = 15, color = "black", face = "bold")) + theme(plot.title = element_text(size = 30, face = "bold", vjust = 1)) + theme(axis.text = element_text(size = 13, face = "bold", color = "black")) + theme(legend.title = element_text(size = 12)) + theme(legend.text = element_text(size = 12))

     
     # view the plot
     
     p
   })})
     
     
     
     observeEvent(input$update,{output$pitchplot2 <- renderPlot({
       
       withProgress(message = 'Creating Pitch Speed Plot',
                    value = 0, {
                      for (i in 1:3) {
                        incProgress(1/3)
                        Sys.sleep(0.25)
                      }
                    },env = parent.frame(n=1))
       
       # generate bins based on input$bins from ui.R
       p <- ggplot(value(), aes(px, pz,color=start_speed))+ geom_point(size = 10, alpha = .65)+ scale_x_continuous(limits = c(-3,3)) + scale_y_continuous(limits = c(0,5)) + annotate("rect", xmin = -1, xmax = 1, ymin = 1.5, ymax = 3.5, color = "black", alpha = 0) + labs( title = "Baseball Pitch Speed Analysis") + ylab("Horizontal Location (ft.)") + xlab("Vertical Location (ft): Catcher's View") + labs(color = "Pitch Speed")+ geom_point(size = 10, alpha = .65) + theme(axis.title = element_text(size = 15, color = "black", face = "bold")) + theme(plot.title = element_text(size = 30, face = "bold", vjust = 1)) + theme(axis.text = element_text(size = 13, face = "bold", color = "black")) + theme(legend.title = element_text(size = 12)) + theme(legend.text = element_text(size = 12))
       
       
       # view the plot
       
       p
     })})
     
     
     datasetpitch <- reactive({
       switch(input$datasetten,
              "James Degrom" = "degrom.csv",
              "Clayton Kershaw" = "kershaw.csv",
              "Matt Shoemaker"= "shoemaker.csv")
     })
     
     
     output$downloadpitch <- downloadHandler(
       filename <- function() {
         paste(input$datasetten, "csv", sep=".")
       },
       
       content <- function(file) {
         file.copy(datasetpitch(), file)
       },
       contentType = "csv"
     )
     
}

# Run the application 
shinyApp(ui = ui, server = server)

