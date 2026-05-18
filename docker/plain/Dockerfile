# Dockerfile for Hailo test environment (plain version)
FROM ubuntu:22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV HAILO_USERNAME=hailo

# Install required packages including dependencies for Python 3.12
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    ffmpeg \
    build-essential \
    cmake \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
        python3.12 \
        python3.12-venv \
        python3.12-dev \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 \
    && rm -rf /var/lib/apt/lists/*

# Create hailo user
RUN useradd -m -s /bin/bash $HAILO_USERNAME

# Set working directory
WORKDIR /home/$HAILO_USERNAME

# Copy and install HailoRT wheel from local file
COPY hailort-4.21.0-cp312-cp312-linux_x86_64.whl .
RUN python3.12 -m pip install hailort-4.21.0-cp312-cp312-linux_x86_64.whl

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