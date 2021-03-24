#!/bin/bash

GOPATH=$HOME/go

echo -n "creating Zoekt index... "

INDEX_DIR="${ZOEKT_INDEX_DIR}"
REPOS="${GIT_REPOS_DIR}"

for dir in "$REPOS"/*/     # list directories in the form "/tmp/dirname/"
do
	PACKAGE=${dir%*/}
	echo "$PACKAGE"
	$GOPATH/bin/zoekt-index -index "$INDEX_DIR" "$PACKAGE" 
done

echo "done"

exit
