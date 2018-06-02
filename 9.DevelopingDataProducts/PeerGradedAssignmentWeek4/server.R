#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(
    function(input, output, session) {
        
        # Combine the selected variables into a new data frame
        selectedData <- reactive({
            #s2 is used to kno if the uses the datatable filter.
            s2 = input$x1_rows_all
            
            #Select the data regarin the filter field
            if (length(s2) > 0 && length(s2) < nrow(iris)) {
                irisSelect <- iris[s2, , drop = FALSE]
            }else{
                irisSelect <- iris
            }
            
            #Select only the column selected for the clustering 
            irisSelect[, c(input$xcol, input$ycol)]
        })
        
        #Perform the k mean clustering with the selected data
        clusters <- reactive({
            kmeans(selectedData(), input$clusters)
        })
        
        
        #Display the data in the data table
        output$x1<- DT::renderDataTable({
            DT::datatable(iris, options = list(lengthMenu = c(10, 50, 20), pageLength = 10))
        })
        
        #Plot the k mean clustering
        output$plot1 <- renderPlot({
            palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
                      "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
            
            par(mar = c(5.1, 4.1, 0, 1))
            
            plot(selectedData(),
                 col = clusters()$cluster,
                 pch = 20, cex = 3)
            points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
        })
    }
)
