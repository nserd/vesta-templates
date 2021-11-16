# PHP-CGI

Создает php-cgi шаблон в VestaCP.

```
php-cgi.sh phpX.X
```

Доступны версии PHP из репозиториев:
* (Ubuntu) `ppa:ondrej/php` 
* (CentOS) `http://rpms.remirepo.net/enterprise/remi-release-7.rpm` 
* (Debian) `https://packages.sury.org/php/`

# Timeout

Создает на основе существующего шаблона новый шаблон с требуемым временем ожидания ответа.

```
timeout.sh <--help/--list>
timeout.sh <seconds> [template]
```

* `--list`, `-l` - вывести список существующих шаблонов.
