# Trustee FBC

The file based catalog (**FBC**) for trustee.


## Install `opm`

You need v1.46.0 or greater.

Download the binary from [Github releases](https://github.com/operator-framework/operator-registry/releases).


## Update the FBC

1. Run `./update.sh <VERSION>` to update the digests in the template.
1. Run `./render.sh` to update the actual catalog.
1. Open a pull request with your changes.


## Add a new OpenShift version

In examples that follow, the latest release is `v4.15` and you want to release for `v4.18` too.

### New Konflux application

1. In the web UI, add a new application and a new component.
1. Ignore the pull request from the Konflux bot.
1. Add the new application to the ReleasePlanAdmission.
1. Create a new ReleasePlan.

### New PipelineRuns

Create the PipelineRuns to build the new FBC:
1. Enter the `.tekton` folder.
1. Copy the pull-request PipelineRun.

   Example: copy `trustee-fbc-4-15-pull-request.yaml` to `trustee-fbc-4-18-pull-request.yaml`.

1. Copy the push PipelineRun.

   Example: copy `trustee-fbc-4-15-push.yaml` to `trustee-fbc-4-18-push.yaml`.

1. Update all occurrences of the version in the new PipelineRuns. For example, run:
   ```
   sed -i 's/v4.15/v4.18/' trustee-fbc-4-18-*.yaml
   sed -i 's/4-15/4-18/' trustee-fbc-4-18-*.yaml
   ```

### New FBC

Create the new FBC:
1. Copy the folder. For example, copy `v4.15` to `v4.18`.
1. Update the base image version in the Dockerfile. For example, run:
   ```
   sed -i 's/v4.15/v4.18/' v4.18/Dockerfile
   ```
1. Run `./render.sh` to update the actual catalog. Note that this command will not make any changes, if they are not needed.
