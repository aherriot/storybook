#!/bin/bash

# exit on error
set -e

declare test_root=$PWD

# remove run directory before exit to prevent yarn.lock spoiling
function cleanup {
  rm -rfd ${test_root}/run
}
trap cleanup EXIT

fixtures_dir='fixtures'

# parse command-line options
# '-f' sets fixtures directory
while getopts ":uosf:" opt; do
  case $opt in
    f)
      fixtures_dir=$OPTARG
      ;;
  esac
done

# copy all files from fixtures directory to `run`
rm -rfd run
cp -r $fixtures_dir run
cd run

for dir in *
do
  cd $dir

  # run @storybook/cli
  ../../../bin/index.js init --skip-install

  cd ..
done

cd ..

# install all the dependencies in a single run
cd ../../..
yarn install --non-interactive --silent --pure-lockfile
cd ${test_root}/run

for dir in *
do
  # check that storybook starts without errors
  cd $dir
  echo "Running smoke test in $dir"
  yarn storybook --smoke-test
  cd ..
done
