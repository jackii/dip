## 1 - Folder structure
Start with the following files and folder structure
```
project_root
  |- .dev/
  |  |- README.md                 (1)
  |  |- dip.yml                   (2)
  |  |- docker-compose.rails.yml  (3)
  |  |- Dockerfile.dev            (4)
  |
  |- ... Ruby on Rails project files
```
```
1. This file
2. The `dip.yml` config file
3. The compose file for Ruby

```yml
# .dev/dip.yml
version: "5.0"

compose:
  files:
    - ./docker-compose.rails.yml      # <-- use this
  project_name: ruby_on_rails_dip

interaction:
  # Run a Rails container without any dependent services
  bash:
    description: Run an arbitrary script within a container (or open a shell without deps)
    service: rails
    command: /bin/bash
    compose_run_options: [ no-deps ]
  ruby: &ruby
    description: Run Ruby command
    service: rails
    command: ruby
  bundle:
    description: Run Bundler commands
    service: rails
    command: bundle
    compose_run_options: [ no-deps ]
  gem:
    description: Run Rubygems commands
    service: rails
    command: gem
    compose_run_options: [ no-deps ]
  rails:                              # <-- added these lines
    description: Run Rails commands
    service: rails
    command: rails
    subcommands:
      s:
        description: Run Rails server at http://0.0.0.0:3000
        service: rails
        command: bundle exec rails server -b 0.0.0.0 -p 3000
        compose:
          run_options: [service-ports]
```

```yml
# .dev/docker-compose.rails.yml
version: "3.4"

services:
  rails: &rails
    build: Dockerfile.dev
    volumes:
      # That's all the magic!
      - ${PWD}:/${PWD}:cached
      - bundler_data:/usr/local/bundle
    environment:
      HISTFILE: /usr/local/hist/.bash_history
      LANG: C.UTF-8
      PROMPT_DIRTRIM: 2
      PS1: '[\W]\! '
      # Plays nice with gemfiles/*.gemfile files for CI
      BUNDLE_GEMFILE: ${BUNDLE_GEMFILE:-Gemfile}
    # And that's the second part of the spell
    working_dir: ${PWD}
    ports:
      - 3000:3000
    tmpfs:
      - /tmp
volumes:
  bundler_data:
```

```yml
# Dockerfile.dev
# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.1.4
FROM registry.docker.com/library/ruby:$RUBY_VERSION as base # use the same as docker-compose.ruby.yml

# Set production environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install application gems
COPY Gemfile ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
```
## 2 - Getting Started
### Install rails
Run the following commands
```shell
$ export DIP_FILE=$(pwd)/.dev/dip.yml

# Install rails
$ dip gem install rails
```
### Create rails application
```shell
$ dip bash -c "rails -v" 
$ dip bash -c "rails new -h" 

# Create a new rails application with defaults
$ dip bash -c "rails new . --name RailsOnDip"
```

```ad-note
The `Dockefile` created by rails is only for production, hence it's not suitable for development mode in `dip`
```

### Running the application
```shell
$ dip rails s
```
Open http://0.0.0.0.0:3000 on your browser

## 3. Things to note
1. Use `ruby:3.x.x` version on `Dockerfile.dev` for development, do not use `-slim` or `-alpine` version
2. Use `docker-compose.rails.yml` instead of `docker-compose.ruby.yml`
3. Must open up the ports in the container. See the `ports` in the `docker-compose.rails.yml`
4. When running rails server, must bind the ip address to `0.0.0.0`. i.e. `bundle exec rails s -b 0.0.0.0`. See the subcommand of the `rails` command in the `dip.yml`
