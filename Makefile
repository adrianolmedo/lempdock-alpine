build:
	docker build -f php-fpm.Dockerfile -t lempdock-php:latest .
	docker build -f nginx.Dockerfile -t lempdock-nginx:latest .
run:
	docker compose up -d php-fpm nginx --build mysql phpmyadmin

deps:
	docker exec -u 1000 -i lempdock-php /bin/sh -c "composer install --ignore-platform-req=ext-http"

perms:
	docker exec -u root -i lempdock-php /bin/sh -c "chown -R lempdock:www-data /var/www/*"
	docker exec -u 1000 -i lempdock-php /bin/sh -c "chmod -R g+rw /var/www/*"
