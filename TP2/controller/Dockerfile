FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANSIBLE_HOST_KEY_CHECKING=false
ENV ANSIBLE_FORCE_COLOR=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    ansible-core \
    ca-certificates \
    curl \
    docker.io \
    docker-compose-v2 \
    git \
    iputils-ping \
    jq \
    openssh-client \
    python3 \
    python3-jinja2 \
    python3-pip \
    python3-requests \
    python3-winrm \
    rsync \
    sshpass \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml

WORKDIR /workspace

CMD ["bash"]
