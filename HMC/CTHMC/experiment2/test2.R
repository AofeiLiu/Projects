tempered_HMC_e2 <- function(U,K,grad_U,epsilon,L,q_0,mass,coeff = 1,n, integrator){
  sample_q <- matrix(NA, n+1, ncol= ncol(t(q_0)))
  sample_q[1,] <- t(q_0)
  current_q <- q_0
  
  p_0 <- rmvnorm(1, mean = rep(0, nrow(mass)), sigma = sqrt(mass))
  current_p <- t(p_0)
  
  accept_num <- 0
  
  v <- sample_q[1,1]
  mean_v <- c()
  
  for (i in 1:n){
    next_q <- integrator(U,K,grad_U,epsilon, L, current_q,current_p, mass)
    
    if (any(next_q != current_q)){
      sample_q[i+1,] <- t(next_q)
      accept_num <- accept_num + 1
      v[i+1] <- sample_q[i+1,1]
    }
    
    else{
      v[i+1] <- NA
    }
    
    mean_v[i] <- mean(v[!is.na(v)])
    
    
    current_q <- next_q
    p_star <- t(rmvnorm(1, mean = rep(0, nrow(mass)), sigma = mass))
    current_p <- coeff * p_star + (1-coeff^2)^0.5 * current_p
  }
  cat("acceptance rate = ", accept_num / n , "\n")
  return(mean_v)
}

library("ggplot2")

inverse_temp2 <- function(u){
  result <- (1+ exp(-u))^(-1)
  return(result)
}

log_jacobian2 <- function(u){
  u <- u/2
  result <- log(inverse_temp2(u)) + log(1-inverse_temp2(u))
  return(result)
}

phi_func2 <- function(q){
  result <- - log(target2(q))
  return(result)
}

psi_func2 <- function(q){
  result <- -log(prior_density2(q))
  return(result)
}

target2 <- function(q){
  v <- q[1,]
  result <- 0
  for (i in 2:10){
    result <- result + exp(-0.5 * q[i,] / exp(v))
  }
  result <- exp(-0.5 * v^2 / 9) + result
  return(result)
}

prior_density2 <- function(q){
  v <- q[1,]
  result <- exp(- 0.5 * t(q - mean_p2) %*% solve(cov_prior2) %*% (q-mean_p2))
  return(result)
}

U2 <- function(q){
  a <- matrix(q[1:nrow(q)-1,],ncol = ncol(q))
  u <- q[nrow(q),]
  result <- inverse_temp2(u) * phi_func2(a) + (1-inverse_temp2(u)) * psi_func2(a) - log_jacobian2(u)
  return(result)
}

K2 <- function(p,mass){
  result <- 0.5 * (t(p)) %*% solve(mass) %*% p
  return(result)
}

grad_U2<- function(q){
  result <- matrix(pracma::grad(U2,q),ncol = ncol(q))
  return(result)
}

dim2 <- 10

#setup

mass2 <- diag(dim2 + 1)

mean_p2 <- matrix(rep(0,10),nrow = 10)
cov_prior2 <- diag(dim2)

x0_2 <- rmvnorm(1, mean = mean_p2, sigma = sqrt(cov_prior2))

x0_2 <- t(x0_2)

temp_ini2 <- -100

x0_2 <- rbind(x0_2,temp_ini2)

coeff2 =1

#Algotrithm

mean_v_d <- tempered_HMC_e2(U2,K2,grad_U2,epsilon=0.1,L=2,x0_2,mass2,coeff2,n=5000,leapfrog_star)

mean_v_d <- tempered_HMC_e2(U2,K2,grad_U2,epsilon=0.2,L=2,x0_2,mass2,coeff2,n=5000,leapfrog_star)

mean_v_d <- tempered_HMC_e2(U2,K2,grad_U2,epsilon=0.3,L=2,x0_2,mass2,coeff2,n=5000,leapfrog_star)

