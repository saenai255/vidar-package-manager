#!/bin/sh
# Turns libs/ into local git repos and installs them with vpm.
set -e
cd "$(dirname "$0")"
here=$(pwd)
vpm=${VPM:-$here/../../out/vpm}
repos=$here/.repos
export VPM_CACHE=$repos/cache

rm -rf "$repos" deps vpm.lock project.toml vidar.toml out

publish() {
	name=$1
	shift
	mkdir -p "$repos/$name"
	cp -R "libs/$name/." "$repos/$name/"
	[ -f "$repos/$name/project.toml" ] && sed -i.bak "s#@REPOS@#$repos#" "$repos/$name/project.toml" && rm "$repos/$name/project.toml.bak"
	git -C "$repos/$name" init -q
	git -C "$repos/$name" add -A
	for tag in "$@"; do
		git -C "$repos/$name" -c user.name=vpm -c user.email=vpm@example.com commit -q --allow-empty -m "$tag"
		git -C "$repos/$name" tag "$tag"
	done
}

publish gadget v1.0.0 v1.1.0 v2.0.0
publish widget v1.0.0
publish sprocket v1.0.0

"$vpm" init diamond
"$vpm" get "widget=file://$repos/widget" "sprocket=file://$repos/sprocket" "gadget=file://$repos/gadget@^1.0.0"
"$vpm" list
"$vpm" run run
