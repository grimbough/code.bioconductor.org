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

## process argument specifying number of packages to initialise with
if(length(args) >= 1 && ("--all" %in% args)) {
    UPDATE_ALL <- TRUE
} else {
    UPDATE_ALL <- FALSE
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
    updated_pkgs <- updateRepositories(repo_dir = REPO_DIR, manifest = manifest, 
                                 update_all = UPDATE_ALL)
    if(!is.null(updated_pkgs)) {
        updateCommitMessages(repo_dir = REPO_DIR, manifest = manifest, pkgs = updated_pkgs)
    }
}

## update the record of the last packages we updated
printMessage("Writing last_hash.rds... ", 0, appendLF = FALSE)
old_hash <- file.path(REPO_DIR, "last_hash.rds")
tmp_hash <- file.path(REPO_DIR, "last_hash_tmp.rds")

if(file.exists(tmp_hash)) {
    if(file.exists(old_hash)) {
        file.remove(old_hash)
    }
    invisible(file.rename(from = tmp_hash, to = old_hash))
}
message("done")
