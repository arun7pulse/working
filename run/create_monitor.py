# data dog create monitor 
# 
# arun7pulse org
api_key = "095d1c1bc8907297e6c4925bd65f0bc6"
application_key = "9205f16b85f8d712476528d0fca9c4bee03b507e"

# lululemon org
# api_key = "095d1c1bc8907297e6c4925bd65f0bc6"
# application_key = "9205f16b85f8d712476528d0fca9c4bee03b507e"

import requests
import json

url = "https://api.datadoghq.com/api/v1/monitor"

payload = json.dumps({
  "message": "You may need to add web hosts if this is consistently high.",
  "name": "Bytes received on host0",
  "options": {
    "no_data_timeframe": 20,
    "notify_no_data": True
  },
  "query": "avg(last_5m):sum:system.net.bytes_rcvd{host:host0} > 100",
  "tags": [
    "app:webserver",
    "frontend"
  ],
  "type": "query alert"
})
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  '095d1c1bc8907297e6c4925bd65f0bc6': '••••••'
}

response = requests.request("POST", url, headers=headers, data=payload)

print(response.text)

