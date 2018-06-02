#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)

# Define UI for application that draws a histogram
shinyUI(
    pageWithSidebar(
        headerPanel('Iris k-means clustering with filtering'),
        
        # The silde pannel contains the variables used for the k mean clustering and the number of clusters 
        sidebarPanel(
            selectInput('xcol', 'X Variable', names(iris)),
            selectInput('ycol', 'Y Variable', names(iris),
                        selected=names(iris)[[2]]),
            numericInput('clusters', 'Cluster count', 3,
                         min = 1, max = 9)
        ),
        
        #The main plot will display the variables used for the k mean. 
        #The data table will reflect the data plotted
        #The data dable will allows to filter the data
        mainPanel(
            plotOutput('plot1'),
            p("Enter a value in the search field to filter the dataset"),
            DT::dataTableOutput("x1")
        )
    )
)
