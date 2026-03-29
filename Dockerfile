FROM debian:trixie-slim

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt -y upgrade && \
    apt -y install \
        make \
        clang-19 \
        lld-19 \
        mingw-w64 \
        clang-format \
        nasm
