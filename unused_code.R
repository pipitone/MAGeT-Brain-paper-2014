#Representative 3T image parameters were TR = 2300ms, TI = 900ms, TE = 3.0ms,
#flip angle = $8{\circ}$, field of view = 256 x 240mm, a 256 x 256 x 166 matrix
#(x, y, and z directions) yielding a voxel resolution of 1.00 x 1.00 x 1.2
#$mm^3$.

########################################
#
# ADNI1 Complete 1Yr Template Library Demographics Table
#
#
# <<ADNI1-scr-tmpllib-demographics, echo=F, results="asis",cache=FALSE>>=
# scr_tmpllib_RIDs = c(0295, 0413, 0619, 0685, 0729, 0782, 0938, 0954, 1018, 1155,
#                  0907, 0981, 0448, 0553, 0814, 1130, 0698, 1339, 1095, 0991,
#                  0159)
# tab <- summary(DX.bl ~ AGE + PTGENDER + PTEDUCAT + PTETHCAT + CDRSB + ADAS13 +
#                MMSE, data = adnimerge, subset = VISCODE == 'bl' & RID #in#
#                scr_tmpllib_RIDs, method = "reverse", test=FALSE, overall=TRUE)
# 
# latex(tab, landscape=FALSE, ctable=FALSE, file="", size="scriptsize",
#       caption="ADNI1 Complete 1Yr Template Library demographics", 
#       title="tab:ADNI1-scr-tmpllib-demographics")
# @
########################################


# <<ADNI1-Xval-sd-by-subject, cache=TRUE>>=
# SDs = data.stats[c('subject','label','atlases','templates.mb','MA.sd','MB.sd')]
# SDs = subset(SDs, templates.mb #in# c(5,10,15,20) & atlases == 5)
# 
# melted = melt(SDs, measure.vars=c('MA.sd','MB.sd'))
# ggplot(melted, aes(x=templates.mb, y=value, 
#                    group=interaction(templates.mb, variable), colour=as.factor(variable))) + 
#   scale_x_continuous(breaks=c(5,10,15,20)) + 
#   geom_violin() 
# @
# \begin{figure}
# <<ADN1-Xval-k-diff-ANTS-20tmpls, cache=TRUE, dependson='ADNI1-Xval-prep'>>=
# a_20_tmpls = subset(all_data_mean, 
#                       reg_method  == "ANTS" &
#                       method.mb   == "Majority Vote" &
#                       templates.mb== 20)
# ggplot(a_20_tmpls, aes(x=factor(atlases))) +
#   #geom_point(aes(y=k.mb,group=1,colour="MAGeT"),position="jitter") + 
#   #geom_point(aes(y=k.ma,group=2,colour="MA"),position="jitter") + 
#   geom_violin(aes(y=k.mb,group=factor(atlases),colour="MAGeT")) + 
#   geom_violin(aes(y=k.ma,group=factor(atlases),colour="MA")) + 
#   geom_smooth(aes(y=k.mb,group=1,colour="MAGeT")) +
#   geom_smooth(aes(y=k.ma,group=2,colour="MA")) +
#   
#   #stat_summary(fun.y=mean,geom='point',size=3,colour="red",aes(y=k.ma)) +
#   #stat_summary(fun.y=mean,geom='line',colour="red",aes(y=k.ma,group=1)) +
#   #stat_summary(fun.y=mean,geom='point',size=3,colour="blue",aes(y=k.mb)) +
#   #stat_summary(fun.y=mean,geom='line',colour="blue",aes(y=k.mb,group=1)) +
#   labs(x="Number of Atlases", y = "Kappa", 
#        title="mean Kappa of MA and MAGeT brain (ANTS/20 templates) \nvs\natlas library size") +
#   scale_colour_hue(name="Method") + 
#   coord_cartesian(ylim=c(0.7,0.9))
#   #theme(legend.justification=c(1,0), legend.position=c(1,0))
# @
#   \caption{Change in mean Kappa between multi-atlas and \mb using \ants,
#   20 templates}
#   \label{}
# \end{figure}
# 
# \begin{figure}
# <<ADN1-Xval-ANTS-20tmpls-t-test-sd, cache=TRUE, dependson='ADNI1-Xval-prep'>>=
# a_20_tmpls = subset(all_data, 
#                       reg_method  == "ANTS" &
#                       method.mb    == "Majority Vote" &
#                       templates.mb == 20 &
#                       atlases     == 9 & 
#                       volume.ma < 10000)
# stddev = ddply(a_20_tmpls, c("subject", "label"), function (df) {
#   data.frame(
#     MA = sd(df$k.ma),  #MA
#     MB = sd(df$k.mb)  #MB
#   )
# })
# 
# 
# # TODO: against SNT
# melted = melt(stddev, id.vars=c("subject", "label"))
# ggplot(melted, aes(x=variable, y=value)) + geom_boxplot()
# t.test(stddev$MA, stddev$MB)
# @
#   \caption{}
#   \label{}
# \end{figure}
# 
#

