# frozen_string_literal: true

require "optparse"
require "aws-sdk-ecs"
require "aws-sdk-cloudwatchlogs"

module EcsOneshot
  class CLI
    def run(args = ARGV)
      options = parse_options(args)

      run_task(options)
    rescue Error => e
      warn e.message
      exit 1
    end

    private

    def load_config(options)
      path = options[:config]
      env = options[:environment]
      config = File.exist?(path) ? Config.load(path, env) : Config.new

      other = Config.safe_build(options)
      config.merge(other)
    end

    def run_task(options)
      config = load_config(options)
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
