# syntax=docker/dockerfile:1.7

FROM rocker/geospatial:4.5.3

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/vscode/.local/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    ca-certificates \
    build-essential \
    passwd \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    openssh-client \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# prepare the user spec
RUN useradd -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /workspaces/LandUsePLN

# ---------------------------
# Python dependency layer
# ---------------------------
COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/
# if it exists, copy existing cache of Python dependencies to speed up installation
COPY pyproject.toml* uv.lock* ./
ENV UV_PROJECT_ENVIRONMENT=/workspaces/LandUsePLN/.venv
ENV UV_CACHE_DIR=/root/.cache/uv

RUN mkdir -p /root/.cache/uv

# Optional: only initialize if pyproject.toml is absent
RUN test -f pyproject.toml || uv init --bare

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project

# # ---------------------------
# # R dependency layer
# # ---------------------------
RUN curl -fsSL https://raw.githubusercontent.com/A2-ai/rv/main/scripts/install.sh | bash \
    && install -m 0755 /root/.local/bin/rv /usr/local/bin/rv
COPY rproject.toml* rv.lock* ./
ENV RV_GLOBAL_CACHE_DIR=/root/.cache/rv
RUN mkdir -p /root/.cache/rv

# Optional: only initialize if rproject.toml is absent
RUN test -f rproject.toml || rv init
RUN --mount=type=cache,target=/root/.cache/rv \
    rv sync

# ---------------------------
# User-facing tools
# ---------------------------
RUN curl --proto '=https' --tlsv1.2 -LsSf \
    https://github.com/eitsupi/arf/releases/latest/download/arf-console-installer.sh \
    | sh \
    && install -m 0755 /root/.cargo/bin/arf /usr/local/bin/arf

# # ---------------------------
# # Project source layer
# # ---------------------------
COPY . .
# fix ownership for runtime/dev use
RUN chown -R vscode:vscode /workspaces/LandUsePLN /home/vscode

USER vscode

CMD ["/bin/bash"]