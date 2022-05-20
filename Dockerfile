# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git build-essential

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/xml.c.git
WORKDIR /xml.c
RUN git checkout mayhem

## Build
RUN mkdir -p build
WORKDIR build
RUN CC=clang CXX=clang++ cmake -DBUILD_FUZZER=1 -DCMAKE_BUILD_TYPE=Release ..
RUN make

# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /xml.c/build/fuzz/xml-fuzzer /

## Configure corpus
RUN mkdir /corpus
COPY --from=builder /xml.c/test/test.xml /corpus
COPY --from=builder /xml.c/test/test-attributes.xml /corpus

## Set up fuzzing!
ENTRYPOINT []
CMD /xml-fuzzer /corpus -close_fd_mask=2
