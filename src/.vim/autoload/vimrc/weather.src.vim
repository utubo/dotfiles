vim9script

const weather_marks = [
  # 00-03: Clear/Cloudy/Developing:
  '☀️', '🌤️', '⛅', '☁️',
  # 04-09: Haze/Smoke/Dust:
  '🌫️', '🌫️', '🌫️', '💨', '💨', '💨',
  # 10-12: Mist/Fog:
  '🌫️', '🌫️', '🌫️',
  # 13-19:
  '⚡', '☁️', '☁️', '☁️',
  '⚡', '⛈️', '🌪',
  # 20-24: Non rain
  '☀️', '☀️', '☀️', '☀️', '☀️',
  # 25-29: Rain/Snow
  '🌂', '⛄', '❄️', '❄️', '⛈️',
  # 30-35: Sand/Duststorm:
  '💨', '💨', '💨', '🌪️', '🌪️', '🌪️',
  # 36-39: Blowing/Drifting Snow:
  '⛄', '⛄', '⛄', '⛄',
  # 40-49: Fog/Ice Fog:
  '🌫️', '🌫️', '🌫️', '🌫️', '🌫️',
  '🌫️', '🌫️', '🌫️', '🌫️', '🌫️',
  # 50-59: Drizzle:
  '🌂', '🌦️', '🌧️', '🌦️', '🌦️',
  '🌦️', '🌦️', '🌧️', '🌦️', '🌦️',
  # 60-69: Rain
  '🌂', '🌂', '☔', '☔', '⛈️',
  '⛈️', '❄️', '🌨️', '⛄', '⛄',
  # 70-79: Snow/Mixed:
  '⛄', '⛄', '⛄', '⛄', '⛄',
  '⛄', '⛄', '⛄', '⛄', '⛄',
  # 80-82: Rain Showers:
  '🌂', '☔', '☔',
  # 83-86: Snow/Rain-Snow Showers:
  '⛄', '⛄', '⛄', '⛄',
  # 87-90: Hail/Small Hail:
  '⛄', '⛄', '⛄', '⛄',
  # 91-94: Rain/Snow with Thunder:
  '⛈️', '⛈️', '⛈️', '⛈️',
  # 95-99: Thunderstorm:
  '⛈️', '🌩️', '🌩️', '🌪️', '🌪️',
]

# 3日分の天気を取得
export def UpdateWeather()
  const url = 'https://api.open-meteo.com/v1/forecast?latitude=35.6785&longitude=139.6823&timezone=Asia%2FTokyo&forecast_days=3&daily=weather_code'
  job_start(['curl', '-s', url], { out_cb: OnResponseWeather, out_mode: 'nl' })
enddef

def OnResponseWeather(_: any, msg: string)
  const data = json_decode(msg)
  var list = []
  for w in data.daily.weather_code
    list += [get(weather_marks, w, '❔')]
  endfor
  g:weather = list->join('>')
enddef

