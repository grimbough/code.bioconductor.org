#!/bin/bash

source $HOME/bioc-code-tools/helper_functions.sh

BRANCHES=("RELEASE_3_11" "master")
#DIR=/home/ubuntu/repositories/
DIR="$HOME/repositories/"
TMPDB=/tmp/packages_tmp.db
FINALDB=/tmp/packages.db

TMPJSON=/tmp/packages_tmp.json
FINALJSON="$DIR/packages.json"

## create sqlite database for packages and latest commits
if [[ -f "$TMPDB" ]]; then
    rm "$TMPDB"
fi
sqlite3 "$TMPDB" "CREATE TABLE packages (pkg_name TEXT PRIMARY KEY, author TEXT NOT NULL, date TEXT NOT NULL, branch TEXT NOT NULL);"

## create sqlite database for packages and latest commits
if [[ -f "$TMPJSON" ]]; then
    rm "$TMPJSON"
fi
echo -e "{\n\t\"data\": [" > "$TMPJSON"


touch "$DIR/ignored_packages.txt"
readarray -t ignored < "$DIR/ignored_packages.txt"

echo -n "Acquiring list of packages... "
ssh -i "$HOME/.ssh/xps_key" git@git.bioconductor.org info | grep -e "packages" | cut -f 2 | tail -n +3 | cut -f 2 -d "/" | head -n 50 > /tmp/packages.txt
#ssh -i "$HOME/.ssh/xps_key" git@git.bioconductor.org info | grep -e "packages" | cut -f 2 | tail -n +3 | cut -f 2 -d "/" > /tmp/packages.txt
echo "SummarizedExperiment" >> /tmp/packages.txt
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
            rm -r "${PACK}"
            echo "removed"
            continue
        fi
        
        ## add commit info to package db
        sqlite3 "$TMPDB" "insert into packages (pkg_name, author, date, branch) values (\"$PACK\", \"${author}\", \"$date\", \"master\");"

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
        sqlite3 "$TMPDB" "insert into packages (pkg_name, author, date, branch) values (\"$PACK\", \"${recent_author}\", \"$recent_date\", \"$recent_branch\");"
        echo -e "\t\t[" >> "$TMPJSON"
        echo -e "\t\t\t\"<i class='fas fa-folder'></i>&nbsp;<a href=\\\"/gitlist/$PACK\\\">$PACK</a>\"," >> "$TMPJSON"
        echo -e "\t\t\t\"$recent_date by $recent_author to $recent_branch&nbsp;<span class=\\\"subject\\\">'$subject'</span>\"" >> "$TMPJSON"
        echo -e "\t\t], " >> "$TMPJSON"
        echo "done"
        
        cd ../
    fi
done </tmp/packages.txt

echo -n "Moving database..."
mv "$TMPDB" "$FINALDB"
echo "done"

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

$HOME/bioc-code-tools/create_hound_config.sh
$HOME/bioc-code-tools/create_hound_config_itpp.sh

