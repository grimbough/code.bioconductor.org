args <- commandArgs(trailingOnly=TRUE)



#######################
## Argument handling ##
#######################

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

## --all means we should git pull and reindex all existing repos
all_arg <- length(args) >= 1 && ("--all" %in% args)
## Update everything once a week.  Currently Wednesday 14:30
special_time <- grepl(pattern = "3-14:3[0-9]", strftime(Sys.time(), format = "%w-%H:%M"))
if(all_arg || special_time) {
    UPDATE_ALL <- TRUE
} else {
    UPDATE_ALL <- FALSE
}

REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")
if(!nzchar(REPO_DIR)) {
    stop("Repo directory not set\n",
    "Please set the GIT_REPOS_DIR environment variable.")
}

INDEX_DIR <- Sys.getenv("CONTAINER_ZOEKT_IDX_DIR")
if(!nzchar(INDEX_DIR)) {
    stop("Repo directory not set\n",
         "Please set the CONTAINER_ZOEKT_IDX_DIR environment variable.")
}

source("utils.R")
source("git_update_functions.R")
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyRSS))
suppressPackageStartupMessages(library(gert))
suppressPackageStartupMessages(library(jsonlite))

##############################################
## Find packages on server and local mirror ##
##############################################
manifest <- getManifest(n_pkgs = n_pkgs)
existing_pkgs <- list.dirs(REPO_DIR, recursive = FALSE)
removePackages(manifest, existing_pkgs, index_dir = INDEX_DIR)

#########################################################
## Is this starting afresh or updating existing mirror ##
#########################################################
if(length(existing_pkgs) == 0 || CLEAN) {
    cleanDir(repo_dir = REPO_DIR, index_dir = INDEX_DIR)
    createLockFile(repo_dir = REPO_DIR)
    updated_pkgs <- initialiseRepositories(repo_dir = REPO_DIR, manifest = manifest)
} else {
    createLockFile(repo_dir = REPO_DIR)
    updated_pkgs <- updateRepositories(repo_dir = REPO_DIR, manifest = manifest, 
                                 update_all = UPDATE_ALL)
}

##############################################################################
## If packages were changed, update the homepage json and the zoekt indices ##
##############################################################################
if(!is.null(updated_pkgs)) {
    updateZoektIndices(repo_dir = REPO_DIR, index_dir = INDEX_DIR, pkgs = updated_pkgs)
    if(special_time) {
        updateCommitMessages(repo_dir = REPO_DIR, manifest = manifest)
    } else {
        updateCommitMessages(repo_dir = REPO_DIR, manifest = manifest, pkgs = updated_pkgs)
    }
    
}

cleanUp(repo_dir = REPO_DIR)


