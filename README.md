# 🌦️ Anga - Smart Climate Insights for Farmers

### **Accurate weather forecast powered by AI & Machine Learning to help farmers plan better.**

---

## 🚀 Overview

**Anga** is a weather forecasting platform that leverages **Machine Learning (ML) models** and **real-time data processing** to deliver **accurate climate insights for farmers and agricultural stakeholders**. 

The system predicts weather parameters such as **temperature and rainfall** using **time-series forecasting models**, providing farmers with **actionable insights** to improve productivity.

The project consists of:
- **Weather Forecasting API** (built with FastAPI & deployed on AWS).
- **Machine Learning models** for **temperature & rainfall** predictions.
- **Flutter-based mobile app** for **real-time access to weather forecasts**.

---

## ✨ Key Features
✅ **AI-Powered Forecasts** – Uses **Prophet & time-series forecasting** models for accurate predictions.  
✅ **Weather API** – Built with **FastAPI**, providing farmers with real-time weather updates.  
✅ **Flutter Mobile App** – A user-friendly app for farmers to access **weather forecasts & alerts**.  
✅ **Historical Weather Data Processing** – Cleans & preprocesses past data for **improved accuracy**.  
✅ **Scalability** – Can extend support to **more locations, parameters & climate risk insights**.  
✅ **Secure User Authentication** – Users **login/register** securely via **Flutter & FastAPI backend**.  
✅ **Cloud Deployment** – The backend API is **hosted on AWS EC2** for global accessibility.  

---

## 🛠️ Technologies Used

| **Category**           | **Technology**     |
|------------------------|-------------------|
| 🌐 **Frontend**        | Flutter (Dart)   |
| 🖥️ **Backend API**     | FastAPI (Python) |
| 🧠 **Machine Learning**| Prophet, Pandas, NumPy |
| 📊 **Database**        | SQLite + SQLAlchemy |
| ☁️ **Cloud Hosting**   | AWS EC2, Uvicorn |
| 🔧 **Development**     | Python, Google Colab |
| 🔄 **Version Control** | GitHub |

---

## 📱 Flutter Mobile App Features

- 🌟 **Modern & Intuitive UI** – User-friendly interface for farmers.
- 📊 **Real-time Weather Data** – Displays **current weather & forecasts**.
- 🌍 **Location-Based Forecasts** – Provides **local** & **regional** climate insights.
- 🚨 **Weather Alerts** – Sends **push notifications** for extreme weather conditions.
- 🔑 **Secure Login & Registration** – Ensures **data privacy & user authentication**.

📌 **The Flutter app fetches weather data from the FastAPI backend and presents it in an intuitive way.**

---

## 🔧 Installation & Setup

### 🔹 Backend (FastAPI) Setup

1️⃣ Clone this repository:
```sh
git clone https://github.com/yourusername/clime.git
cd clime
