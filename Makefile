all: *.tex
	pdflatex -shell-escape talk.tex $<
	while grep 'Rerun to get ' *.log ; do pdflatex -shell-escape talk.tex $< ; done
