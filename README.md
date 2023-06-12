# Tools for browsing the Bioconductor code repository

This repository details the source behind https://code.bioconductor.org

The site is hosted on a Kubernetes instance managed by the European Molecular Biology Laboratory.  It comprises of four Docker containers that provide various parts of the site.  Each of these is found in the sub-folders of this repository:

- [homepage](homepage): Static home page providing links to the other services and details of the website
- [gitlist](gitlist): Git browser
- [zoekt-webserver](zoekt-webserver): Search interface
- [mirror-updater](mirror-updater): Combination of R scripts and zoekt index tools that maintain the local mirror of [git.bioconductor.org](https://git.bioconductor.org)

Pre-built container images can be found on [Docker Hub](https://hub.docker.com/u/grimbough).

## Running containers locally

Environment variables defining paths for mounting folders inside the containers.
- `LOCAL_*` refers to the directories on the host machine.  
- `CONTAINER_*` are the mount points inside the containers, where the applications are expecting to find files.

```bash
LOCAL_REPO_DIR=/tmp/docker/repos
LOCAL_ZOEKT_IDX_DIR=/tmp/docker/zoekt

## don't customise these for now
CONTAINER_REPO_DIR=/var/git
CONTAINER_ZOEKT_IDX_DIR=/var/zoekt
```

Initialise or update the collection of BioC package git repositories.  If `${LOCAL_REPO_DIR}` is empty it will clone all repositories from the Bioconductor git server.  If `${LOCAL_REPO_DIR}` contains one or more directories it will only clone packages or update existing repositories that have change since the last update.  After packages have been cloned or updated it will create Zoekt index files for the affected repositories.

Can be passed the following arguments:

  - `--all`     If `${LOCAL_REPO_DIR}` is not empty, this will try to update all existing packages and clone any not currently present.
  - `--clean`   Delete everything found in `${LOCAL_REPO_DIR}` and re-download.
  - `--npkgs=N` If `${LOCAL_REPO_DIR}` is empty, or `--clean` has been supplied, only download the first `N` packages found in the manifest.
  - `--extra_pkgs=` Provide a vector of specific package names to include in the checkout.  Some escaping of quotes is required e.g. `--extra_pkgs="c(\"rhdf5\", \"biomaRt\")"`.

```bash
docker run -it \
  --env GIT_REPOS_DIR=${CONTAINER_REPO_DIR} \
  --env CONTAINER_ZOEKT_IDX_DIR=${CONTAINER_ZOEKT_IDX_DIR} \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  --mount type=bind,source=${LOCAL_ZOEKT_IDX_DIR},target=${CONTAINER_ZOEKT_IDX_DIR} \
  grimbough/code.bioc-mirror-updater
```

Launch the docker containers for the gitlist and zoekt webservers.  

```bash
docker run -p 8888:8080 -d --name zoekt-webserver --rm=true \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  --mount type=bind,source=${LOCAL_ZOEKT_IDX_DIR},target=${CONTAINER_ZOEKT_IDX_DIR} \
  grimbough/code.bioc-zoekt-webserver

docker run -p 8889:8080 -d --name gitlist-webserver --rm=true \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  grimbough/code.bioc-gitlist
```