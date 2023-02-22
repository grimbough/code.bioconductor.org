## Print log with date and message
printMessage <- function(msg, n = 0, appendLF = TRUE) {
    message("[ ", Sys.time(), " ] ", rep(" ", n), msg, appendLF = appendLF)
}

## Get a vector containing the names of all packages currently part of 
## Bioconductor.  This differs from the complete list of repositories hosted
## on the git server.
getManifest <- function(repo_dir = tempdir(), n_pkgs, extra_pkgs = NULL) {
    printMessage("Aquiring list of packages... ", 0, appendLF = FALSE)
    output_dir <- file.path(repo_dir, "manifest")
    if(!dir.exists(output_dir)) {
        gert::git_clone("https://git.bioconductor.org/admin/manifest", 
                        path = file.path(repo_dir, "manifest"),
                        verbose = FALSE)
    }
    manifest <- scan(file.path(repo_dir, "manifest", "software.txt"), 
                     what = character(), quiet = TRUE,
                     blank.lines.skip=TRUE, sep = "\n", skip = 1)
    manifest <- gsub("Package: ", "", x = manifest, fixed = TRUE)
    
    if(!is.null(extra_pkgs)) {
        extra_pkgs <- extra_pkgs[extra_pkgs %in% manifest]
        manifest <- c(extra_pkgs, manifest)
    }
    
    if(is.finite(n_pkgs)) {
        manifest <- manifest[seq_len(n_pkgs)]
    }
    message("done")
    return(manifest)
}

getRSSfeed <- function(devel = TRUE) {
    url <- ifelse(devel,
                  'https://bioconductor.org/developers/rss-feeds/gitlog.xml',
                  'https://bioconductor.org/developers/rss-feeds/gitlog.release.xml')
    
    feed <- suppressMessages(
        tidyfeed(url, parse_dates = FALSE, list = TRUE) %>%
            magrittr::extract2("entries")
    )
    return(feed)
}

## Around release time updates may take longer than the time between cron jobs
## Detect if a lock file from a running process exists and exit if so.
## Lock files older than 24 hours are ignored and deleted.
createLockFile <- function(repo_dir) {
    lock_file <- file.path(repo_dir, "lock")
    if(file.exists(lock_file)) {
        if(difftime(Sys.time(), file.mtime(lock_file), units = "hours") < 24) {
            printMessage("Lock file found. Exiting", n = 0)
            quit(save = "no")
        } else {
            printMessage("Removing stale lock file.", n = 0)
            file.remove(lock_file)
        }
    }
    file.create(lock_file)
}

cleanDir <- function(repo_dir, index_dir) {
    existing_pkgs <- list.dirs(repo_dir, recursive = FALSE)
    if(length(existing_pkgs)) {
        printMessage("Deleting existing packages... ", 0, appendLF = FALSE)
        unlink(existing_pkgs, recursive = TRUE)
        message("done")
    }
    
    existing_files <- list.files(repo_dir, full.names = TRUE)
    if(length(existing_files)) {
        printMessage("Deleting existing files... ", 0, appendLF = FALSE)
        file.remove(existing_files)
        message("done")
    }
    
    index_files <- list.files(index_dir, full.names = TRUE)
    if(length(index_files)) {
        printMessage("Deleting index files... ", 0, appendLF = FALSE)
        file.remove(index_files)
        message("done")
    }
}

## Should be run at the end of each update round.
## Updates the saved hashes of the most recent commits
## and removes the lock file for this process
cleanUp <- function(repo_dir) {
    
    old_hash <- file.path(REPO_DIR, "last_hash.rds")
    tmp_hash <- file.path(REPO_DIR, "last_hash_tmp.rds")
    lock_file <- file.path(REPO_DIR, "lock")
    
    ## update the record of the last packages we updated
    printMessage("Writing last_hash.rds... ", 0, appendLF = FALSE)
    if(file.exists(tmp_hash)) {
        if(file.exists(old_hash)) {
            file.remove(old_hash)
        }
        invisible(file.rename(from = tmp_hash, to = old_hash))
    }
    message("done")
    
    printMessage("Removing lock file... ", 0, appendLF = FALSE)
    file.remove(lock_file)
    message("done")
}
