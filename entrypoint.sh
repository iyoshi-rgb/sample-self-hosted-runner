#!/bin/bash
set -e

./config.sh --jitconfig "${JIT_CONFIG}" --ephemeral --unattended

./run.sh