# ------------------------ THP Names -------------------------------------------
library(gemini)
lib.pa()

adm <- fread("C:/Users/guoyi/Desktop/marked_names/thp/THP MED GIM IP_physicianNames.csv")
mrp <- fread("C:/Users/guoyi/Desktop/marked_names/thp/THP MED GIM IP GENERALDAD_physicianNames.csv")
apply(adm, 2, function(x)sum(x==""))

thp <- readg(thp, dad)
length(unique(thp$EncID.new))

intersect(adm$AdmittingPhysicianCode, mrp$MostResponsibleDoctorCode)
adm[AdmittingPhysicianCode=="1050"]
mrp[MostResponsibleDoctorCode=="1050"]
# all names are in the same coding system


all.names <- rbind(data.table(Code = adm$AdmittingPhysicianCode,
                              first.name = adm$AdmittingPhysicianFirstName,
                              last.name = adm$AdmittingPhysicianLastName),
                   data.table(Code = adm$DischargingPhysicianCode,
                              first.name = adm$DischargingPhysicianFirstName,
                              last.name = adm$DischargingPhysicianLastName),
                   data.table(Code = mrp$MostResponsibleDoctorCode,
                              first.name = mrp$MostResponsiblePhysicianFirstName,
                              last.name = mrp$MostResponsiblePhysicianLastName))

all.names <- merge(unique(all.names), data.table(table(all.names$Code)),
                   by.x = "Code", by.y= "V1", all.x = T)

all.names$code.type <- "thp"
all.names$GIM <- "y"

fwrite(all.names, "H:/GEMINI/Results/DataSummary/physician_names/complete.name.list/thp.names.csv")