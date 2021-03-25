REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")
if(!nzchar(REPO_DIR)) {
    stop("Repo directory not set\n",
    "Please set the GIT_REPOS_DIR environment variable.")
}

source("git_update_functions.R")

suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyRSS))
suppressPackageStartupMessages(library(gert))
suppressPackageStartupMessages(library(jsonlite))

if(length(list.files(REPO_DIR, "")) == 0) {
    initialiseRepositories(repo_dir = REPO_DIR)
} else {
    manifest <- getManifest()
    update <- updateRepositories(repo_dir = REPO_DIR, manifest = manifest)
    if(update) {
        updateCommitMessages(repo_dir = REPO_DIR, manifest = manifest)
    }
}