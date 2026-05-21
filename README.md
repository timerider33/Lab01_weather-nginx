# Weather JSON Parser

Курс DevOps, задание 1.

Bash-скрипт получает текущую погоду с сервиса `wttr.in`, достает из JSON температуру, влажность и описание через `jq`, после чего формирует HTML-страницу и записывает ее в дефолтный сайт nginx:

```text
/var/www/html/index.html
```

Готовую страницу отдает nginx.

## Схема работы

```text
cron -> weather.sh -> wttr.in JSON -> jq -> index.html -> nginx
```

## Структура проекта

```text
/home/ops/projects/weather-nginx/
├── README.md
├── weather-cron.log
├── weather.json
└── weather.sh
```

## Использование скрипта

Скрипт находится в директории проекта:

```text
/home/ops/projects/weather-nginx/weather.sh
```

Запустить вручную:

```bash
/home/ops/projects/weather-nginx/weather.sh Moscow
```

Если город не передан, используется город по умолчанию:

```text
Perm
```

## Как скрипт получает данные

Скрипт обращается к адресу:

```text
https://wttr.in/{CITY}?format=j1
```

Параметр:

```text
format=j1
```

означает, что сервис вернет данные в JSON-формате.

Основные поля берутся из объекта:

```text
.current_condition[0]
```

Используемые значения:

```bash
.current_condition[0].temp_C
.current_condition[0].humidity
.current_condition[0].weatherDesc[0].value
```

## Запись страницы в nginx

Скрипт записывает HTML-файл в:

```text
/var/www/html/index.html
```

Для записи используется `sudo tee`:

```bash
sudo tee "$OUTPUT_FILE"
```

Так как каталог `/var/www/html` принадлежит `root`, для локального пользователя нужно настроить запуск `sudo` без ввода пароля.

## Настройка cron

Открыть `crontab`:

```bash
crontab -e
```

Добавить строку:

```cron
* * * * * /home/ops/projects/weather-nginx/weather.sh Perm >> /home/ops/projects/weather-nginx/weather-cron.log 2>&1
```

Эта строка запускает скрипт каждую минуту.
