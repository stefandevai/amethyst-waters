#!/bin/bash

# Global variables:
# -----------------
# SOURCE_FILES:  Fennel source files to be compiled
# SOURCE_DIR:    Directory to which the lua output file will be placed
# OUT_FILE:      Name of the output lua file
# BUILD_DIR:     Directory for the build files
# DATA_FILE:     File containing sprite, map and palette data for TIC-80

SOURCE_FILES=(main.fnl)
SOURCE_DIR=source
OUT_FILE=game.lua
BUILD_DIR=build
DATA_FILE=data.lua

# Compiles all source Fennel files to a single Lua file
# -----------------------------------------------------

compile()
{
  mkdir -p build
  echo "Compiling source files (${SOURCE_FILES[*]}) to $OUT_FILE..."
  echo "" > $BUILD_DIR/out.fnl

  for file in "${SOURCE_FILES[@]}"; do
    cat $SOURCE_DIR/"$file" >> $BUILD_DIR/out.fnl
  done

  fennel --compile $BUILD_DIR/out.fnl > $BUILD_DIR/$OUT_FILE
  cat $DATA_FILE >> $BUILD_DIR/$OUT_FILE
}

# Runs the compiled lua file with TIC-80
# --------------------------------------

run()
{
  echo "Running $OUT_FILE with TIC-80..."
  tic80 $SOURCE_DIR/main.fnl
}

# Prints usage instructions
# -------------------------
usage()
{
  echo "
FENNEL UTILS

Created by Stefan Devai <https://github.com/stefandevai>

USAGE: ./utils.sh [command]

COMMANDS:
  -c, --compile    Compile fennel source files in ./source
  -r, --run        Run compiled file with TIC-80
  -h, --help       Show this prompt
"
}

# Parses command line arguments:
# ------------------------------
# -c, --compile: compile source files
# -r, --run:     run compiled file with tic80

if [ "$#" -gt 0 ]; then
  while [ "$1" != "" ]; do
    case $1 in
      -c | --compile )
        compile
        ;;
      -r | --run )
        run
        ;;
      * )
        usage
        exit 1
    esac
    shift
  done
else
  usage
fi

