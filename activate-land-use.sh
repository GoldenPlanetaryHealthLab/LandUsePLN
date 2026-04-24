#!/usr/bin/env bash

set -euo pipefail

module purge
export MAMBA_ROOT_PREFIX='/n/home03/ttapera/.local/share/mamba'
eval "$(/n/sw/Miniforge3-25.3.1-0/bin/mamba shell hook --shell bash)"
mamba activate landuse-dev

unset PROJ_LIB
export PROJ_DATA="$CONDA_PREFIX/share/proj"
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib"
