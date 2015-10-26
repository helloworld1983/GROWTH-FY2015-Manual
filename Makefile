growth_manual.html: $(wildcard growth_manual_*.md)
	pandoc --toc --number-section -s -c github.css $^ -o growth_manual.html

check: growth_manual.html
	open growth_manual.html
