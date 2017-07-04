require 'fluent/plugin/input'
require 'json'

module Fluent::Plugin
  class HypershInput < Input
    # First, register the plugin. NAME is the name of this plugin
    # and identifies the plugin in the configuration file.
    Fluent::Plugin.register_input('hypersh', self)

    # config_param defines a parameter. You can refer a parameter via @port instance variable
    # :default means this parameter is optional
    config_param :service, :string

    # This method is called before starting.
    # 'conf' is a Hash that includes configuration parameters.
    # If the configuration is invalid, raise Fluent::ConfigError.
    def configure(conf)
      super

      # configured "port" is referred by `@port` or instance method #port
      if @service == ''
        raise Fluent::ConfigError, "service parameter must be defined"
      end
    end

    # This method is called when starting.
    # Open sockets or files and create a thread here.
    def start
      super

      # Identify containers running under the requested service
      service_info = JSON.parse(`hyper service inspect #{service}`)

      tag = "hypersh.#{service}"

      # start thread for each container
      # service_info[0]["Containers"][0]
      service_info[0]["Containers"].each do |container_id|
        t = Thread.new { 
          IO.popen("hyper logs --since='1s' -t -f #{container_id}") do |io|
            while (line = io.gets) do
              time = DateTime.rfc3339(line.split(' ')[0]).to_time
              fluent_time = Fluent::EventTime.new(time.to_i, time.nsec)
              record = {"message"=>line}
              router.emit(tag, fluent_time, record)
            end
          end
        }
        t.join
      end
      
    end

    # This method is called when shutting down.
    def shutdown
      # my own shutdown code

      super
    end
  end
end