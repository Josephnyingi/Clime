from flask import Flask, request, Response
from datetime import datetime, timedelta
import requests

app = Flask(__name__)

ALLOWED_LOCATIONS = ['machakos']
FASTAPI_URL = "http://localhost:8000/predict/"

@app.route('/ussd', methods=['POST'])
def ussd_callback():
    session_id = request.form.get("sessionId")
    phone_number = request.form.get("phoneNumber")
    text = request.form.get("text", "").strip()

    print(f"[USSD REQUEST] sessionId={session_id}, phone={phone_number}, text={text}")

    inputs = text.split("*") if text else []

    response = ""

    if len(inputs) == 0:
        response = "CON Welcome to ANGA Weather 🌦️\n1. Get Forecast"
    elif len(inputs) == 1 and inputs[0] == "1":
        response = "CON Enter location (e.g., Machakos):"
    elif len(inputs) == 2:
        location = inputs[1].strip().lower()
        if location not in ALLOWED_LOCATIONS:
            response = "END ❌ Location not supported.\nOnly 'Machakos' is available for now."
        else:
            response = "CON Enter start date (YYYY-MM-DD):"
    elif len(inputs) == 3:
        if not is_valid_date(inputs[2]):
            response = "END ❌ Invalid start date format.\nUse YYYY-MM-DD."
        else:
            response = "CON Enter end date (YYYY-MM-DD):"
    elif len(inputs) == 4:
        location = inputs[1].strip().lower()
        start_date = inputs[2]
        end_date = inputs[3]

        if not is_valid_date(end_date):
            response = "END ❌ Invalid end date format.\nUse YYYY-MM-DD."
        else:
            try:
                forecast_result = []
                start = datetime.strptime(start_date, "%Y-%m-%d")
                end = datetime.strptime(end_date, "%Y-%m-%d")

                if start > end:
                    return Response("END ❌ Start date must be before end date.", mimetype="text/plain")

                # Limit to max 16 days to avoid long USSD response
                if (end - start).days > 15:
                    return Response("END ❌ Max forecast range is 16 days.", mimetype="text/plain")

                current = start
                while current <= end:
                    res = requests.post(FASTAPI_URL, json={
                        "date": current.strftime("%Y-%m-%d"),
                        "location": location
                    })
                    if res.status_code == 200:
                        data = res.json()
                        forecast_result.append(f"{current.strftime('%d/%m')}: {data['temperature_prediction']}°C, {data['rain_prediction']}mm")
                    else:
                        forecast_result.append(f"{current.strftime('%d/%m')}: No data")
                    current += timedelta(days=1)

                response = "END ✅ Forecast for " + location.title() + ":\n" + "\n".join(forecast_result)

            except Exception as e:
                print("⚠️ Error fetching forecast:", e)
                response = "END ⚠️ System error. Please try again."
    else:
        response = "END ❌ Invalid input. Please start again."

    return Response(response, mimetype="text/plain")

def is_valid_date(date_str):
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False

if __name__ == '__main__':
    app.run(debug=True, port=5000)