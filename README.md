# pulumi-composite-actions

There is already the [pulumi/actions](https://github.com/pulumi/actions)
repository, so you might be wondering why I created these actions? Simply put,
the other actions are too slow. When you have a Docker action, the Docker
container needs to be built before the workflow can run. If you use something
like a TypeScript action or a composite action, the action itself runs
instantly.

Then you might ask, but Aaron, they re-did their actions to use the Pulumi
automation API! Now the actions are entirely in TypeScript. Isn't that fast
enough?

Yeah, yeah, you're right. But then I found another reason why I don't like
their action. Their action will ALWAYS leave a comment on your PR after every
single run, even when there isn't an actual change to be applied. Even if you
don't have any Pulumi related changes, you'll get a new comment on your PR for
every single push you make to a PR. This action will only comment if there are
changes detected.

**This does assume that pulumi is already installed by the time this action is
called**

I recommend setting up [asdf-vm](https://asdf-vm.com/#/) and then using the
Pulumi plugin to install directly to the runner host with
[asdf-vm/actions](https://github.com/asdf-vm/actions). You could alternatively
use
[pulumi/action-install-pulumi-cli](https://github.com/pulumi/action-install-pulumi-cli)

## Inputs

```yaml
inputs:
  command:
    description: "The pulumi command to run"
    required: true
  stack:
    description: "The pulumi stack to use"
    required: true
  passphrase:
    description: "The passphrase to set for the project"
    required: false
    default: ""
  working_directory:
    description: "The directory to run all the commands in"
    required: false
    default: "."
```

## Examples

### preview

```yaml
- uses: abatilo/pulumi-composite-actions@v1.0.0
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    passphrase: ${{ secrets.PULUMI_CONFIG_PASSPHRASE }}
    command: preview
    stack: stack-name
```

### up

```yaml
- uses: abatilo/pulumi-composite-actions@v1.0.0
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    passphrase: ${{ secrets.PULUMI_CONFIG_PASSPHRASE }}
    command: up
    stack: stack-name
```
