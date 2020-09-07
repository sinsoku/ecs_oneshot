# frozen_string_literal: true

require "optparse"
require "aws-sdk-ecs"
require "aws-sdk-cloudwatchlogs"

module EcsOneshot
  class CLI
    def run(args = ARGV)
      options = parse_options(args)
      config = load_config(options)

      run_task(config)
    rescue Error => e
      warn e.message
      exit 1
    end

    private

    def load_config(options)
      opts = options.dup

      path = opts.delete(:config)
      env = opts.delete(:environment)
      cli_config = Config.new(**opts)

      if File.exist?(path)
        Config.load(path, env).merge(cli_config)
      else
        cli_config
      end
    end

    def run_task(config)
      raise Error, "<command> is required." if config.command.empty?

      t = Task.new(config)
      t.run
      puts "Task started. Watch this task's details in the Amazon ECS console: #{t.console_url}\n\n"
      puts "=== Wait for Task Starting..."
      t.wait_running
      puts "=== Following Logs..."
      t.each_log { |log| puts(log) }
      puts "\n=== Task Stopped."
    end

    def parse_options(args) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      opts = OptionParser.new
      opts.banner = "Usage: ecs_oneshot [options] -- <command>"
      opts.version = VERSION

      opts.on("-c", "--config FILE", "Specify configuration file. (default: .ecs_oneshot.yml)")
      opts.on("-e", "--environment ENVIRONMENT", "Specify environment. (default: production)")
      opts.on("--cluster CLUSTER")
      opts.on("--service SERVICE")
      opts.on("--task-definition TASK_DEFINITION")
      opts.on("--container CONTAINER")

      {}.tap do |h|
        h[:command] = opts.parse(args, into: h)
        h[:config] ||= ".ecs_oneshot.yml"
        h[:environment] ||= "production"
        h[:task_definition] = h.delete(:"task-definition")
      end
    end
  end
end
