# Trustee FBC

The file based catalog (**FBC**) for trustee.

## Install `opm`

You need v1.46.0 or greater.

Download the binary from [Github releases](https://github.com/operator-framework/operator-registry/releases).

## Update the FBC

1. Update the digests in `catalog-template.json`.
1. Run `./render.sh` to update the actual catalog.
1. Good job, now open a pull request with your changes.
