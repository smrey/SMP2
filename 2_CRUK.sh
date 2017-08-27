#!/bin/bash
set -euo pipefail

#Description: CRUK Basespace app pipeline
#Author: Sara Rey
#Status: DEVELOPMENT/TESTING
Version=0.1

# Aliases for local python VE
alias python='/home/transfer/basespace_vm/venv/bin/python'
PATH="$PATH":/home/transfer/basespace_vm/venv/bin/

# How to use
# bash 2_CRUK.sh <path/to/local/folder/to/download/results/>

# Variables- load in from config file
CONFIG=
projectId=
appResultsId=


bs cp conf://"$CONFIG"/Projects/"$projectId"/appresults/"$appResultsId"/*.bam "$RESULTSFOLDER"
bs cp conf://"$CONFIG"/Projects/"$projectId"/appresults/"$appResultsId"/*.bai "$RESULTSFOLDER"
bs cp conf://"$CONFIG"/Projects/"$projectId"/appresults/"$appResultsId"/*.xls* "$RESULTSFOLDER"

# Check files have been downloaded and Clear config file ready for next run