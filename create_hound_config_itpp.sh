#!/bin/bash

echo -n "creating Hound ITPP config... "

TMPFILE=/tmp/config-itpp.tmp
OUTPUT="$HOME/bioc-code-tools/hound/config-itpp.json"
REPOS="$HOME/repositories"

echo -e "{
\t\"max-concurrent-indexers\" : 2,
\t\"max-concurrent-searchers\" : 2,
\t\"dbpath\" : \"db\",
\t\"title\" : \"BioC Code Search\",
\t\"health-check-uri\" : \"/healthz\",
\t\"repos\" : [" > "${TMPFILE}"

for dir in "$REPOS"/*/     # list directories in the form "/tmp/dirname/"
do
    dir=${dir%*/}      # remove the trailing "/"
    echo -e "\t\t{" >> "${TMPFILE}" 
    echo -e "\t\t\t\"name\" : \"${dir##*/}\"," >> "${TMPFILE}" 
    echo -e "\t\t\t\"url\" : \"file:///${dir}\"," >> "${TMPFILE}"
    echo -e "\t\t\t\"ms-between-poll\" : 3600000" >> "${TMPFILE}"
    echo -e "\t\t}," >> "${TMPFILE}"
done

readarray -t a < "${TMPFILE}"

## remove temp file and output if it exists
rm "${TMPFILE}"
if [[ -f "${OUTPUT}" ]]; then
    rm "${OUTPUT}"
fi

## write all but last line of out temp to outfile
for ((i=0; i<${#a[@]}-1; i++)); do
    echo "${a[$i]}" >> "${OUTPUT}"
done

echo "done"

echo -e "\t\t}\n\t]\n}" >> "${OUTPUT}"

exit
