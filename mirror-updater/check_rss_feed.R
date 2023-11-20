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

#CLEAN <- TRUE

## process argument specifying number of packages to initialise with
if(length(args) >= 1 && any(grepl("--npkgs=[0-9]*", args))) {
    arg <- args[grepl("--npkgs=[0-9]*", args)]
    n_pkgs <- as.integer(gsub("--npkgs=([0-9]*)", "\\1", arg))
} else {
    n_pkgs <- Inf
}

## process argument specifying specific packages to include
if(length(args) >= 1 && any(grepl("--extra_pkgs=[[:alnum:]]*", args))) {
    arg <- args[grepl("--extra_pkgs=[[:alnum:]]*", args)]
    extra_pkgs <- gsub("--extra_pkgs=([[:alnum:]]*)", "\\1", arg)
    extra_pkgs <- eval(parse(text = extra_pkgs))
} else {
    extra_pkgs <- NULL
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

#########################
## Create new log file ##
#########################
lock_file <- file.path(REPO_DIR, "lock")
log_file <- file.path(REPO_DIR, "status.log")
if(file.exists(log_file) && !file.exists(lock_file)) { 
    unlink(log_file) 
}

##############################################
## Find packages on server and local mirror ##
##############################################
manifest <- getManifest(n_pkgs = n_pkgs, extra_pkgs = extra_pkgs)
existing_pkgs <- list.dirs(REPO_DIR, recursive = FALSE)
removePackages(manifest, existing_pkgs, index_dir = INDEX_DIR)

#########################################################
## Is this starting afresh or updating existing mirror ##
#########################################################
if(length(existing_pkgs) == 0 || CLEAN) {
    cleanDir(repo_dir = REPO_DIR, index_dir = INDEX_DIR)
    createUnderConstruction(repo_dir = REPO_DIR)
    createLockFile(repo_dir = REPO_DIR)
    updated_pkgs <- initialiseRepositories(repo_dir = REPO_DIR, manifest = manifest)
} else {
    ## Uncomment these lines to force deletion of the lock file
    # lock_file <- file.path(REPO_DIR, "lock")
    # if(file.exists(lock_file)) { file.remove(lock_file) }
    #UPDATE_ALL <- TRUE
    createLockFile(repo_dir = REPO_DIR)
    
    #unlink(x = file.path(REPO_DIR, c("nnSVG", "scp")), recursive = TRUE)
    
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

####################################################
## Once per day update the count table of commits ##
####################################################
suppressPackageStartupMessages(library(lubridate))
commit_count_time <- grepl(pattern = "01:0[0-9]", strftime(Sys.time(), format = "%H:%M"))
#commit_count_time <- TRUE
if( commit_count_time ) {
    source("process_repos.R")
}

cleanUp(repo_dir = REPO_DIR)

