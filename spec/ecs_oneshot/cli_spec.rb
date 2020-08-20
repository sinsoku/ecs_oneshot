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

        expect(File.read(path))
          .to eq "---\nproduction:\n  cluster:\n  service:\n  container:\n  command: []\n"
      end
    end
  end
end
