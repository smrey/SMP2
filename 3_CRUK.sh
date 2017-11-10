#!/bin/bash
set -euo pipefail

#Description: CRUK BaseSpace app pipeline
#Author: Sara Rey
#Status: DEVELOPMENT/TESTING
Version="1.1.0"

# Commandline argument
SAMPLEPAIRS="$1"

# Load any variables file to obtain worksheet id
. $(ls -d */ | tail -n 1)/*.variables

# Path to node bin directory (do not include trailing /)
NODE="/share/apps/node-distros/node-v6.11.3-linux-x64/bin"

# Path to location of node_modules
NODE_MOD=$(echo $NODE | awk -F '/' 'BEGIN {OFS = FS} NF{NF--; print $0}')

# Make directory for results
mkdir "$worklistId"

# Make directories with the tumour sample id name to put the results in
#cd "$worklistId"
cut -f1 "$SAMPLEPAIRS" | xargs -L 1 -i mkdir "$worklistId""/"{}
#cd ..


# Launch node javascript file and pass node path to script
"$NODE"/node ./baseSpace.js "$NODE_MOD" >baseSpace.out 2>baseSpace.err

# 
while read line
	do
		tum=$(printf "$line" | cut -d$'\t' -f1)
		nor=$(printf "$line" | cut -d$'\t' -f2)
		mv "$worklistId"/*"$tum"*.xlsx "$worklistId"/"$tum"
		mv "$worklistId"/*"$tum"*.bam "$worklistId"/"$tum"
		mv "$worklistId"/*"$tum"*.bai "$worklistId"/"$tum"
		mv "$worklistId"/*"$nor"*.bam "$worklistId"/"$tum"
		mv "$worklistId"/*"$nor"*.bai "$worklistId"/"$tum"
done < "$SAMPLEPAIRS" >3_CRUK_copy.out 2>3_CRUK_copy.err