#mean_v_d <- tempered_HMC_e2(U2,K2,grad_U2,epsilon=0.7,L=2,x0_2,mass2,coeff2,n=3000,leapfrog_star)

#mean_v_d <- tempered_HMC_e2(U2,K2,grad_U2,epsilon=1,L=2,x0_2,mass2,coeff2,n=3000,leapfrog_star)

#mean_v_d <- tempered_HMC_e2(U2,K2,grad_U2,epsilon=0.2,L=20,x0_2,mass2,coeff2,n=3000,leapfrog_star)

mean_v_df <- as.data.frame(mean_v_d)
colnames(mean_v_df) <- "mean_v"
mean_v_df$iterations <- as.numeric(row.names(mean_v_df))

ggplot(data = mean_v_df, aes(x=iterations, y = mean_v)) +
  geom_line(aes(color = "estimated mean")) +
  geom_hline(aes(yintercept = 0, linetype = "true mean"), color = "red" ) +
  scale_color_manual(name = "", values = c("estimated mean" = "black")) +
  scale_linetype_manual(name = "", values = c(1,1)) +
  scale_y_continuous(breaks = seq(floor(min(mean_v_d)), ceiling(max(mean_v_d)), by = 0.2)) +
  labs(x = "iterations", y = "mean value")



# ========================================Simple HMC===============================================
simple_HMC_e2 <- function(U,K,grad_U,epsilon,L,q_0,mass,n, integrator){
  sample_q <- matrix(NA, n+1, ncol= ncol(t(q_0)))
  sample_q[1,] <- t(q_0)
  current_q <- q_0
  
  accept_num <- 0
  
  v <- sample_q[1,1]
  mean_v <- c()
  
  for (i in 1:n){
    next_q <- integrator(U,K,grad_U,epsilon, L, current_q, mass)
    
    if (any(next_q != current_q)){
      sample_q[i+1,] <- t(next_q)
      accept_num <- accept_num + 1
      v[i+1] <- sample_q[i+1,1]
    }
    
    else{
      v[i+1] <- NA
    }
    mean_v[i] <- mean(v[!is.na(v)])
    current_q <- next_q
  }
  cat("acceptance rate = ", accept_num / n , "\n")
  return(mean_v)
}

U2_simple <- function(q){
  v <- q[1,]
  result <- 0
  for (i in 2:10){
    result <- result + exp(-0.5 * q[i,] / exp(v))
  }
  result <- exp(-0.5 * v^2 / 9) + result
  result <- -log(result)
  return(result)
}

grad_U2_simple<- function(q){
  result <- matrix(pracma::grad(U2_simple,q),ncol = ncol(q))
  return(result)
}

K2_simple <- function(p,mass){
  result <- 0.5 * (t(p)) %*% solve(mass) %*% p
  return(result)
}

mass2_simple <- diag(dim2)

x0_simple <- rmvnorm(1, mean = mean_p2, sigma = sqrt(cov_prior2))

x0_simple <- matrix(x0_2[1:nrow(x0_2)-1,],ncol = 1)

mean_v_d <- simple_HMC_e2(U2_simple,K2_simple,grad_U2_simple,epsilon=0.3,L=2,x0_2simple,mass2_simple,n=3000,leapfrog)

mean_v_df <- as.data.frame(mean_v_d)
colnames(mean_v_df) <- "mean_v"
mean_v_df$iterations <- as.numeric(row.names(mean_v_df))

ggplot(data = mean_v_df, aes(x=iterations, y = mean_v)) +
  geom_line(aes(color = "estimated mean")) +
  geom_hline(aes(yintercept = 0, linetype = "true mean"), color = "red" ) +
  scale_color_manual(name = "", values = c("estimated mean" = "black")) +
  scale_linetype_manual(name = "", values = c(1,1)) +
  scale_y_continuous(breaks = seq(floor(min(mean_v_d)), ceiling(max(mean_v_d)), by = 0.2)) +
  labs(x = "iterations", y = "mean value")


