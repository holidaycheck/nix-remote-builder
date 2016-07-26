#!/usr/bin/env bash

nix-build -Q --argstr system x86_64-linux --argstr time "$(date)"
