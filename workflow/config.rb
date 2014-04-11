#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'workflow_config'
config = WorkflowConfig.new

# extract variables
command, content = ARGV.join(' ').split('|', 2)

case command
  when 'delete'

    # calculates wether delete or error
    exists = /^edit/ =~ content
    unless exists
      `/usr/bin/afplay /System/Library/Sounds/Funk.aiff`
      exit 1
    end

    # deletes the pipe
    noop, content = content.split('|', 2)
    pipe = config.get_pipe(content)
    config.remove_pipe(content)
    puts pipe[:name]
    exit 0

  when 'edit'

    pipe = config.get_pipe(content)
    `open pipes/#{pipe[:key]}.sh`

  when 'create-name'

    config.add_pipe_name(content)
    `osascript -e 'tell application "Alfred 2" to search "configpipe "'`

  when 'create-code'
    name = config.add_pipe_code(content)
    print name
end
