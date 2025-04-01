from flask import Flask, request, Response
from datetime import datetime
import re

app = Flask(__name__)

# Only one available location for now
ALLOWED_LOCATIONS = ['machakos']

@app.route('/ussd', methods=['POST'])
def ussd_callback():
    session_id = request.form.get("sessionId")
    phone_number = request.form.get("phoneNumber")
    text = request.form.get("text", "").strip()

    inputs = text.split("*") if text else []

    response = ""

    if len(inputs) == 0 or text == "":
        response = "CON Welcome to ANGA Weather 🌦️\n"
        response += "1. Get Forecast"
    elif len(inputs) == 1 and inputs[0] == "1":
        response = "CON Enter location (e.g., Machakos):"
    elif len(inputs) == 2:
        location = inputs[1].strip().lower()
        if location not in ALLOWED_LOCATIONS:
            response = "END ❌ Location not available.\nOnly 'Machakos' is supported for now."
        else:
            response = "CON Enter start date (YYYY-MM-DD):"
    elif len(inputs) == 3:
        if not is_valid_date(inputs[2]):
            response = "END ❌ Invalid date format.\nUse YYYY-MM-DD."
        else:
            response = "CON Enter end date (YYYY-MM-DD):"
    elif len(inputs) == 4:
        if not is_valid_date(inputs[3]):
            response = "END ❌ Invalid date format.\nUse YYYY-MM-DD."
        else:
            location = inputs[1].strip().lower()
            start_date = inputs[2]
            end_date = inputs[3]

            # Simulate a forecast (replace with actual logic)
            response = (
                f"END ✅ Forecast for {location.title()}\n"
                f"From: {start_date} To: {end_date}\n"
                f"Temp: 28°C\nRain: 3.5mm"
            )
    else:
        response = "END ❌ Invalid input. Please try again."

    return Response(response, mimetype="text/plain")

def is_valid_date(date_str):
    """Validates date format: YYYY-MM-DD"""
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False

if __name__ == '__main__':
    app.run(debug=True)
