pkgsNeeded <- c(
	"lubridate",
	"dplyr",
	"tidyRSS",
	"gert",
	"jsonlite"
)

BRANCHES <- c("RELEASE_3_12", "master")

pkgsAvailable <- installed.packages()[, "Package"]
pkgsToInstall <- setdiff(pkgsNeeded, pkgsAvailable)

if(length(pkgsToInstall)) {
	install.packages(pkgsToInstall, repos = "https://cloud.r-project.org")
}

suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyRSS))

getPackagesToUpdate <- function() {

    feed <- tidyfeed('https://bioconductor.org/developers/rss-feeds/gitlog.xml')

    feed %>% 
	    filter(item_pub_date > lubridate::now() - minutes(10)) %>% 
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
        message("  Cloning repository... ", appendLF = FALSE)
        gert::git_clone(paste0("https://git.bioconductor.org/packages/", pkg_name), 
                    path = file.path(repo_dir, pkg_name),
                    verbose = FALSE)
        message("done")
    } else {
        message("  Directory already exists")
    }
}

checkoutBranch <- function(pkg_name, repo_dir) {
    repo <- file.path(repo_dir, pkg_name)
    ## gert doesn't like a double slash in the path
    repo <- gsub("//", "/", repo)
    
    if(!dir.exists(repo)) {
    } else {
        message("  Checking out branches... ", appendLF = FALSE)
        for(b in BRANCHES) {
            if(gert::git_branch_exists(branch = b, local = FALSE, repo = repo)) {
                gert::git_branch_checkout(branch = b, repo = repo)
            }
        }
        message("done")
    }
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
        paste0(date, " by ", author, " to ", branch, "<span class=\\\"subject\\\">", msg, "</span>")
    )
    return(json_content)
}




initialiseRepositories <- function() {
    
    pkgs <- getManifest(n_pkgs = 25)
    
    commit_messages <- list()
    
    for(pkg in pkgs) {
        message(pkg)
        clonePackage(pkg, repo_dir = "/tmp/repos")
        checkoutBranch(pkg, repo_dir = "/tmp/repos")
        commit_messages[[pkg]] <- processMostRecentCommit(pkg, repo_dir = "/tmp/repos")
    }
    
    ## munging to get json in the format for DataTable HTML
    json_pkg_list <- toJSON(list(data = do.call(rbind, commit_messages)), pretty = TRUE)
    writeLines(json_pkg_list, con = "/tmp/repos/packages_new.json")
    
}