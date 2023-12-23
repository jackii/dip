## 1 - Folder structure
```
project_root
  |- .dev/
  |  |- README.md          (1)
  |  |- dip.yml            (2)
  |  |- docker-compose.yml (3)
  |- ... other project files
```
1. This file
2. dip config file
3. docker-compose file that defines the available services
## 2 - dip.yml 
```yml
version: "5.0"

compose:
  files:
    - ./docker-compose.ruby.yml
  project_name: ruby_dip

interaction:
  bash: &bash
    description: Open service terminal
    service: ruby
    command: /bin/bash
  ruby: &ruby
    description: Run ruby command
    service: ruby
    command: ruby
```
## 3 - docker-compose.yml
```
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
    tmpfs:
      - /tmp
volumes:
  bundler_data:
```
## 4 - Environment setup
```shell
$ cd <project_root>
$ export DIP_FILE=$(pwd)/.dev/dip.yml

## Commands
```shell
$ dip ruby
```
