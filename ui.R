library(shiny)

shinyUI(fluidPage(
  tags$style(type="text/css",
             ".recalculating { opacity: 1.0; }"
  ),
  titlePanel("Akshay's Page"),
  sidebarLayout(
    sidebarPanel(
      textInput("text1", "Enter terms to be searched on Twitter as shown", "Clinton OR Trump"),
      sliderInput("slider2", label = "BoxPlot of Retweet Counts",
                  min = 0, max = 3000, value = c(1, 75)),
      checkboxGroupInput("check1", label = h3("Candidates to show in plot 3"), 
                         choices = list("Trump" = "Trump", "Clinton" = "Clinton", 
                                        "Rubio" = "Rubio", "Sanders" = "Sanders", 
                                        "Kasich" = "Kasich"), selected = c("Clinton", "Sanders", "Rubio", "Kasich", "Trump"))
      
    ),
    mainPanel(
      verbatimTextOutput("summary"),
      plotOutput("plot1"),
      plotOutput("plot2"),
      plotOutput("plot3")
    )
  )
))