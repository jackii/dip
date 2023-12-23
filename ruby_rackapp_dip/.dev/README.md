## 1 - Folder structure
```
project_root
  |- .dev/
  |  |- README.md               (1)
  |  |- dip.yml                 (2)
  |  |- docker-compose.ruby.yml (3)
  |- Gemfile                    (4)
  |- Gemfile.lock               (4)
  |- config.ru                  (5)
  |- ... other project files
```
1. This file
2. dip config file
3. docker-compose file that defines the available services
4. Gemfile for the Rack-App
5. Rack-App config file for single endpoint `GET /` path
## 2 - dip.yml 
```yml
version: "5.0"

compose:
  files:
    - ./docker-compose.ruby.yml
  project_name: ruby_rackapp_dip

interaction:
  bash:
    description: Run an arbitrary script within a container or open a shell without deps
    service: ruby
    command: /bin/bash
    compose_run_options: [ no-deps ]
  ruby: &ruby
    description: Run ruby command
    service: ruby
    command: ruby
  bundle:
    description: Run Bundler commands
    service: ruby
    command: bundle
    compose_run_options: [ no-deps ]
  rackup:
    description: Run rackup commands
    service: ruby
    command: bundle exec rackup --host 0.0.0.0
    compose:
      run_options: [service-ports]

```
## 3 - docker-compose.yml
```yml
version: "3.0"

services:
  # Current stable Ruby
  ruby: &ruby
    image: ruby:3.1
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
    # Specify frequenlty used ports to expose (9292 — Puma, 3000 — Rails).
    # Use `dip ruby server` to run a container with ports exposed.
    # Note that we "prefix" the ports with "1", so, 9292 will be available at 19292 on the host machine.
    ports:
      - 19292:9292
      - 13000:3000
      - 18080:8080

	tmpfs:
      - /tmp
volumes:
  bundler_data:
```
## 4 - Environment setup
```shell
$ cd <project_root>
$ export DIP_FILE=$(pwd)/.dev/dip.yml
```

## 5 - Commands
```shell
$ dip ruby -v

ruby 3.3.0dev (2023-12-10T11:43:47Z master d9dbcd848f) [x86_64-linux]

$ dip ruby main.rb

Welcome to ruby with dip!
ruby 3.1.4p223

$ dip bundle -v

Bundler version 2.5.0.dev

$ dip bundle install
Fetching gem metadata from https://rubygems.org/...
Resolving dependencies...
Fetching rack 3.0.8
Fetching webrick 1.8.1
Installing webrick 1.8.1
Installing rack 3.0.8
Fetching rackup 2.1.0
Installing rackup 2.1.0
Fetching rack-app 11.0.2
Installing rack-app 11.0.2
Bundle complete! 1 Gemfile dependency, 5 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```
### Run the Rack-App
```shell
$ dip rackup

[2023-12-23 19:00:43] INFO  WEBrick 1.8.1
[2023-12-23 19:00:43] INFO  ruby 3.3.0 (2023-12-10) [x86_64-linux]
[2023-12-23 19:00:43] INFO  WEBrick::HTTPServer#start: pid=1 port=9292
192.168.167.1 - - [23/Dec/2023:19:00:50 +0000] "GET / HTTP/1.1" 200 16 0.0027
192.168.167.1 - - [23/Dec/2023:19:00:50 +0000] "GET /favicon.ico HTTP/1.1" 404 13 0.0005
```

Open your browser and go to http://localhost:19292 or http://0.0.0.0:19292
