#!/bin/bash

# Скрипт получает название города первым параметром, по умолчанию Perm
CITY="${1:-Perm}"

# Файл, в который будем писать - дефолтный сайт nginx
OUTPUT_FILE="/var/www/html/index.html"

# Адрес wttr.in, который отдаёт погоду в JSON-формате
URL="https://wttr.in/${CITY}?format=j1"

# Получаем JSON с погодой
WEATHER_JSON=$(curl -sS "$URL")

# Все интересующее нас тут: .current_condition[0]
# [
#   {
#     "FeelsLikeC": "10",
#     "FeelsLikeF": "50",
#     "cloudcover": "37",
#     "humidity": "88",
#     "observation_time": "04:49 AM",
#     "precipInches": "0.0",
#     "precipMM": "0.0",
#     "pressure": "1013",
#     "pressureInches": "30",
#     "temp_C": "12",
#     "temp_F": "54",
#     "uvIndex": "0",
#     "visibility": "10",
#     "visibilityMiles": "6",
#     "weatherCode": "116",
#     "weatherDesc": [
#       {
#         "value": "Partly cloudy"
#       }
#     ],


TEMP=$(jq -r '.current_condition[0].temp_C' <<< "$WEATHER_JSON")
HUMIDITY=$(jq -r '.current_condition[0].humidity' <<< "$WEATHER_JSON")
DESCRIPTION=$(jq -r '.current_condition[0].weatherDesc[0].value' <<< "$WEATHER_JSON")

# Текущее время
NOW=$(date)

# Создаём HTML-страницу и записываем её в index.html nginx
sudo tee "$OUTPUT_FILE" > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Weather</title>
</head>
<body>
    <h1>Weather in $CITY</h1>

    <p>Temperature: $TEMP °C</p>
    <p>Humidity: $HUMIDITY%</p>
    <p>Description: $DESCRIPTION</p>

    <hr>

    <p>Last update: $NOW</p>
</body>
</html>
EOF
