args <- commandArgs(trailingOnly=TRUE)

## should the existing set of packages be deleted?
if(length(args) >= 1 && ("--clean" %in% args)) {
    CLEAN <- TRUE
} else {
    CLEAN <- FALSE
}

## process argument specifying number of packages to initialise with
if(length(args) >= 1 && any(grepl("--npkgs=[0-9]*", args))) {
    arg <- args[grepl("--npkgs=[0-9]*", args)]
    n_pkgs <- as.integer(gsub("--npkgs=([0-9]*)", "\\1", arg))
} else {
    n_pkgs <- Inf
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
    initialiseRepositories(repo_dir = REPO_DIR, n_pkgs = n_pkgs)
} else {
    manifest <- getManifest(n_pkgs = Inf)
    update <- updateRepositories(repo_dir = REPO_DIR, manifest = manifest)
    if(update) {
        updateCommitMessages(repo_dir = REPO_DIR, manifest = manifest)
    }
}