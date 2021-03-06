#!/bin/bash

# names.txt will have to be provided with a list of package names
# separated by a line
# ex.
# xonsh
# event-model

# This script will:

# 1. create a dependency graph of feedstocks
# 2. update version numbers in the dependency graph
# 3. create migrations, but not run them
# 4. run migrations and submit pull requests on GitHub for the nsls-ii-forge
# 5. display the status of migrations/pull requests

# This will use ~/.conda-smithy authentication for GitHub token
# It will use nsls2forge username on GitHub
# It will not fork repositories but instead create new branches
# It will use a max of 10 workers to build the graph

# If something goes wrong while executing this script
# please use 'auto-tick clean', fix the issue, and try again

# will stop execution if error occurs
set -e

# activate environment from setup.sh
source ~/mc/etc/profile.d/conda.sh
conda env list
conda activate botenv
# list of packages to be updated (in graph)
echo "=================="
cat names.txt
echo "=================="
# clean current directory of bot files
auto-tick clean -y
# create graph with node_attrs/* and graph.json
time graph-utils make -o nsls-ii-forge -c -f names.txt -m 10
# update graph with new versions from their sources (see versions/*)
time graph-utils update
# dry run of migrations to catch errors before PRs
auto-tick run --dry-run
# full run of migrations and submit PRs (see pr_json/*)
time auto-tick run
# output status of migrations to status/*
auto-tick status
# cleanup
auto-tick clean -y
