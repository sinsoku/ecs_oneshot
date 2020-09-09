# frozen_string_literal: true

module EcsOneshot
  RSpec.describe CLI do
    let(:cli) { CLI.new }
    let(:example_args) do
      %w[--cluster mycluster --service myservice --task-definition rails-app:1 --container app -- bin/rails -T]
    end

    describe "#load_config" do
      context "configuration file not exist" do
        let(:config) { cli.load_config(example_args) }

        it "returns a config generated from command line args" do
          expect(config.cluster).to eq "mycluster"
          expect(config.service).to eq "myservice"
          expect(config.task_definition).to eq "rails-app:1"
          expect(config.container).to eq "app"
          expect(config.command).to eq ["bin/rails", "-T"]
        end
      end

      context "configuration file exists" do
        it "merges with values loaded from the file" do
          Tempfile.create do |f|
            f.write("---\nproduction:\n  cluster: foo\n  service: bar\n  task_definition: buz\n  container: qux\n")
            f.close

            config = cli.load_config(["--config", f.path, "--task-definition", "rails-app:1", "--", "echo", '"hello"'])
            expect(config.cluster).to eq "foo"
            expect(config.service).to eq "bar"
            expect(config.task_definition).to eq "rails-app:1" # overwrite
            expect(config.container).to eq "qux"
            expect(config.command).to eq ["echo", '"hello"']
          end
        end
      end
    end

    describe "#run" do
      let(:task) { instance_double("Task", console_url: "console_url") }

      before do
        allow(task).to receive(:wait_running)
        allow(task).to receive(:each_log).and_yield(%w[ecs_log_1 ecs_log_2])
        allow(Task).to receive(:run) { task }
      end

      it "execute ECS task and output logs" do
        actual = expect { cli.run(example_args) }
        actual.to output(/console_url/).to_stdout
        actual.to output(/ecs_log_1/).to_stdout
        actual.to output(/ecs_log_2/).to_stdout
      end
    end
  end
end
