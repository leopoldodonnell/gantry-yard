FROM ruby:alpine

RUN apk add --update git bash openssh-client graphviz

# Install Packer
ARG PACKER_VERSION='0.12.1'
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/packer_${PACKER_VERSION}_linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS && \
  sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS && \
  unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
  rm -f packer_${PACKER_VERSION}_linux_amd64.zip

# Install terraform
ARG TERRAFORM_VERSION='0.8.4'
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN sed -i '/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
  sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  /bin/terraform version

# Install kubectl
ARG KUBECTL_VERSION='1.3.4'
ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod +x /bin/kubectl

# Install stern
ARG STERN_VERSION='1.2.0'
ADD https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 /bin/stern
RUN chmod +x /bin/stern

# Install docker and docker-compose
ARG DOCKER_VERSION='1.11.2'
ADD https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz ./
RUN tar xf docker-${DOCKER_VERSION}.tgz && find docker -exec cp {}  /usr/bin \; && rm -rf docker docker-${DOCKER_VERSION}.tgz

ARG DOCKER_COMPOSE_VERSION="1.8.1"
ADD https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 /bin/docker-compose
RUN chmod +x /bin/docker-compose
 
ARG HELM_VERSION="2.0.0"
ADD http://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz ./
RUN tar xf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    cp linux-amd64/helm /bin/helm && \
    rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

ARG INSPEC_VERSION="0.28.0"
ARG TRAIN_VERSION="0.15.1"
ARG TERRAFORMING_VERSION="0.9.1"
ARG MIMEMAGIC_VERSION="0.3.2"

RUN apk add --update build-base libxml2-dev libffi-dev && \
  gem install inspec -v ${INSPEC_VERSION} --no-document && \
  gem install train -v ${TRAIN_VERSION} --no-document && \
  gem install terraforming -v ${TERRAFORMING_VERSION}  --no-document && \
  gem install mimemagic -v ${MIMEMAGIC_VERSION} --no-document && \
  apk del build-base

ADD lib /gantry-yard/lib
ADD tasks /gantry-yard/tasks

VOLUME ["/share", "/root/.aws", "/root/.kube", "/root/.ssh", "/root/.helm", "/var/run/docker.sock" ]
WORKDIR /share

CMD help
ENTRYPOINT [ "rake", "--rakefile", "/gantry-yard/tasks/Rakefile" ]
