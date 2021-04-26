printMessage <- function(msg, n, appendLF = TRUE) {
    message("[ ", Sys.time(), " ] ", rep(" ", n), msg, appendLF = appendLF)
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

getRSSfeed <- function(devel = TRUE) {
    url <- ifelse(devel,
                  'https://bioconductor.org/developers/rss-feeds/gitlog.xml',
                  'https://bioconductor.org/developers/rss-feeds/gitlog.release.xml')
    
    feed <- suppressMessages(
        tidyfeed('https://bioconductor.org/developers/rss-feeds/gitlog.xml', 
                 parse_dates = FALSE, list = TRUE) %>%
            magrittr::extract2("entries")
    )
    return(feed)
}

getPackagesToUpdate <- function(manifest, repo_dir) {
    
    feed_devel <- getRSSfeed(devel = TRUE)
    feed_release <- getRSSfeed(devel = FALSE)
    
    saveRDS(list(devel = feed_devel$item_guid[1], release = feed_release$item_guid[1]),
            file = file.path(repo_dir, "last_hash_tmp.rds"))
    
    hash_file <- file.path(repo_dir, "last_hash.rds")
    if(file.exists(hash_file)) {
        last_hash <- readRDS(hash_file)
        idx_devel <- which(feed_devel$item_guid == last_hash$devel)-1
        idx_release <- which(feed_release$item_guid == last_hash$release)-1
    } 
    
    ## it could be that we have missed 500+ commits
    ## then update everything
    if(!file.exists(hash_file) || length(idx_devel) == 0 || length(idx_release) == 0) {
        printMessage("Last hash not found", 2)
        pkgs <- manifest
    } else {
        pkgs <- bind_rows(
            slice(feed_devel, seq_len(idx_devel)),
            slice(feed_release, seq_len(idx_release))
        ) %>%
            filter(item_title %in% manifest) %>%
            magrittr::extract2("item_title") %>% 
            unique() 
    }
    return(pkgs)
}

## Get a vector containing the names of all packages currently part of 
## Bioconductor.  This differs from the complete list of repositories hosted
## on the git server.
getManifest <- function(repo_dir = tempdir(), n_pkgs) {
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
    if(is.finite(n_pkgs)) {
        manifest <- manifest[seq_len(n_pkgs)]
    }
    message("done")
    return(manifest)
}

clonePackage <- function(pkg_name, repo_dir) {
    
    out_path <- file.path(repo_dir, pkg_name)
    ## gert doesn't like a double slash in the path
    out_path <- gsub("//", "/", out_path)
    
    if(!dir.exists(out_path)) {
        printMessage("Cloning repository... ", 2, appendLF = FALSE)
        gert::git_clone(paste0("https://git.bioconductor.org/packages/", pkg_name), 
                        path = file.path(repo_dir, pkg_name),
                        verbose = FALSE)
        message("done")
    } else {
        message("  Directory already exists")
    }
}

checkoutBranches <- function(pkg_name, repo_dir) {
    repo <- file.path(repo_dir, pkg_name)
    ## gert doesn't like a double slash in the path
    repo <- gsub("//", "/", repo)
    
    if(!dir.exists(repo)) {
    } else {
        printMessage("Checking out branches... ", 2)
        
        ## only interested in RELEASE and master branches
        branches <- gert::git_branch_list(local = FALSE, repo = repo) %>%
            filter(grepl("(RELEASE_[1-9]_[0-9]{1,2}$|master)", name)) %>%
            arrange(desc(name))
        
        for(b in branches$name) {
            printMessage(basename(b), 4)
            suppressMessages(
                gert::git_branch_checkout(branch = basename(b), repo = repo)
            )
        }
        ## finish with the master branch checkout
        gert::git_branch_checkout(branch = "master", repo = repo)
        printMessage("done", 2)
    }
}

updateBranches <- function(pkg_name, repo_dir) {
    
    repo <- file.path(repo_dir, pkg_name)
    repo <- gsub("//", "/", repo)
    
    printMessage("Updating branches... ", 2, appendLF = TRUE)
    
    gert::git_fetch(repo = repo, verbose = FALSE)
    ## update the two most recent branches - should be devel and current release
    branches <- gert::git_branch_list(local = FALSE, repo = repo) %>%
        filter(grepl("(RELEASE_[1-9]_[0-9]{1,2}$|master)", name)) %>%
        arrange(desc(updated)) %>%
        slice(1:2)
    for(b in branches$name) {
        printMessage(basename(b), 4)
        gert::git_branch_checkout(branch = basename(b), repo = repo)
        suppressMessages(
            gert::git_pull(repo = repo, verbose = FALSE)
        )
    }
    ## finish with the master branch checkout
    gert::git_branch_checkout(branch = "master", repo = repo)
    printMessage("done", 2)
}

processMostRecentCommit <- function(pkg_name, repo_dir) {
    
    repo <- file.path(repo_dir, pkg_name)
    repo <- gsub("//", "/", repo)
    if(!dir.exists(repo)) {
        stop("directory doesn't exist")
    }
    
    ## sort branches by commit time.  Sometimes RELEASE and master will be identical
    ## Sorting on branch isn't reliable, so we resolve this below
    top2commits <- gert::git_branch_list(local = TRUE, repo = repo) %>% 
        arrange(desc(updated)) %>% 
        slice(1:2)
    
    if(identical(top2commits$updated[1], top2commits$updated[2])) {
        most_recent_commit <- filter(top2commits, name == "master")
    } else {
        most_recent_commit <- slice(top2commits, 1)
    }
    
    branch <- most_recent_commit$name[1]
    
    ## Not sure when this can happen, but NA seen on k8s test machine.
    ## Return NULL should be a temporary fix
    if(is.na(branch)) { return(NULL) }
    
    commit_log <- git_log(ref = branch, max = 1, repo = repo)
    author <- gsub(pattern = "( <.*>)", replacement = "", x = commit_log$author)
    date <- commit_log$time
    
    msg <- commit_log$message
    if(nchar(msg) > 80) { 
        msg <- paste0(strtrim(msg, 80), "...")
    }
    
    json_content <- c(
        paste0("<i class='fas fa-folder'></i>&nbsp;<a href='/browse/", pkg_name, "'>", pkg_name, "</a>"),
        paste0(format(date, tz = "UTC"), " UTC by ", author, " to ", branch, "&nbsp;<span class='subject'>", msg, "</span>")
    )
    return(json_content)
}


initialiseRepositories <- function(repo_dir, manifest, n_pkgs) {
    
    ## store the last git commits registered before we begin cloning
    ## we'll use this to make sure we get all updates next time
    feed_devel <- getRSSfeed(devel = TRUE)
    feed_release <- getRSSfeed(devel = FALSE)
    
    rds_tmp_file <- file.path(repo_dir, "last_hash_tmp.rds")
    if(file.exists(rds_tmp_file)) { file.remove(rds_tmp_file) }
    saveRDS(list(devel = feed_devel$item_guid[1], release = feed_release$item_guid[1]),
            file = rds_tmp_file)

    for(pkg in manifest) {
        printMessage(paste0("Package: ", pkg), 0)
        clonePackage(pkg, repo_dir = repo_dir)
        checkoutBranches(pkg, repo_dir = repo_dir)
    }
    
    return(manifest)
}

updateCommitMessages <- function(repo_dir, manifest, pkgs) {
    
    printMessage("Writing packages.json... ", 0, appendLF = FALSE)
    
    json_file <- file.path(repo_dir, "packages.json")
    rds_file <- file.path(repo_dir, "packages.rds")
    merge <- TRUE
    
    ## if we don't specify a list of pkgs update all repos
    if(missing(pkgs) || !file.exists(rds_file)) {
        pkgs <- list.dirs(repo_dir, recursive = FALSE, full.names = FALSE)
        merge <- FALSE
    }
    
    if(any(!pkgs %in% manifest)) {
        pkgs <- pkgs[pkgs %in% manifest]
    }
    
    commit_messages <- sapply(pkgs, FUN = processMostRecentCommit, repo_dir = repo_dir, 
                              simplify = FALSE, USE.NAMES = TRUE)

    ## combine out updated packages with the existing database
    if(merge) {
        old_commit_messages <- readRDS(rds_file)
        for(i in names(pkgs)) {
            old_commit_messages[[ i ]] <- commit_messages[[ i ]]
        }
        commit_messages <- old_commit_messages
    }
    
    saveRDS(commit_messages, file = rds_file)
    ## munging to get json in the format for DataTable HTML
    json_pkg_list <- toJSON(list(data = do.call(rbind, commit_messages)), pretty = TRUE)
    writeLines(json_pkg_list, con = file.path(repo_dir, "packages.json"))
    message("done")
    
}

updateZoektIndices <- function(repo_dir, index_dir, pkgs) {
    printMessage("Updating zoekt indices... ", 0, appendLF = TRUE)
    for(pkg in pkgs) {
        printMessage(pkg, 2, appendLF = TRUE)
        pkg_dir <- file.path(repo_dir, pkg)
        system2(command = "zoekt-index", args = c("-index", index_dir, pkg_dir), 
                stdout = NULL, stderr = NULL)
    }
    printMessage("done")
}


updateRepositories <- function(repo_dir, manifest, update_all = FALSE) {
    
    printMessage("Updating repositories", 0)
    
    if(update_all) {
        pkgs <- manifest
    } else {
        pkgs <- getPackagesToUpdate(manifest = manifest, repo_dir = repo_dir)
    }
    
    if(length(pkgs) == 0) {
        printMessage("No updates found", 2)
        return(NULL)
    } else {
        extra <- ifelse(length(pkgs) > 10, paste("+", length(pkgs) - 10, "more"), "")
        printMessage(paste("Updating:", paste(c(head(pkgs, 10), extra), collapse = ", ")), 2)
        for(pkg in pkgs) {
            printMessage(paste0("Package: ", pkg), 0)
            repo <- file.path(repo_dir, pkg)
            if(!dir.exists(repo)) {
                clonePackage(pkg, repo_dir = repo_dir)
                checkoutBranches(pkg, repo_dir = repo_dir)
            } else {
                updateBranches(pkg, repo_dir = repo_dir)
            }
            
        }
        printMessage("Finished updating repositories", 0)
        return(pkgs)
    }
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
