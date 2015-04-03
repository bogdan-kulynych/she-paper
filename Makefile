SHELL     := /bin/bash

TITLEPAGE := title.tex

LATEXC    := lualatex
LXFLAGS   := -interaction=batchmode
SDFLAGS   := --natbib
BIBTEX    := bibtex

SOURCES   := main.md
TARGET    := paper

BUILDDIR  := build
RESDIR    := resources
SETTINGS  := settings/kma.yml

all: pdf

html:
	@mkdir -p $(BUILDDIR)
	scholdoc $(SOURCES) $(SDFLAGS) --citeproc --output=$(BUILDDIR)/$(TARGET).html
	@firefox $(BUILDDIR)/$(TARGET).html

latex:
	@mkdir -p $(BUILDDIR)
	scholdoc $(SETTINGS) $(SDFLAGS) $(SOURCES) --include-before-body=$(TITLEPAGE) --output=$(BUILDDIR)/$(TARGET).tex

pdf: latex links
	@mkdir -p $(BUILDDIR)
	@cd $(BUILDDIR) ; \
	$(LATEXC) $(LXFLAGS) -pdf $(TARGET).tex ; \
	$(BIBTEX) $(TARGET).aux ; \
	$(LATEXC) $(LXFLAGS) -pdf $(TARGET).tex ; \
	$(LATEXC) $(LXFLAGS) -pdf $(TARGET).tex
	@evince $(BUILDDIR)/$(TARGET).pdf &

links:
	@ln -sf $(shell pwd)/$(RESDIR) $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)

.PHONY: html latex pdf autopdf clean
