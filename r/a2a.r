library(ggplot2)
# Authors jon julie jason martin jens aristotle mallar
#X11 = function (...) grDevices::x11(...,type='cairo')
#X11 = CairoX11()

multiplot <- function(..., plotlist=NULL, cols) {
    require(grid)

    # Make a list from the ... arguments and plotlist
    plots <- c(list(...), plotlist)

    numPlots = length(plots)

    # Make the panel
    plotCols = cols                          # Number of columns of plots
    plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols

    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
    vplayout <- function(x, y)
        viewport(layout.pos.row = x, layout.pos.col = y)

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
        curRow = ceiling(i/plotCols)
        curCol = (i-1) %% plotCols + 1
        print(plots[[i]], vp = vplayout(curRow, curCol ))
    }

}

#####################################################
# TRACC
t_naive      = read.csv(file='a2a_tracc_naive.csv')
t_data       = read.csv(file='a2a_tracc_results_2012_08_30.csv')
t_maj        = subset(t_data, method == 'majvote')
t_xcorr      = subset(t_data, method == 'xcorr')
t_nmi        = subset(t_data, method == 'nmi')
t_mean_naive = mean(t_naive$k)
t_ylimits    = c(0.7,0.85)

t_multiatlas = read.csv(file='a2a_tracc_multiatlas_2012_08_14.csv')
t_ma_means   = aggregate( k ~ num_atlases , data=t_multiatlas, mean)
t_maj$k_minus_ma_mean   <- t_maj$k   - t_ma_means[ t_maj$num_atlases - 3, 2 ]
t_xcorr$k_minus_ma_mean <- t_xcorr$k - t_ma_means[ t_xcorr$num_atlases - 3, 2 ]
t_nmi$k_minus_ma_mean   <- t_nmi$k   - t_ma_means[ t_nmi$num_atlases - 3, 2 ]

# Majority Vote
# plots kappa by numbeer of templates used
#geom = c('smooth'), line=1.5, formula=y~poly(x,2), method='lm') + 
t_maj_plot <- qplot(x=num_templates, y=k, data=t_maj, colour=as.factor(num_atlases), 
  geom = c('smooth')) + 
geom_hline(aes(yintercept=t_mean_naive)) + 
geom_hline(aes(yintercept = k, colour = as.factor(num_atlases)), linetype="dotted", 
  data = t_ma_means ) + 
opts(title = "ANIMAL\nMajority vote") +
opts(legend.position = "None") + 
scale_colour_hue(name="Atlases") +
xlab( "Number of Templates" ) + 
ylab( "Kappa" ) + 
coord_cartesian(ylim=t_ylimits) 

# X-Corr results with a full suite of templates
# plots kappa by top N templates choosen 
t_xcorr_plot <- qplot(x=top_n, y=k, data=t_xcorr,
colour=as.factor(num_atlases), geom=c('smooth')) + 
geom_hline(aes(yintercept=t_mean_naive))  +
coord_cartesian(ylim=t_ylimits) + 
opts(title = "X-Corr vote") +
opts(legend.position = "None") + 
scale_colour_hue(name="Atlases") +
xlab( "Number of Templates" ) + 
ylab( "Kappa" ) + 
coord_cartesian(ylim=t_ylimits) 

# NMI results with a full suite of templates
# plots kappa by top N templates choosen 
t_nmi_plot <- qplot(x=top_n, y=k, data=t_nmi,
colour=as.factor(num_atlases), geom=c('smooth')) +
geom_hline(aes(yintercept=t_mean_naive))  +
opts(title = "NMI vote") + 
opts(legend.position = "None") + 
scale_colour_hue(name="Atlases") +
xlab( "Number of Templates" ) + 
ylab( "Kappa" ) + 
coord_cartesian(ylim=t_ylimits) 

#####################################################
# ANTS

a_naive      = read.csv(file='a2a_ants_naive_2012_08_30.csv')
a_data       = read.csv(file='a2a_ants_results_2012_08_30.csv')
a_maj        = subset(a_data, method == 'majvote')
a_xcorr      = subset(a_data, method == 'xcorr')
a_nmi        = subset(a_data, method == 'nmi')
a_mean_naive = mean(a_naive$k)
a_ylimits    = c(0.7,0.85)

a_multiatlas = read.csv(file='a2a_ants_multiatlas_2012_08_14.csv')
a_ma_means   = aggregate( k ~ num_atlases , data=a_multiatlas, mean)
a_maj$k_minus_ma_mean   <- a_maj$k - a_ma_means[ a_maj$num_atlases - 3, 2 ]
a_xcorr$k_minus_ma_mean <- a_xcorr$k - a_ma_means[ a_xcorr$num_atlases - 3, 2 ]
a_nmi$k_minus_ma_mean   <- a_nmi$k   - a_ma_means[ a_nmi$num_atlases - 3, 2 ]

# Majority Vote
# plots kappa by numbeer of templates used

