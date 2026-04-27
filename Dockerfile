FROM rocker/geospatial:4.5.3

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/vscode/.local/bin:/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    make \
    cmake \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    libssl-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /bin/

RUN curl -fsSL https://raw.githubusercontent.com/A2-ai/rv/refs/heads/main/scripts/install.sh | bash

WORKDIR /workspaces/LandUsePLN

COPY ./rproject.toml ./rproject.toml
COPY ./pyproject.toml ./pyproject.toml
COPY ./uv.lock ./uv.lock

USER vscode