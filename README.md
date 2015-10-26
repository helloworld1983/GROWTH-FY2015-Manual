# GROWTH FY2015 User Manual

This is a repository for a user manual of the detector system developed for the Gamma-ray Observation Winter Thundercloud (GROWTH) experiment FY2015 campaign.

## Produce HTML document

### Install git/pandoc

Install necessary software using [Homebrew](http://brew.sh).

```
brew install git
brew cask install pandoc
```

### Convert Markdown files to an HTML file

Execute the following in the command line:

```
make check
```

On Mac, a generated HTML file will be opened using the default web browser.

## Edit

- Chapters are divided into separate Markdown files.
- Figures should be located in ```figures/```.
