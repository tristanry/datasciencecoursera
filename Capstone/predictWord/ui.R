#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Predict word"),
  
  actionButton("word1", "", width = 150),   actionButton("word2", "", width = 150),   actionButton("word3", "", width = 150),
  textInput("text","Enter a word", "", width = 460)
))
