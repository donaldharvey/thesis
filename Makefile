all:
	rm report.*
	pandoc --from markdown+footnotes --filter pandoc-citeproc metadata.yaml sections/*.md -s -o report.tex --include-in-header=preamble.tex --template=template.tex
	# latex report.tex
	# bibtex report
	# latex report.tex
	latexmk -pdf report.tex

clean:
	rm report.*