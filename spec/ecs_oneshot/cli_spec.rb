# frozen_string_literal: true

module EcsOneshot
  RSpec.describe CLI do
    let(:cli) { CLI.new }

    describe "#init_config" do
      let(:path) { ".ecs_oneshot.yml" }

      before { File.delete(path) if File.exist?(path) }
      after { File.delete(path) if File.exist?(path) }

      it "generates a configuration file" do
        cli.run(["--init"])

        yaml = YAML.load_file(path)
        expect(yaml).to eq(
          "production" => {
            "cluster" => nil,
            "service" => nil,
            "container" => nil,
            "command" => []
          }
        )
      end
    end
  end
end
