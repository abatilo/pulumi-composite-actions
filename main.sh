#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo 'Usage: ./main.sh $command'
  exit 1
fi

# This will reduce certain non-actionable command output
# See: https://www.pulumi.com/docs/reference/cli/environment-variables/
export PULUMI_SKIP_CONFIRMATIONS=true
export PULUMI_SKIP_UPDATE_CHECK=true
export PULUMI_SELF_MANAGED_STATE_LOCKING=1

# Have a place to store output
outputStdOut=$(mktemp)
outputStdErr=$(mktemp)

workingDir="$2"
function main {
  command="$1"
  scriptDir=$(dirname ${0})
  source ${scriptDir}/preview.sh

  case "${command}" in
    preview)
      pulumiPreview "$2" "$3"
      ;;
    *)
      echo "Error: Unrecognized command ${command}"
      exit 1
      ;;
  esac
}


main "$1" "${outputStdOut}" "${outputStdErr}"

# Perform retries in the case of a stack lock
ATTEMPTS=0
while grep 'error: the stack is currently locked' ${outputStdErr};
do
  # Retry every 30 seconds up to 20 times, for a max of 10 minutes
  if [[ "${ATTEMPTS}" -eq 20 ]]; then
    echo "Could not acquire lock after ${ATTEMPTS} tries. Exiting..."
    ecit 1
  fi

  echo "Stack is currently locked"
  sleep 30
  ATTEMPTS=$(( ATTEMPTS + 1 ))
  main "$1" "${outputStdOut}" "${outputStdErr}"
done
