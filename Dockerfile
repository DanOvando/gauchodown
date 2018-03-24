# get the base image
FROM rocker/verse:3.4.1

# required
MAINTAINER Ben Marwick <bmarwick@uw.edu>

COPY . /huskydown

# go into the repo directory
RUN . /etc/environment \

  # Install linux depedendencies here
  && sudo apt-get update \
  # install fonts
  && sudo apt-get install fonts-ebgaramond -y \
  && sudo git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git /usr/local/share/fonts/source-code-pro \
  && sudo fc-cache -f -v \
  && sudo apt-get install fonts-lato -y \
  
  # get latex & xetex
  # && R -e "install.packages('tinytex'); tinytex::install_tinytex(force = TRUE, repository = 'ctan')" \

  # build this compendium package
  && R -e "devtools::install('/huskydown', dep=TRUE)" \

 # make a PhD thesis from the template, remove pre-built PDF,
 # then render new thesis into a PDF, then check it could work:
  && R -e "if (dir.exists('index')) unlink('index', recursive = TRUE)" \
  && R -e "rmarkdown::draft('index.Rmd', template = 'thesis', package = 'huskydown', create_dir = TRUE, edit = FALSE)" \
  && R -e "if (file.exists('index/_book/thesis.pdf')) file.remove('index/_book/thesis.pdf')" \
  && R -e "setwd('index');  bookdown::render_book('index.Rmd', huskydown::thesis_pdf(latex_engine = 'xelatex'))" \
  && R -e "file.exists('index/_book/thesis.pdf')"
