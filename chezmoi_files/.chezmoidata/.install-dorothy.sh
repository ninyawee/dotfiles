#!/usr/bin/env bash

if [[ -z "$DOROTHY" ]]; then
    echo "\$DOROTHY is not set, installing dorothy"
    bash -ic "$(curl -fsSL https://dorothy.bevry.me/install)"
fi
