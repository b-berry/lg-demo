#!/bin/bash

# Remove previous snippets
rm *_escaped.json
# Run modification operations
for n in *.json; do 
  echo "        \"uscs_message\": \"$(cat $n | tr -d '\n' | sed -e 's/\ //g' | sed -e 's/\"/\\\"/g')\"," > ${n%.json}_escaped.json;
done
