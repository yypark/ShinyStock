####
#
library(shiny)
library(quantmod)
library(forecast)

file="stock_data_google_2010_2016.RData"
if (file.exists(file)) load(file) else {
    from.dat <- as.Date("01/01/10", format="%m/%d/%y")
    to.dat <- as.Date("12/30/16", format="%m/%d/%y")
    GOOG <- getSymbols("GOOG", src="yahoo", from = from.dat, to = to.dat) # 'xts' object
    save(GOOG, file=file)
}
google_stock <- GOOG # a copy of  'xts' object

shinyServer(
    function(input, output, session) {
        # 1) Return the selected dataset using 'eventReactive()', which depends on input$Go
        # the output is only updated when the user clicks the button
        datarange_sel <- reactive({
            # selected date range
            date_from_to <- as.Date(input$dates, format="%Y-%m-%d")
        })
        TechInd_sel <- eventReactive(input$Go, {
            # selecting technical indicators
            input$radio1
        })
        
        observeEvent(input$Go,{
            #
            # some processing for forecasting
            date_range <- isolate(input$dates)
            weekly_GOOG <- to.weekly(google_stock[ paste(date_range[1],"::",date_range[2],sep="")]) 
            weekly_GOOG_closing <- Cl(weekly_GOOG)
            ts1 <- ts(weekly_GOOG_closing, frequency=5) # roughly 5 weeks per month
            
            # #### for 1 year (52 week) fixed case:
            length_ts1 <- length(ts1)
            num_length_ts1_p7 <- round((length_ts1*0.7)/4) # ==> 70% of weeks to # of months (assuming 4weeks/month)
            num_length_ts1_end <- round(length_ts1/4)+1
            ts1Train <- window(ts1, start=1, end=num_length_ts1_p7) # about 1 ~ 8 month : 41 elements(weeks)
            ts1Test <- window(ts1, start=num_length_ts1_p7, end=num_length_ts1_end) # about 9 ~ 12 month :13 elements(weeks)

            ###### forecast: Multiplicative Holt-Winters method with multiplicative errors
            #
            ets1 <- ets(ts1Train, model="MAM") 
            fcast <- forecast(ets1)
            output$plot2 <-  renderPlot( {plot(fcast, xlab="Months")
                                         lines(ts1Test, col="red")}) # for debugging
            accuracy_fcast <- accuracy(fcast, ts1Test)
            output$table2 <- renderTable({ accuracy_fcast })   # 41 elements 
            
            # selecting technical indicators
            input$radio1
        })
        

        
        # 2) Show the n-observations using 'isolate()'
        # the table is updated only when the user clicks the action table
        output$table <- renderTable({
            # just for actionButton
            TechInd_chosen <- TechInd_sel()             # e.g. [1] "addSMA()"

            OHLC_ckbx <- isolate(input$ckbxgrp1)    # e.g. [1] "1" "2" "3" "4"
            output$dump1 <- renderPrint(OHLC_ckbx)  #for debugging
            
            date_range <- isolate(input$dates)      # e.g. [1] "2013-02-01" "2013-12-31"
            output$dump2 <- renderPrint(date_range) # for debugging
            
            num_obs <- isolate(input$num1)  # number of observations
            
            subset_GOOG <- google_stock[ , c(as.integer(OHLC_ckbx), 5)] # 5 for volume
            head(subset_GOOG[paste(date_range[1],"::",date_range[2],sep="")], num_obs)
        })
        
        # 3) Show the plot using 'isolate()'
        # the plot is updated only when the user clicks the action table
        output$plot <- renderPlot({
            TechInd_chosen <- TechInd_sel()             
            OHLC_ckbx <- isolate(input$ckbxgrp1)    
            date_range <- isolate(input$dates)      

            subset_GOOG <- google_stock[ , c(as.integer(OHLC_ckbx),5)] # '5' for volume
            
            chartSeries(subset_GOOG[paste(date_range[1],"::",date_range[2],sep="")],
                        name="Google (GOOG) in $USD", TA=NULL)
            ###
            switch(isolate(input$radio1),
                   "addVo()" = addVo(),
                   "addSMA()" = addSMA(),
                   "addWMA()" = addWMA(),
                   "addEMA()" = addEMA(),
                   "addDEMA()" = addDEMA(),
                   "addMACD()" = addMACD()
                   )

        })
  
    }
)