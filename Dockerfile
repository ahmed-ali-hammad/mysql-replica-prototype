FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    wget \
    lsb-release \
    gnupg \
    && apt-get clean

RUN apt-get install -y mysql-server

# Install all required dependencies for mydumper
RUN apt-get update && \
    apt-get install -y \
    cmake \
    g++ \
    libglib2.0-dev \
    libmysqlclient-dev \
    zlib1g-dev \
    libpcre3-dev \
    libssl-dev \
    libzstd-dev \
    wget

# Download, extract, and set up mydumper
RUN wget https://launchpad.net/mydumper/0.9/0.9.1/+download/mydumper-0.9.1.tar.gz && \
    tar -xvzf mydumper-0.9.1.tar.gz && \
    rm mydumper-0.9.1.tar.gz && \
    mv mydumper-0.9.1 mydumper && \
    cd mydumper && \
    cmake . && \
    make

# Create symbolic links
RUN ln -s /mydumper/mydumper /usr/bin/mydumper && \
    ln -s /mydumper/myloader /usr/bin/myloader

# for percona-toolkit
RUN apt-get install percona-toolkit

