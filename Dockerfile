FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bwa samtools biobambam2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
