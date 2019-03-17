library('dplyr')

#=======================================================================================================

#=========================================== daily return ==============================================

return_value <- function(adj_close){
  #dataset dates in ascending order
  output <- c()
  output[1] <- NA
  for (i in 2:length(adj_close)){
    output[i] <- (adj_close[i] - adj_close[i-1])/ adj_close[i-1]
  }
  return(output)
}

#=======================================================================================================

#=========================================== return_value ==============================================

full_data <- read.csv2("C:/Users/AoFei/Desktop/University of Torono/risk_lab/data2/full_data_tsx.csv")

str(full_data)

full_data[, 3:8] <- sapply(full_data[, 3:8], as.character)
full_data[, 3:8] <- sapply(full_data[, 3:8], as.numeric)

ticker_list <- unique(full_data$ticker)

return_val <- c()

for (i in 1:length(ticker_list)){
  company_data <- subset(full_data, ticker == ticker_list[i])
  company_data <- company_data[nrow(company_data):1,]
  adj_close_data <- company_data$adj_close_price
  return_val_company <- return_value(adj_close_data)
  return_val_company <- return_val_company[length(return_val_company):1]
  return_val <- c(return_val, return_val_company)
}

full_data <- cbind(full_data, return_val) #dates descending order

company_data_l <- list()

for (i in 1:length(ticker_list)){
  company_data_l[[i]] <- subset(full_data, ticker == ticker_list[i])
}

names(company_data_l) <- ticker_list

company_data_l$AD



#=======================================================================================================

#=============================================r_m - r_f=================================================

tsx_data <- read.csv2("C:/Users/AoFei/Desktop/University of Torono/risk_lab/data2/tsx.csv")

str(tsx_data)

tsx_data[, 2:ncol(tsx_data)] <- sapply(tsx_data[, 2:ncol(tsx_data)], as.character)

tsx_data[, 2:ncol(tsx_data)] <- sapply(tsx_data[, 2:ncol(tsx_data)], as.numeric)

tsx_value <- return_value(tsx_data$adj_close_price_total)

tsx_data <- cbind(tsx_data, tsx_value)

first_regressior <- data.frame(tsx_data$tsx_value - tsx_data$rate)

first_regressior <- cbind(tsx_data$dates, first_regressior)

colnames(first_regressior) <- c('dates', 'first_reg') #dates descending order

write.csv(first_regressior, file = 'C:/Users/AoFei/Desktop/University of Torono/risk_lab/data2/first_reg_data.csv')

#=======================================================================================================

#=============================================== SMB ===================================================
return_data <- full_data %>% select(company_name, ticker, dates, return_val)

levels(return_data$dates)

write.csv(return_data,file = 'C:/Users/AoFei/Desktop/University of Torono/risk_lab/data2/return_data.csv' )

SMB <- read.csv2("C:/Users/AoFei/Desktop/University of Torono/risk_lab/data2/smb.csv")

#=======================================================================================================

#=============================================== HML ===================================================

HML <- read.csv2("C:/Users/AoFei/Desktop/University of Torono/risk_lab/data2/hml.csv")
colnames(HML) <- c('dates','HML_val')




#=======================================================================================================

#============================================= ff model ================================================
first_regressior$first_reg <- as.factor(first_regressior$first_reg)

response_data <- list()

for (i in 1:length(ticker_list)){
  a <- company_data_l[[i]]
  a <- a %>% select(dates, company_name, ticker, industry, market_cap, return_val)
  a <- left_join(a, tsx_data , by = c('dates' = 'dates'))
  a <- left_join(a, first_regressior , by = c('dates' = 'dates'))
  a <- left_join(a, SMB , by = c('dates' = 'dates'))
  a <- left_join(a, HML , by = c('dates' = 'dates'))
  a$response_val <- a$return_val - a$rate
  a <- na.omit(a)
  response_data[[i]] <- a
  #response_data[[i]] <- cbind(a[match(tsx_data$dates, a$dates),], tsx_data$rate)
  #b <- response_data[[i]]
  #response_data[[i]] <- cbind(b[match(first_regressior$dates, b$dates),], first_regressior$first_reg)
  #c <- response_data[[i]]
  #response_data[[i]] <- cbind(b[match(SMB$dates, c$dates),], SMB$SMB_val)
  #d <- response_data[[i]]
  #response_data[[i]] <- cbind(c[match(HML$dates, d$dates),], HML$HML_val)
  #e <- response_data[[i]]
  #colnames(e) <- c('dates', 'company_name', 'ticker', 'industry', 'market_cap', 'return_val', 'rate', 'SMB', 'HML', 'f_reg')
}

names(response_data) <- ticker_list

AD <- response_data$AD

coef_ff <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(coef_ff) <- c('intercept', 'beta_1','beta_2','beta_3')

adj_r_ff <- data.frame(matrix(ncol = 1, nrow = 0))
colnames(adj_r_ff) <- c('adj_r_squared')

for (i in 1:length(ticker_list)){
  t <- response_data[[i]]
  t <- subset(t, is.finite(t$return_val))
  t$SMB_val <- as.character(t$SMB_val)
  t$HML_val <- as.character(t$HML_val)
  t$first_reg <- as.character(t$first_reg)
  t$SMB_val <- as.numeric(t$SMB_val)
  t$HML_val <- as.numeric(t$HML_val)
  t$first_reg <- as.numeric(t$first_reg)
  t <- subset(t, is.finite(t$first_reg))
  t <- subset(t, is.finite(t$SMB_val))
  t <- subset(t, is.finite(t$HML_val))
  fit <- lm(response_val ~ first_reg + SMB_val + HML_val, data = t,na.action = na.pass)
  coef_ff <- rbind(coef_ff, t(as.data.frame(fit$coefficients)))
  adj_r_ff <- rbind(adj_r_ff, as.data.frame(summary(fit)$adj.r.squared))
}

colnames(coef_ff) <- c('Intercept', 'Market_Premium', 'SMB_val', 'HML_val')
rownames(coef_ff) <- as.character(ticker_list)[1:18]
colnames(adj_r_ff) <- c('adj_r_squared')
rownames(adj_r_ff) <- as.character(ticker_list)[1:18]






