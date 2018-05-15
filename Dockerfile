FROM ruby:2.5.0-alpine3.7

RUN apk add --no-cache \
      unzip \
      git \
      bash \
      wget \
      curl \
      jq \
      openssh-client \
      util-linux \
      openssl \
      build-base \
      libxml2-dev \
      libffi-dev \
      python \
      docker

# Install Packer
ARG PACKER_VERSION='1.2.2'
RUN curl -L -o packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    curl -L -o packer_${PACKER_VERSION}_SHA256SUMS https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS && \
    sed -i "/packer_${PACKER_VERSION}_linux_amd64.zip/!d" packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum -c packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip

# Install terraform
ARG TERRAFORM_VERSION='0.11.5'
RUN curl -L -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -L -o terraform_${TERRAFORM_VERSION}_SHA256SUMS https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sed -i "/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d" terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    /bin/terraform version

# Install KOPS
ARG KOPS_VERSION='1.9.0'
RUN KOPS_URL="https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64" && \
    KOPS_SHA="$(curl -L https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64-sha1)  /usr/local/bin/kops" && \
    curl -SsL --retry 5 "${KOPS_URL}" > /usr/local/bin/kops && \
    echo "$KOPS_SHA" |sha1sum -c - && \
    chmod +x /usr/local/bin/kops

# Install kubectl
ARG KUBECTL_VERSION='1.9.7'
RUN curl -L -o /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /bin/kubectl

# Install stern
ARG STERN_VERSION='1.6.0'
RUN curl -L -o /bin/stern https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 && \
    chmod +x /bin/stern

ARG HELM_VERSION="2.9.1"
RUN curl -L -o helm-v${HELM_VERSION}-linux-amd64.tar.gz http://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar xf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    cp linux-amd64/helm /bin/helm && \
    rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

WORKDIR /
COPY Gemfile /

RUN bundle install --system

# Install the AWS CLI and docker-compose
RUN apk -Uuv add python-dev py-pip && \
    pip install --upgrade pip && \
    pip install awscli && \
    pip install docker-compose

# Install Google Cloud Tools
ARG GCLOUD_VERSION='201.0.0'
ENV PATH "/usr/local/google-cloud-sdk/bin:${PATH}"
RUN curl -L -o /tmp/gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
    cd /usr/local/ && \
    tar xvf /tmp/gcloud.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm /tmp/gcloud.tar.gz

# Install our version of az - which depends on docker
COPY az /usr/local/bin/az

# Install the aws cli - can't specify versions
RUN apk --purge -v del py-pip build-base && \
    rm /var/cache/apk/*

# Add the ruby libraries and built in tasks
ADD lib /mt/lib
ADD built-in-tasks /mt/tasks

# Create an app user/group and run as this user by default
RUN mkdir -p /mthome \
  && addgroup -S app \
  && adduser -S -G app -h /mthome -D app \
  && addgroup app root

USER app
WORKDIR /share

VOLUME ["/share", "/mthome/.aws", "/mthome/.config", "/mthome/.kube", "/mthome/.ssh", "/mthome/.helm", "/var/run/docker.sock:rw" ]
CMD [ "rake", "--rakefile", "/mt/tasks/Rakefile" ]
