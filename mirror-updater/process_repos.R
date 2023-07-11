REPO_DIR <- Sys.getenv("GIT_REPOS_DIR")

current_pkgs <- list.dirs(REPO_DIR, recursive = FALSE)

printMessage("Finding current disk usage... ", 0, appendLF = FALSE)
du_in_KiB <- system2("du", args = sprintf("-s -k %s", REPO_DIR), stdout = TRUE) |>
    tail(1) |> 
    gsub(pattern = "\\t.*$", replacement = "") |>
    as.numeric()
printMessage(sprintf(" %s GiB", round(du_in_KiB / (1024^2), digits = 2)), 0, timestamp = FALSE)

printMessage("Getting all git commits... ", 0, appendLF = TRUE)
all_commits <- list()
for(i in current_pkgs) {
    printMessage(basename(i), 2)
    if(basename(i) %in% c("STATegRa", "flowDensity")) {
        printMessage("skipped!", 4)
        next;
    }
    all_commits[[ i ]] <- git_log(ref = "devel", repo = i, max = 10e7) |>
        select("author", "time") |>
        mutate(repo = basename(i))
}
printMessage(" done", 0)

printMessage("Writing commit table... ", 0, appendLF = FALSE)
tmp <- lapply(all_commits, FUN = function(x) {
    x |> group_by(repo) |>
    summarise(all_time = n(),
              last_year = length(which(time > (today() - years(1)))),
              last_month = length(which(time > (today() - months(1)))),
    ) |> unlist()
})
commit_counts_json <- toJSON(list(data = do.call(rbind, tmp)), pretty = TRUE)
writeLines(commit_counts_json, con = file.path(REPO_DIR, "commit_counts.json"))
printMessage(" done", 0, timestamp = FALSE)
