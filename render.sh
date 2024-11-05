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

    # enable migrate params for OCP 4.17 and onwards
    OCP_VERSION_NUMERAL=$(echo $OCP_VERSION | grep -o -E '[0-9.]+')
    if [ "`echo "${OCP_VERSION_NUMERAL} > 4.16" | bc`" -eq 1 ]; then
        MIGRATE_PARAM="--migrate-level bundle-object-to-csv-metadata"
    else
        MIGRATE_PARAM=""
    fi

    # Render that template. It's what we're here for.
    opm $MIGRATE_PARAM alpha render-template basic $OCP_VERSION/catalog-template.json > $OCP_VERSION/catalog/trustee-operator/catalog.json
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
