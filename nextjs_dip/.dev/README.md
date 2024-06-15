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

```
$ dip yarn create next-app

Need to install the following packages:
  create-next-app@14.2.4
Ok to proceed? (y) y
✔ What is your project named? … nextjs-with-dip
✔ Would you like to use TypeScript? … No / *Yes
✔ Would you like to use ESLint? … No / *Yes
✔ Would you like to use Tailwind CSS? … No / *Yes
✔ Would you like to use `src/` directory? … No / *Yes
✔ Would you like to use App Router? (recommended) … No / *Yes
✔ Would you like to customize the default import alias (@/*)? … No / *Yes
✔ What import alias would you like configured? … @/*
Creating a new Next.js app in /app/nextjs-with-dip

Using yarn.

Initializing project with template: app-tw 


Installing dependencies:
- react
- react-dom
- next

Installing devDependencies:
- typescript
- @types/node
- @types/react
- @types/react-dom
- postcss
- tailwindcss
- eslint
- eslint-config-next

yarn install v1.22.22
info No lockfile found.
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
[4/4] Building fresh packages...
success Saved lockfile.
Done in 45.71s.
Success! Created nextjs-with-dip at /app/nextjs-with-dip

Done in 143.40s.
```

```
# Also need to install `next` command
$ dip yarn add next@latest 

yarn add v1.22.22
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
[4/4] Building fresh packages...
success Saved lockfile.
success Saved 1 new dependency.
info Direct dependencies
└─ next@14.2.4
info All dependencies
└─ next@14.2.4
Done in 17.98s.
```

```
$ dip yarn dev

yarn run v1.22.22
$ next dev
  ▲ Next.js 14.2.4
  - Local:        http://localhost:3000

 ✓ Starting...
Attention: Next.js now collects completely anonymous telemetry regarding usage.
This information is used to shape Next.js' roadmap and prioritize features.
You can learn more, including how to opt-out if you'd not like to participate in this anonymous program, by visiting the following URL:
https://nextjs.org/telemetry

 ✓ Ready in 1507ms
```

```
$ dip compose up                                                                                                                                [3:30:40]
[+] Running 1/0
 ✔ Container nextjs-app-1  Created                                                                                                                                             0.1s 
Attaching to app-1
app-1  | yarn run v1.22.22
app-1  | $ next dev -p ${PORT-4000}
app-1  |   ▲ Next.js 14.2.4
app-1  |   - Local:        http://localhost:4000
app-1  | 
app-1  |  ✓ Starting...
app-1  |  ✓ Ready in 2.6s
```
