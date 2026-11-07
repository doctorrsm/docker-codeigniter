# CodeIgniter 4 in Docker

Local development stack: PHP 8.3, Nginx, MySQL 8, phpMyAdmin, Redis, and Mailpit. One command starts the containers as your user and installs CodeIgniter when it is not there yet.

## Requirements

- Docker and Docker Compose
- Make
- Bash

## Start

```bash
make up
```

The command copies `.env.example` to `.env` when that file is missing, builds the containers, and starts them. PHP writes files in `src/` as your uid and gid. If `src/` has no CodeIgniter, it installs `codeigniter4/appstarter`. If the app is already there but `vendor/` is missing, it runs `composer install`. An existing `src/` is not replaced.

After startup:

- app: http://localhost:8080
- phpMyAdmin: http://localhost:8081
- Mailpit: http://localhost:8025

Database credentials come from `.env`. The example uses `ci4_user` / `ci4_password` and the database `ci4_db`. These passwords are for your machine only. Change them in `.env` before exposing any port, run `make env`, then recreate the containers. Ports are bound to `127.0.0.1`.

`make env` rebuilds `src/.env` from the root `.env`. A normal `make up` leaves an existing `src/.env` alone.

Container names come from the project directory, so two clones do not clash. Change the ports in the second project's `.env`, or `8080`, `3306`, and the rest stay taken.

## Commands

```bash
make install              # install CodeIgniter or composer install only
make down                 # stop the containers
make restart              # restart
make logs                 # logs
make shell                # PHP shell as your user
make composer c="install" # any Composer command
make spark c="migrate"    # any spark command
```

Changing `MYSQL_PASSWORD` does not change the password in an existing MySQL volume. For an empty database, run `docker compose down -v`. That deletes the database and Redis data.
