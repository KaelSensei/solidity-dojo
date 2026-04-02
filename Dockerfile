FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git build-essential pkg-config libssl-dev \
    python3 python3-pip \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:$PATH"
RUN foundryup

# Slither (static analyzer) expects `solc` available on PATH
RUN pip3 install --no-cache-dir slither-analyzer solc-select \
    && solc-select install 0.8.26 \
    && solc-select use 0.8.26

WORKDIR /workspace
