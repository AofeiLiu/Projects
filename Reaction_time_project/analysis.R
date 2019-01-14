library(tidyverse)
library(readxl)
library(lme4)
library(ggplot2)
library(sjPlot)
library(sjmisc)


#==============================================check correlation and effect==========================================

ggplot(rt4903, aes(x=numtime, y= log(seconds))) +
    geom_point() +
    geom_smooth(se=F)

ggplot(rt4903, aes(x= hunger, y= log(seconds))) +
  geom_point() +
  geom_smooth(se=F)

ggplot(rt4903, aes(x=fatigue, y= log(seconds))) +
  geom_point() +
  geom_smooth(se=F)

ggplot(rt4903, aes(x=MEQ, y= log(seconds))) +
  geom_point() +
  geom_smooth(se=F)

ggplot(rt4903, aes(x=sleep, y= log(seconds))) +
  geom_point() +
  geom_smooth(se=F)


# Check correlation between different features
predata <- rt4902 %>% select(busy_light, stimulant, hunger, fatigue,MEQ,sleep,illness)
predata$busy_light <- as.numeric(predata$busy_light)
predata$stimulant <- as.numeric(predata$stimulant)
predata$illness <- as.numeric(predata$illness)
predata$hunger2 <- predata$hunger ^2

cor(x = rt4902$seconds, y = predata %>% as.matrix, use = "complete.obs") %>% t()

#=================================================interaction analysis===============================================

#null model
logm_null <- lmer(log(seconds) ~ (1|ID), data = rt4903, REML = FALSE)
logm_numtime <-lmer(log(seconds)~ numtime + (1|ID), data = rt4903, REML = FALSE)
anova(logm_null, logm_numtime) #p = 0.07977

#Stimulant: quantitative time
logm_sti_inter <- lmer(log(seconds) ~ numtime*stimulant+ (1|ID), data = rt4903, REML = FALSE)
logm_sti_add <- lmer(log(seconds) ~ numtime + stimulant + (1|ID), data = rt4903, REML = FALSE)
anova(logm_sti_inter, logm_sti_add) #p = 0.9616

#fatigue: quantitative time
logm_fat_inter <- lmer(log(seconds) ~ numtime*fatigue+ (1|ID), data = rt4903, REML = FALSE)
logm_fat_add <-lmer(log(seconds) ~ numtime + fatigue + (1|ID), data = rt4903, REML = FALSE)
anova(logm_fat_inter, logm_fat_add) #p = 0.8373


#hunger: quantitative time ##################
logm_hunger_inter <- lmer(log(seconds) ~ numtime*hunger^2+ (1|ID), data = rt4903, REML = FALSE)
logm_hunger_add <-lmer(log(seconds) ~ numtime + hunger^2 + (1|ID), data = rt4903, REML = FALSE)
anova(logm_hunger_inter, logm_hunger_add) #p = 0.3285


#ill: quantitative time
logm_illness_inter <- lmer(log(seconds) ~ numtime*illness+ (1|ID), data = rt4903, REML = FALSE)
logm_illness_add <-lmer(log(seconds) ~ numtime + illness + (1|ID), data = rt4903, REML = FALSE)
anova(logm_illness_inter, logm_illness_add) #p = 0.8173


#MEQ: quantitative time and quantitative MEQ
logm_MEQ_inter <- lmer(seconds ~ numtime*MEQ + (1|ID), data = rt4903, REML = FALSE)
logm_MEQ_add <-lmer(seconds ~ numtime + MEQ + (1|ID), data = rt4903, REML = FALSE)
anova(logm_MEQ_inter, logm_MEQ_add) #p = 0.9149

#IMEQ3: quantitative time and categorical MEQ
logm_IMEQ3_inter <- lmer(log(seconds) ~ numtime*IMEQ3+ (1|ID), data = rt4903, REML = FALSE)
logm_IMEQ3_add<-lmer(log(seconds) ~ numtime + IMEQ3 + (1|ID), data = rt4903, REML = FALSE)
anova(logm_IMEQ3_inter, logm_IMEQ3_add) #p = 0.3974

#protocol: quantative time
logm_proto_inter <- lmer(log(seconds) ~ numtime*protocol+ (1|ID), data = rt4903, REML = FALSE)
logm_proto_add <-lmer(log(seconds)~ numtime + protocol + (1|ID), data = rt4903, REML = FALSE)
anova(logm_proto_inter, logm_proto_add) #p = 0.0680

#======================================================= fit model ===============================================================================

