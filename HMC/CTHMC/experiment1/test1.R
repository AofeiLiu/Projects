inverse_temp <- function(u){
  result <- (1+ exp(-u))^(-1)
  return(result)
}

#inverse_temp1 <- function(u){
#  a <- abs((u + 1) % 2 - 1)
#  theta1 <- 5
#  theta2 <- 0.5
#  z <- (a - theta1) / (theta2 - theta1)
#  
#  if (z < 0){
#    f <- 1
#  }
#  else{
#    if (z >1){
#      f <- 0
#    }
#    else{
#      f <- 1 + cos(pi * z) / 2
#    }
#  }
#  return(f)
#}

log_jacobian <- function(u){
  u <- u/2
  result <- log(inverse_temp(u)) + log(1-inverse_temp(u))
  #result <- pracma::grad(inverse_temp,u)
  #result <- log(abs(result))
  return(result)
}

target <- function(q){
  result <- 1/4 * exp(- 0.5 * t(q - mean1) %*% solve(cov1) %*% (q-mean1)) + 3/4 * exp(-0.5 * t(q-mean2) %*% solve(cov2) %*% (q-mean2)) + 10 ^ (-5)
  return(result)
}

phi_func <- function(q){
  result <- - log(target(q))
  return(result)
}

prior_density <- function(q){
  result <- exp(- 0.5 * t(q - mean_p) %*% solve(cov_prior) %*% (q-mean_p))
  return(result)
}

psi_func <- function(q){
  result <- -log(prior_density(q))
  return(result)
}

U <- function(q){
  a <- matrix(q[1:nrow(q)-1,],ncol = ncol(q))
  u <- q[nrow(q),]
  result <- inverse_temp(u) * (phi_func(a)+log(norm_estimate)) + (1-inverse_temp(u)) * psi_func(a) - log_jacobian(u)
  return(result)
}

K <- function(p,mass){
  result <- 0.5 * (t(p)) %*% solve(mass) %*% p
  return(result)
}

grad_U <- function(q){
  result <- matrix(pracma::grad(U,q),ncol = ncol(q))
  return(result)
}


#data
dim1 <- 2

mean1 <- matrix(c(1,0), nrow = 2)
cov1 <- diag(dim1) * 0.1

mean2 <- matrix(c(-3,0), nrow = 2)
cov2 <- diag(dim1) * 0.1

norm_estimate <- 1/4 * sqrt((2*pi)^dim1 * det(cov1)) + 3/4 * sqrt((2*pi)^dim1 * det(cov2))

#setup

mass1 <- diag(dim1 + 1)

mean_p <- matrix(c(-1,0), nrow = 2)
cov_prior <- diag(dim1) * 4

x0_1 <- rmvnorm(1, mean = c(1,0), sigma = sqrt(cov1))

x0_1 <- t(x0_1)

temp_ini <- -5

x0_1 <- rbind(x0_1,temp_ini)

coeff =1

#Algotrithm

q_hist1 <- tempered_HMC(U,K,grad_U,epsilon=0.2,L=2,x0_1,mass1,coeff,n=2000,leapfrog_star)

#q_hist_acc1 <- matrix(q_hist1[apply(q_hist1,1,Compose(is.finite,all)),], ncol = dim1 + 1)
q_hist_acc1 <- na.omit(q_hist1)

x <- seq(from = -5,to = 3, length.out = 100)
y <- seq(from = -2,to = 2, length.out = 100)
out <- matrix(NA, nrow = 100, ncol = 100)

for (i in 1:length(x)){
  for (j in 1:length(y)){
    out[i,j] <- 1/4 * dmvnorm(c(x[i],y[j]), mean = mean1, sigma = sqrt(cov1))  + 3/4 * dmvnorm(c(x[i],y[j]), mean = mean2, sigma = sqrt(cov2))
  }
}

contour(x,y,out)
lines(x = q_hist_acc1[,1], y = q_hist_acc1[,2], type = "l")

q_hist_conv <- matrix(q_hist_acc1[inverse_temp(q_hist_acc1[,3]) > 0.95], ncol =3)

for (i in 1:length(x)){
  for (j in 1:length(y)){
    out[i,j] <- 1/4 * dmvnorm(c(x[i],y[j]), mean = mean1, sigma = sqrt(cov1))  + 3/4 * dmvnorm(c(x[i],y[j]), mean = mean2, sigma = sqrt(cov2))
  }
}

