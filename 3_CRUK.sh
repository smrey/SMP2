#!/bin/bash
set -euo pipefail

#Description: CRUK BaseSpace app pipeline
#Author: Sara Rey
#Status: DEVELOPMENT/TESTING
Version="1.1.0"

# Path to node bin directory (do not include trailing /)
NODE="/share/apps/node-distros/node-v6.11.3-linux-x64/bin"

# Path to location of node_modules
NODE_MOD=$(echo $NODE | awk -F '/' 'BEGIN {OFS = FS} NF{NF--; print $0}')

# Launch node javascript file and pass node path to script
"$NODE"/node ./baseSpace.js "$NODE_MOD"