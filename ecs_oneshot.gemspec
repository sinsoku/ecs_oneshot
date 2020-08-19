# frozen_string_literal: true

require_relative "lib/ecs_oneshot/version"

Gem::Specification.new do |spec|
  spec.name          = "ecs_oneshot"
  spec.version       = EcsOneshot::VERSION
  spec.authors       = ["Takumi Shotoku"]
  spec.email         = ["sinsoku.listy@gmail.com"]

  spec.summary       = "A CLI tool that simply executes tasks on AWS Fargate."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/sinsoku/ecs_oneshot"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk-cloudwatchlogs"
  spec.add_runtime_dependency "aws-sdk-ecs"
end
