# ru_carpooling_frontend
Ride-sharing mobile application platform exclusively designed for Rutgers University students

RU Carpooling App 🚗💨

📌 Project Purpose
The RU Carpooling App is a ride-sharing platform exclusively designed for Rutgers University students. This application enables students to share rides, reduce commuting costs, promote sustainability, and foster a strong university community. The platform ensures security by verifying users with Rutgers credentials, making carpooling both safe and efficient.

🏗 Technology Stack & Innovation
Backend Architecture
✅ Authentication & Security

AWS Cognito – Secure user authentication for Rutgers students.
IAM Roles & Policies – Restricts unauthorized access to the database.
✅ Serverless Cloud Architecture

AWS Lambda – Handles ride posting, user registration, and ride-matching dynamically.
AWS API Gateway – Manages HTTP requests securely.
AWS DynamoDB – Stores real-time ride tracking data for seamless user experience.
AWS CloudWatch – Enables logging, debugging, and analytics.
✅ Geospatial Search & Ride Matching

OSRM (Open Source Routing Machine) – Calculates optimized routes for efficient ride-sharing.
Frontend Architecture
✅ Flutter Framework

Cross-platform support – Works on both Android & iOS seamlessly.
State Management – Uses Provider/Riverpod for managing UI state.
✅ API Communication & UI Enhancements

Dio/http Package – Handles backend API requests.
Google Maps API – Provides real-time tracking and route visualization.

🚀 How the Project Works
1️⃣ Secure User Authentication
🔹 Students log in via AWS Cognito, ensuring that only verified Rutgers students can use the platform.

2️⃣ Ride Posting & Searching
🔹 Drivers list rides with pickup/drop-off locations, availability, and timings.
🔹 Passengers search for rides based on location and time preferences.

3️⃣ Smart Ride Matching & Requesting
🔹 OSRM-powered geospatial search matches drivers and passengers based on optimal routes.
🔹 Passengers request rides, and drivers approve or decline requests.

4️⃣ Ride Booking & Real-Time Tracking (Future Enhancement 🚀)
🔹 Accepted ride requests are stored in AWS DynamoDB for real-time ride status updates.

5️⃣ Notifications & Updates (Future Enhancement 🚀)
🔹 Users will receive ride confirmations, reminders, and status updates via AWS SNS push notifications.

🔮 Future Roadmap

🚀 Planned Enhancements:

💳 Payments & Ride Cost Splitting – Integrate payment gateways for seamless transactions.
⭐ User Ratings & Reviews – Implement rating systems for drivers and riders.
🤖 AI-Powered Ride Matching – Recommend rides based on user preferences.
🌎 Multi-University Expansion – Scale the solution to other university campuses.
📜 How to Contribute
We welcome contributions from the Rutgers developer community! If you want to help improve this project:

Fork the repository 🍴
Clone the repository 🖥
[git clone https://github.com/aneesa2023/ru_carpooling_frontend.git](https://github.com/aneesa2023/RUCarpooling_Frontend)

Create a new branch 🌱
git checkout -b feature-branch-name

Make your changes & commit ✅
git commit -m "Added a new feature"

Push changes & create a pull request 🚀
git push origin feature-branch-name

Submit a pull request 📝

🚀 Let's make University commuting more affordable, secure, and efficient together!



A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

![](/Users/villageit/Downloads/demo_screenshots/search_route.jpeg)
![](/Users/villageit/Downloads/demo_screenshots/post_ride_details.jpeg)
![](/Users/villageit/Downloads/demo_screenshots/posted_rides_list.jpeg)
![](/Users/villageit/Downloads/demo_screenshots/home_page.jpeg)
![](/Users/villageit/Downloads/demo_screenshots/menu.jpeg)
![](/Users/villageit/Downloads/demo_screenshots/my_trips_list.jpeg)
