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

  # list new ones, filtered
  search = config.search_pipes(query)

  if search.length
    search.each do |pipe|
      fb.add_item({
          :title => pipe[:name],
          :subtitle => pipe[:code],
          :arg => pipe[:key],
          :valid => 'yes',
      })
    end
  else
    fb.add_item({
        :title => 'No results for your search',
        :subtitle => '',
        :valid => 'no',
    })

  end

  puts fb.to_xml
end
