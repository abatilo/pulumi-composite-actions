#!/bin/bash

function pulumiUp {
  outputStdOut="$1"
  outputStdErr="$2"
  command="pulumi up -s ${PULUMI_STACK} --yes --skip-preview --color=never --suppress-outputs=true --suppress-permalink=true"

  # Redirect stdout to a file and stdout with tee
  # Redirect stderr to a file and stderr with tee
  # Because we use --expect-no-changes then no changes would have an exit code
  # of 0 and let us exit immediately
  if bash -c "${command}" > >(tee ${outputStdOut}) 2> >(tee ${outputStdErr} >&2); then
    echo "Successfully applied changes"
    return 0
  fi

  if grep 'error: the stack is currently locked' ${outputStdErr}; then
    # Don't exit shell, return 0 and let main.sh retry loop kick in
    return 0
  fi

  echo "There was an error when performing update"
  cat ${outputStdErr}

  exit 1
}
