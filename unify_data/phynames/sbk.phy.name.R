# ==============================================================================
# =====================  SBK Physician Names  ==================================
# ======================    March 2 2017   =====================================
library(gemini)
lib.pa()
rm(list = ls())

names.marked <- fread("C:/Users/guoyi/Desktop/names_code_link_ASW.csv")
adm.names <- fread("R:/GEMINI/_RESTORE/SBK/Physicians/adm.physician.hashes.csv")
dad.names <- fread("R:/GEMINI/_RESTORE/SBK/Physicians/dad.mrp.hashes.csv")

intersect(dad.names$mrpCode, adm.names$admitCode)
intersect(dad.names$mrpCode, adm.names$disCode)

adm.names <- merge(adm.names, names.marked[,.(hashed, `Was GIM Attending`)],
                   by.x = "admitCode", by.y = "hashed",
                   all.x = T, all.y = F)

adm.names <- merge(adm.names, names.marked[,.(hashed, `Was GIM Attending`)],
                   by.x = "disCode", by.y = "hashed",
                   all.x = T, all.y = F)
names(adm.names)[4:5] <- c("gim.adm", "gim.dis")
sum(is.na(adm.names$gim.dis))
sum(is.na(adm.names$gim.adm))

adm.names[,gim:= ifelse(gim.adm=="Y"|gim.dis=="Y", "Y", 
                        ifelse(gim.adm=="N"&gim.dis=="N", "N", "U"))]
table(adm.names$gim)

fwrite(adm.names, "R:/GEMINI/_RESTORE/SBK/Physicians/adm.physician.hashes.marked.csv")