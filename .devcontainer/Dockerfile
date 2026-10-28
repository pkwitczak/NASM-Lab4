FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nasm \
        gcc \
        make \
        gdb \
        binutils \
        file \
    && rm -rf /var/lib/apt/lists/*