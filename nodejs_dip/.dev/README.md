## 1 - Folder structure
```
project_root
  |- .dev/
  |  |- .bashrc                 (1)
  |  |- Aptfile                 (2)
  |  |- Dockerfile              (3)
  |  |- README.md               (4)
  |  |- dip.yml                 (5)
  |  |- docker-compose.yml      (6)
  |- package.json               (7)
  |- yarn.lock                  (8)
  |- node_modules/              (9)
  |- ... other project files
```
1. The bashrc script file
2. Extra apt packages that are needed
3. The Dockerfile
4. This file
5. The dip config file
6. docker-compose file that defines the available services
7. pacakge.json for the nodejs
8. yarn.lock lockfile
9. node_modules folder
## 2 - dip.yml 
```yml
version: '8.0'

compose:
  files:
    - ./docker-compose.yml
  project_name: nextjs

interaction:
  # This command spins up a container without and opens a terminal within it.
  runner:
    description: Open a Bash shell within the container
    service: app
    command: /bin/bash
    compose_run_options: [ no-deps ]
  node:
    description: Run the node command
    service: app
    command: node
  npm:
    description: Run the npm command
    service: app
    command: npm
  yarn:
    description: Run the yarn command
    service: app
    command: yarn
```
## 3 - docker-compose.yml
```yml
x-app: &app
  build:
    context: ../
    dockerfile: .dev/Dockerfile
    args:
      NODE_MAJOR: '18'
  environment: &env
    NODE_ENV: ${NODE_ENV:-development}
  tmpfs:
    - /tmp
 
services:
  app:
    <<: *app
    command: tail -f /dev/null
    volumes:
      - ..:/app:cached
      - node_modules:/app/node_modules
      - history:/usr/local/hist
      - ./.bashrc:/root/.bashrc:ro

volumes:
  history:
  node_modules:
```
## 4 - Environment setup
```shell
$ cd <project_root>
$ export DIP_FILE=$(pwd)/.dev/dip.yml
```

## 5 - Commands
```shell
$ dip node -v
v18.17.1

$ dip npm -v 
9.6.7

$ dip yarn -v
1.22.22

$ dip yarn install
yarn install v1.22.22
[1/4] Resolving packages...
success Already up-to-date.
Done in 0.06s.
```
