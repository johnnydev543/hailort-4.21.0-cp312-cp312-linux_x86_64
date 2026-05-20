# Dockerfile for Hailo test environment
# Build arg: ENABLE_SSH=true to include SSH server functionality (default: true)
FROM ubuntu:24.04

# Build argument to enable/disable SSH
ARG ENABLE_SSH=true

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=root
ENV PASSWORD=***

# Install required packages: Python, build dependencies for HailoRT, and conditionally SSH
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    ffmpeg \
    build-essential \
    cmake \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    $(if [ "$ENABLE_SSH" = "true" ]; then echo "openssh-server"; fi) \
    && rm -rf /var/lib/apt/lists/*

# Install HailoRT runtime library (v4.21.0 deb package)
RUN curl -L -o /tmp/hailort_4.21.0_amd64.deb https://github.com/johnnydev543/frigate-hailo/raw/refs/heads/main/hailort_4.21.0_amd64.deb && \
    dpkg -i /tmp/hailort_4.21.0_amd64.deb && \
    ldconfig && \
    rm /tmp/hailort_4.21.0_amd64.deb

# Set up SSH server (only if ENABLE_SSH=true)
RUN if [ "$ENABLE_SSH" = "true" ]; then \
    mkdir /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A && \
    mkdir -p /var/run/sshd && \
    echo "root:root" | chpasswd; \
    fi

# Copy entrypoint script
COPY docker/start-service.sh /start-service.sh
RUN chmod +x /start-service.sh

# Set working directory
WORKDIR /root

# Expose SSH port (only meaningful when ENABLE_SSH=true)
EXPOSE 22

# Set default command
CMD ["/start-service.sh"]