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
        location_menu = "\n".join([f"{i+1}. {loc.title()}" for i, loc in enumerate(ALLOWED_LOCATIONS)])
        response = f"CON Choose location:\n{location_menu}"

    elif len(inputs) == 2:
        try:
            location_index = int(inputs[1]) - 1
            if location_index not in range(len(ALLOWED_LOCATIONS)):
                response = "END ❌ Invalid location selection."
            else:
                response = "CON Forecast range:\n1. 1 week\n2. 2 weeks\n3. Enter date range"
        except ValueError:
            response = "END ❌ Please enter a valid location number."

    elif len(inputs) == 3:
        try:
            range_option = int(inputs[2])
            if range_option in [1, 2]:
                location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
                start = datetime.today()
                end = start + timedelta(days=7 if range_option == 1 else 14)
                return generate_forecast_response(location, start, end)
            elif range_option == 3:
                response = "CON Enter start date (YYYY-MM-DD):"
            else:
                response = "END ❌ Invalid range option."
        except:
            response = "END ❌ Invalid input for range selection."

    elif len(inputs) == 4:
        if not is_valid_date(inputs[3]):
            response = "END ❌ Invalid start date format.\nUse YYYY-MM-DD."
        else:
            response = "CON Enter end date (YYYY-MM-DD):"

    elif len(inputs) == 5:
        try:
            location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
        except:
            return Response("END ❌ Location error.", mimetype="text/plain")

        start_date = inputs[3]
        end_date = inputs[4]

        if not is_valid_date(end_date):
            response = "END ❌ Invalid end date format."
        else:
            start = datetime.strptime(start_date, "%Y-%m-%d")
            end = datetime.strptime(end_date, "%Y-%m-%d")

            if start > end:
                return Response("END ❌ Start date must be before end date.", mimetype="text/plain")
            if (end - start).days > 15:
                return Response("END ❌ Max forecast range is 16 days.", mimetype="text/plain")

            return generate_forecast_response(location, start, end)

    else:
        response = "END ❌ Invalid input. Please try again."

    return Response(response, mimetype="text/plain")


def is_valid_date(date_str):
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False

def generate_forecast_response(location, start, end):
    try:
        forecast_result = []
        current = start

        while current <= end:
            res = requests.post(FASTAPI_URL, json={
                "date": current.strftime("%Y-%m-%d"),
                "location": location
            })
            if res.status_code == 200:
                data = res.json()
                forecast_result.append(
                    f"{current.strftime('%d/%m')}: {data['temperature_prediction']}°C, {data['rain_prediction']}mm")
            else:
                forecast_result.append(f"{current.strftime('%d/%m')}: No data")
            current += timedelta(days=1)

        result = f"END ✅ Forecast for {location.title()}:\n" + "\n".join(forecast_result)
        return Response(result, mimetype="text/plain")

    except Exception as e:
        print("⚠️ Error fetching forecast:", e)
        return Response("END ⚠️ Error retrieving data. Try again.", mimetype="text/plain")


if __name__ == '__main__':
    app.run(debug=True, port=5000)
