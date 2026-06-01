  makeSimpleBiocContainer <- function(package,
                                      container = "mycontainer",
                                      data = NULL,
                                      script = NULL) {
      message("Creating the container directory")
      if (file.exists(container))
          stop("Container directory already exists.")
      dir.create(container)
      message("Creating the Dockerfile.")
      df <- file.path(container, "Dockerfile")
      stopifnot(file.create(df))
      bioccontainer <- paste0("bioconductor/bioconductor_docker:RELEASE_", sub("\\.", "_", BiocManager::version()))
      cat(paste("FROM ", bioccontainer, "\n"), file = df, append = TRUE)
      cat("RUN apt-get update && apt-get install -y  cmake git libcurl4-openssl-dev libssl-dev libuv1-dev make pandoc && rm -rf /var/lib/apt/lists/*\n",
          file = df, append = TRUE)
      cat("RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/\n", file = df, append = TRUE)
      cat("RUN echo \"options(repos = c(BioCsoft = 'https://bioconductor.org/packages/3.23/bioc', BioCann = 'https://bioconductor.org/packages/3.23/data/annotation', BioCexp = 'https://bioconductor.org/packages/3.23/data/experiment', BioCworkflows = 'https://bioconductor.org/packages/3.23/workflows', BioCbooks = 'https://bioconductor.org/packages/3.23/books', CRAN = 'https://cloud.r-project.org'), download.file.method = 'libcurl', Ncpus = 4)\" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site\n",
          file = df, append = TRUE)
      cat("RUN R -e 'options(warn = 2); install.packages(\"BiocManager\")'\n", file = df, append = TRUE)
      sapply(package, function(x) {
          cmd <- paste0("RUN Rscript -e 'BiocManager::install(\"", x, "\", update = FALSE, ask = FALSE)'\n")
          cat(cmd, file = df, append = TRUE)
      })
      if (!is.null(data)) {
          message("Adding data.")
          dir.create(file.path(container, "data"))
          file.copy(data, paste0(container, "/data/"))
          cat("ADD data /home/rstudio/data/\n", file = df, append = TRUE)
      }
      if (!is.null(script)) {
          message("Adding scripts.")
          dir.create(file.path(container, "script"))
          file.copy(script, paste0(container, "/script/"))
          cat("ADD script /home/rstudio/script/\n", file = df, append = TRUE)
      }
      message("Done :-)")
  }