full_logmodel <- lmer(log(seconds) ~ numtime + stimulant + fatigue + hunger^2 + busy_light + illness + sleep + protocol + MEQ  + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

full_logmodel2 <- lmer(log(seconds) ~ stimulant + fatigue + hunger^2 + busy_light + illness + sleep + protocol + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_sti_r <- lmer(log(seconds) ~ numtime + fatigue + hunger^2 + busy_light + illness + sleep + protocol + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_fat_r<- lmer(log(seconds) ~ numtime + hunger^2 + busy_light + illness + sleep + protocol + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_h_r<- lmer(log(seconds) ~ numtime + fatigue +busy_light + illness + sleep + protocol + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_busy_r<- lmer(log(seconds) ~ numtime + fatigue+ illness + sleep +protocol + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_ill_r<- lmer(log(seconds) ~ numtime+ fatigue + sleep+ protocol + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_sleep_r<- lmer(log(seconds) ~ numtime + fatigue +protocol +MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

logm_proto_r<- lmer(log(seconds) ~ numtime + fatigue  + MEQ + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

#======== fitted model
logm_MEQ_r<- lmer(log(seconds) ~ numtime +fatigue + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)
#========

anova(logm_MEQ_r, logm_proto_r)

#================================================================ numtime ====================================================================

research_qeslogY3 <-lmer(log(seconds) ~ numtime + (1|ID), data = rt4903, REML = FALSE)

#check leverage
ggplot(rt4903, aes(x=numtime, y = log(seconds))) +
  geom_point(size = 1) +
  geom_line(aes(y=predict(research_qeslogY3), group = ID,color=ID))

leverage3 <- data.frame(lev = hatvalues(research_qeslogY3), pearson = residuals(research_qeslogY3, type = "pearson"))

ggplot(leverage3, aes(x=lev, y=pearson)) +
  geom_point() +
  geom_vline(xintercept = 0.135, color = "firebrick2", size = 1) +
  geom_hline(yintercept = -0.75, color = "dodgerblue1", size = 1) +
  xlab("leverage") +
  ylab("residual") +
  theme_bw()

#remove influential point
datalev3 <- rt4903[which(hatvalues(research_qeslogY3) < 0.135),]

#compare estimaters
research_qeslogY_lev3 <- lmer(log(seconds) ~ numtime + (1|ID), data=datalev3)
research_qeslogY_levCD3 <- data.frame(effect=fixef(research_qeslogY3),
                                      change=(fixef(research_qeslogY_lev3) - fixef(research_qeslogY3)),
                                      se=sqrt(diag(vcov(research_qeslogY3))))

rownames(research_qeslogY_levCD3) <- names(fixef(research_qeslogY_lev3))
research_qeslogY_levCD3$multiples <- abs(research_qeslogY_levCD3$change / research_qeslogY_levCD3$se)
research_qeslogY_levCD3

#remove outliers
dataout3 <- rt4903[which(residuals(research_qeslogY3, type = "pearson") > -0.75),]

#compare estimaters
research_qeslogY_out3 <- lmer(log(seconds) ~ numtime + (1|ID), data=dataout3)
research_qeslogY_outCD3 <- data.frame(effect=fixef(research_qeslogY3),
                                      change=(fixef(research_qeslogY_out3) - fixef(research_qeslogY3)),
                                      se=sqrt(diag(vcov(research_qeslogY3))))

rownames(research_qeslogY_outCD3) <- names(fixef(research_qeslogY_out3))
research_qeslogY_outCD3$multiples <- abs(research_qeslogY_outCD3$change / research_qeslogY_outCD3$se)
research_qeslogY_outCD3

#Check normality
#before removing outlier

research_q <- data.frame(r = residuals(research_qeslogY3))
ggplot(research_q, aes(x=r)) +
  geom_histogram(color = "black", fill ="grey") +
  stat_function(fun=dnorm,color="firebrick2", args=list(mean=mean(research_q$r), sd=sd(research_q$r)), size = 1)

ggplot(research_q, aes(sample=r)) +
  stat_qq() +
  stat_qq_line(color = "firebrick2", size = 1) +
  xlab("sample quatile") +
  ylab("theoritical quantile")

#after removing outlier

research_q_out_df <- data.frame(r = residuals(research_qeslogY_out3))

ggplot(research_q_out_df, aes(x=r)) +
  geom_histogram(color = "black", fill ="grey") +
  stat_function(fun=dnorm,color="firebrick2", args=list(mean=mean(research_q_out_df$r), sd=sd(research_q_out_df$r)), size = 1)

ggplot(research_q_out_df, aes(sample=r)) +
  stat_qq() +
  stat_qq_line(color = "firebrick2", size = 1)


#Constant variance
#before removing outliers
cv1 <- data.frame(fit = predict(research_qeslogY3), pearson = residuals(research_qeslogY3, type = "pearson"))
ggplot(cv1, aes(fit, pearson)) +
  geom_point() +
  geom_hline(yintercept = 0, color= "firebrick2", size = 1)

#after removing outliers
cv <- data.frame(fit = predict(research_qeslogY_out3), pearson = residuals(research_qeslogY_out3, type = "pearson"))
ggplot(cv, aes(fit, pearson)) +
  geom_point() +
  geom_hline(yintercept = 0, color= "firebrick2", size = 1)


#============================================================== final model ==================================================================================

loglme <- lmer(log(seconds) ~ numtime + fatigue + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

#check leverage
ggplot(rt4903, aes(x=numtime, y = log(seconds))) +
  geom_point(size = 1) +
  geom_line(aes(y=predict(loglme), group = ID,color=ID))

leverage_loglme <- data.frame(lev = hatvalues(loglme), pearson = residuals(loglme, type = "pearson"))

ggplot(leverage_loglme, aes(x=lev, y=pearson)) +
  geom_point() +
  geom_vline(xintercept = 0.152, color = "firebrick2", size = 1) +
  geom_hline(yintercept = -0.5, color = "dodgerblue1", size = 1) +
  xlab("leverage") +
  ylab("residual") +
  theme_bw()

#remove influential point
datalev_r <- rt4903[which(hatvalues(loglme) < 0.152),]

#compare estimaters
loglme_lev <- lmer(log(seconds) ~ numtime + fatigue + (1|ID), data=datalev_r)
loglme_levdf <- data.frame(effect=fixef(loglme),
                                      change=(fixef(loglme_lev) - fixef(loglme)),
                                      se=sqrt(diag(vcov(loglme))))

rownames(loglme_levdf) <- names(fixef(loglme))
loglme_levdf$multiples <- abs(loglme_levdf$change / loglme_levdf$se)
loglme_levdf

#remove outliers
dataout_r <- rt4903[which(residuals(loglme, type = "pearson") > -0.5),]

#compare estimaters
loglme_out_r <- lmer(log(seconds) ~ numtime + fatigue + (1|ID), data=dataout_r)
loglme_out_rdf <- data.frame(effect=fixef(loglme),
                                      change=(fixef(loglme_out_r) - fixef(loglme)),
                                      se=sqrt(diag(vcov(loglme))))

rownames(loglme_out_rdf) <- names(fixef(loglme))
loglme_out_rdf$multiples <- abs(loglme_out_rdf$change / loglme_out_rdf$se)
loglme_out_rdf

#Check normality
#before removing outlier
r_df <- data.frame(r = residuals(loglme))
ggplot(r_df, aes(x=r)) +
  geom_histogram(color = "black", fill ="grey") +
  stat_function(fun=dnorm,color="firebrick2", args=list(mean=mean(r_df$r), sd=sd(r_df$r)), size = 1)

ggplot(r_df, aes(sample=r)) +
  stat_qq() +
  stat_qq_line(color = "firebrick2", size = 1) +
  xlab("sample quatile") +
  ylab("theoritical quantile")

#after removing outlier
r_out_df <- data.frame(r = residuals(loglme_out_r))
ggplot(r_out_df, aes(x=r)) +
  geom_histogram(color = "black", fill ="grey") +
  stat_function(fun=dnorm,color="firebrick2", args=list(mean=mean(r_out_df$r), sd=sd(r_out_df$r)), size = 1)

ggplot(r_out_df, aes(sample=r)) +
  stat_qq() +
  stat_qq_line(color = "firebrick2", size = 1)

cvar_df <- data.frame(fit = predict(loglme), pearson = residuals(loglme, type = "pearson"))
ggplot(cvar_df, aes(fit, pearson)) +
  geom_point() +
  geom_hline(yintercept = 0, color= "firebrick2", size = 1)

cvar_out_rdf <- data.frame(fit = predict(loglme_out_r), pearson = residuals(loglme_out_r, type = "pearson"))
ggplot(cvar_out_rdf, aes(fit, pearson)) +
  geom_point() +
  geom_hline(yintercept = 0, color= "firebrick2", size = 1)

#===================================================================================================================================================

loglme2 <- lmer(log(seconds) ~ numtime + protocol:numtime + (1|ID), data = rt4903, REML = FALSE)

#check leverage
ggplot(rt4903, aes(x=protocol, y = seconds)) +
  geom_point(size = 1) +
  geom_line(aes(y=predict(loglme2), group = ID,color=ID))

leverage_loglme2 <- data.frame(lev = hatvalues(loglme2), pearson = residuals(loglme2, type = "pearson"))

ggplot(leverage_loglme2, aes(x=lev, y=pearson)) +
  geom_point() +
  geom_vline(xintercept = 0.25, color = "firebrick2", size = 1) +
  geom_hline(yintercept = -0.5, color = "dodgerblue1", size = 1) +
  xlab("leverage") +
  ylab("residual") +
  theme_bw()

#remove influential point
datalev_r2 <- rt4903[which(hatvalues(loglme2) < 0.25),]

#compare estimaters
loglme_lev2 <- lmer(log(seconds) ~ numtime * protocol + (1|ID), data=datalev_r2)
loglme_levdf2 <- data.frame(effect=fixef(loglme2),
                           change=(fixef(loglme_lev2) - fixef(loglme2)),
                           se=sqrt(diag(vcov(loglme2))))

rownames(loglme_levdf2) <- names(fixef(loglme2))
loglme_levdf2$multiples <- abs(loglme_levdf2$change / loglme_levdf2$se)
loglme_levdf2

#remove outliers
dataout_r2 <- rt4903[which(residuals(loglme2, type = "pearson") > -0.5),]

#compare estimaters
loglme_out_r2 <- lmer(log(seconds) ~ numtime + protocol:numtime + (1|ID), data=dataout_r2)
loglme_out_rdf2 <- data.frame(effect=fixef(loglme2),
                             change=(fixef(loglme_out_r2) - fixef(loglme2)),
                             se=sqrt(diag(vcov(loglme2))))

rownames(loglme_out_rdf2) <- names(fixef(loglme2))
loglme_out_rdf2$multiples2 <- abs(loglme_out_rdf2$change / loglme_out_rdf2$se)
loglme_out_rdf2

#Check normality
#before removing outlier
r_df2 <- data.frame(r = residuals(loglme2))
ggplot(r_df2, aes(x=r)) +
  geom_histogram(color = "black", fill ="grey") +
  stat_function(fun=dnorm,color="firebrick2", args=list(mean=mean(r_df2$r), sd=sd(r_df2$r)), size = 1)

ggplot(r_df2, aes(sample=r)) +
  stat_qq() +
  stat_qq_line(color = "firebrick2", size = 1) +
  xlab("sample quatile") +
  ylab("theoritical quantile")

#after removing outlier
r_out_df2 <- data.frame(r = residuals(loglme_out_r2))
ggplot(r_out_df2, aes(x=r)) +
  geom_histogram(color = "black", fill ="grey") +
  stat_function(fun=dnorm,color="firebrick2", args=list(mean=mean(r_out_df2$r), sd=sd(r_out_df2$r)), size = 1)

ggplot(r_out_df2, aes(sample=r)) +
  stat_qq() +
  stat_qq_line(color = "firebrick2", size = 1)


cvar_df2 <- data.frame(fit = predict(loglme2), pearson = residuals(loglme2, type = "pearson"))
ggplot(cvar_df2, aes(fit, pearson)) +
  geom_point() +
  geom_hline(yintercept = 0, color= "firebrick2", size = 1)

cvar_out_rdf2 <- data.frame(fit = predict(loglme_out_r2), pearson = residuals(loglme_out_r2, type = "pearson"))
ggplot(cvar_out_rdf2, aes(fit, pearson)) +
  geom_point() +
  geom_hline(yintercept = 0, color= "firebrick2", size = 1)

#=========================================================================================================

fitted <-  lmer(log(seconds) ~ numtime + (1|ID), data = rt4903, REML = FALSE)
ggplot(rt4903, aes(x = numtime, y = log(seconds), colour=ID)) +
  labs(x="numerical time",y="log(seconds)")+
  geom_point(shape = 16, size=1.8) +
  geom_abline(aes(intercept=`(Intercept)`, slope=numtime), as.data.frame(t(fixef(fitted))))


fitted_2 <-  lmer(log(seconds) ~ fatigue + (1|ID), data = rt4903, REML = FALSE)
ggplot(rt4903, aes(x = fatigue, y = log(seconds), colour=ID)) +
  labs(x="fatigue",y="log(seconds)") +
  geom_point(shape = 16, size=1.8) +
  geom_abline(aes(intercept=`(Intercept)`, slope=fatigue), as.data.frame(t(fixef(fitted_2))))

fitted_3 <- lmer(log(seconds) ~ numtime * protocol + (1|ID), data = rt4903, REML = FALSE)

theme_set(theme_sjplot())

plot_model(fitted_3, type = "int")
