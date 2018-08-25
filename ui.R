###
shinyUI(pageWithSidebar(
    headerPanel("Google Stock Price for Table, Plot, and Forecast"),
    sidebarPanel(
        checkboxGroupInput('ckbxgrp1', label=h3('Choose data type'),
                           choices = list('Open price' = '1', # Open stock price 
                                          'High price' = '2',  # High stock price
                                          'Low price' = '3',   # Low stock price
                                          'Close price' = '4'),   # Close stock price
                           selected = '1'), 

        dateRangeInput("dates", label = h3("Sub-range of data"),
                       start = "2013-01-01",
                       end = "2013-12-31",
                       min = "2010-01-01",
                       max = "2016-12-31"),
 
        numericInput('num1', 'Number of observations to view: ', value = 10),

        helpText("You should push this button to view the result"),
        actionButton("Go", "Go for Table/Plot/Forecasting"),

        radioButtons('radio1', label=h3('Technical indicators'),
                    choices = list( 
                             'Volume' = 'addVo()',   # addVo(): volume
                             'Simple Moving Average(MA)' = 'addSMA()',     # addSMA(): Simple Moving Average
                             'Weighted MA' = 'addWMA()',     # addWMA(): Weighted Moving Average
                             'Exponential MA' = 'addEMA()',     # addEMA(): Exponential Moving Average
                             'Double Exponential MA' = 'addDEMA()',   # addDEMA(): Double Exponential Moving Average
                             'MA Convergence Divergence' = 'addMACD()'),  # addMACD(): Moving Average Convergence Divergence
                    selected = 'addVo()'),
        tags$br()
    ),
    mainPanel(
        
        # Output: tabset w/ table, plot, and forecasting
        tabsetPanel(type = "tabs",
                    # data table with given number of observations: 
                    tabPanel("Table", 
                             h4("Usage of Table tab:"),
                             helpText("You can print out data table of the google stock price in various ways"),
                             helpText("- Step1: Choose either open, high, low, or close stock price, or select combinations of some or all of the prices."),
                             helpText("- Step2: Set the date range of the stock price that you like."),
                             helpText("- Step3: Select a number of observations of data to view."),
                             helpText("- Then, click 'GO for Table/Plot/Forecast' buttion to generate the data table."),
                             helpText("[Note: the other widgets are not affecting the result]"),
                             tableOutput("table")),
                    # time series plot
                    tabPanel("Plot", 
                             h4("Usage of Plot tab:"),
                             helpText("You can plot data table of the google stock price in various ways"),
                             helpText("- Step1: Choose only either open, high, low or close price, or all of them. (CAUTION: combinations of two or three are not supported)."),
                             helpText("- Step2: Set the date range of the stock price that you like."),
                             helpText("- Step3: Select a technical indication that you would like to display with."),
                             helpText("   (for MA Convergence Divergence indicator case, you should choose all the open, high, low, and close price checkboxes to make it displayed.)"),
                             helpText("- Then, click 'GO for Table/Plot/Forecast' buttion to generate the Plot."),
                             helpText("[Note: the other widgets are not affecting the result]"),
                             plotOutput("plot")),
                    # Forecasting
                    tabPanel("Forecasting",
                             h4("Usage of Forecasting tab:"),
                             helpText("You can simulate a forecasting of the google stock price. Here, data is fixed as the close price, and aggregated as weekly data for a setup of the simulation."),
                             helpText("You can only control the date range of the stock price. Then, click 'GO for Table/Plot/Forecast' buttion to generate the Plot."),
                             helpText("[Note: the other widgets are not affecting the result]"),
                             br(),
                             helpText("You can see the forecasting price as a blue line and the actual price as a red line the result plot. he accuracy of the forecasting is shown below the plot."),

                             ## for forecasting plot
                             p('exponential filtering: multiplicative Holt-Winters method'),
                             plotOutput('plot2'),
                             ## for forecasting accuracy
                             p('Forecasting Accuracy:'),
                             tableOutput('table2')
                             )

        )

    )
))

