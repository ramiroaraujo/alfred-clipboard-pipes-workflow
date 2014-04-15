#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'workflow_config'
config = WorkflowConfig.new

# extract variables
command, content = ARGV.join(' ').split('|', 2)

case command
  when 'delete'

    # deletes the pipe or temp
    command, content = content.split('|', 2)
    if command == 'edit-code'
      pipe = config.get_pipe(content)
      config.remove_pipe(content)
      puts pipe[:name]
      exit 0
    else
      File.delete 'temp'
      exit 0
    end

  when 'edit-code'

    pipe = config.get_pipe(content)
    `open pipes/#{pipe[:key]}.sh`

  when 'create-name'

    config.add_pipe_name(content)
    `osascript -e 'tell application "Alfred 2" to search "_configpipe "'`

  when 'create-code'
    name = config.add_pipe_code(content)
    print name
end

config.refresh_pipes(true)
