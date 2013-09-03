RSCRIPT:=R
.PHONY: help cache paper dist clean
CSVS := 

# help   :: show makefile commands
help: 
	@echo $(CSVS)
	@grep '^#.*::' Makefile

# cache  :: rebuild the cache of munged data
cache: 
	mkdir -p data/cache
	$(RSCRIPT) --vanilla < cache_analysis.R 

# paper  :: produce the paper
paper: paper.pdf

paper.pdf: paper.tex 
	sed -i -e 's#\\begin{table}#\\begin{table*}#g' -e 's#\\end{table}#\\end{table*}#g' paper.tex
	pdflatex paper.tex
	bibtex paper.aux
	pdflatex paper.tex
	pdflatex paper.tex

paper.tex: paper.Rnw  
	#R CMD Sweave $*.Rnw
	$(RSCRIPT) -e "library(knitr); knit(\"$*.Rnw\")" 

paper.Rnw: $(shell find . -name '*.csv' | sed 's/:/\\:/g') 
	rm -rf cache paper.tex 
	touch paper.Rnw 

# dist   :: zip up all the source material
dist: paper.tex
	zip -r paper paper.tex references.bib IEEEbib.bst spconf.sty montage.png figure

# clean  :: remove generated files
clean:
	rm -f *.aux *.log *.bbl *.blg paper.pdf *.tex
