#!/bin/sh

function check_that_file_exist {
  FILE="$1"
  if [ ! -f "$FILE" ]; then
    log_error "The file $FILE doesn't exist!"
  fi
}

function log_error {
  echo "ERROR $*"
  exit 1
}

function log_info {
  echo "INFO  $*"
}
