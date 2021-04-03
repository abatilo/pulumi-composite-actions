#!/bin/bash

function pulumiPreview {
  outputStdOut="$1"
  outputStdErr="$2"
  command="pulumi preview -s ${PULUMI_STACK} --diff --expect-no-changes --color=never --suppress-outputs=true --suppress-permalink=true"

  # Redirect stdout to a file and stdout with tee
  # Redirect stderr to a file and stderr with tee
  # Because we use --expect-no-changes then no changes would have an exit code
  # of 0 and let us exit immediately
  if bash -c "${command}" > >(tee ${outputStdOut}) 2> >(tee ${outputStdErr} >&2); then
    echo "Exiting because there are no changes"
    exit 0
  fi

  # If the GitHub action stems from a Pull Request event, leave a comment
  commentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
  if [ ! -z ${commentsURL} ]; then
    if [ -z $GITHUB_TOKEN ]; then
      echo "ERROR: GITHUB_TOKEN is not set."
    else
      COMMENT="#### \`pulumi preview\`
<details>
  <summary>Details</summary>

  \`\`\`
  $(cat ${outputStdOut} | tail -c 65000)
  \`\`\`
</details>"
      echo "$COMMENT" > comment.txt
      echo '{}' | jq --rawfile body comment.txt '.body = $body' > payload.json
      echo "Commenting on PR ${commentsURL}"
      curl -s -S -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" --data @payload.json "${commentsURL}"
    fi
  fi

  # Pulumi doesn't have Terraform's -detailed-exitcode option so we have to improvise
  if grep 'error: no changes were expected but changes were proposed' ${outputStdErr}; then
    echo "Since this isn't an actual error, exiting with status code 0"
    exit 0
  fi
  exit 1
}
