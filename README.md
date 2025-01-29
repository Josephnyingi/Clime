# ClimeTetra

ClimeTetra is a project that uses weather data and machine learning models to provide accurate weather predictions. The goal is to support farmers and other stakeholders by predicting weather parameters such as temperature and rainfall, which can significantly impact agricultural practices.

The project includes a weather prediction API built with FastAPI, machine learning models for temperature and rainfall predictions, and historical data processing.

## Features

- **Weather Prediction API**: This service provides temperature and rainfall predictions based on historical data and machine learning models.
- **Temperature Prediction Model**: A machine learning model for forecasting temperature using Prophet time series forecasting.
- **Rainfall Prediction Model**: A machine learning model for forecasting rainfall.
- **Data Processing**: Clean and preprocess historical weather data for model training.
- **FastAPI**: High-performance API built using FastAPI framework.
- **Scalable**: Can be extended to include more weather parameters and locations in the future.

## Technologies Used

- **Python** is the project's core language for all model building, data processing, and API development.
- **FastAPI**: A fast and modern web framework for building APIs with Python 3.7+.
- **Postman** used to test the API
- **Prophet**: A time series forecasting tool for weather prediction (temperature and rainfall).
- **Pandas**: A data manipulation library for preprocessing and analyzing weather data.
- **Uvicorn**: An ASGI server to run the FastAPI app.
- **Pydantic**: Used for data validation in FastAPI to ensure correct data input.
- **Pickle**: A Python library for saving and loading trained models.
- **Collab Notebooks**: Used for model experimentation and data exploration.
- **GitHub**: Used for version control and project management.
- **AWS EC2**: Deployed the API to AWS for cloud hosting.

## Contributors
Joseph Nyingi
## Mentor
Alta Saunders
