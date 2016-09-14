library(shiny)
library(ggplot2)
library(twitteR)
library(streamR)
library(plyr)
library(RJSONIO)
library(scales)

#Execute the script in modules as guided by the comments.

#Obtain the following 4 variables from your twitter developer account.
#block
consumer_key <- "CONSUMER_KEY"
consumer_secret<- "CONSUMER_SECRET"
access_token <- "ACCESS_TOKEN"
access_secret <- "ACCESS_SECRET"
setup_twitter_oauth(consumer_key, consumer_secret, access_token = access_token, access_secret = access_secret)
#end of block
#execute the above block once. comment after initialization


modify <- function(x){
  x$textlo <- gsub("[^[:alpha:][:space:]]*", "", x$text)
  x$textlo <- tolower(x$textlo)
  x$candidate[grepl("trump",x$textlo)] <- "Trump"
  x$candidate[grepl("clinton",x$textlo)] <- "Clinton"
  x$candidate[grepl("sanders",x$textlo)] <- "Sanders"
  x$candidate[grepl("rubio",x$textlo)] <- "Rubio"
  x$candidate[grepl("kasich",x$textlo)] <- "Kasich"
  x$candidate <- as.factor(x$candidate)
  x <- x[complete.cases(x$candidate),]
  x$date <- as.Date(x$created)
  return(x)
}
tracker<- "Sanders OR Clinton OR Trump OR Rubio OR Kasich"

# to initialize past data, execute the code in block below
#block 
data <- searchTwitter(searchString = tracker, n=5000, since ="2016-02-01")
qtest <- twListToDF(data)
qtest <- modify(qtest)
# end of block 
#comment above block after intialization

shinyServer(function(input,output, session){
      observe({
        invalidateLater(3000, session)
        tracker <- input$text1
        data <- searchTwitter(searchString = tracker, n=20, since ="2016-02-20")
      if(length(data)>0){
        new.tweets <- twListToDF(data)
        new.tweets <- modify(new.tweets)
        qtest <- rbind(new.tweets, qtest)
        #qtest <- unique(qtest)
      }
        output$summary <- renderText({
          return(head(new.tweets$text))
        })
        
        output$plot1 <- renderPlot({
          ggplot(data = qtest, aes(x = candidate, y = date, color = candidate)) + 
            geom_jitter()+ylab("Created (UTC)")+ggtitle("Plot 1:Live Plot of Incoming Tweets. New Points Will Appear")
        
          
          })
        output$plot2 <- renderPlot({
          ggplot(data = subset(qtest, (qtest$retweetCount > input$slider2[1])&(qtest$retweetCount < input$slider2[2])), aes(x = candidate, y = retweetCount, fill = candidate)) + geom_boxplot() + ggtitle("Plot 2: Virality of tweets")
        })
        output$plot3 <- renderPlot({
         ggplot(data = subset(qtest, qtest$candidate %in% input$check1), aes(x = candidate, fill = candidate)) + geom_bar()+ylab("Total tweet count") + ggtitle("Plot3: Total Tweets per Candidates")
         # ggplot(data = qtest, aes(x = candidate, fill = candidate)) + geom_bar()+ylab("Total tweet count") + ggtitle("Plot3: Total Tweets per Candidates")
          
           })
        
    })
  
})
##################
