# Dockerfile for Hailo test environment (SSH version)
FROM ubuntu:24.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=root
ENV PASSWORD=root

# Install required packages including SSH server and Python 3.12 dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    ffmpeg \
    build-essential \
    cmake \
    openssh-server \
    sudo \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
        python3.12 \
        python3.12-venv \
        python3.12-dev \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 \
    && rm -rf /var/lib/apt/lists/*

# Set up SSH server
RUN mkdir /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Generate ssh host key
RUN ssh-keygen -A
RUN mkdir -p /var/run/sshd

# Set root password
RUN echo "root:root" | chpasswd

# Ensure host keys are generated at runtime if they don't exist
COPY start-sshd.sh /start-sshd.sh
RUN chmod +x /start-sshd.sh

# Set working directory
WORKDIR /root

# Copy requirements file
COPY requirements.txt ./

# Expose SSH port
EXPOSE 22

# Set default command to start SSH server
CMD ["/start-sshd.sh"]