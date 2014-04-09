RSCRIPT:=R
.PHONY: help cache paper dist clean

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
	sed -i "s/^url =.*//g" references.bib  # remove urls
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


# diff   :: make old=HEAD^^ new=HEAD diff
.PHONY: diff
diff:
	rm paper.tex && \
	git checkout $(old) && \
	make paper.tex && \
	mv paper.tex old.tex && \
	git checkout $(new) && \
	make paper.tex && \
	mv paper.tex new.tex && \
	git checkout HEAD && \
	latexdiff old.tex new.tex > paper.tex && \
	make paper.pdf && \
	mv paper.pdf diff-$(old)-$(new).pdf

# dist   :: zip up all the source material
.PHONY: dist
dist: paper.tex
	zip -r paper.zip paper.tex references.bib \
		figure/*.pdf \
		figure/ADNI1_SNT_MB_montage/montage.pdf \
		figure/winterburn-atlas-montage/figure.pdf


# clean  :: remove generated files
clean:
	rm -f *.aux *.log *.bbl *.blg paper.pdf *.tex

check:
	@echo "Unclosed newcommands"
	@grep -n -o -e '\\\w\+ ' paper.Rnw | \
		grep -v '\(item\|em\|pm\|it\|tiny\|tabularnewline\)' | \
		grep -v '\(times\|newline\|tt\|textbf\|textbf\|hline\)' | \
		grep -v '\(cup\|cap\|choose\)'

.PHONY:letters
letters: 
	pdflatex letters/neuroimage.tex
	pdflatex letters/neuroimage.tex
	pdflatex letters/neuroimage.tex
