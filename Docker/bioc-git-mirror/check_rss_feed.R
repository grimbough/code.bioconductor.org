REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")
if(!nzchar(REPO_DIR)) {
    stop("Repo directory not set\n",
    "Please set the GIT_REPOS_DIR environment variable.")
}

getPackagesToUpdate <- function() {

    feed <- suppressMessages(
        tidyfeed('https://bioconductor.org/developers/rss-feeds/gitlog.xml')
    )

    feed %>% 
	    filter(item_pub_date > lubridate::now() - minutes(20)) %>% 
	    magrittr::extract2("item_title") %>% 
	    unique() 
}

getManifest <- function(repo_dir = tempdir(), n_pkgs) {
    message("Aquiring list of packages... ", appendLF = FALSE)
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
    if(!missing(n_pkgs)) {
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
        branches <- gert::git_branch_list(local = FALSE, repo = repo)
        for(b in branches$name) {
            printMessage(basename(b), 4)
            suppressMessages(
                gert::git_branch_checkout(branch = basename(b), repo = repo)
            )
        }
        printMessage("done", 2)
    }
}

updateBranches <- function(pkg_name, repo_dir) {
    
    repo <- file.path(repo_dir, pkg_name)
    repo <- gsub("//", "/", repo)
    
    printMessage("Updating branches... ", 2, appendLF = FALSE)
    
    branches <- gert::git_branch_list(local = TRUE, repo = repo)
    for(b in branches$name) {
        ## update any branch changed in the last 30 minutes
        if(branches$updated > (lubridate::now() - minutes(30))) {
            gert::git_branch_checkout(branch = b, repo = repo)
            gert::git_pull(repo = repo)
        }
    }
    message("done")
}

processMostRecentCommit <- function(pkg_name, repo_dir) {
    
    repo <- file.path(repo_dir, pkg_name)
    repo <- gsub("//", "/", repo)
    if(!dir.exists(repo)) {
        stop("directory doesn't exist")
    }
    
    recent_commits <- lapply(BRANCHES, gert::git_log, max = 1, repo = repo)
    ## determine whether the master or release branch was most recent
    idx <- ifelse(recent_commits[[2]]$time >= recent_commits[[2]]$time, 2, 1)
    
    branch <- BRANCHES[idx]
    commit <- recent_commits[[idx]]
    author <- commit$author
    date <- commit$time
    
    msg <- commit$message
    if(nchar(msg) > 80) { 
        msg <- paste0(strtrim(msg, 80), "...")
    }
    
    json_content <- c(
        paste0("<i class='fas fa-folder'></i>&nbsp;<a href=\\\"/", pkg_name, "\\\">", pkg_name, "</a>"),
        paste0(date, " by ", author, " to ", branch, "&nbsp;<span class=\\\"subject\\\">", msg, "</span>")
    )
    return(json_content)
}


initialiseRepositories <- function(repo_dir) {
    
    pkgs <- getManifest(n_pkgs = 25)
    
    commit_messages <- list()
    
    for(pkg in pkgs) {
        message(pkg)
        clonePackage(pkg, repo_dir = repo_dir)
        checkoutBranches(pkg, repo_dir = repo_dir)
        commit_messages[[pkg]] <- processMostRecentCommit(pkg, repo_dir = repo_dir)
    }
    
    ## munging to get json in the format for DataTable HTML
    json_pkg_list <- toJSON(list(data = do.call(rbind, commit_messages)), pretty = TRUE)
    writeLines(json_pkg_list, con = file.path(repo_dir, "packages.json"))
    
}

printMessage <- function(msg, n, appendLF = TRUE) {
    message("[ ", Sys.time(), " ] ", rep(" ", n), msg, appendLF = appendLF)
}

updateRepositories <- function(repo_dir) {

    printMessage("Updating repositories", 0)
    
    pkgs <- getPackagesToUpdate()
    if(length(pkgs) == 0) {
        printMessage("None found", 2)
        return(FALSE)
    } else {
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
    }
    printMessage("Finished updating repositories", 0)
}

suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyRSS))
suppressPackageStartupMessages(library(gert))
suppressPackageStartupMessages(library(jsonlite))

if(length(list.files(REPO_DIR, "")) == 0) {
    initialiseRepositories(repo_dir = REPO_DIR)
} else {
    updateRepositories(repo_dir = REPO_DIR)
}