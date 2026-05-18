# Dockerfile for Hailo test environment (plain version)
FROM ubuntu:22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV HAILO_USERNAME=hailo
ENV HAILO_WHEEL_URL=https://github.com/johnnydev543/hailort-4.21.0-cp312-cp312-linux_x86_64/raw/main/hailort-4.21.0-cp312-cp312-linux_x86_64.whl

# Install required packages
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3-pip \
    ffmpeg \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Create hailo user
RUN useradd -m -s /bin/bash $HAILO_USERNAME

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

# Switch to hailo user
USER $HAILO_USERNAME

# Set default command
CMD ["/bin/bash"]