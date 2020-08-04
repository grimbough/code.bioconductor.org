#!/bin/bash

BRANCHES=("RELEASE_3_11" "master")
DIR=/tmp/repositories/

ssh -i "xps_key" git@git.bioconductor.org info | grep -e "packages" | cut -f 2 | tail -n +3 | cut -f 2 -d "/" | head -n 50 > /tmp/packages.txt

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
		cd ../
	else
        cd $PACK
        git remote update
		cd ../
	fi
done </tmp/packages.txt


