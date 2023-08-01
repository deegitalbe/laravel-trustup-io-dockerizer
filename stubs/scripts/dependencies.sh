#!/bin/bash

echo -e "$(cat .dockerdependencies) \n" | while read project
do
  if [ "$project" != "" ]
    then
      cd ../ && ./cli $1 $project && cd $PWD
  fi
done