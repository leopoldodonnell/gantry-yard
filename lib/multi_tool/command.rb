require 'open3'
require 'timeout'

module MultiTool
  module Command
    
    # Run a command (no stdin) and return the process exit status
    #
    # By default, output will be written to stdout unless a block is given.
    #
    # command_line (String) the command line to execute
    # block (block) a code block that receives a line of input for each line of command output
    #
    def self.run(command_line, &block)
      LOGGER.debug("Running command: #{command_line}")
      status = false
      Open3.popen2(command_line) do | stdin, stdout, thread |
        stdin.close
        stdout.each_line { |line| if block then yield line else puts line end }
        status = thread.value.exitstatus
      end
    end
    
    # Run a command until its output satisfies some match unless a time limit is reached.
    #
    # command_line (String) athe command line to execute
    # time_limit (int) the number of seconds to wait for a matching condition
    # match_expression (Regexp) if no match_block is given, this should be the regular espression to match
    # match_block (block) a code block that reeceives a line of input to match. The method will return when this
    #   block return true
    #
    # Returns true if the match has occurred, otherwise false
    #
    def self.run_until(command_line, time_limit, match_expression = nil, &match_block)
      result = false
      Open3.popen2(command_line) { | stdin, stdout, thread |
        stdin.close
        begin
          Timeout.timeout(time_limit) {
            result = stdout.any? { |line| LOGGER.debug(line); if match_block then yield line else line =~ match_expression end }
            Process.kill("TERM", thread.pid) if result && thread.alive?
          }
        rescue Timeout::Error
          Process.kill("TERM", thread.pid)
        end        
      }
      result
    end
  end
end