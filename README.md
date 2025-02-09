# RU Carpooling App 🚗💨  
A ride-sharing platform exclusively designed for Rutgers University students, making commuting **cheaper, safer, and more sustainable**.

---
## 🚀 Inspiration  
As international students, we realized how **expensive and inconvenient** Uber and public transport could be for daily commutes. We wondered—**what if students with cars could offer affordable rides to others?**
Thus, **RU Carpooling** was born—to help students **save money, reduce their carbon footprint, and foster a strong university community.**

---
## 🎯 What It Does  
✔ **Find & Post Rides** – Riders can search for available rides, and drivers can post trips.  
✔ **Secure NetID Authentication** – Ensures only Rutgers students can access the platform.  
✔ **Ride Preferences** – Filters for **trunk space, pet-friendly, and wheelchair accessibility.**  
✔ **Real-time Notifications** – Stay updated on ride requests and confirmations.  
✔ **Smart AI Features** – Uses **Groq** for **speech-to-text** in Google Maps and **fun carbon footprint summaries** based on ride details.  
✔ **Sustainability-Focused** – Encourages carpooling to reduce **traffic congestion** and **carbon emissions**.

---
## 🏗 How We Built It  
### **Frontend (Mobile App)**  
- **Flutter (Dart)** – Cross-platform support for **Android & iOS**.
- **Google Maps API** – Real-time **route tracking & visualization**.
- **Dio/http Package** – Manages **API requests**.

### **Backend (Serverless Architecture)**  
- **FastAPI (Python)** – Efficient API handling.
- **AWS DynamoDB** – NoSQL database for fast and scalable data storage.
- **AWS Cognito** – Ensures **secure authentication** for Rutgers students.
- **AWS Lambda & API Gateway** – Manages ride **posting, matching, and user registration.**
- **AWS EventBridge & WebSockets** – **Real-time ride notifications** & status updates.
- **OSRM (Open Source Routing Machine)** – Optimizes ride-matching via **geospatial indexing & routing.**
- **Groq AI** – Powers **speech-to-text** for location entry and **carbon emission insights**.

---
## 🚧 Challenges We Faced  
🔹 **Ride Matching Optimization** – Fine-tuned **geohash calculations** for faster and more accurate ride matching.  
🔹 **AWS Lambda Module Issues** – Solved **dependency errors** by integrating **Lambda Layers**.  
🔹 **AI-Powered Enhancements** – Experimented with **Groq's AI for voice input & carbon footprint analysis**.

---
## 🏆 Accomplishments & Learnings  
✅ **Designed a Scalable Event-Driven System** – Ensured **real-time ride matching & instant notifications**.
✅ **Enhanced Sustainability Awareness** – Introduced **AI-driven carbon footprint tracking**.
✅ **Implemented AI Speech-to-Text** – Improved accessibility by **allowing voice input for location search**.

---
## 📈 Future Roadmap  
🔹 **Live Ride Tracking** – See real-time updates of your driver’s location.  
🔹 **License ID Verification** – Add extra security for drivers & passengers.  
🔹 **In-App Chat** – Seamless **communication** between riders & drivers.  
🔹 **Dynamic Fare Calculation** – Use **Gen AI** to set fair ride prices.  
🔹 **Multi-University Expansion** – Scale the platform to **other colleges & universities.**  

---
## 💻 Built With  
- **Amazon CloudWatch** – Logging & debugging  
- **AWS DynamoDB** – NoSQL database  
- **AWS Lambda** – Serverless execution  
- **AWS SES/SNS** – Email & push notifications  
- **FastAPI (Python)** – Backend framework  
- **Flutter (Dart)** – Frontend framework  
- **Groq AI** – AI-powered automation  
- **OSRM** – Route optimization  
- **WebSockets** – Real-time communication  

---
## 📜 How to Contribute  
We welcome contributions from the **Rutgers developer community**!

1️⃣ **Fork the repository** 🍴  
2️⃣ **Clone the repository** 🖥  
```bash
git clone https://github.com/aneesa2023/ru_carpooling_frontend.git
```
3️⃣ **Create a new branch** 🌱  
```bash
git checkout -b feature-branch-name
```
4️⃣ **Make changes & commit** ✅  
```bash
git commit -m "Added a new feature"
```
5️⃣ **Push changes & create a pull request** 🚀  
```bash
git push origin feature-branch-name
```
6️⃣ **Submit a pull request** 📝  

Let's make university commuting **more affordable, secure, and efficient together!** 🚗

---
## 📲 Try It Out!  
🔗 **[GitHub Repo](https://github.com/aneesa2023/RUCarpooling_Frontend)**  
🔗 **[Firebase App Distribution](appdistribution.firebase.google.com)**  

---
### 📸 Check out demo video here: 
🔗  https://vimeo.com/1054955277?share=copy

🚀 **RU Carpooling – Making campus commuting smarter, greener, and more affordable!**