contour(x,y,out)
lines(x= q_hist_conv[,1], y = q_hist_conv[,2], type = "p")

q_data <- as.data.frame(q_hist_acc1)
colnames(q_data) <- c("q1","q2","u")
q_data$iters <- as.numeric(row.names(q_data))

ggplot(data = q_data, aes(x=iters,y=u)) +
  geom_line(color = "black") +
  geom_hline(aes(yintercept = 2.2), color = "red" ) +
  scale_y_continuous(breaks = c(-5,0,2.2,5,10)) +
  labs(x= "iterations", y = "temperature control variable")

ggplot(data = q_data, aes(x = iters, y = inverse_temp(u))) +
  geom_line(color = "black") +
  geom_hline(aes(yintercept = 0.9), color = "red" ) +
  scale_y_continuous(breaks = c(seq(0,1, by = 0.2),0.9)) +
  labs(x= "iterations", y = "inverse temperature")

acc_rate_v <- length(q_hist_conv[,3]) / length(q_hist_acc1[,3])

ess_t <- c()
ess_L_t <- c()

x_0 <- matrix(c(1.5564636, -0.80418881), ncol = 2)
x_0 <- t(x_0)
x_0 <- rbind(x_0,temp_ini)
q_hist1 <- tempered_HMC(U,K,grad_U,epsilon=1.1,L=15,x_0,mass1,coeff,n=2000,leapfrog_star)
q_hist_acc1 <- na.omit(q_hist1)
q_hist_conv1 <- matrix(q_hist_acc1[inverse_temp(q_hist_acc1[,3]) > 0.9], ncol =3)
q_hist_conv1

ess_t[1] <- ESS(q_hist_conv1)
ess_L_t[1] <- ESS(q_hist_conv1) / (nrow(q_hist_conv1) * 15)

ess_L <- c(6.846981,5.507111,6.197230,6.158362,6.704143,8.749486,4.265579,8.065649,5.587677,6.846981)

ess_Lm <- matrix(c(ess_L,ess_L_t), ncol = 1)

ess_Lm <- cbind(ess_Lm, matrix(c(rep("adaptive CTHMC",10), rep("CTHMC",10)), ncol = 1))
colnames(ess_Lm) <- c("val","method")

ess_data <- as.data.frame(ess_Lm)

ess_data$val <- as.numeric(ess_data$val)

ggplot(data = ess_data, aes(x = method, y = val)) +
  geom_boxplot(aes(fill = method)) +
  scale_y_continuous(name = "ESS/L", breaks = seq(0,20,2), limits = c(0,20)) +
  scale_x_discrete(name = "HMC samplers") +
  theme_bw() +
  theme(legend.position = "none")
  

#=================================Simple HMC=================================================

mass_simple <- diag(dim1) * 0.1

U_simple <- function(q){
  result <- - log(1/4 * exp(- 0.5 * t(q - mean1) %*% solve(cov1) %*% (q-mean1)) + 3/4 * exp(-0.5 * t(q-mean2) %*% solve(cov2) %*% (q-mean2)) + 10 ^ (-5))
  return(result)
}

K_simple <- function(p,mass){
  result <- t(p) %*% solve(mass) %*% p
  return(result)
}

grad_U_simple <- function(q){
  result <- pracma::grad(U_simple,q)
  return(result)
}

x0_simple <- rmvnorm(1, mean = c(1,0), sigma = sqrt(cov1))

x0_simple <- t(x0_simple)

q_hist_simple <- simple_HMC(U_simple,K_simple,grad_U_simple,epsilon=0.2,L=2,x0_simple,mass_simple,n=1000, leapfrog)

q_hist_acc_simple <- na.omit(q_hist_simple)

x <- seq(from = -5,to = 3, length.out = 100)
y <- seq(from = -2,to = 2, length.out = 100)
out <- matrix(NA, nrow = 100, ncol = 100)

for (i in 1:length(x)){
  for (j in 1:length(y)){
    out[i,j] <- 1/4 * dmvnorm(c(x[i],y[j]), mean = mean1, sigma = sqrt(cov1)) + 3/4 * dmvnorm(c(x[i],y[j]), mean = mean2, sigma = sqrt(cov2))
  }
}

contour(x,y,out)

lines(x = q_hist_acc_simple[,1], y = q_hist_acc_simple[,2], type = "l")

expend.grid