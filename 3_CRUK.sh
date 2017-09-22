#!/bin/bash
set -euo pipefail

#Description: CRUK Basespace app pipeline
#Author: Sara Rey
#Status: DEVELOPMENT/TESTING
Version=2.0

# Path to node
NODE="/share/apps/node-distros/node-v6.11.3-linux-x64/bin/"

# Path to location of node_modules
NODE_MOD=$(echo $NODE | awk -F '/' 'BEGIN {OFS = FS} {print $1, $2, $3, $4, $5}')

# Launch node javascript file and pass node path to script
"$NODE"node ./baseSpace.js "$NODE_MOD"
