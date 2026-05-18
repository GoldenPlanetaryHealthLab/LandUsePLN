# syntax=docker/dockerfile:1.7

FROM rocker/geospatial:4.5.3

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_PROJECT_ENVIRONMENT=/workspaces/LandUsePLN/.venv
ENV UV_CACHE_DIR=/home/vscode/.cache/uv
ENV PATH="/workspaces/LandUsePLN/.venv/bin:/home/vscode/.local/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN apt-get update && apt-get install -y \
    curl git sudo ca-certificates build-essential passwd \
    python3 python3-pip python3-venv python-is-python3 \
    openssh-client gnupg lsof libglpk40 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /workspaces/LandUsePLN

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

COPY pyproject.toml* uv.lock* ./

RUN mkdir -p /home/vscode/.cache/uv \
    && chown -R vscode:vscode /home/vscode/.cache

RUN test -f pyproject.toml || uv init --bare

RUN --mount=type=cache,target=/tmp/uv-cache \
    UV_CACHE_DIR=/tmp/uv-cache \
    uv sync --locked --no-install-project

# R dependency layer unchanged...
RUN curl -fsSL https://raw.githubusercontent.com/A2-ai/rv/main/scripts/install.sh | bash \
    && install -m 0755 /root/.local/bin/rv /usr/local/bin/rv

COPY rproject.toml* rv.lock* ./

ENV RV_GLOBAL_CACHE_DIR=/home/vscode/.cache/rv

RUN mkdir -p /home/vscode/.cache/rv \
    && chown -R vscode:vscode /home/vscode/.cache

RUN test -f rproject.toml || rv init

RUN --mount=type=cache,target=/tmp/rv-cache \
    RV_GLOBAL_CACHE_DIR=/tmp/rv-cache \
    rv sync

RUN curl --proto '=https' --tlsv1.2 -LsSf \
    https://github.com/eitsupi/arf/releases/latest/download/arf-console-installer.sh \
    | sh \
    && install -m 0755 /root/.cargo/bin/arf /usr/local/bin/arf

COPY . .

# Important: install the actual project after copying source.
RUN --mount=type=cache,target=/tmp/uv-cache \
    UV_CACHE_DIR=/tmp/uv-cache \
    uv sync --locked

RUN chown -R vscode:vscode /workspaces/LandUsePLN /home/vscode

USER vscode

CMD ["/bin/bash"]