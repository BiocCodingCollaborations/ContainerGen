## Participants

- Dania, Joao, Ata, Laurent, Sneha (online).

## General aim

I would like to create a new container with my packages and my data,
and be able to easily share this container with other users through
[docker hub](https://hub.docker.com/) (see the [SimpleBiocContainer](https://github.com/lgatto/SimpleBiocContainer) package).

Parallel tasks

- Create a docker file from a DESCRIPTION file.
- Getting started with Docker.
- Explore dockerfiler.
- Who are our users? Dependencies?
- How to add data to a container? Where: in the `~/data` directory.
- How to add scripts to a container? Where: in the `~/scripts` directory.

## Ressource

- [Bioconductor docker page](https://bioconductor.org/help/docker/)
- [CRAN: Package dockerfiler](https://cran.r-project.org/web/packages/dockerfiler/index.html)

## Usage

Create the Dockerfile for the package(s) of interest, optionally
adding data or scripts to the container.

```r
> x <- makeSimpleBiocContainer("MsCoreUtils", container = "sbc", data = "/home/lgatto/tmp/foo.txt")
Creating the container directory 🪐.
Creating the Dockerfile 🔔.
Adding data 📂.
Done 👍
> x
[1] "/home/lgatto/tmp/sbc"
```

Build and push the container.

```r
> runDocker(x, "lgatto")
Building container 🏠.
[+] Building 0.0s (0/1)                                                                              docker:default
[+] Building 0.1s (12/12) FINISHED                                                                   docker:default
 => [internal] load build definition from Dockerfile                                                           0.0s
 => => transferring dockerfile: 838B                                                                           0.0s
 => [internal] load metadata for docker.io/bioconductor/bioconductor_docker:RELEASE_3_23                       0.0s
 => [internal] load .dockerignore                                                                              0.0s
 => => transferring context: 2B                                                                                0.0s
 => [1/7] FROM docker.io/bioconductor/bioconductor_docker:RELEASE_3_23                                         0.0s
 => [internal] load build context                                                                              0.0s
 => => transferring context: 73B                                                                               0.0s
 => CACHED [2/7] RUN apt-get update &&  apt-get install -y  cmake git libcurl4-openssl-dev libssl-dev libuv1-  0.0s
 => CACHED [3/7] RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/                                            0.0s
 => CACHED [4/7] RUN echo "options(repos = c(BioCsoft = 'https://bioconductor.org/packages/3.23/bioc',BioCann  0.0s
 => CACHED [5/7] RUN R -e 'options(warn = 2); install.packages("BiocManager")'                                 0.0s
 => CACHED [6/7] RUN Rscript -e 'BiocManager::install("MsCoreUtils", update = FALSE, ask = FALSE)'             0.0s
 => CACHED [7/7] ADD data /home/rstudio/data/                                                                  0.0s
 => exporting to image                                                                                         0.0s
 => => exporting layers                                                                                        0.0s
 => => writing image sha256:0529842f001d41895652d7c05d0c571791ebacd5fe5bbc3c19863aff1e4afd01                   0.0s
 => => naming to docker.io/lgatto/sbc                                                                          0.0s
Pushing container 📌.
Using default tag: latest
The push refers to repository [docker.io/lgatto/sbc]
latest: digest: sha256:ed3db35bb75115a8a50bf94c3a1e5254b290e079e2f6e618f056d8fe7aeb947d size: 5549
[1] "lgatto/sbc"
>
```
