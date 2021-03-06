# frozen_string_literal: true

require "aws-sdk-cloudwatchlogs"
require "aws-sdk-ecs"

module EcsOneshot
  class Task
    # Number of seconds between API calls to get CloudWatch Logs
    WAIT_TIME = 10

    def initialize(config)
      @config = config
      @ecs = Aws::ECS::Client.new
      @logs = Aws::CloudWatchLogs::Client.new
    end

    def run
      resp = run_task
      @arn = resp.tasks[0].task_arn
      @id = @arn.split("/").last
    end

    def console_url
      "https://console.aws.amazon.com/ecs/home?#{ecs.config.region}#/clusters/#{config.cluster}/tasks/#{@id}/details"
    end

    def wait_running
      ecs.wait_until(:tasks_running, cluster: config.cluster, tasks: [arn])
    rescue Aws::Waiters::Errors::WaiterFailed
      ecs.wait_until(:tasks_stopped, cluster: config.cluster, tasks: [arn])
    end

    def each_log(&block)
      return unless log_configuration

      last_event = nil

      loop do
        start_time = last_event.timestamp + 1 if last_event
        events = get_log_events(start_time: start_time)
        break if last_event && events.empty?

        events.each { |event| block.call(event.message) }
        last_event = events.last

        sleep(WAIT_TIME)
      end
    end

    private

    attr_reader :id, :arn, :config, :ecs, :logs

    def log_configuration
      @log_configuration ||= task_definition.container_definitions
                                            .find { |c| c.name == config.container }
                                            .log_configuration
    end

    def get_log_events(start_time:)
      awslogs_group = log_configuration.options["awslogs-group"]
      awslogs_stream_prefix = log_configuration.options["awslogs-stream-prefix"]

      resp = logs.get_log_events(
        log_group_name: awslogs_group,
        log_stream_name: "#{awslogs_stream_prefix}/#{config.container}/#{id}",
        start_time: start_time
      )
      resp.events
    end

    def task_definition
      return @task_definition if @task_definition

      task_definition = config.task_definition || service.task_definition
      @task_definition = ecs.describe_task_definition(task_definition: task_definition)
                            .task_definition
    end

    def service
      @service ||= ecs.describe_services(cluster: config.cluster, services: [config.service])
                      .services[0]
    end

    def run_task # rubocop:disable Metrics/AbcSize
      options = {
        cluster: config.cluster,
        launch_type: service.launch_type,
        overrides: { container_overrides: [{ name: config.container, command: config.command }] },
        task_definition: task_definition.task_definition_arn
      }
      options[:network_configuration] = service.network_configuration.to_h if service.network_configuration

      ecs.run_task(options)
    end
  end
end
