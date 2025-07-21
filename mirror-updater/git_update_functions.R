
## Packages that aren't found in the manifest should be removed
## Also make sure the zoekt index is deleted
removePackages <- function(manifest, existing_pkgs, index_dir) {
    printMessage("Checking for packages to remove... ", 0)
    pkg_status <- basename(existing_pkgs) %in% manifest
    if(any(!pkg_status)) {
        pkgs_rm <- existing_pkgs[!pkg_status]
        for(pkg in pkgs_rm) {
            printMessage(basename(pkg), 2)
            unlink(pkg, recursive = TRUE)
            zoekt_indices <- file.path(index_dir, paste0(basename(pkg), "*", ".zoekt"))
            unlink(zoekt_indices, recursive = FALSE, expand = TRUE)
        }
    } else {
        printMessage("None found", 2)
    }
    printMessage("done", 0)
}

getChangedPackages <- function(manifest, repo_dir) {
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

getNewPackages <- function(manifest, repo_dir) {
    manifest[!(manifest %in% list.dirs(repo_dir, full.names = FALSE))]
}

## Packages to update should either be those with more recent commits
## than the last one we can identify AND new packages in the manifest we
## don't currently have.
getPackagesToUpdate <- function(manifest, repo_dir) {

    changed_pkgs <- getChangedPackages(manifest, repo_dir)
    new_pkgs <- getNewPackages(manifest, repo_dir)

    return(unique(c(new_pkgs, changed_pkgs)))
}



clonePackage <- function(pkg_name, repo_dir, tmp_log = NULL) {
    
    out_path <- file.path(repo_dir, pkg_name)
    ## gert doesn't like a double slash in the path
    out_path <- gsub("//", "/", out_path)
    
    if(!dir.exists(out_path)) {
        printMessage("Cloning repository... ", 2, appendLF = FALSE, tmp_log = tmp_log)
        gert::git_clone(paste0("https://git.bioconductor.org/packages/", pkg_name),
                        path = out_path,
                        verbose = FALSE)
        printMessage("  done", 0, timestamp = FALSE, tmp_log = tmp_log)
    } else {
        printMessage("  Directory already exists", 0, timestamp = FALSE, tmp_log = tmp_log)
    }
}

## ensure we have a local copy of devel and all RELEASE branches
checkoutBranches <- function(pkg_name, repo_dir, tmp_log = NULL) {
    repo <- file.path(repo_dir, pkg_name)
    ## gert doesn't like a double slash in the path
    repo <- gsub("//", "/", repo)

    if(!dir.exists(repo)) {
    } else {
        printMessage("Checking out branches... ", n = 2, tmp_log = tmp_log)

        ## only interested in RELEASE and devel branches
        branches <- gert::git_branch_list(local = FALSE, repo = repo) %>%
            filter(grepl("(RELEASE_[1-9]_[0-9]{1,2}$|devel)", name)) %>%
            arrange(desc(name))

        for(b in branches$name) {
            printMessage(basename(b), n = 4, tmp_log = tmp_log)
            suppressMessages(
                gert::git_branch_checkout(branch = basename(b), repo = repo)
            )
        }
        ## finish with the devel branch checkout
        suppressMessages(
            gert::git_branch_checkout(branch = "devel", repo = repo)
        )
        printMessage("done", appendLF = TRUE, n = 2, tmp_log = tmp_log)
    }
}

updateBranches <- function(pkg_name, repo_dir, tmp_log = NULL) {

    repo <- file.path(repo_dir, pkg_name)
    repo <- gsub("//", "/", repo)

    printMessage("Updating branches... ", 2, appendLF = TRUE, tmp_log = tmp_log)

    gert::git_fetch(repo = repo, verbose = FALSE)
    ## update the two most recent branches - should be devel and current release
    branches <- gert::git_branch_list(local = FALSE, repo = repo) %>%
        filter(grepl("(RELEASE_[1-9]_[0-9]{1,2}$|devel)", name)) %>%
        arrange(desc(updated)) %>%
        slice(1:2)
    for(b in branches$name) {
        printMessage(basename(b), n = 4, tmp_log = tmp_log)
        gert::git_branch_checkout(branch = basename(b), repo = repo)
        suppressMessages(
            gert::git_pull(repo = repo, verbose = FALSE)
        )
    }
    ## finish with the devel branch checkout
    suppressMessages(
        gert::git_branch_checkout(branch = "devel", repo = repo)
    )

    printMessage("done", n = 2, tmp_log = tmp_log)
}

processMostRecentCommit <- function(pkg_name, repo_dir) {
    
    repo <- file.path(repo_dir, pkg_name)
    repo <- gsub("//", "/", repo)
    if(!dir.exists(repo)) {
        stop("directory doesn't exist")
    }

    ## sort branches by commit time.  Sometimes RELEASE and devel will be identical
    ## Sorting on branch isn't reliable, so we resolve this below
    top2commits <- gert::git_branch_list(local = TRUE, repo = repo) %>% 
        filter(grepl("(RELEASE_[1-9]_[0-9]{1,2}$|devel)", name)) %>%
        arrange(desc(updated)) %>% 
        slice(1:2)

    if(identical(top2commits$updated[1], top2commits$updated[2])) {
        most_recent_commit <- filter(top2commits, name == "devel")
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

## create a placeholder table when the site is being updated
createUnderConstruction <- function(repo_dir) {

    json_content <- c(
        "The code browser is undergoing maintenance",
        "It will return soon"
    )

    message <- toJSON(list(data = list(json_content)), pretty = TRUE)

    writeLines(message, con = file.path(repo_dir, "packages.json"))
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

    ## combine our updated packages with the existing database
    if(merge) {
        old_commit_messages <- readRDS(rds_file)
        for(i in pkgs) {
            old_commit_messages[[ i ]] <- commit_messages[[ i ]]
        }
        commit_messages <- old_commit_messages
    }
    
    saveRDS(commit_messages, file = rds_file)
    ## munging to get json in the format for DataTable HTML
    json_pkg_list <- toJSON(list(data = do.call(rbind, commit_messages)), pretty = TRUE)
    writeLines(json_pkg_list, con = file.path(repo_dir, "packages.json"))
    printMessage("  done", 0, timestamp = FALSE)
    
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

updateSingleRepository <- function(pkg, pkgs, repo_dir) {
    tmp_log <- tempfile()
    printMessage(sprintf("Package: %s (%i of %i)", pkg, which(pkgs == pkg), length(pkgs)), n = 0, tmp_log = tmp_log)
    repo <- file.path(repo_dir, pkg)
    skipped_pkg <- FALSE
    if (!dir.exists(repo)) {
        skip <- tryCatch(
            {
                clonePackage(pkg, repo_dir = repo_dir, tmp_log = tmp_log)
            },
            error = function(cond) {
                printMessage("Failed to clone package!", n = 0, appendLF = TRUE, timestamp = FALSE, tmp_log = tmp_log)
                return(TRUE)
            }
        )
        if (isTRUE(skip)) {
            skipped_pkg <- TRUE
        } else {
            checkoutBranches(pkg, repo_dir = repo_dir, tmp_log = tmp_log)
        }
    } else {
        skip <- tryCatch(
            {
                updateBranches(pkg, repo_dir = repo_dir, tmp_log = tmp_log)
            },
            error = function(cond) {
                printMessage(sprintf("Failed to update branches! Message: %s", cond),
                    n = 0, timestamp = TRUE, tmp_log = tmp_log
                )
                return(TRUE)
            }
        )
        if (isTRUE(skip)) {
            skipped_pkg <- TRUE
        }
    }
    writeTmpMessage(tmp_log = tmp_log)
    return(skipped_pkg)
}


updateRepositories <- function(repo_dir, manifest, update_all = FALSE) {

    printMessage("Updating repositories", 0)

    if(update_all) {
        pkgs <- manifest
    } else {
        pkgs <- getPackagesToUpdate(manifest = manifest, repo_dir = repo_dir)
    }
    I
    if(length(pkgs) == 0) {
        printMessage("No updates found", 2)
        return(NULL)
    } else {
        extra <- ifelse(length(pkgs) > 10, paste("+", length(pkgs) - 10, "more"), "")
        printMessage(paste("Updating:", paste(c(head(pkgs, 10), extra), collapse = ", ")), 2)
        skipped_pkgs <- NULL

        skipped <- parallel::mclapply(pkgs, FUN = updateSingleRepository, pkgs = pkgs, repo_dir = repo_dir, mc.cores = 3L)
        # for(i in seq_along(pkgs)) {
        #     pkg <- pkgs[i]
        #     tmp_log <- tempfile()
        #     printMessage(sprintf("Package: %s (%i of %i)", pkg, i, length(pkgs)), n = 0, tmp_log = tmp_log)
        #     repo <- file.path(repo_dir, pkg)

        #     if(!dir.exists(repo)) {
        #         skip <- tryCatch({
        #             clonePackage(pkg, repo_dir = repo_dir, tmp_log = tmp_log)
        #         },
        #         error = function(cond) {
        #             printMessage("Failed to clone package!", n = 0, appendLF = TRUE, timestamp = FALSE, tmp_log = tmp_log)
        #             return(TRUE)
        #         })
        #         if(isTRUE(skip)) { 
        #             skipped_pkgs <- c(skipped_pkgs, pkg)
        #         } else {
        #             checkoutBranches(pkg, repo_dir = repo_dir, tmp_log = tmp_log)
        #         }
        #     } else {
        #         skip <- tryCatch({
        #             updateBranches(pkg, repo_dir = repo_dir, tmp_log = tmp_log)
        #         },
        #         error = function(cond) {
        #             printMessage(sprintf("Failed to update branches! Message: %s", cond),
        #                          0, timestamp = TRUE, tmp_log = tmp_log)
        #             return(TRUE)
        #         })
        #         if(isTRUE(skip)) { skipped_pkgs <- c(skipped_pkgs, pkg) }
        #     }
        #     writeTmpMessage(tmp_log = tmp_log)
        # }
        skipped_pkgs <- pkgs[unlist(skipped)]
        pkgs <- setdiff(pkgs, skipped_pkgs)
        printMessage("Finished updating repositories", 0)
        return(pkgs)
    }
}
