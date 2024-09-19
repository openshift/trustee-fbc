#!/usr/bin/env sh

# Print what you're doing, exit on error.
set -xe

BUILD_REGISTRY="quay.io/redhat-user-workloads/ose-osc-tenant/trustee/"
RELEASE_REGISTRY="registry.redhat.io/confidential-compute-attestation-tech-preview/"

for OCP_VERSION in v4.*
do
    # A blank line in the log
    echo
    # Switch to the build registry, so `opm` can pull freely.
    sed -i "s|$RELEASE_REGISTRY|$BUILD_REGISTRY|" $OCP_VERSION/catalog-template.json
    # Render that template. It's what we're here for.
    opm alpha render-template basic $OCP_VERSION/catalog-template.json > $OCP_VERSION/catalog/trustee-operator/catalog.json
    # Switch back to the release registry.
    sed -i "s|$BUILD_REGISTRY|$RELEASE_REGISTRY|" $OCP_VERSION/catalog-template.json
    sed -i "s|$BUILD_REGISTRY|$RELEASE_REGISTRY|" $OCP_VERSION/catalog/trustee-operator/catalog.json
    # Rename images. Why? Need "-rhel9" in release images.
    sed -i "s|/trustee@|/trustee-rhel9@|" $OCP_VERSION/catalog/trustee-operator/catalog.json
    sed -i "s|/trustee-operator@|/trustee-rhel9-operator@|" $OCP_VERSION/catalog/trustee-operator/catalog.json
done

# No more debug. All went good.
set +x

echo "
Done."
