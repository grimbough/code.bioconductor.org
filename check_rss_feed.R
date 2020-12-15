pkgsNeeded <- c(
	"lubridate",
	"dplyr",
	"tidyRSS"
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
