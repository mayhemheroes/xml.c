# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git build-essential

## Add source code to the build stage.
ADD . /xml.c
WORKDIR /xml.c

## Build
RUN mkdir -p build
WORKDIR build
RUN CC=clang CXX=clang++ cmake -DBUILD_FUZZER=1 -DCMAKE_BUILD_TYPE=Release ..
RUN make

# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /xml.c/build/fuzz/xml-fuzzer /

## Configure testsuite
RUN mkdir /testsuite
COPY --from=builder /xml.c/test/test.xml /testsuite
COPY --from=builder /xml.c/test/test-attributes.xml /testsuite

## Set up fuzzing!
ENTRYPOINT []
CMD /xml-fuzzer -close_fd_mask=2
