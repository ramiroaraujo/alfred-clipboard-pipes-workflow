require_relative 'workflow_config'

config = WorkflowConfig.new

pipe = config.get_pipe(ARGV.join(' '))
utf8 = 'export __CF_USER_TEXT_ENCODING=0x1F5:0x8000100:0x8000100'

result = `#{utf8}; /bin/bash -c 'pbpaste | ./pipes/#{pipe[:key]}.sh'`.chomp("\n")

print result