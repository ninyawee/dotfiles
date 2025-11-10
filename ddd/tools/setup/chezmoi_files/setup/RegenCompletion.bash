#!/usr/bin/env bash

# use to regen all completions
# ./RegenCompletion.bash
# pre-reqs: run at setup dir 
set -e


mise completions bash > ../dot_bash_completions/mise.bash
just --completions bash > ../dot_bash_completions/just.bash
gh completion -s bash > ../dot_bash_completions/gh.bash