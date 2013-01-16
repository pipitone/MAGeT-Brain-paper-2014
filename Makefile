RSCRIPT:=R

paper.pdf: paper.tex 
	sed -i -e 's#\\begin{table}#\\begin{table*}#g' -e 's#\\end{table}#\\end{table*}#g' paper.tex
	pdflatex paper.tex
	bibtex paper.aux
	pdflatex paper.tex
	pdflatex paper.tex

%.tex: %.Rnw
	#R CMD Sweave $*.Rnw
	$(RSCRIPT) -e "library(knitr); knit(\"$*.Rnw\")" 

dist:paper.tex
	zip -r paper paper.tex references.bib IEEEbib.bst spconf.sty montage.png figure

clean:
	rm -f *.aux *.log *.bbl *.blg paper.pdf *.tex
