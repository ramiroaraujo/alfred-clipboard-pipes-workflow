#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative 'bundle/bundler/setup'
require 'alfred'
require_relative 'workflow_config'

query = ARGV[0] || ''

Alfred.with_friendly_error do |alfred|

  fb = alfred.feedback
  config = WorkflowConfig.new

  # check for temp file to calculate state
  state = File.exist?('temp') ? 'code' : 'name'

  if state == 'name'
    search = config.search_pipes(query)
    name = config.get_file_name_from_key(query)
    pipe = config.get_pipe(name)

    if pipe
      fb.add_item({
          :title => 'duplicated name',
          :subtitle => '',
          :valid => 'no',
      })
    else
      fb.add_item({
          :title => 'Enter the Pipe name',
          :subtitle => 'Enter to next step',
          :arg => "create-name|#{query}",
          :valid => 'yes',
      })
    end
    search.each do |p|
      fb.add_item({
          :title => p[:name],
          :subtitle => 'Action to edit, Alt+action to delete',
          :arg => "edit|#{p[:key]}",
          :valid => 'yes',
      })
    end
  else
    fb.add_item({
        :title => 'Complete the pipe with the code',
        :subtitle => 'yep',
        :arg => "create-code|#{query}",
        :valid => 'yes',
    })
  end

  puts fb.to_xml
end
