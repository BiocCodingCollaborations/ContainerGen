getProjectPackages <- function(project_dir = "."){
  if(!requireNamespace("renv", quietly = TRUE)){
    install.packages("renv")
  }
  files_in_dir = list.files(path = project_dir,
                            pattern = "\\.R$",
                            recursive = TRUE)
  if(length(files_in_dir) == 0){
    stop("No R packages Found.")
  }
  packages <- list()
  for (file in files_in_dir){
    dependencies <- renv::dependencies(file)
    if ( !is.null(dependencies) || !nrow(dependencies) == 0) {
    message("adding new deps")
    packages <- c(packages, dependencies$Package)
    }
  }
  exclude <- c("BiocManager", "renv")
  packages <- unique(packages)
  packages <- setdiff(packages,exclude)
  return(packages)
}



makeSimpleBiocContainer <- function(path = ".",
                                    container = "mycontainer",
                                    data = NULL,
                                    script = NULL) {
    ## Check if files/dir are/is available/missing
    if (!is.null(data))
        if (!any(file.exists(data))) stop("Data not found.")
    if (!is.null(script))
        if (!any(file.exists(script))) stop("Script(s) not found.")
    if (file.exists(container))
        stop("Container directory already exists.")
    message("Creating the container directory 🪐.")
    dir.create(container)
    message("Creating the Dockerfile 🔔.")
    package <- getProjectPackages()
    df <- file.path(container, "Dockerfile")
    stopifnot(file.create(df))
    v <- as.character(BiocManager::version())
    bioccontainer <- paste0("bioconductor/bioconductor_docker:RELEASE_", sub("\\.", "_", v))
    cat(paste("FROM ", bioccontainer, "\n"), file = df, append = TRUE)
    cat("RUN apt-get update && ",
        "apt-get install -y  cmake git libcurl4-openssl-dev libssl-dev libuv1-dev make pandoc && ",
        "rm -rf /var/lib/apt/lists/*\n",
        file = df, append = TRUE)
    cat("RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/\n", file = df, append = TRUE)
    cat("RUN echo \"options(repos = c(BioCsoft = 'https://bioconductor.org/packages/", v, "/bioc',",
        "BioCann = 'https://bioconductor.org/packages/", v, "/data/annotation', ",
        "BioCexp = 'https://bioconductor.org/packages/", v, "/data/experiment', ",
        "CRAN = 'https://cloud.r-project.org'), download.file.method = 'libcurl', Ncpus = 4)\" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site\n",
        sep = "", file = df, append = TRUE)
    cat("RUN R -e 'options(warn = 2); install.packages(\"BiocManager\")'\n", file = df, append = TRUE)
    sapply(package, function(x) {
        cmd <- paste0("RUN Rscript -e 'BiocManager::install(\"", x, "\", update = FALSE, ask = FALSE)'\n")
        cat(cmd, file = df, append = TRUE)
    })
    if (!is.null(data)) {
        message("Adding data 📂.")
        dir.create(file.path(container, "data"))
        file.copy(data, paste0(container, "/data/"))
        cat("ADD data /home/rstudio/data/\n", file = df, append = TRUE)
    }
    if (!is.null(script)) {
        message("Adding scripts 🐶.")
        dir.create(file.path(container, "script"))
        file.copy(script, paste0(container, "/script/"))
        cat("ADD script /home/rstudio/script/\n", file = df, append = TRUE)
    }
    message("Done 👍")
    invisible(file.path(getwd(), container))
}

runDocker <- function(container, username) {
    oldpath <- getwd()
    on.exit(setwd(oldpath))
    containername <- paste0(username, "/", basename(container))
    setwd(container)
    buildargs <- paste0("build -t ", containername, " .")
    message("Building container 🏠.")
    system2("docker", args = buildargs)
    pushargs <- paste0("push ", containername)
    message("Pushing container 📌.")
    system2("docker", args = pushargs)
    return(containername)
}