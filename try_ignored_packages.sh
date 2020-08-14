#!/bin/bash

source $HOME/bioc-code-tools/helper_functions.sh

BRANCHES=("RELEASE_3_11" "master")
#DIR=/home/ubuntu/repositories/
DIR="$HOME/repositories/"
TMPDB=/tmp/packages_tmp.db
FINALDB=/tmp/packages.db

TMPJSON=/tmp/packages_tmp.json
FINALJSON="$DIR/packages.json"

readarray -t a < "$DIR/ignored_packages.txt"
rm "$DIR/ignored_packages.txt"

mkdir -p ${DIR}
cd ${DIR}
for ((i=0; i<${#a[@]}; i++)); do
    PACK=`echo "${a[$i]}"`

    echo "Package: ${PACK}"

    if [[ ! -d "${PACK}" ]]; then
    
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

        ## find the number of lines in the git log
        ## we will remove empty repos with 0 commits
        ncommits=`git log | wc -l`
        author=`git log --date=iso -n 1 --pretty="%an"`
        date=`git log --date=iso -n 1 --pretty="%ad"`
        cd ../

        ## find the size of the downloaded repo
        ## we will remove any that are too large
        dirsize=`du -s "${PACK}" | cut -f1`

        ## some repos are empty, just delete them
        if [ "$ncommits" -eq 0 ] 
        then
            echo -n "  Empty repository... "
            rm -r "${PACK}"
            echo "${PACK}" >> ignored_packages.txt
            echo "removed"
            continue
        fi

        if [[ "$dirsize" -gt 200000 ]]
        then
            echo -n "  Repository too large... "
            echo "${PACK}" >> ignored_packages.txt
            rm -rf "${PACK}"
            echo "removed"
            continue
        fi
    fi
done;


