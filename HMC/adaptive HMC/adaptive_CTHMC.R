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
  sample_q <- matrix(NA, n, ncol= ncol(t(q_0)))
  current_q <- q_0
  
  p_0 <- rmvnorm(1, mean = rep(0, nrow(mass)), sigma = sqrt(mass))
  current_p <- t(p_0)
  
  accept_num <- 0
  
  for (i in 1:n){
    next_q <- integrator(U,K,grad_U,epsilon, L, current_q,current_p, mass)
    if (any(next_q != current_q)){
      sample_q[i,] <- t(next_q)
      accept_num <- accept_num + 1
    }
    else{
      sample_q[i,] <- t(next_q)
    }
    current_q <- next_q
    p_star <- t(rmvnorm(1, mean = rep(0, nrow(mass)), sigma = sqrt(mass)))
    current_p <- coeff * p_star + (1-coeff^2)^0.5 * current_p
  }
  return(sample_q)
}

adaptive_CTHMC <- function(U, K, grad_U, gamma_0, q_0, mass, coeff = 1, n, integrator, m, sigma_noise, delta = 0.1, k, alpha, box_cons){
  #gamma:vector
  D <- matrix(NA, nrow = k, ncol = 3)
  cur_gamma <- gamma_0
  #sample_gamma <- matrix(NA, nrow = n+1, ncol = 2)
  #sample_gamma[1,] <- gamma_0
  acc_gamma <- 0
  
  sample_state <- matrix(t(q_0), nrow = 1)
  sample_state <- cbind(sample_state, matrix(cur_gamma,ncol=2))
  
  for (i in 1: k){
    eps <- cur_gamma[1]
    L <- cur_gamma[2]
    state <- tempered_HMC(U,K,grad_U,eps,L,t(t(sample_state[nrow(sample_state),1:nrow(q_0)])), mass,coeff, m, integrator)
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
      nxt_gamma <- box_cons[which.max(output),]
      acc_gamma <- acc_gamma + 1
    }
    else{
      nxt_gamma <- cur_gamma
    }
    cur_gamma <- nxt_gamma
  }
  eps <- cur_gamma[1]
  L <- cur_gamma[2]
  state <- tempered_HMC(U,K,grad_U,eps,L,t(t(sample_state[nrow(sample_state),1:nrow(q_0)])), mass,coeff, m*n-m*k, integrator)
  state <- cbind(state, matrix(rep(cur_gamma, nrow(state)), ncol = 2, byrow = TRUE))
  sample_state <- rbind(sample_state, state)
  
  return(sample_state)
}

inverse_temp <- function(u){
  result <- (1+ exp(-u))^(-1)
  return(result)
}

log_jacobian <- function(u){
  u <- u/2
  result <- log(inverse_temp(u)) + log(1-inverse_temp(u))
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

ESS <- function(q_data){
  a <- c(q_data[,1:(ncol(q_data)-3)])
  b <- acf(a)
  result <- nrow(q_data) * ( 1+ 2*sum(b$acf))
  return(result)
}


#===================================data====================================
dim1 <- 2

mean1 <- matrix(c(1,0), nrow = 2)
cov1 <- diag(dim1) * 0.1

mean2 <- matrix(c(-3,0), nrow = 2)
cov2 <- diag(dim1) * 0.1

norm_estimate <- 1/4 * sqrt((2*pi)^dim1 * det(cov1)) + 3/4 * sqrt((2*pi)^dim1 * det(cov2))

#====================================setup======================================

mass1 <- diag(dim1 + 1)

mean_p <- matrix(c(-1,0), nrow = 2)
cov_prior <- diag(dim1) * 4

coeff =1

alpha <- 0.2

k <- 20

m <- 20

n <- 100

eps_list <- seq(from = 0.1, to = 3, length.out = 30)

L_list <- seq(from = 5, to = 25, by= 1)

box_cons <- as.matrix(expand.grid(eps_list, L_list))

eps_0 <- sample(eps_list, size = 1)
L_0 <- sample(L_list, size = 1)
g_0 <- c(eps_0,L_0)

sigma_noise <- 1

temp_ini <- -5

ess <- c()
ess_L <- c()

x_data <- matrix(NA, nrow =10, ncol = 3)

for (i in 1:10){
  x0_1 <- rmvnorm(1, mean = c(1,0), sigma = sqrt(cov1))
  
  x0_1 <- t(x0_1)
  x0_1 <- rbind(x0_1,temp_ini)
  
  q_hist2 <- adaptive_CTHMC(U, K, grad_U, g_0, x0_1, mass1, coeff = 1, n, leapfrog_star, m, sigma_noise, delta = 0.1, k, alpha, box_cons)
  q_hist_acc2 <- unique(q_hist2[(m*k+1):n,])
  q_hist_conv2 <- matrix(q_hist_acc2[inverse_temp(q_hist_acc2[,3]) > 0.9], ncol =5)
  ess[i] <- ESS(q_hist_conv2)
  ess_L[i] <- ESS(q_hist_conv2) / sum(q_hist_conv2[,5])
  x_data[i,] <- t(x0_1)
}

for (i in 1:10){
  x0_1 <- t(x_data[i,])
  q_hist1 <- tempered_HMC(U,K,grad_U,epsilon=g_0[1],L=g_0[2],x0_1,mass1,coeff,n=2000,leapfrog_star)
  q_hist_acc1 <- na.omit(q_hist1)
  q_hist_conv1 <- matrix(q_hist_acc1[inverse_temp(q_hist_acc1[,3]) > 0.9], ncol =3)
  ess_t[i] <- ESS(q_hist_conv1)
  ess_L_t[i] <- ESS(q_hist_conv1) / (nrow(q_hist_conv1) * g_0[2])
}

my_data <- matrix(c(sort(ess_L), sort(ess_L_t)), ncol = 2)
my_data <- as.data.frame(my_data)

ggplot(my_data, aes(ess_L, ess_L_t)) + 
  geom_point() +
  scale_y_continuous(name = "CTHMC", breaks = seq(0,2,0.2), limits = c(0,2), expand = c(0,0)) +
  scale_x_continuous(name = "adaptive CTHMC", breaks = seq(0,10,2), limits = c(0,10), expand = c(0,0)) +
  coord_fixed(ratio = 5) +
  theme_bw() +
  geom_abline(slope = 1, color = "coral2", size = 1.2)

ggplot(my_data, aes(ess_L, ess_L_t)) + 
  geom_point() +
  scale_y_continuous(name = "CTHMC", breaks = seq(0,10,2), limits = c(0,10), expand = c(0,0)) +
  scale_x_continuous(name = "adaptive CTHMC", breaks = seq(0,10,2), limits = c(0,10), expand = c(0,0)) +
  coord_fixed(ratio = 1) +
  theme_bw() +
  geom_abline(slope = 1, color = "coral2", size = 1.2)

