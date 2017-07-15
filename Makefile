APP_NAME = appname
CONTAINER_APP = appname_app_1
CONTAINER_DATABASE = appname_database_1

DB_DATABASE = db_database
DB_USERNAME = db_username
DB_PASSWORD = db_password
DB_ROOTUSERNAME = db_rootusername
DB_ROOTPASSWORD = db_rootpassword

ifndef CI
	INTERACTIVE_MODE = "-ti"
endif

up:
	@docker-compose -p $(APP_NAME) up -d ${ARGS}

down:
	@docker-compose -p $(APP_NAME) down ${ARGS}

install:
	@docker run -v `pwd`:/app composer/composer install
	@cp .env.example .env
	@$(MAKE) up ARGS="--build"
	@until docker exec $(CONTAINER_DATABASE) mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) -e "select 1" > /dev/null 2>&1; do sleep 1; done
	@docker exec $(CONTAINER_APP) php artisan key:generate
	@docker exec $(CONTAINER_APP) php artisan migrate
	@$(MAKE) down

install_test:
	@$(MAKE) up >/dev/null 2>/dev/null
	@until docker exec $(CONTAINER_DATABASE) mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) -e "select 1" > /dev/null 2>&1; do sleep 1; done
	@docker exec $(CONTAINER_DATABASE) mysql -u $(DB_ROOTUSERNAME) -p$(DB_ROOTPASSWORD) -e "CREATE DATABASE IF NOT EXISTS $(DB_DATABASE)_testing"

test_ci:
	@$(MAKE) up >/dev/null 2>/dev/null
	@$(MAKE) -s test CI="true"

test:
	@docker exec $(INTERACTIVE_MODE) $(CONTAINER_APP) sh -c "vendor/bin/phpunit ${TEST_ARGS}"