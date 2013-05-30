#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# ADNI1-XVAL: prep
# Prepares the data in a the form needed for plotting.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# all data from the validation trials
a_data       = read.csv(gzfile('data/a2a_ants/results_2013_01_03.csv.gz'))
t_data       = read.csv(gzfile('data/a2a_tracc/results_xfmjoin_2013_04_04.csv.gz'))
diagnoses    = read.csv('data/a2a_diagnoses.csv')

# simplify the data
t_data       = subset(t_data, atlases %in% seq(1,9,1))
a_data       = subset(a_data, atlases %in% seq(1,9,1))
t_data$se    = NULL
t_data$sn    = NULL
t_data$j     = NULL
a_data$se    = NULL
a_data$sn    = NULL
a_data$j     = NULL       

# add registration method column 
t_data       = cbind(t_data, reg_method = "ANIMAL")
a_data       = cbind(a_data, reg_method = "ANTS")

# separate MA majvote from MB so we can compute differences
# we only compare multiatlas using majority vote
t_ma = subset(t_data, approach=="ma" & method=="majvote")
t_ma$approach="multiatlas"
a_ma = subset(a_data, approach=="multiatlas" & method=="majvote")
t_mb = subset(t_data, approach=="mb")
a_mb = subset(a_data, approach=="mb")

ma = rbind(t_ma,a_ma)
mb = rbind(t_mb,a_mb)

ma$num_labels = ma$atlases
mb$num_labels = mb$atlases * mb$templates 

# set up a few equivalences for multi-atlas, to make nomenclature simpler
ma$templates =  ma$atlases  # because no template library
mb[mb$method != 'majvote',]$templates = mb[mb$method != 'majvote',]$top_n 

# aggregate over batches
ma_mean = aggregate(k ~ subject + reg_method + approach + method + atlases +
                    templates + top_n + label, data = ma, mean)
mb_mean = aggregate(k ~ subject + reg_method + approach + method + atlases +
                    templates + top_n + label, data = mb, mean)                    

all_data = merge(ma, mb, by=c("timestamp", "atlases", "batch", "label",
                              "reg_method", "subject"), 
                 suffixes=c(".ma", ".mb"))

all_data_mean = merge(ma_mean, mb_mean, by=c("reg_method", "label", "atlases",
                                             "subject"), 
                 suffixes=c(".ma", ".mb"))

all_data$k_diff = all_data$k.mb - all_data$k.ma
all_data_mean$k_diff = all_data_mean$k.mb - all_data_mean$k.ma

vote_levels <- list("Majority Vote" = "majvote", "NMI Vote" = "nmi",
                    "Cross-correlation Vote" = "xcorr")

levels(all_data$method.mb) <- vote_levels
levels(all_data_mean$method.mb) <- vote_levels

all_data       = merge(all_data, diagnoses)
all_data_mean  = merge(all_data_mean, diagnoses)
remove(t_ma, a_ma, t_mb, a_mb, ma, mb)
write.csv(all_data     ,'data/cache/ADNI-XVAL:all_data.csv')
write.csv(all_data_mean,'data/cache/ADNI-XVAL:all_data_mean.csv')


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# ADNI1-Complete
# Prepares the data in a the form needed for plotting.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#bl    = read.csv("data/ADNI_baseline_volumes/ADNI1_Complete_1Yr_1.5T_11_15_2012.csv")
mb    = read.csv("data/ADNI_baseline_volumes/ADNI1_1.5T_MAGeT_volumes.csv")
maper = read.csv("data/ADNI_baseline_volumes/MAPER_volumes.csv")
snt   = read.csv("data/ADNI_baseline_volumes/UCSFSNTVOL.csv")
fs    = read.csv("data/ADNI_baseline_volumes/UCSFFSX_02_15_12.csv")
fsl   = read.csv("data/ADNI_baseline_volumes/ADNI1_1.5T_FSLFIRST_volumes.csv", sep=';')
qc    = read.csv("data/ADNI_baseline_volumes/ADNI1_Complete_1Yr_1.5T_QC_Park.csv", sep="\t")

