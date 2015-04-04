SHELL     := /bin/bash

TITLEPAGE := title.tex

LATEXC    := lualatex
LXFLAGS   := -interaction=batchmode
SDFLAGS   := --natbib --latex-engine=$(LATEXC) --toc
BIBTEX    := bibtex

SOURCES   := main.md
TARGET    := paper

BUILDDIR  := build
RESDIR    := resources
SETTINGS  := settings/kma.yml

all: pdf

html: buildenv
	scholdoc $(SDFLAGS) --citeproc --output=$(BUILDDIR)/$(TARGET).html $(SOURCES)
	@firefox $(BUILDDIR)/$(TARGET).html

latex: buildenv
	scholdoc $(SETTINGS) $(SDFLAGS) --include-before-body=$(TITLEPAGE) --output=$(BUILDDIR)/$(TARGET).tex $(SOURCES)

prev: buildenv
	scholdoc $(SETTINGS) $(SDFLAGS) --include-before-body=$(TITLEPAGE) --to=latex --output=$(BUILDDIR)/$(TARGET).pdf $(SOURCES)
	@evince $(BUILDDIR)/$(TARGET).pdf &

buildenv: $(BUILDDIR)
$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

pdf: latex links
	@cd $(BUILDDIR) ; \
	$(LATEXC) $(LXFLAGS) -pdf $(TARGET).tex ; \
	$(BIBTEX) $(TARGET).aux ; \
	$(LATEXC) $(LXFLAGS) -pdf $(TARGET).tex ; \
	$(LATEXC) $(LXFLAGS) -pdf $(TARGET).tex
	@evince $(BUILDDIR)/$(TARGET).pdf &

links: buildenv
	@ln -sf $(shell pwd)/$(RESDIR) $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)

.PHONY: html latex prev pdf clean
