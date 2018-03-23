# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/verse:3.4.4

# required
MAINTAINER Ben Marwick <bmarwick@uw.edu>

COPY . /huskydown

# go into the repo directory
RUN . /etc/environment \

  # Install linux depedendencies here
  # need this because rocker/verse doesn't have xelatex - really?
  && sudo apt-get update \
  && sudo apt-get install texlive-base -y \
  && sudo apt-get install texlive-binaries -y \
  && sudo apt-get install texlive-latex-base -y \
  && sudo apt-get install texlive-latex-extra -y \
  && sudo apt-get install texlive-xetex -y \
  && sudo apt-get install texlive-bibtex-extra biber -y \
  # install fonts
  && sudo apt-get install fonts-ebgaramond -y \
  && sudo git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git /usr/share/fonts/ \
  && sudo fc-cache -f -v \
  && sudo apt-get install fonts-lato -y \

  # build this compendium package
  && R -e "devtools::install('/huskydown', dep=TRUE)" \

 # make a PhD thesis from the template, remove pre-built PDF,
 # then render new thesis into a PDF, then check it could work:
  && R -e "rmarkdown::draft('index.Rmd', template = 'thesis', package = 'huskydown', create_dir = TRUE, edit = FALSE); setwd('index'); file.remove('_book/thesis.pdf'); bookdown::render_book('index.Rmd', huskydown::thesis_pdf(latex_engine = 'xelatex')); file.exists('_book/thesis.pdf')"
