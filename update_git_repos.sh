#!/bin/bash

BRANCHES=("RELEASE_3_11" "master")
#DIR=/tmp/repositories/
DIR=/home/mike/repositories/

touch "$DIR/ignored_packages.txt"
readarray -t ignored < "$DIR/ignored_packages.txt"

echo -n "Acquiring list of packages... "
ssh -i "$HOME/.ssh/xps_key" git@git.bioconductor.org info | grep -e "packages" | cut -f 2 | tail -n +3 | cut -f 2 -d "/" | head -n 57 > /tmp/packages.txt
echo "done"

mkdir -p ${DIR}
cd ${DIR}
while read PACK; do

    echo "Package: ${PACK}"
    echo "  `date`"

    ## check if we've added this package to our ignore list
    if [[ " ${ignored[@]} " =~ " ${PACK} " ]]; then
        echo "  Found in ignore list... skipped"
	    continue
    fi

	if [[ ! -d "${PACK}" ]]
	then
	    
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

		if [[ "$dirsize" -gt 150000 ]]
		then
		    echo -n "  Repository too large... "
		    echo "${PACK}" >> ignored_packages.txt
		    rm -r "${PACK}"
		    echo "removed"
            continue
		fi

	else
        cd $PACK
        echo "  Repository already exists"
        for BRANCH in ${BRANCHES[@]}
        do
            remote=`git ls-remote origin $BRANCH | cut -f 1`
            local=`git rev-parse $BRANCH`

            if [[ "$remote" != "$local" ]]
            then
                echo -n "  Updating $BRANCH branch... "
                git checkout $BRANCH 
	            git pull origin $BRANCH
	            echo "done"
            fi
        done
        
        ## finish on the master branch
        curbranch=`git rev-parse --abbrev-ref HEAD`
        if [[ "$curbranch" != "master" ]]; then
            git checkout master
        fi
        
		cd ../
	fi
done </tmp/packages.txt


