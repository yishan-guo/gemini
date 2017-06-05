# -------------------------- Significance plot function ------------------------


plot.phy.sig <- function(data, title, xlab = "Physician", 
                     ylab, nextreme = 1,
                     ave.fun, xstart = -2, digit = 1, show.sig = F, varname = NULL,
                     var_cat = F, category = TRUE){
  #data <- hide_site(data)
  df <- ddply(data, ~physician, .fun = ave.fun) %>% data.table
  digitform <- paste("%.", digit, "f", sep = "")
  names(df)[4] <- "phy.ave"
  site.mean <- ddply(data[data$physician%in%df$physician, ], ~Institution.Number, .fun = ave.fun)
  names(site.mean)[4] <- "site.mean"
  df <- merge(df, site.mean[,c(1,4)], by.x = "site", by.y = "Institution.Number")
  data <- data.frame(data)
  for(i in unique(df$site)){
    df[site ==i, phy := as.numeric(factor(physician, levels = physician[order(phy.ave, decreasing = T)]))]
    for(j in unique(df[df$site==i, physician])){
      if(var_cat == T){
        df$var_sig[df$site==i&df$physician==j] <-
          prop.test(c(sum(data[data$Institution.Number==i&data$physician==j, varname]==category, na.rm = T),
                      sum(data[data$Institution.Number==i&data$physician!=j, varname]==category, na.rm = T)),
                    c(sum(!is.na(data[data$Institution.Number==i&data$physician==j, varname])),
                      sum(!is.na(data[data$Institution.Number==i&data$physician!=j, varname]))))$p.value
      } else{
        df$var_sig[df$site==i&df$physician==j] <- 
          t.test(data[data$Institution.Number==i&data$physician==j, varname],
                 data[data$Institution.Number==i&data$physician!=j, varname]
          )$p.value
      }
    }
  }
  df$col = as.character(df$site)
  df$col[df$var_sig>=0.05] = "nonsig"
  if("A"%in%df$site){
    mycol = c("A" = "#F8766D",
                         "B" = "#B79F00",
                         "C" = "#00BA38",
                         "D" = "#00BFC4",
                         "E" = "#619CFF",
                         "F" = "#A58AFF",
                         "G" = "#FB61D7",
                         "nonsig" = "#AAAAAA")
  }else{
    mycol = c("SHS" = "#F8766D",
              "SHSC" = "#B79F00",
              "SMH" = "#00BA38",
              "THP-C" = "#00BFC4",
              "THP-M" = "#619CFF",
              "UHN-TG" = "#A58AFF",
              "UHN-TW" = "#FB61D7",
              "nonsig" = "#AAAAAA")
  }
  p <- ggplot(df, aes(phy, phy.ave, fill = col)) + 
    geom_bar(stat = "identity", width = 0.5) + 
    #geom_line(aes(x = phy, y = site.mean), alpha = 0.5,
    #          linetype = 2, size = 0.5) + 
    facet_grid(.~site, scales = "free_x") + 
    scale_fill_manual(values = mycol) +
    ggtitle(title) +
    xlab(xlab) +
    ylab(ylab) +
    expand_limits(x = xstart) +
    theme(plot.title = element_text(hjust = 0.5),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          legend.position="none")
  print(df)
  # del <- ddply(df, ~site, summarise,
  #              site.ave = sum(phy.ave * N)/sum(N),
  #              #site.ave = mean(phy.ave), # for patient sum only
  #              xm = max(phy),
  #              ymi = quantile(phy.ave, probs = 0.25),
  #              yma = quantile(phy.ave, probs = 0.75),
  #              yav = quantile(phy.ave, probs = 0.5),
  #              ydiff = sprintf(digitform , yma - ymi))
  # print(del)
  # ave.shift <- max(df$phy.ave) * 0.02
  # p <- p + geom_errorbar(data = del, aes(x = xstart/2, y = NULL,ymin = ymi, ymax = yma),
  #                        alpha = 0.3, width = 2) 
  #   # plot the 25% - 75% range
  #   geom_rect(data = del, aes(x = NULL, y = NULL, xmin = xstart/2 - 1, xmax =  xstart/2 +1,
  #                             ymin = yav-0.5*ave.shift, ymax = yav+0.5*ave.shift), fill = "#EEEEEE") +
  #   geom_text(data = del, aes(x = xstart/2, y = yav, label = ydiff), size = 3) +
  #   # plot the label for average
  #   geom_text(data = del, aes(x = xm-2, y = site.ave + ave.shift,
  #                             label = sprintf(digitform , site.ave)),
  #             size = 3)
  print(p)
}


