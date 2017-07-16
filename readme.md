# Laravel Docker Development Environment

Starter configuration to develop docker virtualized laravel projects.

#### Requirements:

 - build-essential (Makefile)
 - Docker (min >= 1.13)
 - Docker-Compose (min >= 1.10.0 https://github.com/docker/compose/releases/tag/1.10.0)

#### Available Commands

```sh
$ make install
# dependency installation and migrations
```

```sh
$ make up
# turn on server (8080 web, 33061 mysql) => http://www.appname.localhost:8080
```

```sh
$ make down
# turn off server
```

```sh
$ make install_test
# install test database
```

```sh
$ make test
# tests executions (phpunit)
# use TEST_ARGS to pass arguments. ej. make test TEST_ARGS='--filter TestClass'
```