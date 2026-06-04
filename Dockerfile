# Build Stage
FROM --platform=linux/amd64 ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
## Install build dependencies.
RUN apt-get update && apt-get install -y cmake clang llvm curl

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install cargo-fuzz

## Add source code to the build stage.
ADD . /candid/
WORKDIR /candid/rust/candid/fuzz/

RUN cargo +nightly fuzz build parser

# Package Stage
FROM --platform=linux/amd64 ubuntu:22.04

COPY --from=builder /candid/rust/candid/fuzz/target/x86_64-unknown-linux-gnu/release/parser /parser
