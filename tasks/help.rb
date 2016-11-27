
desc "Display a description of gantry-yard with helpful information"
task :help do
  puts <<~HEREDOC

  gantry-yard - a scaffold for building and managing cloud infrastructure without a low installation footprint

  gantry-yard currently offers a Ruby Rake framework with the following tools available:
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

  > docker --rm -ti -v ${PWD}:/share gantry-yard -T

  To call a specific rake rule
  
  > docker --rm -ti -v ${PWD}:/share gantry-yard {rake arguments}

  Mount points that can be useful to these tools include:

    - /root/.aws  to access your AWS credentials
    - /root/.kube to access your Kubernetes kubectl configuration
    - /var/run/docker.sock to share a docker socket for docker commands within the container

  HEREDOC
end