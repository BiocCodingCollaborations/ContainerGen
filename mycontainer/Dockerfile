FROM  bioconductor/bioconductor_docker:RELEASE_3_23 
RUN apt-get update &&  apt-get install -y  cmake git libcurl4-openssl-dev libssl-dev libuv1-dev make pandoc &&  rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(BioCsoft = 'https://bioconductor.org/packages/3.23/bioc',BioCann = 'https://bioconductor.org/packages/3.23/data/annotation', BioCexp = 'https://bioconductor.org/packages/3.23/data/experiment', CRAN = 'https://cloud.r-project.org'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'options(warn = 2); install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("DESeq2", update = FALSE, ask = FALSE)'
RUN Rscript -e 'BiocManager::install("dplyr", update = FALSE, ask = FALSE)'
RUN Rscript -e 'BiocManager::install("edgeR", update = FALSE, ask = FALSE)'
RUN Rscript -e 'BiocManager::install("ggplot2", update = FALSE, ask = FALSE)'
RUN Rscript -e 'BiocManager::install("limma", update = FALSE, ask = FALSE)'
