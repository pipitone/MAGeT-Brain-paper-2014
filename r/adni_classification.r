# Classify the 69 ADNI subjects by hippocampal volume
data = read.csv('adni_data.csv', sep=";")

# defaults showing t-values for AD to NX 
summary(lm((HC_left_vol + HC_right_vol) ~ DX + Sex + Age, data = data))

# NX to AD/NX
data$DX<-relevel(x=data$DX, ref="NX")
summary(lm((HC_left_vol + HC_right_vol) ~ DX + Sex + Age, data = data))
