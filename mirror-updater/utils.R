## Print log with date and message
printMessage <- function(msg, n = 0, appendLF = TRUE, timestamp = TRUE, tmp_log = NULL) {

    if(is.null(tmp_log)) {
        REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")
        log_file <- file.path(REPO_DIR, "status.log")
    } else {
        log_file <- tmp_log
    }

    text <- sprintf("%s%s%s%s", 
                    if(timestamp) timestamp(prefix = "[ ", suffix = " ] ", quiet = TRUE) else "",
                    strrep(" ", n),
                    msg,
                    if(appendLF) "\n" else "")
    ## suppress printing to screen if this is a temporary log
    if(is.null(tmp_log)) {
        message(text, appendLF = FALSE)
    }
    cat(text, file = log_file, append = TRUE)
}

## Here we actually commit the constructed message to stdout and disk
writeTmpMessage <- function(tmp_log) {

    REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")
    log_file <- file.path(REPO_DIR, "status.log")

    lines <- readLines(tmp_log)
    msg <- paste(lines, collapse = "\n")

    message(msg, appendLF = TRUE)
    cat(msg, "\n", file = log_file, append = TRUE)

    ## tidy up
    file.remove(tmp_log)
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
    printMessage("  done", 0, timestamp = FALSE)
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
## Lock files older than 18 hours are ignored and deleted.
createLockFile <- function(repo_dir) {
    lock_file <- file.path(repo_dir, "lock")
    if(file.exists(lock_file)) {
        file_modified <- file.mtime(lock_file)
        if(difftime(Sys.time(), file_modified, units = "hours") < 18) {
            printMessage(paste0("Lock file found. Created at: ", file_modified, ". Exiting"), n = 0)
            quit(save = "no")
        } else {
            printMessage("Removing stale lock file.", n = 0)
            file.remove(lock_file)
        }
    }
    file.create(lock_file)
}

cleanDir <- function(repo_dir, index_dir, exclude_log = TRUE) {
    existing_pkgs <- list.dirs(repo_dir, recursive = FALSE)
    if(length(existing_pkgs)) {
        printMessage("Deleting existing packages... ", 0, appendLF = FALSE)
        unlink(existing_pkgs, recursive = TRUE)
        printMessage("  done", 0, timestamp = FALSE)
    }

    existing_files <- list.files(repo_dir, full.names = TRUE)

    if(exclude_log) {
        idx <- grep("status.log", existing_files)
        if(length(idx) > 0) { existing_files <- existing_files[-idx] }
    }

    if(length(existing_files)) {
        printMessage("Deleting existing files... ", 0, appendLF = FALSE)
        file.remove(existing_files)
        printMessage("  done", 0, timestamp = FALSE)
    }

    index_files <- list.files(index_dir, full.names = TRUE)
    if(length(index_files)) {
        printMessage("Deleting index files... ", 0, appendLF = FALSE)
        file.remove(index_files)
        printMessage("  done", 0, timestamp = FALSE)
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
    printMessage("  done", 0, timestamp = FALSE)

    printMessage("Removing lock file... ", 0, appendLF = FALSE)
    file.remove(lock_file)
    printMessage("  done", 0, timestamp = FALSE)
}


# ## Write a robots.txt file allowing access to the devel branch only
write_robots_txt <- function(pkgs, output_file = "/var/shared/robots.txt") {

    con <- file(output_file, open = "wt")
    on.exit(close(con))

    excluded_bots <- c("Amazonbot", "BLEXBot", "TurnitinBot",
                       "GPTBot", "AhrefsBot", "PetalBot", "ClaudeBot",
                       "SemrushBot", "meta-externalagent", "SEOkicks",
                       "AwarioRssBot", "AwarioSmartBot", "ImagesiftBot",
                       "AliyunSecBot", "Aliyun", "Bytespider")

    for(bot in excluded_bots) {
        writeLines(paste0("User-agent: ", bot), con = con)
        writeLines("Disallow: /\n", con = con)
    }

    writeLines("User-agent: *", con = con)

    writeLines(paste0("Allow: /browse/*/"), con = con)
    writeLines(paste0("Disallow: /browse/*/*/"), con = con)
    writeLines(paste0("Disallow: *tree/"), con = con)
    writeLines(paste0("Disallow: *blob/"), con = con)
    writeLines(paste0("Disallow: *commit"), con = con)
    writeLines(paste0("Disallow: *treegraph"), con = con)
    writeLines(paste0("Disallow: *stats/"), con = con)
    writeLines(paste0("Disallow: *network/"), con = con)
    writeLines(paste0("Disallow: *RELEASE_"), con = con)
    writeLines(paste0("Disallow: *raw/"), con = con)
    writeLines(paste0("Disallow: *logpatch/"), con = con)
    writeLines(paste0("Disallow: *zipball/"), con = con)
    writeLines(paste0("Disallow: *tarball/"), con = con)
    writeLines(paste0("Disallow: *blame/"), con = con)
    writeLines(paste0("Disallow: *rss/"), con = con)
    writeLines(paste0("Disallow: /browse/themes"), con = con)

    writeLines(paste0("Disallow: /search/search?q"), con = con)

    writeLines("\nSitemap: https://code.bioconductor.org/sitemap.txt", con = con)
}

## Write a sitemap.txt providing links to the devel branch only
write_sitemap <- function(pkgs, output_file = "/var/shared/sitemap.txt") {

    con = file(output_file, open = "wt")
    on.exit(close(con))

    writeLines("https://code.bioconductor.org/index.html")
    writeLines("https://code.bioconductor.org/about.html")
    writeLines("https://code.bioconductor.org/search/")
    writeLines("https://code.bioconductor.org/browse/")
    writeLines(paste0("https://code.bioconductor.org/browse/", basename(pkgs), "/"), con = con)
}