a_maj_plot <- qplot(x=num_templates, y=k, data=a_maj, colour=as.factor(num_atlases), 
  geom=c('smooth')) + 
geom_hline(aes(yintercept=a_mean_naive))  +
coord_cartesian(ylim=a_ylimits) + 
geom_hline(aes(yintercept = k, colour = as.factor(num_atlases)), linetype="dotted", 
  data = a_ma_means ) +
opts(title = "ANTS\nMajority vote")  +
opts(legend.position = "None") + 
scale_colour_hue(name="Atlases") +
xlab( "Number of Templates" ) + 
ylab( "Kappa" )  

# X-Corr results with a full suite of templates
# plots kappa by top N templates choosen 
a_xcorr_plot <- qplot(x=top_n, y=k, data=a_xcorr,
colour=as.factor(num_atlases), geom=c('smooth')) + 
geom_hline(aes(yintercept=a_mean_naive))  +
opts(title = "X-Corr vote") +
opts(legend.direction = "horizontal") + 
opts(legend.position = "bottom") + 
coord_cartesian(ylim=a_ylimits)  +
scale_colour_hue(name="Atlases") +
xlab( "Number of Templates" ) + 
ylab( "Kappa" )  

# NMI results with a full suite of templates
# plots kappa by top N templates choosen 
a_nmi_plot <- qplot(x=top_n, y=k, data=a_nmi,
colour=as.factor(num_atlases), geom=c('smooth')) +
geom_hline(aes(yintercept=a_mean_naive))  +
opts(title = "NMI vote") + 
opts(legend.position = "None") + 
coord_cartesian(ylim=a_ylimits) +
scale_colour_hue(name="Atlases") +
xlab( "Number of Templates" ) + 
ylab( "Kappa" )  

#loess.control(trace.hat = c("approximate"), statistics = c("approximate"), surface = c("interpolate"))
pdf("a2a_kbytemplates.pdf", width=15, height=15)
multiplot(t_maj_plot  , a_maj_plot  ,
          t_xcorr_plot, a_xcorr_plot, 
          t_nmi_plot  , a_nmi_plot  , cols=2)
dev.off()

############################################
#  Kappa adjusted by Multi-atlas mean 
a_ylimits    = c(-0.03,0.04)
t_ylimits    = a_ylimits

t_maj_plot <- qplot(x=num_templates, y=k_minus_ma_mean, data=t_maj, colour=as.factor(num_atlases), geom = c('smooth'), se=FALSE) + 
opts(title = "ANIMAL\nMajority vote") + opts(legend.position = "None") + 
xlab( "Number of Templates" ) + ylab( "Kappa - MA means" ) + 
coord_cartesian(ylim=t_ylimits) 

t_xcorr_plot <- qplot(x=top_n, y=k_minus_ma_mean, data=t_xcorr, colour=as.factor(num_atlases), geom = c('smooth'), se=FALSE) + 
opts(title = "X-Corr vote") + opts(legend.position = "None") + 
xlab( "Number of Templates" ) + ylab( "Kappa - MA means" ) + 
coord_cartesian(ylim=t_ylimits) 

t_nmi_plot <- qplot(x=top_n, y=k_minus_ma_mean, data=t_nmi, colour=as.factor(num_atlases), geom = c('smooth'), se=FALSE) + 
opts(title = "NMI vote") + opts(legend.position = "None") + 
xlab( "Number of Templates" ) + ylab( "Kappa - MA means" ) + 
coord_cartesian(ylim=t_ylimits) 

a_maj_plot <- qplot(x=num_templates, y=k_minus_ma_mean, data=a_maj, colour=as.factor(num_atlases), geom = c('smooth'), se=FALSE) + 
opts(title = "ANTS\nMajority vote") + opts(legend.position = "None") + 
xlab( "Number of Templates" ) + ylab( "Kappa - MA means" ) + 
coord_cartesian(ylim=a_ylimits) 

a_xcorr_plot <- qplot(x=top_n, y=k_minus_ma_mean, data=a_xcorr, colour=as.factor(num_atlases), geom = c('smooth'), se=FALSE) + 
opts(title = "X-Corr vote") + opts(legend.position = "None") + 
xlab( "Number of Templates" ) + ylab( "Kappa - MA means" ) + 
coord_cartesian(ylim=a_ylimits) 

a_nmi_plot <- qplot(x=top_n, y=k_minus_ma_mean, data=a_nmi, colour=as.factor(num_atlases), geom = c('smooth'), se=FALSE) + 
opts(title = "NMI vote") + opts(legend.position = "None") + 
xlab( "Number of Templates" ) + ylab( "Kappa - MA means" ) + 
coord_cartesian(ylim=a_ylimits) 

pdf("a2a_kminusMAmean.pdf", width=15, height=15)
multiplot(t_maj_plot  , a_maj_plot  ,
          t_xcorr_plot, a_xcorr_plot, 
          t_nmi_plot  , a_nmi_plot  , cols=2)
dev.off()
