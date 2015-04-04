## Prerequisites

Certain settings assume lualatex is used for PDF generation

```
apt-get install lualatex
```

[Sholdoc](http://scholdoc.scholarlymarkdown.com/) is used to compile Scholarly Markdown to TeX.

```
cabal update
cabal install scholdoc
cabal install scholdoc-citeproc
```

## Build

```
# Produce build/paper.pdf
make pdf

# Produce build/paper.tex
make latex
```
