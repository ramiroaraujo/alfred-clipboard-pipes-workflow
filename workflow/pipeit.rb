require_relative 'workflow_config'

config = WorkflowConfig.new

command = ARGV[0].split('<<|>>')[0]
params = ARGV[0].split('<<|>>')[1..-1]

pipe = config.get_pipe(command)

if pipe[:params].length > params.length
  `osascript -e 'tell application "Alfred 2" to search "_| #{command} #{params.join(',')}"'`
  exit
end

utf8 = 'export __CF_USER_TEXT_ENCODING=0x1F5:0x8000100:0x8000100'

if pipe[:params].length == 0
  script = "./pipes/#{pipe[:key]}.sh"
else
  temp_script = File.open('temp_script', 'w', 0755) do |file|
    orig_script = File.read("./pipes/#{pipe[:key]}.sh")
    orig_script.gsub!(/\{([a-z0-9\-]+?)\}/).with_index do |noop, index|
      params[index]
    end
    file.write(orig_script)
  end
  script = "./temp_script"
end

result = `#{utf8}; /bin/bash -c 'pbpaste | #{script}'`.chomp("\n")

if defined? temp_script
  File.delete script
end

print result