library(rms)
data = read.csv('adni_data.csv', sep=';')
summary(data)
dd <- datadist(data)
options(datadist="dd")
describe(data)
mod <- lrm(data=data, DX ~ hc_left_vol + Age + Sex)
mod
modleft <- lrm(data=data, DX ~ hc_left_vol + Age + Sex)
modright <- lrm(data=data, DX ~ hc_right_vol + Age + Sex)
modright <- lrm(data=data, DX ~ hc_right_vol + Age + Sex, subset=DX!=MCI)
modright <- lrm(data=data, DX ~ hc_right_vol + Age + Sex, subset=DX!="MCI")
modright
modleft <- lrm(data=data, DX ~ hc_left_vol + Age + Sex, subset=DX!="MCI")
modleft

summary(modleft)
summary(modright)
modleft
modleft2 <- lrm(data=data, DX ~ Age + Sex, subset=DX!="MCI")
lrtest(modleft, modleft2)
validate(modleft, method=.632)
modleft <- lrm(data=data, DX ~ hc_left_vol + Age + Sex, subset=DX!="MCI", x=TRUE, y=TRUE)
validate(modleft, method=.632)
validate(modleft, method=".632")
validate(modleft, method=boot)
validate(modleft, method="boot")
calibrate(modleft, method="boot")
modleft <- lrm(data=data, DX ~ hc_left_vol + Age + Sex, subset=DX!="MCI", x=TRUE, y=TRUE)
modleft
summary(modleft)
print(modleft <- lrm(data=data, DX ~ hc_left_vol + Age + Sex, subset=DX!="AD", x=TRUE, y=TRUE))
summary(modleft)
print(modleft <- lrm(data=data, DX ~ hc_left_vol + Age + Sex, subset=DX!="NX", x=TRUE, y=TRUE))
savehistory("dan-model-validation.R")
