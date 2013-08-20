RSCRIPT:=R
.PHONY: help cache paper dist clean

# help   :: show makefile commands
help: 
	@grep '^#.*::' Makefile

# cache  :: rebuild the cache of munged data
cache: 
	$(RSCRIPT) --vanilla < cache_analysis.R 

# paper  :: produce the paper
paper: paper.pdf

paper.pdf: paper.tex 
	sed -i -e 's#\\begin{table}#\\begin{table*}#g' -e 's#\\end{table}#\\end{table*}#g' paper.tex
	pdflatex paper.tex
	bibtex paper.aux
	pdflatex paper.tex
	pdflatex paper.tex

%.tex: %.Rnw
	#R CMD Sweave $*.Rnw
	$(RSCRIPT) -e "library(knitr); knit(\"$*.Rnw\")" 

# dist   :: zip up all the source material
dist: paper.tex
	zip -r paper paper.tex references.bib IEEEbib.bst spconf.sty montage.png figure

# clean  :: remove generated files
clean:
	rm -f *.aux *.log *.bbl *.blg paper.pdf *.tex
