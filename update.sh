#!/usr/bin/env sh

# Print what you're doing, exit on error.
set -xe

# Which OCP versions are we running this for.
VERSIONS=$@

[ -n "$VERSIONS" ] || VERSIONS="v4.*"

# Check that a folder exists for the versions you set.
ls $VERSIONS > /dev/null

# Make script fail when API requests fail.
alias curl="curl --fail"

# Get the latest merge commit for the bundle. This is the string the bundle image is tagged with.
get_tag () {
    URL="https://api.github.com/repos/openshift/trustee-operator/commits?per_page=1&path=bundle"
    COMMIT=$(curl "$URL" | jq -r '.[0].sha')
    URL="https://api.github.com/repos/openshift/trustee-operator/commits/$COMMIT/pulls"
    curl "$URL" | jq -r '.[0].merge_commit_sha'
}

# Get the digest for a tagged image. Pass the <TAG> as the first argument.
# Quay API docs are at https://docs.quay.io/api/swagger/#!/tag/listRepoTags.
get_digest () {
    TAG="$1"
    URL="https://quay.io/api/v1/repository/redhat-user-workloads/ose-osc-tenant/trustee/trustee-operator-bundle/tag?specificTag=$TAG"
    curl -L "$URL" | jq -r '.tags[0].manifest_digest'
}

sed_digest () {
    DIGEST="$1"
    sed -E -i "s/sha256:[0-9a-f]{64}/$DIGEST/"
}

# Replace any digest in the <FILE> with the new <DIGEST>.
replace_digest () {
    DIGEST="$1"
    FILE="$2"
    sed -E -i "s/sha256:[0-9a-f]{64}/$DIGEST/" "$FILE"
}

# Update the last bundle image digest in the <FILE> with the new <DIGEST>
replace_digest_last () {
    DIGEST="$1"
    FILE="$2"

    OLD_DIGEST=$(yq '.entries[] | select(.schema == "olm.bundle") | .image' "$FILE" | tail -n1 | sed 's/.*@//')

    sed -i "s/$OLD_DIGEST/$DIGEST/" "$FILE"
}

TAG="$(get_tag)"
DIGEST="$(get_digest $TAG)"

for VERSION in $VERSIONS; do
    FILE="$VERSION/catalog-template.yaml"
    replace_digest_last "$DIGEST" "$FILE"
done

# No more debug. All went good.
set +x

echo "
Done."
