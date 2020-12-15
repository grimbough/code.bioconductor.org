pkgsNeeded <- c(
	"lubridate",
	"dplyr",
	"tidyRSS",
	"gert"
)
output_file <- "/tmp/packages_to_update.txt"

pkgsAvailable <- installed.packages()[, "Package"]
pkgsToInstall <- setdiff(pkgsNeeded, pkgsAvailable)

if(length(pkgsToInstall)) {
	install.packages(pkgsToInstall, repos = "https://cloud.r-project.org")
}


suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyRSS))

feed <- tidyfeed('https://bioconductor.org/developers/rss-feeds/gitlog.xml')

feed %>% 
	filter(item_pub_date > lubridate::now() - minutes(10)) %>% 
	magrittr::extract2("item_title") %>% 
	unique() %>% 
	writeLines(output_file)

getManifest <- function(repo_dir = "/tmp/manifest", n_pkgs) {
  message("Aquiring list of packages... ", appendLF = FALSE)
  gert::git_clone("https://git.bioconductor.org/admin/manifest", path = repo_dir)
  manifest <- scan(file.path(repo_dir, "software.txt"), what = character(), 
       blank.lines.skip=TRUE, sep = "\n", skip = 1)
  manifest <- gsub("Package: ", "", x = manifest, fixed = TRUE)
  if(!missing(n_pkgs)) {
    manifest <- manifest[seq_len(n_pkgs)]
  }
  message("done")
  return(manifest)
}
