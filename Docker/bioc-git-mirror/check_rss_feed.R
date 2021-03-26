args <- commandArgs(trailingOnly=TRUE)

if(length(args) >= 1 && args[1] == "clean") {
    CLEAN <- TRUE
} else {
    CLEAN <- FALSE
}

REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")
if(!nzchar(REPO_DIR)) {
    stop("Repo directory not set\n",
    "Please set the GIT_REPOS_DIR environment variable.")
}

source("git_update_functions.R")

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyRSS))
suppressPackageStartupMessages(library(gert))
suppressPackageStartupMessages(library(jsonlite))

existing_pkgs <- list.dirs(REPO_DIR, recursive = FALSE)

if(length(existing_pkgs) == 0 || CLEAN) {
    cleanDir(repo_dir = REPO_DIR)
    initialiseRepositories(repo_dir = REPO_DIR)
} else {
    manifest <- getManifest()
    update <- updateRepositories(repo_dir = REPO_DIR, manifest = manifest)
    if(update) {
        updateCommitMessages(repo_dir = REPO_DIR, manifest = manifest)
    }
}