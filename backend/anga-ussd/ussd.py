from flask import Flask, request, Response
from datetime import datetime, timedelta
import requests

app = Flask(__name__)

# Supported locations
ALLOWED_LOCATIONS = ["machakos", "vhembe"]
FASTAPI_PREDICT_URL = "http://localhost:8000/predict/"
FASTAPI_LIVE_URL = "http://localhost:8000/live_weather/"

@app.route("/ussd", methods=["POST"])
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
                # Forecast range now includes: Today, 1 day, 2, 3, 7, 14, custom
                response = (
                    "CON Forecast range:\n"
                    "1. Today\n2. 1 day\n3. 2 days\n4. 3 days\n"
                    "5. 7 days\n6. 14 days\n7. Enter date range"
                )
        except ValueError:
            response = "END ❌ Please enter a valid location number."

    elif len(inputs) == 3:
        try:
            option = int(inputs[2])
            location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
            today = datetime.today()

            if option == 1:
                return get_live_forecast(location)
            elif option in [2, 3, 4, 5, 6]:
                days_map = {2: 1, 3: 2, 4: 3, 5: 7, 6: 14}
                end = today + timedelta(days=days_map[option])
                return generate_forecast_response(location, today, end)
            elif option == 7:
                response = "CON Enter start date (YYYY-MM-DD):"
            else:
                response = "END ❌ Invalid forecast option."
        except:
            response = "END ❌ Invalid selection."

    elif len(inputs) == 4:
        if not is_valid_date(inputs[3]):
            response = "END ❌ Invalid start date format. Use YYYY-MM-DD."
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
            res = requests.post(FASTAPI_PREDICT_URL, json={
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

def get_live_forecast(location):
    try:
        res = requests.get(f"{FASTAPI_LIVE_URL}?location={location}")
        if res.status_code == 200:
            data = res.json()
            return Response(
                f"END ✅ Today's Weather in {data['location']}:\n"
                f"{data['date']}\n"
                f"Temp: {data['temperature_max']}\n"
                f"Rain: {data['rain_sum']}",
                mimetype="text/plain"
            )
        else:
            return Response("END ❌ Failed to retrieve live data.", mimetype="text/plain")
    except Exception as e:
        print("⚠️ Live error:", e)
        return Response("END ⚠️ Error fetching live data.", mimetype="text/plain")


if __name__ == '__main__':
    app.run(debug=True, port=5000)