#!/bin/bash

function pulumiPreview {
  outputStdOut=$(mktemp)
  outputStdErr=$(mktemp)
  command="pulumi preview -s ${PULUMI_STACK} --expect-no-changes --color never --suppress-outputs --suppress-permalink ${*}"

  if bash -c "${command}" > >(tee -a ${outputStdOut}) 2> >(tee -a ${outputStdErr} >&2); then
    exit 0
  fi

  # If the GitHub action stems from a Pull Request event, leave a comment
  commentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
  if [ ! -z ${commentsURL} ]; then
    if [ -z $GITHUB_TOKEN ]; then
      echo "ERROR: GITHUB_TOKEN is not set."
    else
      COMMENT="#### \`preview\`
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

  if grep 'error: no changes were expected but changes were proposed' ${outputStdErr}; then
    exit 0
  fi
  exit 1
}
