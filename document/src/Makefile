tex_files=$(wildcard *.tex)
dot_files=$(wildcard *.dot)
dot_figures=$(patsubst %.dot,%.pdf,$(dot_files))
svg_files=$(wildcard *.svg)
svg_figures=$(patsubst %.svg,%.pdf,$(svg_files))
#octave_files=$(wildcard *.m)
#octave_figures=$(patsubst %.m,%.tex,$(octave_files))
data_files=$(wildcard *.data)

.SUFFIXES: .png .dot .pdf .tex .txt .dat .svg .m .diction .style
.PHONY: clean all distclean spell document_checks

aggregate_dependencies=document_checks thesis.tex asudis.sty thesis.bib $(tex_files) $(dot_figures) $(svg_figures) $(octave_figures) experiment_algorithm.py

all: thesis.pdf thesis.diction thesis.style

document_checks:
	#./check_contractions.sh
	./check_abstract.sh

thesis.pdf: $(aggregate_dependencies)

thesis.diction: $(aggregate_dependencies)

thesis.style: $(aggregate_dependencies)

personal.aspell: $(HOME)/.vim/spell/en.utf-8.add
	aspell --lang=en create master ./personal.aspell < ~/dotfiles/vim/spell/en.utf-8.add

spell: $(tex_files) personal.aspell
	$(foreach doc,$(tex_files), aspell --personal personal.aspell --lang=en --mode=tex check $(doc);)

.tex.pdf: 
	latexmk -pdf --halt-on-error $< > compile.log

.pdf.txt:
	ps2txt $< $@

.tex.diction:
	detex $< | diction -b -s > $@

.tex.style:
	detex $< | style -n > $@
	
.dot.svg:
	dot -Tsvg $< > $@

.svg.pdf:
	inkscape --export-area-drawing --export-latex -A$@ $<

#.m.tex:
#	octave $<

clean:
	git clean -xf 


