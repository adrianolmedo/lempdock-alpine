# LEMPDock Alpine

Simple LEMP server dockerized with Alpine Linux, a full dev environment for PHP that include some utilities like Xdebug, Composer and Vim.

## Contents

 * [Services](#services)
 * [Usage example](#usage-example)
   * [Step 1 - Setting environment project](#step-1---setting-environment-project)
   * [Step 2 - Prepare the project](#step-2---prepare-the-project)
   * [Step 3 - Up services](#step-3---up-services)
 * [Enable Xdebug](#enable-xdebug)
 * [Remote Containers in VSCode](#remote-containers-in-vscode)
   * [Step 1 - Open VSCode on LEMPDock directory](#step-1---open-vscode-on-lempdock-directory)
   * [Step 2 - Up services](#step-2---up-services)

---

## Services

```bash
nginx
php-fpm
mysql
```

---

## Usage example

#### Step 1 - Setting environment project

```bash
$ git clone https://github.com/adrianolmedo/lempdock-alpine.git
$ mv lempdock-alpine lempdock && cd lempdock/
$ cp .env.example .env && vim .env
```

This project needs PHP 8 and MySQL 8:

```
APP_CODE_PATH_HOST=../hello-world

APACHE_HOST_HTTP_PORT=8080

PHP_VERSION=8

MYSQL_VERSION=8
MYSQL_DATABASE=lempdock
MYSQL_USER=admin
MYSQL_PASSWORD=1234567b
MYSQL_PORT=3307
MYSQL_ROOT_PASSWORD=1234567a
```

You must create your project directories outside of `lempdock/`:

```bash
$ cd ..
$ mkdir hello-world
```

The structure of the full environment must be:

```bash
$ tree .
lempdock
hello-world
```

#### Step 2 - Prepare the project

```bash
$ vim hello-world/index.php
```

```php
<?php
$dbhost = 'mysql';
$dbname = 'lempdock';
$dbroot = 'root';
$dbpass = '1234567a';

try {
    $conn = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbroot, $dbpass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo 'Connected successfully';
} catch(PDOException $e) {
    echo 'Connection failed: ' . $e->getMessage();
}
?>
```

#### Step 3 - Up services

```bash
$ cd lempdock
$ docker-compose up -d --build
```

Go to http://172.17.0.1:8080.

![Connected successfully to MySQL](https://i.imgur.com/crTX0m9.png)

---

## Enable Xdebug

Get access to `php-fpm` service executing:

```bash
$ docker-compose exec -u root php-fpm bash
```

Then to uncomment the first line in `/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini` and then restart service:

```bash
$ docker restart php-fpm
```

*Happy debbuging with your favorite IDE!*

---

## Remote Containers in VSCode

#### Step 1 - Open VSCode on LEMPDock directory

```bash
$ cd lempdock && code .
```

In `.devcontainer/` rename `devcontainer.example.json` to `devcontainer.json`.

Put your settings and extensions favorites, example:

```json
"settings": {
	"terminal.integrated.sendKeybindingsToShell": true,
	"terminal.integrated.tabs.enabled": true,
	"php.validate.executablePath": "/usr/local/bin/php"
},

"extensions": [
	"bmewburn.vscode-intelephense-client",
	"ecmel.vscode-html-css",
	"felixfbecker.php-debug",
	"felixfbecker.php-intellisense",
	"formulahendry.terminal",
	"kakumei.php-xdebug",
	"lonefy.vscode-JS-CSS-HTML-formatter"
]
```

#### Step 2 - Up services

`Ctrl+Shitf+P` > *Remote-Containers: Rebuild and Reopen in Container*.

This way VSCode it will cache your extensions into the container, check it with:

```bash
$ docker diff php-fpm
```

