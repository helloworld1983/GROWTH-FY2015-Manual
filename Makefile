growth_manual.html: growth_manual.md
	pandoc --toc --number-section -s -c github.css growth_manual.md -o growth_manual.html
