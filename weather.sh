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
FEELS_LIKE=$(jq -r '.current_condition[0].FeelsLikeC' <<< "$WEATHER_JSON")
HUMIDITY=$(jq -r '.current_condition[0].humidity' <<< "$WEATHER_JSON")
DESCRIPTION=$(jq -r '.current_condition[0].weatherDesc[0].value' <<< "$WEATHER_JSON")
WIND_SPEED=$(jq -r '.current_condition[0].windspeedKmph' <<< "$WEATHER_JSON")
PRESSURE=$(jq -r '.current_condition[0].pressure' <<< "$WEATHER_JSON")
VISIBILITY=$(jq -r '.current_condition[0].visibility' <<< "$WEATHER_JSON")
UV_INDEX=$(jq -r '.current_condition[0].uvIndex' <<< "$WEATHER_JSON")
ICON_URL=$(jq -r '.current_condition[0].weatherIconUrl[0].value' <<< "$WEATHER_JSON")

# Текущее время
NOW=$(date)

# Создаём HTML-страницу и записываем её в index.html nginx
sudo tee "$OUTPUT_FILE" > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather in $CITY</title>
    <style>
        :root {
            color-scheme: light;
            --ink: #16202a;
            --muted: #66707c;
            --line: #d8dde3;
            --panel: #ffffff;
            --surface: #eef2f4;
            --sky: #9ed7ff;
            --mint: #93e2bd;
            --sun: #ffc857;
            --storm: #4f6478;
            --accent: #0f766e;
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            margin: 0;
            font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            color: var(--ink);
            background:
                linear-gradient(135deg, rgba(158, 215, 255, 0.9), rgba(147, 226, 189, 0.68) 44%, rgba(255, 200, 87, 0.44)),
                var(--surface);
        }

        main {
            width: min(1040px, calc(100% - 32px));
            min-height: 100vh;
            margin: 0 auto;
            display: grid;
            align-content: center;
            gap: 18px;
            padding: 32px 0;
        }

        .weather-shell {
            display: grid;
            grid-template-columns: minmax(0, 1.1fr) minmax(280px, 0.9fr);
            min-height: 560px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.68);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.7);
            box-shadow: 0 24px 80px rgba(35, 48, 61, 0.22);
            backdrop-filter: blur(18px);
        }

        .hero {
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: clamp(28px, 5vw, 56px);
            color: #ffffff;
            background:
                linear-gradient(140deg, rgba(17, 32, 46, 0.82), rgba(15, 118, 110, 0.58)),
                url("$ICON_URL") center 38% / 190px no-repeat,
                linear-gradient(155deg, var(--storm), var(--accent) 52%, #d79a2b);
        }

        .hero::after {
            content: "";
            position: absolute;
            inset: auto 0 0;
            height: 42%;
            background: linear-gradient(0deg, rgba(0, 0, 0, 0.28), transparent);
            pointer-events: none;
        }

        .hero > * {
            position: relative;
            z-index: 1;
        }

        .eyebrow {
            width: fit-content;
            margin: 0;
            padding: 7px 10px;
            border: 1px solid rgba(255, 255, 255, 0.34);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.12);
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        h1 {
            margin: 0;
            font-size: clamp(2.4rem, 8vw, 6.8rem);
            line-height: 0.9;
            font-weight: 850;
        }

        .description {
            max-width: 520px;
            margin: 16px 0 0;
            font-size: clamp(1.15rem, 2.2vw, 1.65rem);
            line-height: 1.24;
            font-weight: 650;
        }

        .temperature {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-top: 28px;
        }

        .temperature strong {
            font-size: clamp(5.2rem, 15vw, 10rem);
            line-height: 0.78;
            letter-spacing: 0;
        }

        .temperature span {
            margin-top: 8px;
            font-size: clamp(1.7rem, 3vw, 2.8rem);
            font-weight: 750;
        }

        .details {
            display: grid;
            grid-template-rows: auto 1fr auto;
            gap: 22px;
            padding: clamp(24px, 4vw, 42px);
            background: rgba(255, 255, 255, 0.9);
        }

        .details-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding-bottom: 18px;
            border-bottom: 1px solid var(--line);
        }

        .place {
            min-width: 0;
        }

        .place p {
            margin: 0 0 6px;
            color: var(--muted);
            font-size: 0.86rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        .place h2 {
            margin: 0;
            overflow-wrap: anywhere;
            font-size: clamp(1.85rem, 4vw, 3rem);
            line-height: 1;
        }

        .weather-icon {
            width: 76px;
            height: 76px;
            flex: 0 0 auto;
            border: 1px solid var(--line);
            border-radius: 8px;
            background: #f8fafc;
            object-fit: contain;
        }

        .metrics {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            align-content: start;
        }

        .metric {
            min-height: 112px;
            padding: 16px;
            border: 1px solid var(--line);
            border-radius: 8px;
            background: var(--panel);
        }

        .metric span {
            display: block;
            margin-bottom: 12px;
            color: var(--muted);
            font-size: 0.78rem;
            font-weight: 750;
            text-transform: uppercase;
        }

        .metric strong {
            display: block;
            font-size: clamp(1.55rem, 4vw, 2.25rem);
            line-height: 1;
        }

        .metric small {
            display: block;
            margin-top: 8px;
            color: var(--muted);
            font-size: 0.92rem;
        }

        .updated {
            margin: 0;
            padding-top: 18px;
            border-top: 1px solid var(--line);
            color: var(--muted);
            font-size: 0.92rem;
            line-height: 1.5;
        }

        @media (max-width: 760px) {
            main {
                width: min(100% - 20px, 520px);
                align-content: start;
                padding: 10px 0;
            }

            .weather-shell {
                grid-template-columns: 1fr;
                min-height: 0;
            }

            .hero {
                min-height: 380px;
            }

            .metrics {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <main>
        <section class="weather-shell" aria-label="Current weather">
            <div class="hero">
                <p class="eyebrow">Live weather</p>
                <div>
                    <h1>$CITY</h1>
                    <div class="temperature" aria-label="Temperature $TEMP degrees Celsius">
                        <strong>$TEMP</strong>
                        <span>°C</span>
                    </div>
                    <p class="description">$DESCRIPTION</p>
                </div>
            </div>

            <aside class="details">
                <div class="details-header">
                    <div class="place">
                        <p>Weather in</p>
                        <h2>$CITY</h2>
                    </div>
                    <img class="weather-icon" src="$ICON_URL" alt="">
                </div>

                <div class="metrics">
                    <div class="metric">
                        <span>Feels like</span>
                        <strong>$FEELS_LIKE °C</strong>
                        <small>Apparent temperature</small>
                    </div>
                    <div class="metric">
                        <span>Humidity</span>
                        <strong>$HUMIDITY%</strong>
                        <small>Relative humidity</small>
                    </div>
                    <div class="metric">
                        <span>Wind</span>
                        <strong>$WIND_SPEED</strong>
                        <small>km/h</small>
                    </div>
                    <div class="metric">
                        <span>Pressure</span>
                        <strong>$PRESSURE</strong>
                        <small>hPa</small>
                    </div>
                    <div class="metric">
                        <span>Visibility</span>
                        <strong>$VISIBILITY</strong>
                        <small>km</small>
                    </div>
                    <div class="metric">
                        <span>UV index</span>
                        <strong>$UV_INDEX</strong>
                        <small>Current level</small>
                    </div>
                </div>

                <p class="updated">Last update: $NOW</p>
            </aside>
        </section>
    </main>
</body>
</html>
EOF
