# frozen_string_literal: true

module EcsOneshot
  RSpec.describe Task do
    let(:ecs_url) { "https://ecs.us-west-1.amazonaws.com/" }
    let(:config) { Config.new(cluster: "foo", service: "bar", container: "buz", command: ["echo"]) }

    describe ".run" do
      let(:task_def) { "arn:aws:ecs:us-west-1:123456789012:task-definition/sample:1" }
      let(:task_id) { "a1b2c3d4-5678-90ab-ccdef-11111EXAMPLE" }
      let(:task_arn) { "arn:aws:ecs:us-west-1:123456789012:task/#{task_id}" }

      let!(:ecs_describe_services) do
        req = { cluster: config.cluster, services: [config.service] }.to_json
        res = { services: [{ taskDefinition: task_def, launchType: "FARGATE" }] }.to_json

        stub_request(:post, ecs_url).with(body: req).to_return(body: res)
      end
      let!(:ecs_describe_task_definition) do
        req = { taskDefinition: task_def }.to_json
        res = { taskDefinition: { taskDefinitionArn: task_def } }.to_json

        stub_request(:post, ecs_url).with(body: req).to_return(body: res)
      end
      let!(:ecs_run_task) do
        req = {
          cluster: config.cluster,
          launchType: "FARGATE",
          overrides: { containerOverrides: [{ name: config.container, command: config.command }] },
          taskDefinition: task_def
        }.to_json
        res = { tasks: [{ taskArn: task_arn }] }.to_json

       stub_request(:post, ecs_url).with(body: req).to_return(body: res)
      end

      it "returns an instance created from API responses" do
        task = described_class.run(config)

        expect(ecs_describe_services).to have_been_requested
        expect(ecs_describe_task_definition).to have_been_requested
        expect(ecs_run_task).to have_been_requested

        expect(task.arn).to eq task_arn
        expect(task.id).to eq task_id
        expect(task.console_url).to eq(
          "https://console.aws.amazon.com/ecs/home?us-west-1#/clusters/foo/tasks/#{task_id}/details"
        )
      end
    end

    describe "#wait_running" do
      let(:config) { Config.new(cluster: "foo", service: "bar", container: "buz", command: ["echo"]) }
      let(:arn) { "arn:aws:ecs:us-west-1:123456789012:task/123" }
      let(:task) { described_class.new(config: config, arn: arn, task_definition: nil) }

      context "when the task is running" do
        let!(:ecs_wait_running) do
          req = { cluster: config.cluster, tasks: [arn] }.to_json
          res = { tasks: [{ lastStatus: "RUNNING" }] }.to_json

          stub_request(:post, ecs_url).with(body: req).to_return(body: res)
        end

        it "wait a running task" do
          expect(task.wait_running).to be
          expect(ecs_wait_running).to have_been_requested
        end
      end

      context "when the task is stopped" do
        let!(:ecs_wait_running) do
          req = { cluster: config.cluster, tasks: [arn] }.to_json
          res = { tasks: [{ lastStatus: "STOPPED" }] }.to_json

          stub_request(:post, ecs_url).with(body: req).to_return(body: res)
        end

        it "wait a running task" do
          expect(task.wait_running).to be
          expect(ecs_wait_running).to have_been_requested.twice
        end
      end
    end
  end
end