# Get subjects, and diagnoses
yr1 = read.csv("data/ADNI_baseline_volumes/ADNI1_Complete_1Yr_1.5T_11_15_2012.csv")
yr1 = subset(yr1, !grepl("Scaled_2", Description)) #TODO: remove Scaled_2? 
yr1$VISCODE <- factor(yr1$Visit, levels = c(1,2,3,4), labels=c("bl","m03","m06","m12"))
subjects = yr1[,c("Image.Data.ID", "RID","VISCODE")]  # we only need these fields
dx = unique(adnimerge[c("DX.bl", "RID", "VISCODE")])
subjects = merge(subjects, dx) 

# fetch just the columns we need, and do a little renaming
mb_pruned     = data.frame(MAGeT_L = mb$Left_Hippo, 
                           MAGeT_R = mb$Right_Hippo, Source = mb$SourceImageID)
maper_pruned  = data.frame(MAPER_L = maper$Left_Hippo, 
                           MAPER_R = maper$Right_Hippo, Source = maper$SourceImageID)
snt_pruned    = data.frame(SNT_L = snt$LEFTHIPPO, 
                           SNT_R = snt$RIGHTHIPPO, Source = snt$IMAGEUID)
fs_pruned     = data.frame(TEMPQC =fs$TEMPQC, 
                           FS_L=fs$ST29SV, 
                           FS_R=fs$ST88SV, 
                           Source = fs$IMAGEUID)
fsl_pruned    = data.frame(FSL_L=fsl$X17, 
                           FSL_R=fsl$X53, Source=fsl$Source)



# Now create one data.frame with all the yr1 volume data we have from each datasource
combined = merge(subjects, mb_pruned   , by.x="Image.Data.ID", by.y="Source", all.x=TRUE)
combined = merge(combined, maper_pruned, by.x="Image.Data.ID", by.y="Source", all.x=TRUE)  # only Baseline
combined = merge(combined, snt_pruned  , by.x="Image.Data.ID", by.y="Source", all.x=TRUE)
combined = merge(combined, fs_pruned   , by.x="Image.Data.ID", by.y="Source", all.x=TRUE)
combined = merge(combined, fsl_pruned  , by.x="Image.Data.ID", by.y="Source", all.x=TRUE)
combined = merge(combined, qc          , by=c("Image.Data.ID", "RID"), all.x=TRUE)

# Step 2: Of those, get counts for the numbers that fail QC
package_totals = data.frame(
  Total     = c(length(subjects$VISCODE), 'N/A'),
  SNT        = c(length(which(!is.na(combined$SNT_L)))    , "--"),
  MAGeT      = c(length(which(!is.na(combined$MAGeT_L)))  , length(which(combined$MAGeT_QC==0))), 
  MAPER      = c(length(which(!is.na(combined$MAPER_L)))  , "--"), 
  FSL        = c(length(which(!is.na(combined$FSL_L)))    , length(which(combined$FSL_QC==0))), 
  FS         = c(length(which(!is.na(combined$FS_L)))     , length(which(combined$TEMPQC == "Fail"))),
  row.names  = c("Images", "Failures")
)


all_qc = subset(combined, TEMPQC != "Fail" & MAGeT_QC == 1 | FSL_QC == 1 )

attach(all_qc)
totals = data.frame(RID = RID, VISCODE = VISCODE, DX = factor(DX.bl),
                  MAGeT = MAGeT_L + MAGeT_R, 
                  MAPER = MAPER_L + MAPER_R, 
                  SNT   = SNT_L + SNT_R, 
                  FS    = FS_L + FS_R, 
                  FSL   = FSL_L + FSL_R)
detach(all_qc)
totals.complete = na.omit(totals)

write.csv(totals.complete, 'data/cache/ADNI1:totals.complete.csv')
write.csv(totals,          'data/cache/ADNI1:totals.csv')
write.csv(package_totals,  'data/cache/ADNI1:package_totals.csv')
