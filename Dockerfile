FROM ruby:2-alpine3.6

RUN apk add --no-cache \
      git \
      bash \
      wget \
      curl \
      jq \
      openssh-client \
      util-linux \
      openssl \
      graphviz \
      docker \
      build-base \
      libxml2-dev \
      libffi-dev
      

# Install Packer
ARG PACKER_VERSION='1.1.3'
RUN curl -L -o packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    curl -L -o packer_${PACKER_VERSION}_SHA256SUMS https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS && \
    sed -i "/packer_${PACKER_VERSION}_linux_amd64.zip/!d" packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip

# Install terraform
ARG TERRAFORM_VERSION='0.11.1'
RUN curl -L -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -L -o terraform_${TERRAFORM_VERSION}_SHA256SUMS https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sed -i "/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d" terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    /bin/terraform version


# Install kubectl
ARG KUBECTL_VERSION='1.8.6'
RUN curl -L -o /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /bin/kubectl

# Install stern
ARG STERN_VERSION='1.6.0'
RUN curl -L -o /bin/stern https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 && \
    chmod +x /bin/stern


ARG HELM_VERSION="2.7.2"
RUN curl -L -o helm-v${HELM_VERSION}-linux-amd64.tar.gz http://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar xf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    cp linux-amd64/helm /bin/helm && \
    rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

WORKDIR /
COPY Gemfile /

RUN bundle install --system
RUN apk del build-base

# Install the aws cli - can't specify versions
RUN apk -Uuv add groff less python py-pip && \
    pip install --upgrade pip && \
    pip install awscli && \
    pip install docker-compose && \
    apk --purge -v del py-pip && \
    rm /var/cache/apk/*

ADD lib /mt/lib
ADD built-in-tasks /mt/tasks

RUN mkdir -p /mthome \
  && addgroup -S app \
  && adduser -S -G app -h /mthome -D app

VOLUME ["/share", "/mthome/.aws", "/mthome/.kube", "/mthome/.ssh", "/mthome/.helm", "/var/run/docker.sock" ]

USER app

WORKDIR /share

CMD [ "rake", "--rakefile", "/mt/tasks/Rakefile" ]
