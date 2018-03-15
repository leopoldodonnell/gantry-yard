
desc "Display a description of multi-tool with helpful information"
task :help do
  puts <<~HEREDOC

  multi-tool - a tool for building and managing cloud infrastructure without a low installation footprint
  
  multi-tool currently offers a Ruby Rake framework with the following tools available:
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

  multi-tool is a container image that is most easily run using the multi-tool script

    To learn about the available rake rules

    > multi-tool -T

    To call a specific rake rule
  
    > multi-tool -t {rake arguments}

    To run a shell command using one of the installed tools
  
    > multi-tool {command and args}

  If you must use the container image directly you will need to setup appropriate mount points and environment
  
  VOLUMES:
  
  /share - should be mounted to the directory where the file resources needed by multi-tool are found.
  /mthome/.aws - should be mounted to the directory where aws credentials are found if needed.
  /mthome/.kube - should be mounted to the directory where kubernetes configurations are found if neeeed.
  /mthome/.ssh - should be mounted to the directory where ssh credentials are found if needed.
  /mthome/.helm - should be mounted to the directory where helm settings are found if needed.
  /var/run/docker.sock:/var/run/docker.sock should be mounted if docker client commands will be run.
    
  HEREDOC
end
