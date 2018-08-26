Time Series Forecasting: Google stock price
========================================================

Yul Young Park

08/24/2018

- Shiny App: <https://yypark.shinyapps.io/shiny_proj/>

- Github repo: <https://github.com/yypark/ShinyStock>




Time series data
========================================================
Components of time series data 
- Seasonal component (S) 
- Trend-cycle component (T)
- Remainder component ( R)  

Composition types of the components
- Additive: S + T + R
- Multiplicative: S \* T \* R

Methods of time series forecasting
- Moving  average
- Exponential filtering
- Autoregressive integrated moving average (ARIMA)
- Advanced methods (Neural network, Bagging, Bootstrapping, etc)

As an example, we demonstrate ARIMA model, and exponential filtering model is shown in Shiny App.






ARIMA model, as an example here
========================================================

Three components of ARIMA model

- Auto Regression (AR) 
- Differencing(Integrated) 
- Moving Average(MA)


```r
library(quantmod)
library(forecast)
load("stock_data_google_2010_2016.RData")
weekly_GOOG <- to.weekly(GOOG[ "2013-01-01::2013-12-31"])
weekly_GOOG_closing <- Cl(weekly_GOOG)
ts1 <- ts(weekly_GOOG_closing, frequency=5)
```
***

```r
autoplot(ts1) # seasonal component adj. excluded due to aperiodicity
```

![plot of chunk unnamed-chunk-2](TimeSeriesForecasting-figure/unnamed-chunk-2-1.png)

Parameter Selection & Fitting a model
========================================================


```r
ts1 %>% diff() %>% ggtsdisplay(main="Differenced data")
```

![plot of chunk unnamed-chunk-3](TimeSeriesForecasting-figure/unnamed-chunk-3-1.png)
***

```r
fit <- Arima(ts1, order=c(6,3,7))
checkresiduals(fit)
```

![plot of chunk unnamed-chunk-4](TimeSeriesForecasting-figure/unnamed-chunk-4-1.png)

```

	Ljung-Box test

data:  Residuals from ARIMA(6,3,7)
Q* = 5.6726, df = 3, p-value = 0.1287

Model df: 13.   Total lags used: 16
```

ARIMA model: Forecasting and Accuracy
========================================================


```r
autoplot(forecast(fit))
```

![plot of chunk unnamed-chunk-5](TimeSeriesForecasting-figure/unnamed-chunk-5-1.png)
***

```r
print(accuracy(fit))
```

```
                    ME     RMSE      MAE      MPE     MAPE      MASE
Training set 0.7272524 11.19919 7.544993 0.131336 1.699653 0.3099237
                     ACF1
Training set -0.006435246
```
 
References:

-- <https://otexts.org/fpp2/>

-- <https://machinelearningmastery.com/time-series-forecasting/>

-- <https://www.r-bloggers.com/forecasting-stock-returns-using-arima-model/>
