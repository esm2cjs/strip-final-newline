#!/bin/bash

mkdir -p cjs
mv index.js esm/index.js
sed -i 's#./index.js#./esm/index.js#' test.js
mv test.js test.mjs

PJSON=$(cat package.json | jq --tab '
	del(.type)
	| .main = "cjs/index.js"
	| .module = "esm/index.js"
	| .exports = {}
	| .exports["."].import = "./esm/index.js"
	| .exports["."].require = "./cjs/index.js"
	| .exports["./package.json"] = "./package.json"
	| .xo = {ignores: ["cjs"]}
	| .description = .description + ". This is a fork of " + .repository + ", but with CommonJS support."
	| .repository = "esm2cjs/" + .name
	| .funding = "https://github.com/sponsors/AlCalzone"
	| .name |= "@esm2cjs/" + .
	'
)
echo "$PJSON" > package.json

npx esm2cjs --in esm --out cjs -t node12
