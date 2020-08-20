# frozen_string_literal: true

module EcsOneshot
  RSpec.describe Config do
    describe ".safe_build" do
      subject { Config.safe_build({ cluster: "foo", env: "production" }) }

      it "returns an object using only attribute keys" do
        is_expected.to eq Config.new(cluster: "foo")
      end
    end

    describe ".load" do
      context "file exists" do
        it do
          Tempfile.create do |f|
            f.write("---\nproduction:\n  cluster: foo\n  service: bar\n  container: buz\n")
            f.close

            config = Config.load(f.path, "production")
            expect(config).to eq Config.new(cluster: "foo", service: "bar", container: "buz")
          end
        end
      end

      context "file does not exist" do
        it do
          expect { Config.load("config.yml", "production") }
            .to raise_error(Error, "'config.yml' file not found.")
        end
      end

      context "file does not include 'env' key" do
        it do
          Tempfile.create do |f|
            f.write("---\ncluster: foo\nservice: bar\ncontainer: buz\n")
            f.close

            expect { Config.load(f.path, "production") }
              .to raise_error(Error, "'production' env not found.")
          end
        end
      end
    end

    describe "#save" do
      let(:config) { Config.new(cluster: "foo", service: "bar", container: "buz") }

      context "file exists" do
        it do
          Tempfile.create do |f|
            expect { config.save(f.path, "production") }
              .to raise_error(Error, "already exists at '#{f.path}'.")
          end
        end
      end

      context "file does not exist" do
        let(:path) { "config.yml" }

        it do
          config.save(path, "production")

          expect(File.read(path))
            .to eq "---\nproduction:\n  cluster: foo\n  service: bar\n  container: buz\n  command:\n"
        ensure
          File.delete(path) if File.exist?(path)
        end
      end
    end

    describe "#merge" do
      let(:config) { Config.new(cluster: "foo", service: "bar") }
      let(:other) { Config.new(cluster: "buz") }

      subject { config.merge(other) }

      it "merges other config" do
        is_expected.to eq Config.new(cluster: "buz", service: "bar")
      end
    end
  end
end
