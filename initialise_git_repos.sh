#!/bin/bash

source $HOME/bioc-code-tools/helper_functions.sh

BRANCHES=("RELEASE_3_11" "master")
REPO_DIR="$HOME/repositories/"
MANIFEST="/tmp/packages.txt"

## checkout manifest
echo -n "Acquiring list of packages... "
cd "$HOME"
git clone https://git.bioconductor.org/admin/manifest
cat manifest/software.txt | cut -d' ' -f2 | sed -r '/^[[:space:]]*$/d' | head -n 25 > "$MANIFEST"
echo "done"


while read PACK; do

    echo "Package: ${PACK}"
    echo "  `date`"

    ## check if we've added this package to our ignore list
    if [[ " ${ignored[@]} " =~ " ${PACK} " ]]; then
        echo "  Found in ignore list... skipped"
        continue
    fi

    echo -n "  Cloning repository... "
    git clone --quiet "https://git.bioconductor.org/packages/${PACK}" > /dev/null
    echo "done"
    
    echo -n "  Checking out branches... "
    cd "${PACK}"
    for BRANCH in ${BRANCHES[@]}
    do
        git checkout --quiet "$BRANCH" > /dev/null
    done
    echo "done"

    cd ../
    ## find the size of the downloaded repo
    ## we will remove any that are too large
    dirsize=`du -s "${PACK}" | cut -f1`

    if [[ "$dirsize" -gt 200000 ]]
    then
        echo -n "  Repository too large... "
        echo "${PACK}" >> ignored_packages.txt
        rm -r "${PACK}"
        echo "removed"
        continue
    fi

done <"$MANIFEST"