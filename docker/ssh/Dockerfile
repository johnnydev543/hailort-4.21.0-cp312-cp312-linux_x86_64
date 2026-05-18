# Dockerfile for Hailo test environment (SSH version)
FROM ubuntu:22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV HAILO_USERNAME=hailo
ENV HAILO_PASSWORD=hailo
ENV HAILO_WHEEL_URL=https://github.com/johnnydev543/hailort-4.21.0-cp312-cp312-linux_x86_64/raw/main/hailort-4.21.0-cp312-cp312-linux_x86_64.whl

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
        python3.12-distutils \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create hailo user with password and give sudo access
RUN useradd -m -s /bin/bash $HAILO_USERNAME && \
    echo "$HAILO_USERNAME:$HAILO_PASSWORD" | chpasswd && \
    usermod -aG sudo $HAILO_USERNAME && \
    echo "$HAILO_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH server
RUN mkdir /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Set working directory
WORKDIR /home/$HAILO_USERNAME

# Download and install HailoRT wheel
RUN curl -L -o hailort-4.21.0-cp312-cp312-linux_x86_64.whl $HAILO_WHEEL_URL && \
    python3.12 -m pip install --upgrade pip && \
    python3.12 -m pip install hailort-4.21.0-cp312-cp312-linux_x86_64.whl

# Install additional packages for Whisper/FastAPI testing
RUN python3.12 -m pip install \
    fastapi \
    uvicorn \
    python-multipart \
    numpy \
    librosa \
    transformers \
    torch

# Clean up
RUN rm hailort-4.21.0-cp312-cp312-linux_x86_64.whl

# Expose SSH port
EXPOSE 22

# Switch to hailo user
USER $HAILO_USERNAME

# Set default command to start SSH server
CMD ["/usr/sbin/sshd", "-D"]