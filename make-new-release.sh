#!/usr/bin/env bash

set -euo pipefail

get_next_version_number() {
	DATE_PART=$(date +%y.%-m)
	ITERATION=0

	while true; do
		VERSION_STRING="${DATE_PART}.${ITERATION}"
		if git rev-list "v$VERSION_STRING" > /dev/null 2>&1; then
			((ITERATION++))
		else
			echo "$VERSION_STRING"
			return
		fi
	done
}

VERSION=$(get_next_version_number)

sed -i -E "s/^version = \".+\"$/version = \"${VERSION}\"/" Cargo.toml
cargo check
git commit "Cargo.*" --message "Release v${VERSION}"
git tag "v${VERSION}"

gitchangelog
${EDITOR:-vim} CHANGES.md
docs/generate.sh
git add CHANGES.md README.md
git commit --amend --no-edit
git tag "v${VERSION}" --force

printf "\n\nSuccessfully created release %s\n" "v${VERSION}"
printf "\nYou'll probably want to continue with:\n"
printf "%s> git push origin main\n" "\t"
printf "%s> git push origin %s\n" "\t" "v${VERSION}"
