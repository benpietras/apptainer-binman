#!/bin/bash

# apptainer_binman.sh
# B.Pietras Nov '24.
# creates bashscripts to replicate binaries inside an apptainer image

# Needs 'template.txt' in pwd
if [[ ! -f ./template.txt ]]; then
  echo "template.txt not found! Exiting."
  exit 1
fi

# Load the below before running script:
module load apps/apptainer/1.3.0

bins=$(mktemp)
template=$(mktemp)
tempo=$(mktemp)

cat template.txt >$template

trap 'rm -rf "$bins" "$template" "$tempo"; exit' ERR EXIT
read -p "Enter /path/to/name.sif: " sif
read -p "Enter exectable path inside sif: " binpath
echo
apptainer exec $sif ls -1 $binpath >$bins
readarray -t bin_array <$bins

# This "THE_SIF" needs to be set in the module file
sif_caps=$(echo $sif | rev | cut -d '/' -f1 | rev | cut -d '.' -f1 | tr '[:lower:]' '[:upper:]')
sif_caps="${sif_caps}_SIF"

if [ ! -d ./bins ]; then
  mkdir -p ./bins
fi

for bin in "${bin_array[@]}"; do
#  echo $bin
  cat $template | sed -e "s|THE_SIF|${sif_caps}|g" -e "s|binpath|${binpath}\/${bin}|g" >$tempo
  cat $tempo >bins/"$bin"
  echo 'bins/'$bin' created'
done

chmod +x bins/*
echo -e '\nDone!'
