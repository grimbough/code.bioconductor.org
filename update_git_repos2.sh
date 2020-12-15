#!/bin/bash

BRANCHES=("RELEASE_3_11" "master")
REPO_DIR="$HOME/repositories/"
MANIFEST="/tmp/packages.txt"

## checkout manifest
echo -n "Updating list of packages... "
cd "$HOME/manifest"
git pull origin master
cat manifest/software.txt | cut -d' ' -f2 | sed -r '/^[[:space:]]*$/d' | head -n 25 > "$MANIFEST"
echo "done"

Rscript check_rss_feed.R

while read PACK; do

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
        
        ## TODO: add new package to json - will be done on next cycle anyway

    else
        cd $PACK
        echo "  Repository already exists"
        recent_date=""
        for BRANCH in ${BRANCHES[@]}; do
        
            ## skip branches that don't exist
            if [[ `is_in_local "$BRANCH"` -eq 0 ]]; then
                echo "  Branch $BRANCH not present"
                continue;
            fi
            
            git checkout --quiet "$BRANCH"      
            remote=`git ls-remote origin $BRANCH | cut -f 1`
            local=`git rev-parse $BRANCH`

            if [[ "$remote" != "$local" ]]
            then
                echo -n "  Updating $BRANCH branch... " 
                git pull origin $BRANCH
                echo "done"
            fi
            
            author=`git log --date=iso-local -n 1 --pretty="%an"`
            date=`git log --date=iso-local -n 1 --pretty="%ad" | cut -f1,2 -d' '`
            subject=`git log --date=iso-local -n 1 --pretty="%s"`
            if [[ "$recent_date" == "" ]] || [[ ! "$recent_date" > "$date" ]]; then
                recent_date="$date"
                recent_branch="$BRANCH" 
                recent_author="$author"
                ## trim commit messages to 80 characters
                if [[ "${#subject}" > 80 ]]; then
                    subject=`echo "$subject" | cut -c 1-80`
                    subject=${subject}...
                fi
                ## santitize
                subject=$(echo "$subject" | sed  -r "s/\\\"/\\\\\"/g")
                recent_subject="$subject"
            fi
            
        done
        
        ## finish on the master branch
        curbranch=`git rev-parse --abbrev-ref HEAD`
        if [[ "$curbranch" != "master" ]]; then
            git checkout master
        fi
        
        echo -n "  Updating commit database... "
        echo -e "\t\t[" >> "$TMPJSON"
        echo -e "\t\t\t\"<i class='fas fa-folder'></i>&nbsp;<a href=\\\"/$PACK\\\">$PACK</a>\"," >> "$TMPJSON"
        echo -e "\t\t\t\"$recent_date by $recent_author to $recent_branch&nbsp;<span class=\\\"subject\\\">'$subject'</span>\"" >> "$TMPJSON"
        echo -e "\t\t], " >> "$TMPJSON"
        echo "done"
        
        cd ../
    fi

done </tmp/packages_to_update.txt

echo -n "Moving JSON..."
readarray -t a < "${TMPJSON}"
if [[ -f "$FINALJSON" ]]; then
    rm "$FINALJSON"
fi
## write all but last line due to issues with commas
for ((i=0; i<${#a[@]}-1; i++)); do
    echo "${a[$i]}" >> "$FINALJSON"
done
echo -e "\t\t]\n\t]\n}" >> "$FINALJSON"
echo "done"