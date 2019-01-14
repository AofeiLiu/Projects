library("mvtnorm")
library("functional")
library("pracma")
library("ggplot2")

leapfrog_star <- function(U,K,grad_U,epsilon, L, current_q,current_p, mass){
  
  q <- current_q
  p <- current_p
  
  p <- p - epsilon * grad_U(q) / 2
  
  for (i in 1:L){
    q <- q + epsilon * p
    
    if (i != L){
      p <-  p - epsilon * grad_U(q)
    }
  }
  
  p <- p - epsilon * grad_U(q) / 2
  
  p <- -p
  
  current_U <- U(current_q)
  current_K <- K(current_p, mass)
  proposed_U <- U(q)
  proposed_K <- K(p, mass)
  
  h <- current_U - proposed_U + current_K - proposed_K
  
  if (!is.na(h) & log(runif(1)) < h){
    return(q)
  }
  else{
    return(current_q)
  }
}

tempered_HMC <- function(U,K,grad_U,epsilon,L,q_0,mass,coeff = 1,n, integrator){
  sample_q <- matrix(NA, n+1, ncol= ncol(t(q_0)))
  sample_q[1,] <- t(q_0)
  current_q <- q_0
  
  p_0 <- rmvnorm(1, mean = rep(0, nrow(mass)), sigma = sqrt(mass))
  current_p <- t(p_0)
  
  accept_num <- 0
  
  for (i in 1:n){
    next_q <- integrator(U,K,grad_U,epsilon, L, current_q,current_p, mass)
    
    if (any(next_q != current_q)){
      sample_q[i+1,] <- t(next_q)
      accept_num <- accept_num + 1
    }
    current_q <- next_q
    p_star <- t(rmvnorm(1, mean = rep(0, nrow(mass)), sigma = sqrt(mass)))
    current_p <- coeff * p_star + (1-coeff^2)^0.5 * current_p
  }
  cat("acceptance rate = ", accept_num / n , "\n")
  return(sample_q)
}