#!/bin/bash

BRANCHES=("RELEASE_3_11" "master")
#DIR=/tmp/repositories/
DIR=/home/mike/repositories/

ssh -i "$HOME/.ssh/xps_key" git@git.bioconductor.org info | grep -e "packages" | cut -f 2 | tail -n +3 | cut -f 2 -d "/" | head -n 50 > /tmp/packages.txt

mkdir -p ${DIR}
cd ${DIR}
while read PACK; do
    echo ${PACK}
	if [[ ! -d "${PACK}" ]]
	then
		git clone "https://git.bioconductor.org/packages/${PACK}"
		cd "${PACK}"
		for BRANCH in ${BRANCHES[@]}
		do
			git checkout $BRANCH
		done
		## find the number of lines in the git log
		tmp=`git log | wc -l`
		cd ../

		## some repos are empty, just delete them
		if [ "$tmp" -eq 0 ] 
		then
		    rm -r ${PACK}
		fi

	else
        cd $PACK
        git remote update
		cd ../
	fi
done </tmp/packages.txt


