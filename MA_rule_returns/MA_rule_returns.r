library("quantmod")
GSPC_daily <- getSymbols(Symbols = "^GSPC", src = "yahoo", auto.assign = FALSE,
                         from = "2009-10-01", to = "2018-09-30")


GSPC_weekly <- getSymbols(Symbols = "^GSPC", src = "yahoo", auto.assign = FALSE,
                          from = "2009-10-01", to = "2018-09-30", periodicity = "weekly")

cat("daily S&P500 index", "\n")

summary(GSPC_daily)

cat("\n","\n")
cat("weekly S&P500 index", "\n")

summary(GSPC_weekly)

X_func <- function(price){
  x_vec <- c()
  for (i in 1: length(price)-1){
    x_vec[i] <- log(price[i] / price[i+1])
  }
  return(x_vec)
}

intergrand <- function(x){
  res <- (sqrt(2 * pi))^(-1) * exp(-x^2 / 2)
  return(res)
}

phi_func <- function(h){
  res <- integrate(intergrand, lower = -Inf, upper = h)$value
  return(res)
}

d_func <- function(m,r){
  res <- c()
  for (i in 1: (r)){
    res[i] <-(m-r) * (i)
  }
  for (i in (r+1):(m-1)){
    res[i] <- r * (m-i)
  }
  return(res)
}

sigma_f_func <- function(m, r, gamma_x){
  d <- d_func(m,r)
  res <- 0
  for (i in 1: (m-1)){
    for (j in 1: (m-1)){
      res <- res + d[i] * d[j] * gamma_x[abs(i-j)+1]
    }
  }
  res <- sqrt(res)
  return(res)
}

mu_f_func <- function(m,r,mu_x){
  d <- d_func(m,r)
  res <- sum(d) * mu_x
  return(res)
}

corr_xf_func <- function(m,r,gamma_x){
  d <- d_func(m,r)
  a <- sigma_f_func(m,r,gamma_x)
  res <- sum(d * gamma_x[2:m]) / (sqrt(gamma_x[1]) * a)
  return(res)
}

expectation <- function(s,m,r){
  GSPC_rev <- as.data.frame(s)
  GSPC_rev <- GSPC_rev[dim(GSPC_rev)[1]:1,]

  x <- X_func(GSPC_rev$GSPC.Adjusted)
  mu_x <- mean(x)
  sigma_x <- sd(x)
  gamma_x <- as.numeric(acf(x, type = "covariance", plot=FALSE, lag.max = length(x))$acf)

  d <- d_func(m,r)
  mu_f <- mu_f_func(m,r,mu_x)
  sigma_f <- sigma_f_func(m,r,gamma_x)
  frac_f <- mu_f / sigma_f
  phi <- phi_func(-frac_f)
  corr <- corr_xf_func(m,r,gamma_x)
  ert <- sqrt(2/pi) * sigma_x * corr * exp(-0.5 * (frac_f ^ 2)) + mu_x * (1 - 2*phi)

  h <- 0
  d <- d_func(m,r)
  for (i in 1: (m-1)){
    for (j in 1: (m-1)){
      h <- h + d[i] * d[j] * gamma_x[abs(i-j-1)+1]
    }
  }
  h <- h / (sigma_f ^2)
  h <- pi / acos(h)

  return(list(ert = ert, h = h))
}

pair <- function(m_max){
  m <- seq(3,m_max,by=1)
  p <- list()
  for (i in 1:length(m)){
    a <- seq(1,m[i]-2,by=1)
    p[[i]] <- expand.grid(m[i],a)
  }
  res <- do.call(rbind, p)
  colnames(res) <- c("m","r")
  return(res)
}

optimal_rt <- function(s,m_max){
  pair_mr <- pair(m_max)
  expected_return_vec <- c()
  for (i in 1: nrow(pair_mr)){
    m_iter <- as.numeric(pair_mr[i,])[1]
    r_iter <- as.numeric(pair_mr[i,])[2]
    expected_return_vec[i] <- expectation(s,m_iter,r_iter)[1]
  }
  max_mr <- pair_mr[which.max(expected_return_vec),]
  return(max_mr)
}

m_max_day <- 50
mr <- optimal_rt(GSPC_daily, m_max_day)
m_max_week <- 52
mr_w <- optimal_rt(GSPC_weekly, m_max_week)

cat("daily S&P500 index","\n")
cat("mr pair", "(", as.numeric(mr[1]), ",", as.numeric(mr[2]),
    ")", "has highest E(Rt)", "\n", "\n")

cat("weekly S&P500 index","\n")
cat("mr pair", "(", as.numeric(mr_w[1]), ",", as.numeric(mr_w[2]),
    ")", "has highest E(Rt)", "\n")


trading_statistics <- function(s,m,r){
  GSPC_rev <- as.data.frame(s)
  GSPC_rev <- GSPC_rev[dim(GSPC_rev)[1]:1,]
  price <- GSPC_rev$GSPC.Adjusted
  x <- X_func(price)
  n <- length(price) - (m-1)
  d <- d_func(n+1,r)
  f <- c()
  for (i in 1:(n)){
    f[i] <- sum(d[i:n] * x[(i+1):(n+1)])
  }
  b <- ifelse(f > 0, 1, -1)
  sum_r_t <- sum(b * x[1:n])
  res <- sum_r_t / n
  count <-  sum(diff(sign(b)) != 0)
  count <- n/count
  return(list(crt=res, avht = count))
}

expect_return_d <- expectation(GSPC_daily, as.numeric(mr)[1], as.numeric(mr)[2])$ert
expect_holding_time <- expectation(GSPC_daily, as.numeric(mr)[1], as.numeric(mr)[2])$h
cumulative_return_d <-  trading_statistics(GSPC_daily, as.numeric(mr)[1], as.numeric(mr)[2])$crt
average_holding <-  trading_statistics(GSPC_daily, as.numeric(mr)[1], as.numeric(mr)[2])$avht

cat("daily S&P500 index","\n")
cat("theoretical cumulative return:" ,expect_return_d, "\n")
cat("sample cumulative return:", cumulative_return_d,"\n","\n")

cat("theoretical holding time:", expect_holding_time,"\n")
cat("sample holding time:", average_holding,"\n","\n")

expect_return_w <- expectation(GSPC_weekly, as.numeric(mr_w)[1], as.numeric(mr_w)[2])$ert
expect_holding_time_w <- expectation(GSPC_weekly, as.numeric(mr_w)[1], as.numeric(mr_w)[2])$h
cumulative_return_w <- trading_statistics(GSPC_weekly, as.numeric(mr_w)[1], as.numeric(mr_w)[2])$crt
average_holding_w <- trading_statistics(GSPC_weekly, as.numeric(mr_w)[1], as.numeric(mr_w)[2])$avht


cat("weekly S&P500 index","\n")
cat("theoretical cumulative return:" ,expect_return_w, "\n")
cat("sample cumulative return:", cumulative_return_w,"\n","\n")

cat("theoretical holding time:", expect_holding_time_w,"\n")
cat("sample holding time:", average_holding_w,"\n")
