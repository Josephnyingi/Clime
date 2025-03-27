from flask import Flask, request  # type: ignore
import requests # type: ignore
from datetime import datetime

app = Flask(__name__)

# Replace with your backend endpoint (ANGA API)
ANGA_URL = "https://your-backend-domain.com/forecast"

# Available locations (future scalability)
locations = {
    "1": "Machakos"
    # Future: add more like "2": "Nairobi", etc.
}

def is_valid_date(date_str):
    """Validate date format YYYY-MM-DD"""
    try:
        return datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        return None

@app.route("/ussd", methods=["POST"])
def ussd_callback():
    session_id = request.form.get("sessionId")
    service_code = request.form.get("serviceCode")
    phone_number = request.form.get("phoneNumber")
    text = request.form.get("text", "")

    parts = text.split("*")
    response = ""

    if text == "":
        response = "CON Welcome to Project ANGA 🌦️\nChoose location:\n1. Machakos"
    elif len(parts) == 1:
        response = "CON Enter start date (YYYY-MM-DD):"
    elif len(parts) == 2:
        response = "CON Enter end date (YYYY-MM-DD):"
    elif len(parts) == 3:
        location_key = parts[0]
        start_date = parts[1]
        end_date = parts[2]
        location = locations.get(location_key, "Machakos")

        start_dt = is_valid_date(start_date)
        end_dt = is_valid_date(end_date)

        if not start_dt or not end_dt:
            response = "END Invalid date format. Use YYYY-MM-DD"
        elif end_dt < start_dt:
            response = "END End date must be after start date."
        else:
            try:
                res = requests.post(ANGA_URL, json={
                    "start_date": start_date,
                    "end_date": end_date,
                    "location": location
                })
                data = res.json()
                forecast = "\n".join([
                    f"{item['date']}: {item['temperature']}°C, {item['rain']}mm"
                    for item in data.get("forecast", [])
                ])
                response = f"END Weather for {location}:\n{forecast}"
            except Exception as e:
                print("Error:", e)
                response = "END Error fetching forecast. Try again later."
    else:
        response = "END Invalid option. Please try again."

    return response

if __name__ == "__main__":
    app.run(debug=True)
