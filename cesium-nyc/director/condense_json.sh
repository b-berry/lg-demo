#!/bin/bash

# Get dir
if [ ! -d $1 ]; then
  echo "Please provide a hostname dir to parse *.json"
  exit 1
else
  pushd $1
fi

function check_status {

  if [ $1 -gt 0 ]; then
    echo "FAIL"
    popd && exit 1
    else
      echo "OK"
    fi

}

BACKUP_DIR=".backup"

# Run modification operations
for n in *.json; do 
  echo $n
  if [[ $n == *"condensed.json" ]]; then
    # Backup previous snippets
    if [ ! -d "$BACKUP_DIR" ]; then
      printf "Creating backup directory: $BACKUP_DIR "
      mkdir -p "$BACKUP_DIR"
      check_status $?
    fi
    NAME="${n%-condensed.json}-$(date +%Y%m%d-%H%M)-condensed.json"
    printf "Creating backup file: $NAME "
    mv $n "$BACKUP_DIR/$NAME"
    check_status $?
  else 
    unset JSON
    printf "Condensing: $n "
    JSON="$(echo "\"uscs_message\": \"{$(cat $n | sed -e '1,2d' | tr -d '\n' | sed -e 's/\ //g' | sed -e 's/\"/\\\"/g')\",")"
    check_status $?
    FILE="${n%.json}-condensed.json"
    printf "Directing uscs_message to: $FILE "
    echo "        $JSON" > $FILE &&\
    check_status $?
  fi
done

popd

