#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

options(shiny.reactlog=TRUE) 
rm(list=ls())

source("predictWord.R")


words <- as.vector(c("","" ,"")) 

# Define server logic required to draw a histogram
shinyServer(function(input, output, clientData, session) {
    
    
    
    observe({
        words <<- predict_next_word(tolower(input$text))
        words[is.na(words)] <<- ""

        updateActionButton(session, inputId = "word1",label = words[1])
        updateActionButton(session, inputId = "word2",label = words[2])
        updateActionButton(session, inputId = "word3",label = words[3])
    })
    
    observeEvent(input$word1, {
        if(!is.na(words[1])){
            updateTextInput(session, inputId = "text", value =  paste(input$text, words[1], sep=" "))
        }
    })
    observeEvent(input$word2, {
        if(!is.na(words[2])){
            updateTextInput(session, inputId = "text", value =  paste(input$text, words[2], sep=" "))
        }
    })
    observeEvent(input$word3, {
        if(!is.na(words[3])){
            updateTextInput(session, inputId = "text", value =  paste(input$text, words[3], sep=" "))
        }
    })
    
})
