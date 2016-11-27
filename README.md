# gantry-yard

[![Docker Repository on Quay](https://quay.io/repository/leopoldodonnell/gantry-yard/status "Docker Repository on Quay")]

**DOCUMENTATION IS UNDER CONSTRUCTION**

A Ruby based DevOps Framework Tool for Container-based Development

## Getting Started

**gantry-yard** currently offers a Ruby Rake framework with the following tools available:
    - terraform
    - packer
    - kubectl
    - helm
    - stern
    - docker
    - docker-compose
    - ruby aws-sdk
    - ruby inpsec
    - ruby terraforming

To learn about the available rake rules

> docker --rm -ti -v ${PWD}:/share quay.io/leopoldodonnell/gantry-yard -T

To call a specific rake rule

> docker --rm -ti -v ${PWD}:/share quay.io/leopoldodonnell/gantry-yard {rake arguments}

While not always necessary, the following mount points will help you provide credentials to the available utilities:

  - /root/.aws  to access your AWS credentials
  - /root/.ssh to access your own ssh credentials
  - /root/.kube to access your Kubernetes kubectl configuration
  - /root/.helm to access your Helm starters
  - /var/run/docker.sock to share a docker socket for docker commands within the container

## Using gantry-yard

**gantry-yard** comes with the bash script `gantry-yard`. This will run the gantry-yard container with appropriate volume mounts

**Usage:** gantry [-c workdir] [-d] [tool tool_args]

* -c : run gantry from within another docker container and use its volume mounts using
the workdir argument as the working directory for the gantry container
* -d : debug mode. Drop into the container using bash as an interactive entry point
