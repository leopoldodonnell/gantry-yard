FROM ruby:2.5-slim

RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
      apt-transport-https \
      unzip \
      git \
      bash \
      wget \
      curl \
      jq \
      openssh-client \
      util-linux \
      openssl \
      graphviz \
      build-essential \
      libxml2-dev \
      libffi-dev \
      lsb-release \
      python-all \
      rlwrap \
      vim \
      nano

RUN apt-get install -qqy gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - ; \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get install -qqy docker-ce

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


# Install kubectl
ARG KUBECTL_VERSION='1.9.3'
RUN curl -L -o /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /bin/kubectl

# Install stern
ARG STERN_VERSION='1.6.0'
RUN curl -L -o /bin/stern https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 && \
    chmod +x /bin/stern


ARG HELM_VERSION="2.8.2"
RUN curl -L -o helm-v${HELM_VERSION}-linux-amd64.tar.gz http://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar xf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    cp linux-amd64/helm /bin/helm && \
    rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

WORKDIR /
COPY Gemfile /

RUN bundle install --system
# RUN apk del build-base

# Install the aws cli - can't specify versions
RUN apt-get install -qqy less python-pip groff

RUN \
    pip install --upgrade pip && \
    pip install awscli && \
    pip install docker-compose
    # apk --purge -v del py-pip && \
    # rm /var/cache/apk/*

# Install Google Cloud Tools
ARG GCLOUD_VERSION='192.0.0'
RUN curl -L -o /tmp/gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
    cd /usr/local/ && \
    tar xvf /tmp/gcloud.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm /tmp/gcloud.tar.gz
ENV PATH "/usr/local/google-cloud-sdk/bin:${PATH}"

# Install AZURE_CLI
ENV AZURE_CLI_VERSION "0.10.13"
ENV NODEJS_APT_ROOT "node_6.x"
ENV NODEJS_VERSION "6.10.0"

RUN curl https://deb.nodesource.com/${NODEJS_APT_ROOT}/pool/main/n/nodejs/nodejs_${NODEJS_VERSION}-1nodesource1~jessie1_amd64.deb > node.deb && \
      dpkg -i node.deb && \
      rm node.deb && \
      npm install --global azure-cli@${AZURE_CLI_VERSION} && \
      mkdir -p ~/.azure && echo '{ "telemetry": false}' > ~/.azure/telemetry.json; \
      azure --completion >> ~/azure.completion.sh && \
      echo 'source ~/azure.completion.sh' >> ~/.bashrc && \
      azure

# Add the ruby libraries and built in tasks
ADD lib /mt/lib
ADD built-in-tasks /mt/tasks

# Create an app user/group and run as this user by default
RUN addgroup --system app \
  && adduser --system --gid 0 --home /mthome --disabled-password app && usermod -a -G app app

USER app
WORKDIR /share

VOLUME ["/share", "/mthome/.aws", "/mthome/.config", "/mthome/.kube", "/mthome/.ssh", "/mthome/.helm", "/var/run/docker.sock:rw" ]
CMD [ "rake", "--rakefile", "/mt/tasks/Rakefile" ]
