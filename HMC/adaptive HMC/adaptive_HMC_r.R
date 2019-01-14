leapfrog <- function(U,K,grad_U,epsilon, L, current_q,current_p, mass){
  q <- current_q
  p <- current_p
  
  p <- p - epsilon * grad_U(q) / 2
  
  for (i in 1:L){
    q = q + epsilon * p
    if (i != L){
      p <- p - epsilon * grad_U(q)
    }
  }
  
  p <- p - epsilon * grad_U(q) / 2
  p <- -p
  
  current_U <- U(current_q)
  current_K <- K(current_p, solve(mass))
  proposed_U <- U(q)
  proposed_K <- K(p, solve(mass))
  
  h <- current_U - proposed_U + current_K - proposed_K
  
  if (!is.na(h) & log(runif(1)) < h){
    return(q)
  }
  else{
    return(current_q)
  }
}

simple_HMC <- function(U,K,grad_U,epsilon,L,q_0,mass, coeff = 1, n, integrator){
  sample_q <- matrix(NA, n+1, ncol= ncol(t(q_0)))
  sample_q[1,] <- t(q_0)
  current_q <- q_0
  
  p_0 <- rmvnorm(1, mean = rep(0, nrow(mass)), sigma = mass)
  current_p <- t(p_0)
  
  accept_num <- 0
  
  for (i in 1:n){
    next_q <- integrator(U,K,grad_U,epsilon, L, current_q,current_p, mass)
    if (any(next_q != current_q)){
      sample_q[i+1,] <- t(next_q)
      accept_num <- accept_num + 1
    }
    else{
      sample_q[i+1,] <- t(next_q)
    }
    current_q <- next_q
    p_star <- t(rmvnorm(1, mean = rep(0, nrow(mass)), sigma = sqrt(mass)))
    current_p <- coeff * p_star + (1-coeff^2)^0.5 * current_p
  }
  #gamma_vec <- matrix(rep(c(epsilon,L), n), ncol = 2, byrow = TRUE)
  #sample_q <- cbind(sample_q, gamma_vec)
  #cat("acceptance rate = ", accept_num / n , "\n")
  return(sample_q)
}

norm_vector <- function(x){
  result <- sqrt(sum(x^2))
  return(result)
}

cov_func <- function(a,b,alpha,box_cons){
  cov_matrix <- diag(x = c((alpha * (box_cons[nrow(box_cons),1] - box_cons[1,1]))^2 , (alpha * (box_cons[nrow(box_cons),2] - box_cons[1,2]))^2))
  result <- exp(-0.5 * a %*% solve(cov_matrix) %*% t(t(b)))
  return(result)
}

UCB <- function(a, gamma_matrix, r_vec, sigma_noise, delta = 0.1, s, p, alpha, box_cons){ 
  # gamma_vec : i by 2 matrix
  # r_vec :1-dim matrix
  
  l <- nrow(gamma_matrix)
  
  k_vec <- matrix(NA, nrow = l, ncol = 1)
  cov_matrix <- matrix(NA, nrow = l, ncol = l)
  beta <- 2 * log((l+1)^(nrow(box_cons)/2 +2) * pi^2 / (3*delta))
  
  for (i in 1:l){
    k_vec[i,] <- cov_func(a,gamma_matrix[i,], alpha, box_cons)
    for (j in 1:l){
      cov_matrix[i,j] <- cov_func(gamma_matrix[i,],gamma_matrix[j,], alpha, box_cons)
    }
  }
  mu_func <- t(k_vec) %*% solve(cov_matrix + sigma_noise * diag(l)) %*% r_vec * s
  sigma_func <- cov_func(a,a, alpha, box_cons) - t(k_vec) %*% solve(cov_matrix + sigma_noise * diag(l)) %*% k_vec
  result <-  mu_func + p * sqrt(beta) * sigma_func
  return(result)
}

argmax <- function(input,func){
  #input: matrix
  outputs <- apply(input, 1,  func)
  result <- input[which.max(outputs),]
  return(result)
}

adaptive_HMC <- function(U, K, grad_U, gamma_0, q_0, mass, coeff = 1, n, integrator, m, sigma_noise, delta = 0.1, k, alpha, box_cons){
  #gamma:vector
  D <- matrix(NA, nrow = m*k, ncol = 3)
  cur_gamma <- gamma_0
  #sample_gamma <- matrix(NA, nrow = n+1, ncol = 2)
  #sample_gamma[1,] <- gamma_0
  acc_gamma <- 0
  
  sample_state <- matrix(t(q_0), nrow = 1)
  sample_state <- cbind(sample_state, matrix(cur_gamma,ncol=2))
  
  for (i in 1: m*k){
    eps <- cur_gamma[1]
    L <- cur_gamma[2]
    state <- simple_HMC(U,K,grad_U,eps,L,t(t(sample_state[nrow(sample_state),1:nrow(q_0)])), mass,coeff, m, integrator)
    state <- cbind(state, matrix(rep(cur_gamma, nrow(state)), ncol = 2, byrow = TRUE))
    sample_state <- rbind(sample_state, state)
    
    norm_vec <- c()
    for (j in 1:nrow(state)-1){
      norm_vec[j] <- (norm_vector(state[j+1,1:nrow(q_0)] - state[j,1:nrow(q_0)]))^2
    }
    
    r <- (1 / m) * sum(norm_vec) / sqrt(L) + rnorm(1, 0, sigma_noise)
    D[i,] <- c(eps,L,r)
    
    D_na_omit <- na.omit(D)
    if (nrow(D_na_omit) == 1){
      r_seq <- D_na_omit[1,3]
    }
    else{
      r_seq <- D_na_omit[1:nrow(D_na_omit)-1,3]
    }
    
    if (r > max(r_seq)){
      s <- alpha/r
    }
    else{
      s <- 1
    }
    
    u <- runif(1,min=0,max=1)
    p <- (max(i - k + 1, 1))^(-0.5)
    
    gamma_matrix <- matrix(na.omit(D)[, 1:2], ncol = 2)
    r_vec <- matrix(na.omit(D)[,3], ncol = 1)
    
    output <- c()
    if (u < p){
      for (v in 1:nrow(box_cons)){
        output[v] <-  UCB(box_cons[v,], gamma_matrix, r_vec, sigma_noise, delta = 0.1, s, p, alpha, box_cons)
      }
      #outputs <- apply(box_cons, 1,  UCB(a, gamma_matrix, r_vec, sigma_noise, delta = 0.1, k, s, p, alpha, box_cons))
      nxt_gamma <- box_cons[which.max(output),]
      #sample_gamma[i+1,] <- nxt_gamma
      acc_gamma <- acc_gamma + 1
    }
    else{
      nxt_gamma <- cur_gamma
    }
    cur_gamma <- nxt_gamma
  }
  eps <- cur_gamma[1]
  L <- cur_gamma[2]
  state <- simple_HMC(U,K,grad_U,eps,L,t(t(sample_state[nrow(sample_state),1:nrow(q_0)])), mass,coeff, n*m-m*k, integrator)
  state <- cbind(state, matrix(rep(cur_gamma, nrow(state)), ncol = 2, byrow = TRUE))
  sample_state <- rbind(sample_state, state)
  #cat("acceptance rate = ", acc_gamma / n , "\n")
  return(sample_state[2:nrow(sample_state), ])
}