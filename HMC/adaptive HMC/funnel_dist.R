target <- function(q){
  v <- q[1,]
  result <- 1
  for (i in 2:10){
    result <- result * exp(-0.5 * q[i,] / exp(v))
  }
  result <- exp(-0.5 * v^2 / 9) * result
  return(result)
}

U <- function(q){
  result <- -log(target(q))
  return(result)
}
K <- function(p,mass){
  result <- 0.5 * (t(p)) %*% solve(mass) %*% p
  return(result)
}

grad_U<- function(q){
  result <- matrix(pracma::grad(U,q),ncol = ncol(q))
  return(result)
}

calc_mean <- function(q, index, num){
  #q: n by 10 matrix
  #split q into num parts
  a <- q[,index]
  mean_val <- c()
  b <- split(a, ceiling(seq_along(a) / (length(a)/num)))
  print(b)
  for (i in 1: num){
    mean_val[i] <- mean(b[[i]])
  }
  return(mean_val)
}

  
#setup
dim <- 10

n = 100

alpha <- 0.1

k <- 20

m <- 20

sigma_noise <- 0.1

coeff =1

eps_list <- seq(from = 0.1, to = 3, length.out = 30)

L_list <- seq.int(from = 5, to = 25, by = 20)

box_cons <- as.matrix(expand.grid(eps_list, L_list))

mass <- diag(dim)

mean_p <- matrix(rep(0,9),nrow = 9)
cov_prior <- diag(dim-1)

v_0 <- 0

x_0 <- rmvnorm(1, mean = mean_p, sigma = sqrt(cov_prior))

x_0 <- c(v_0,x_0)

x_0 <- matrix(x_0, ncol = 1)

eps_0 <- sample(eps_list, size = 1)
L_0 <- sample(L_list, size = 1)

g_0 <- c(eps_0,L_0)

#Algotrithm
q_hist <- adaptive_HMC(U, K, grad_U, g_0, x_0, mass, coeff = 1, n, leapfrog, m, sigma_noise, delta = 0.1, k, alpha, box_cons)

q_hist_r_d <- unique(q_hist[(m*k+1):n,])
mean_v_d <- calc_mean(q = q_hist_r_d, index = 1, num = 20)

mean_v_df <- as.data.frame(mean_v_d)
colnames(mean_v_df) <- "mean_v"
mean_v_df$iterations <- as.numeric(row.names(mean_v_df))

ggplot(data = mean_v_df, aes(x=iterations, y = mean_v)) +
  geom_line(aes(color = "estimated mean")) +
  geom_hline(aes(yintercept = 0, linetype = "true mean"), color = "red" ) +
  scale_color_manual(name = "", values = c("estimated mean" = "black")) +
  scale_linetype_manual(name = "", values = c(1,1)) +
  scale_y_continuous(breaks = seq(floor(min(mean_v_d)), ceiling(max(mean_v_d)), by = 2)) +
  labs(x = "iterations", y = "mean value")











