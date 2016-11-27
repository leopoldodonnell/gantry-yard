##
# Basic availability to call utilties supported by gantry-yard
#
# More opinionated/intersting uses should be provided by namespaced rules
#

desc 'Run terraform with command line arguments'
task :terraform, [:cmd_line_args] do |t, args|
  puts `terraform #{args[:cmd_line_args]}`
end

desc 'Run packer with command line arguments'
task :packer, [:cmd_line_args] do |t, args|
  puts `packer #{args[:cmd_line_args]}`  
end

desc 'Run inspec with command line arguments'
task :inspec, [:cmd_line_args] do |t, args|
  puts `inspec #{args[:cmd_line_args]}`
end

desc 'Run kubectl with command line arguments'
task :kubectl, [:cmd_line_args] do |t, args|
  puts `kubectl #{args[:cmd_line_args]}`
end

desc 'Run helm with command line arguments'
task :helm, [:cmd_line_args] do |t, args|
  puts `helm #{args[:cmd_line_args]}`
end

desc 'Run stern with command line arguments'
task :stern, [:cmd_line_args] do |t, args|
  puts `stern #{args[:cmd_line_args]}`
end


