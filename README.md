# pulumi-composite-actions

There is already the [pulumi/actions](https://github.com/pulumi/actions)
repository, so you might be wondering why I created these actions? Simply put,
the other actions are too slow. When you have a Docker action, the Docker
container needs to be built before the workflow can run. If you use something
like a TypeScript action or a composite action, the action itself runs
instantly.

**This does assume that pulumi is already installed by the time this action is
called**

I recommend setting up [asdf-vm](https://asdf-vm.com/#/) and then using the
Pulumi plugin to install directly to the runner host with
[asdf-vm/actions](https://github.com/asdf-vm/actions). You could alternatively
use
[pulumi/action-install-pulumi-cli](https://github.com/pulumi/action-install-pulumi-cli)

## Inputs

TODO

## Examples

TODO
