# bioc-code-tools

Unofficial and experimental tools for browsing the Bioconductor code repository

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

Initialise or update the collection of BioC pacage git repositories.  If `${LOCAL_REPO_DIR}` is empty it will clone all (currently a test of 25) repositories from the Bioconductor git server.  If `${LOCAL_REPO_DIR}` contains one or more directories it will only clone packages or update existing repositories that have changes in the last 20 minutes.

```bash
docker run -it --env GIT_REPOS_DIR=${CONTAINER_REPO_DIR} \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  grimbough/bioc-git-mirror
```

Run the zoekt indexer.  This should be run after the git repositories have been updated.

```bash
docker run -it --env ZOEKT_INDEX_DIR=${CONTAINER_ZOEKT_IDX_DIR} \
  --env GIT_REPOS_DIR=${CONTAINER_REPO_DIR} \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  --mount type=bind,source=${LOCAL_ZOEKT_IDX_DIR},target=${CONTAINER_ZOEKT_IDX_DIR} \
  grimbough/bioc-zoekt-index
```

Launch the docker containers for the gitlist and zoekt webservers.  

```bash
docker run -p 8888:6070 -d --name zoekt-webserver \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  --mount type=bind,source=${LOCAL_ZOEKT_IDX_DIR},target=${CONTAINER_ZOEKT_IDX_DIR} \
  grimbough/bioc-zoekt-webserver

docker run -p 8889:80 -d --name gitlist-webserver \
  --mount type=bind,source=${LOCAL_REPO_DIR},target=${CONTAINER_REPO_DIR} \
  grimbough/bioc-gitlist
```