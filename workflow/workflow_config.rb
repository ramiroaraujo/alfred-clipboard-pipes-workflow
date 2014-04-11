require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative 'bundle/bundler/setup'
require 'yaml'
require 'stringex_lite'

class WorkflowConfig

  @config

  @pipes
  @pipe_keys

  def initialize
    load_config
  end

  def get_pipes
    @pipes
  end

  def get_pipe(name)
    return false unless @pipe_keys.include? name
    @pipes.find { |pipe| pipe[:key] == name }
  end

  def search_pipes(query)
    query = query.downcase
    @pipes.select do |pipe|
      pipe[:name].downcase =~ /#{query}/
    end
  end


  # adds pipe name to temp data, and prompts user to complete it with the one-liner
  # @param [String] name
  def add_pipe_name(name)

    # check unique filename/key
    filename = get_file_name_from_key name
    raise Exception if @pipe_keys.include? filename
    raise Exception if File.exist? 'pipes/' + filename + '.sh'

    # delete previous temp file, create new one with name
    File.delete 'temp' if File.exist? 'temp'
    File.open('temp', 'w') { |file| file.write(name) }
  end

  # @param [String] code
  def add_pipe_code(code)
    # check temp file with name exists
    raise Exception unless File.exist? 'temp'

    name = File.read('temp')
    File.delete 'temp'

    filename = get_file_name_from_key name

    File.open('pipes/' + filename + '.sh', 'w') { |file| file.write(code) }

    @config[:pipes] << { :name => name, :key => filename }
    refresh_pipes
    name
  end

  def remove_pipe(name)
    raise Exception unless @pipe_keys.include? name

    @config[:pipes] = @pipes.reject { |pipe| pipe[:key] == name }
    File.delete "pipes/#{name}.sh"
    save_config
  end

  def load_config
    @config = YAML.load(File.open('config.yml'))

    refresh_pipes unless @config[:pipes].all? { |pipe| pipe.key?(:code) }

    @pipes = @config[:pipes]
    @pipe_keys = @config[:pipes].map { |pipe| pipe[:key] }
  end

  def save_config
    File.open('config.yml', 'w') { |f| f.write(@config.to_yaml) }
    @pipes = @config[:pipes]
    @pipe_keys = @config[:pipes].map { |pipe| pipe[:key] }
  end

  def refresh_pipes
    @config[:pipes].each do |pipe|
      next if pipe.key?(:code)
      code = File.read "pipes/#{pipe[:key]}.sh"
      code.strip!
      code = code.lines[1..-1].join(' \ ') if /^#!/ =~ code
      code = "#{code[0..100]}..." if code.length > 100
      pipe[:code] = code
    end

    save_config
  end

  def get_file_name_from_key key
    key.to_ascii.gsub(/[^\w]/, '-').gsub(/-{2,}/, '-').gsub(/^[^\w]+/, '').downcase
  end

  private :load_config, :save_config, :initialize

end