# frozen_string_literal: true

require "yaml"

module EcsOneshot
  Config = Struct.new(:cluster, :service, :container, :task_definition, :command, keyword_init: true)

  class Config
    class << self
      def load(path, env)
        raise Error, "'#{path}' file not found." unless File.exist?(path)

        yaml = YAML.load_file(path)
        raise Error, "'#{env}' env not found." unless yaml.key?(env)

        options = yaml[env]
        new(**options)
      end
    end

    def merge(other)
      new_options = to_h.merge(other.to_h.compact)
      Config.new(**new_options)
    end
  end
end
