# Dockerfile for Hailo test environment (SSH version)
FROM ubuntu:24.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=root
ENV PASSWORD=***

# Install required packages including SSH server, Python, and build dependencies for HailoRT
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    ffmpeg \
    build-essential \
    cmake \
    openssh-server \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install HailoRT runtime library (v4.21.0 deb package)
RUN curl -L -o /tmp/hailort_4.21.0_amd64.deb https://github.com/johnnydev543/frigate-hailo/raw/refs/heads/main/hailort_4.21.0_amd64.deb && \
    dpkg -i /tmp/hailort_4.21.0_amd64.deb && \
    ldconfig && \
    rm /tmp/hailort_4.21.0_amd64.deb

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
COPY docker/ssh/start-sshd.sh /start-sshd.sh
RUN chmod +x /start-sshd.sh

# Set working directory
WORKDIR /root

# Expose SSH port
EXPOSE 22

# Set default command to start SSH server
CMD ["/start-sshd.sh"]