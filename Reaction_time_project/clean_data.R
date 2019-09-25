library(tidyverse)
library(readxl)
library(ggplot2)

rt490<-read_excel("C:/Users/AoFei/Desktop/sta490/STA490_draft_report/reactiontime.xlsx", 
                  col_types = 
                    c("numeric", "numeric", "numeric", "numeric", "date", "text", "numeric", "numeric","text","numeric","numeric","text", "text", "skip")) 

#remove NA
rt490<-rt490[!is.na(rt490$seconds),]

#time of day
rt490$timeofday<-as.POSIXlt(rt490$timeofday)
rt490<-rt490 %>% mutate(numtime=rt490$timeofday$hour+rt490$timeofday$min/60) 

#IMEQ
rt490 <- rt490 %>% mutate(IMEQ= MEQ) %>% 
  mutate(IMEQ = replace(IMEQ, which(IMEQ  < 31 & IMEQ > 15), "DefEvening")) %>%
  mutate(IMEQ = replace(IMEQ, which(IMEQ <41 & IMEQ > 30), "ModEvening")) %>%
  mutate(IMEQ = replace(IMEQ, which(IMEQ  < 59 & IMEQ > 41), "Neither")) %>%
  mutate(IMEQ = replace(IMEQ, which(IMEQ < 70 & IMEQ > 58), "ModMorning")) %>%
  mutate(IMEQ = replace(IMEQ, which(IMEQ < 88 & IMEQ > 70), "DefMorning")) %>%
  mutate(IMEQ = replace(IMEQ, which (IMEQ == "evening type" | IMEQ == "Moderately evening person" |IMEQ == "night" ), "ModEvening"))%>% 
  mutate(IMEQ= factor(IMEQ, levels = c("DefEvening","ModEvening", "Neither", "ModMorning", "DefMorning")))
#IMEQ3
rt490 <- rt490 %>% mutate(IMEQ3=IMEQ) %>% 
  mutate(IMEQ3 =ifelse(IMEQ %in% c("DefEvening", "ModEvening"), "Evening", 
                       ifelse(IMEQ =="ModMorning", "Morning",
                              ifelse(IMEQ == "Neither", "Neither", NA))))

#MEQ as numeric
rt490<-rt490 %>% mutate(MEQ=MEQ) %>%
  mutate(MEQ= replace(MEQ, which(MEQ == "evening type"), (59+69)/2)) %>%
  mutate(MEQ= replace(MEQ, which(MEQ == "neither"), (42+58)/2)) %>%
  mutate(MEQ= replace(MEQ, which(MEQ == "Moderately evening person"), (59+69)/2)) %>%
  mutate(MEQ= replace(MEQ, which(MEQ == "Moderately evening person"), (59+69)/2)) %>%
  mutate(MEQ= as.numeric(MEQ))

#illness
rt490<- rt490 %>% mutate(illness = ifelse(illness== "1"), 0, ifelse(illness == "0"), 1) #Evaluation error: argument "yes" is missing, with no default.

#specify class for each variable
rt490<-rt490 %>% mutate(protocol = factor(protocol, levels = c(1, 0)))%>%
  mutate(busy_light =factor(busy_light, levels = c(1, 0))) %>%
  mutate(stimulant = factor(stimulant, levels = c(1, 0))) %>%
  mutate(illness = factor(protocol, levels = c(1, 0)))

rt4902<-na.omit(rt490)

#================================================================ rt4903 =============================================================================
rt4903<-rt490%>% select(-timeofday)# this is mean/most common value

rt4903<-rt4903 %>%
  mutate(stimulant=replace(stimulant, is.na(stimulant), 1))%>%
  mutate(fatigue=replace(fatigue, is.na(fatigue), c(3.42, 2.92, 3.27, 4.78, 3.71, 2.87, 3.51, 4.57)))%>%
  mutate(hunger=replace(hunger, is.na(hunger), c(4.03, 4.87, 5.43, 4.89, 3.97, 4.92, 5.24, 4.73))) %>%
  mutate(illness=replace(illness, is.na(illness), 0))%>%
  mutate(sleep=replace(sleep, is.na(sleep), mean(sleep, na.rm = T))) %>%
  mutate(protocol=replace(protocol, is.na(protocol), 1)) %>%
  mutate(IMEQ3 = replace(IMEQ3, is.na(IMEQ3), "Neither")) %>%
  mutate(MEQ = replace(MEQ, is.na(MEQ), mean(MEQ, na.rm = T))) %>%
  mutate(numtime=replace(numtime, is.na(numtime), c(9.9, 14.8, 19.2, 11.3, 9.37, 14.5, 19.1, 14.4, 9.9, 14.8, 19.2, 11.3, 9.37, 14.5, 19.1, 14.4)))

