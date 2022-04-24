# Build Stage
FROM --platform=linux/amd64 rustlang/rust:nightly as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang

## Add source code to the build stage.
ADD . /candid
WORKDIR /candid/rust/candid/fuzz

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.
RUN cargo +nightly rustc -- \
    -C passes='sancov-module' \
    -C llvm-args='-sanitizer-coverage-level=3' \
    -C llvm-args='-sanitizer-coverage-inline-8bit-counters' \
    -Z sanitizer=address

# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04

## TODO: Change <Path in Builder Stage>
COPY --from=builder /candid/rust/candid/fuzz/target/debug/parser /