setwd("C:/Users/guoyi/Desktop/to.adm/figures.v4/significance_plot/with_sitename")
setwd("C:/Users/guoyi/Desktop/to.adm/figures.v4/significance_plot/no_sitename")




ave.los <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$Acute.LoS, na.rm = T))
}
png("ave.los_overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort,  "Average Acute Length-of-Stay (Days)", 
         ylab = "Average Length-of-Stay (Days)", ave.fun = ave.los,
         show.sig = T,
         varname = "Acute.LoS")
dev.off()


ave.cost <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$Cost, na.rm = T))
}

png("ave.cost.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort,  "Average Cost ($)", 
         ylab = "Average Cost ($)", ave.fun = ave.cost, xstart = -5, digit = 0,
         varname = "Cost")
dev.off()

# ---------------------------average alc days ----------------------------------
ave.alc <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$Number.of.ALC.Days, na.rm = T))
}
png("ave.alc_overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort, "Average ALC Days", ylab = "Average ALC Days", ave.fun = ave.alc,
             varname = "Number.of.ALC.Days")
dev.off()

# ----------------------------- readmission rate -------------------------------
read.rate <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = sum(x$read.in.30, na.rm = T)/sum(!is.na(x$read.in.30), na.rm = T)*100)
}
png("re.admission.rate_overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort, "Re-admission (within 30 days) Rate (%)", 
         ylab = "Re-admission (within 30 days) Rate (%)", ave.fun = read.rate,
         varname = "read.in.30", var_cat = T)
dev.off()

# ----------------------------- mortality rate ---------------------------------
mort <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$Discharge.Disposition ==7, na.rm = T)*100)
}
png("inhospital.mortality_overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort, "In-hospital Mortality (%)", ylab = "In-hospital Mortality (%)", ave.fun = mort,
         varname = "Discharge.Disposition", var_cat = T, category= "7")
dev.off()

# ------------------------------ short admission rate --------------------------
cohort$shortstay <- cohort$Acute.LoS<2
shortadm <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$Acute.LoS < 2, na.rm = T)*100)
}
png("short.adm.rate_overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort, "Short-Admission (<48h) Rate (%)", ylab = "Short-Admission (<48h) Rate (%)", 
         ave.fun = shortadm, xstart = -4, var_cat = T, varname = "shortstay")
dev.off()


# ----------------------------- Rate of ICU admission --------------------------
icuadm<- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$SCU.adm, na.rm = T)*100)
}
png("ICU.uti_overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort[str_sub(EncID.new,1,2)!="15"], "ICU Utilization Rate(%)", 
         ylab = "ICU Utilization Rate(%)", ave.fun = icuadm, xstart = -4,
         varname= "SCU.adm", var_cat = T)
dev.off()

ddply(cohort[str_sub(EncID.new,1,2)!="15"], ~physician, summarise,
      N = length(EncID.new),
      N.icu = sum(SCU.adm==T, na.rm = T),
      mean(SCU.adm, na.rm = T)) %>% filter(N.icu<5)


# ----------------------Number of CT MRI US ------------------------------------
# ctmrius <- fread("C:/Users/guoyi/Desktop/to.adm/n.ctmrius.csv")
# ctmrius$EncID.new <- as.character(ctmrius$EncID.new)
# cohort <- merge(cohort, ctmrius, by = "EncID.new", all.x = T, all.y = F)
# cohort[is.na(N.rad), N.rad:= 0]

