#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative 'bundle/bundler/setup'
require 'alfred'
require_relative 'workflow_config'

query = ARGV[0]
name = query.split(' ')[0]

fb = nil

Alfred.with_friendly_error do |alfred|

  fb = alfred.feedback
  config = WorkflowConfig.new

  pipe = config.get_pipe(name)
  unless pipe
    fb.add_item({
        :title => "query = #{name}",
        :subtitle => '',
        :valid => 'no',
    })
    break
  end

  fb.add_item({
      :title => "parameters for #{pipe[:name]}",
      :subtitle => "parameters needed: #{pipe[:params].join(', ')}",
      :arg => query.split(/,| /).join('<<|>>'),
      :valid => 'yes',
  })
end

puts fb.to_xml
