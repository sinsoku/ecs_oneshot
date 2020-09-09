# EcsOneshot

![Ruby](https://github.com/sinsoku/ecs_oneshot/workflows/Ruby/badge.svg)
[![Gem Version](https://badge.fury.io/rb/ecs_oneshot.svg)](https://badge.fury.io/rb/ecs_oneshot)

Provides a simple way to run one-shot tasks using the ECS runTask API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecs_oneshot'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ecs_oneshot

## Usage

```
Usage: ecs_oneshot [options] -- <command>
    -c, --config FILE                Specify configuration file. (default: .ecs_oneshot.yml)
    -e, --environment ENVIRONMENT    Specify environment. (default: production)
        --cluster CLUSTER
        --service SERVICE
        --task-definition TASK_DEFINITION
        --container CONTAINER
```

## Example

```console
$ ecs_oneshot --cluster mycluster --service myservice --task-definition rails-app:1 --container app -- bin/rails -T
Task started. Watch this task's details in the Amazon ECS console: https://console.aws.amazon.com/ecs/home?ap-northeast-1#/clusters/default/tasks/00000000-1234-5678-9000-aaaaaaaaaaaa/details
=== Wait for Task Starting...
=== Following Logs...
rails about                              # List versions of all Rails frameworks and the environment
rails app:template                       # Applies the template supplied by LOCATION=(/path/to/template) or URL
rails app:update                         # Update configs and some other initially generated files (or use just update:configs or update:bin)
(...)

=== Task Stopped.
```

### Configuration file

If the configuration file exists, it will be loaded.

```yaml
# .ecs_oneshot.yml
---
production:
  cluster: mycluster
  service: myservice
  task_definition: task-def
  container: mycontainer
```

You can simply execute the command by omitting the arguments.

```console
$ ecs_oneshot -- echo "hello"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sinsoku/ecs_oneshot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sinsoku/ecs_oneshot/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EcsOneshot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sinsoku/ecs_oneshot/blob/master/CODE_OF_CONDUCT.md).
