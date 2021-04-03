#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo 'Usage: ./main.sh $command $working_directory'
  exit 1
fi

# This will reduce certain non-actionable command output
# See: https://www.pulumi.com/docs/reference/cli/environment-variables/
export PULUMI_SKIP_CONFIRMATIONS=true
export PULUMI_SKIP_UPDATE_CHECK=true

workingDir="$2"
function main {
  command="$1"
  scriptDir=$(dirname ${0})
  source ${scriptDir}/preview.sh
  source ${scriptDir}/up.sh

  case "${command}" in
    preview)
      pulumiPreview
      ;;
    up)
      pulumiUp
      ;;
    *)
      echo "Error: Unrecognized command ${command}"
      exit 1
      ;;
  esac
}

main "$1"
