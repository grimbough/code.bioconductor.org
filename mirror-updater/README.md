# mirror-updater — Repository Mirroring and Zoekt Indexing

## Description
The `mirror-updater` directory contains scripts and Docker configuration to:
- Maintain a **local mirror** of all Bioconductor Git repositories.
- Keep the **Zoekt code search index** up-to-date.

These components power the repository browsing and search features on [code.bioconductor.org](https://code.bioconductor.org).

## Responsibilities
- Clone all repositories from the Bioconductor Git server when no local mirror exists.
- Update existing mirrored repositories by fetching recent commits.
- Regenerate Zoekt index files for repositories that have changed.

## Command-Line Interface

The main scipt is found in `check_rss_feed.R`.  This will `source()` the other files in this directory.  It can be run via `Rscript` and can take the following options to modifiy it's behaviour.  This can be useful when developing locally to test specific behaviours.

| Flag            | Description |
|-----------------|-------------|
| `--all`         | When local mirror exists, updates all repositories and clones any missing ones. |
| `--clean`       | Clears the local mirror entirely and reloads from scratch. |
| `--npkgs=N`     | When initializing or cleaning, limits cloning to the first `N` packages for testing. |
| `--extra_pkgs=` | Include specific named packages, e.g. `--extra_pkgs="c(\"rhdf5\", \"biomaRt\")"`. |

