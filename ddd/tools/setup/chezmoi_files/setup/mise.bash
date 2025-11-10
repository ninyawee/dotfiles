#!/usr/bin/env bash
# https://mise.jdx.dev/getting-started.html
curl https://mise.jdx.dev/install.sh | sh

# do {
#   let misepath = ($nu.config-path | path dirname | path join "mise.nu")
#   run-external mise activate nu --redirect-stdout | save $misepath -f
#   $"\nsource "($misepath)"" | save $nu.config-path --append
# }