n.rad <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = sum(x$N.rad)/nrow(x))
}
png("n.ctmrius.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort[str_sub(EncID.new, 1, 2)%in%c("11","12","13", "14")],  
         "Number of Radiology Tests (CT/MRI/Ultrasound) per Patient per Doctor", 
         ylab = "Number of Radiology Tests (CT/MRI/Ultrasound) \nper Patient per Doctor", 
         ave.fun = n.rad, varname = "N.rad")
dev.off()

# ----------------------------------- AKI --------------------------------------
aki.rate <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = sum(x$aki, na.rm = T)/nrow(x)*100)
}
png("aki.rate.overall.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort[str_sub(EncID.new, 1, 2)%in%c("11","12","13", "14")],  
         "Proportion of Patients with Hospital-Acquired AKI (%)", 
         ylab = "Proportion of Patients with Hospital-Acquired AKI (%)", 
         ave.fun = aki.rate, varname = "aki", var_cat = T)
dev.off()

# -------------------------Transfusion with pre hgb > 80 -----------------------
num.pre.trans.hgb80 <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = sum(x$N.pre.tran.hgb.gt80)/nrow(x)*1000)
}
png("number.of.rbc.trans.with.prehbg.gt80.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort[str_sub(EncID.new, 1, 2)%in%c("11","12","13", "14")], 
         "Number of RBC Transfusions \n with pre-Transfusion Hgb > 80 \n per 1000 Patient per Doctor", 
         ylab = "Number of RBC Transfusions \n with pre-Transfusion Hgb > 80 \n per 1000 Patient per Doctor", 
         ave.fun = num.pre.trans.hgb80, xstart = -3,
         varname = "N.pre.tran.hgb.gt80", var_cat = F)
dev.off()



# --------------------------------- Adjusted LOS -------------------------------
library(lme4)
for(i in unique(cohort$Institution.Number)){
  fit.los <- lm(Acute.LoS ~ Age + Gender + Charlson.Comorbidity.Index + fiscal.year, 
                data = cohort[Institution.Number==i])
  cohort$adj_acute_los[cohort$Institution.Number==i] <- predict(fit.los, newdata = data.frame(
    Age = median(cohort$Age),
    Gender = "F",
    Charlson.Comorbidity.Index = median(cohort$Charlson.Comorbidity.Index),
    fiscal.year = 2015
  )) + fit.los$residuals
  print(i)
}
cor.test(cohort$Acute.LoS, cohort$adj_acute_los, method = "spearman")
adj.los <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$adj_acute_los, na.rm = T))
}
png("adjusted_ave_acute_los.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort,  "Average Adjusted Acute Length-of-Stay (Days)", 
         ylab = "Average Adjusted Length-of-Stay (Days)", ave.fun = adj.los,
         varname = "adj_acute_los")
dev.off()


# ------------------------------ Adjusted Cost ---------------------------------
library(lme4)
for(i in unique(cohort$Institution.Number)){
  fit <- lm(Cost ~ Age + Gender + Charlson.Comorbidity.Index + fiscal.year, 
            data = cohort[Institution.Number==i,])
  cohort$adj_cost[!is.na(cohort$Cost)&cohort$Institution.Number==i] <- 
    predict(fit, newdata = data.frame(
      Age = median(cohort$Age),
      Gender = "F",
      Charlson.Comorbidity.Index = median(cohort$Charlson.Comorbidity.Index),
      fiscal.year = 2015
    )) + fit$residuals
  print(i)
}
cor.test(cohort$Cost, cohort$adj_cost)
adj.cost <- function(x){
  data.frame(N = nrow(x),
             site = x$Institution.Number[1],
             ave = mean(x$adj_cost, na.rm = T))
}
png("adjusted_cost.png", res = 250, width = 2000, height = 1200)
plot.phy.sig(cohort,  "Average Adjusted Cost ($)", 
         ylab = "Average Adjusted Cost ($)", ave.fun = adj.cost, xstart = -4, digit = 0,
         varname = "adj_cost")
dev.off()