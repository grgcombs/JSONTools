#!/bin/bash

export LANG=en_US.UTF-8

## optional:
# brew update

brew upgrade carthage
carthage checkout --no-use-binaries --color auto