# 
# 
# \begin{figure}
# <<ADN1-Xval-k-by-disease, cache=TRUE, dependson='ADNI1-Xval-prep'>>=
# a_20_tmpls = subset(all_data, 
#                       reg_method  == "ANTS" &
#                       method.y    == "Majority Vote" &
#                       templates.y == 20 &
#                       atlases #in# c(1,9))
# template_library = read.csv('data/a2a_ants/template_library_composition.csv')
# template_library$subject = NULL
# a_20_tmpls = merge(a_20_tmpls, template_library,
#                    by.x=c('timestamp', 'templates.y'), 
#                    by.y=c('timestamp', 'templates'))
# ggplot(a_20_tmpls, aes(y=k.y, x=templates_CN,colour=DX)) +  # why does k.x look the same?
#   facet_grid( . ~ atlases) + 
#   geom_smooth(method='lm',fullrange=F) 
#  # add 
# @
#   \caption{Mean kappa vs. proportion of disease category in template library by disease category}
#   \label{}
# \end{figure}
# 
# 
# \todo{show cost (in registrations) / benefit tradec off graph:  show number of
# registrations per Kappa?  or hours of manual labour per Kappa?)}
# discuss run-time for each of MAGet and multi-atlas 

# 
# <<WAval-error,cach=T>>=
# # compare # error between MAGeT and resampling
# mb0.9mm_diff_over_gold_diff = cbind(subjects, abs(gold_diff) - abs(mb_0.9mm_diff), res="diffdff")
# names(mb0.9mm_diff_over_gold_diff) <- c("subject", "CA1", "Subiculum", "CA4", "CA2/CA3", "Dentate", "res")
# melted = melt(mb0.9mm_diff_over_gold_diff, id.vars=c("subject", "res"))
# names(melted) <- c("subject","res", "region","voldiff")
# ggplot(melted, aes(y=voldiff,x=region)) +
#   geom_boxplot() +
#   labs(title="Absolute difference in # difference between MAGeT and resampling",
#        y="Absolute difference in # difference in volume", 
#        x="Region")
# @

#<<WAval-kappa,cache=T>>=
##data = read.csv('data/WAval-kappa.csv')
#ggplot(data, aes(x=label, y=kappa)) + geom_boxplot(y=kappa)
#@

# # show as a plot
# <<ADNI-scr-summary-table, echo=F, results="asis",cache=FALSE>>=
# # a rather dirty way of computing the pairwise correlations and then forming
# # a printable table out of them.  Sorry.
# melted = melt(totals.complete, measure.vars=c("MAGeT","FSL", "FS", "MAPER"))
# cor_by_dx    = by(melted[c("SNT", "value")], c(melted['variable'], melted['DX']), 
#                   function(x) cor(x$SNT,x$value, use="pairwise.complete.obs"))
# cor_overall  = by(melted[c("SNT", "value")], melted['variable'], 
#                   function(x) cor(x$SNT,x$value, use="pairwise.complete.obs"))
# cor_by_dx = t(rbind(cor_by_dx))
# cor_overall = rbind(cor_overall)
# 
# vol_by_dx = t(rbind(by(totals.complete$MAGeT, totals.complete$DX, mean)))
# colnames(vol_by_dx) <- "Mean Volume"
# vol_overall = matrix(mean(totals.complete$MAGeT),dimnames=list("Overall"))
# 
# dx      = cbind(vol_by_dx, cor_by_dx)
# overall = cbind(vol_overall, cor_overall)
# df      = format.df(rbind(dx, overall), dec=2)
#                     
# #latex(df, title="",
# #      n.cgroup=c(1,ncol(df)-1),cgroup=c("","Volume Correlation"),
# #      file="", size="scriptsize")
# @
