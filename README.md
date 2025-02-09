Inspiration
As international students, we experienced firsthand how expensive Uber and Lyft rides could be, especially for daily commutes. Public transportation wasn’t always convenient, and we often wished for a cheaper, safer, and more student-friendly alternative. That’s when we realized—many students with cars might be willing to offer rides at a lower cost, and what better way to connect than through a community-driven carpooling platform? RU Carpooling was created to help students save money, reduce their carbon footprint, and build a community while getting to their destinations easily.

What it does
Connects Rutgers students to share rides and split costs.
Helps riders find affordable transportation from fellow drivers.
Enables drivers to offer rides, reducing their own expenses.
Includes filters for trunk space, pets, and accessibility, ensuring a comfortable ride.
Ensures safety with NetID authentication for verified users.
Notifies users with ride updates through a built-in notification system.
Fosters a social, campus-wide carpooling community, helping students meet new people.
Promotes sustainability by cutting down on traffic and reducing carbon emissions.
Leveraged Groq APIs for AI-powered speech-to-text, making location input easier, calculates carbon emissions for each ride and generates a fun, personalized summary of the user's environmental impact through carpooling!
How we built it
Frontend: Built using Flutter, Dart for a smooth, cross-platform mobile experience(Android, iOS apps).
Backend: Developed with Python (FastAPI, Boto3) for efficient and scalable API handling.
Database: Uses AWS DynamoDB for fast, serverless data storage.
Authentication: Secured with AWS Cognito for Rutgers NetID verification.
Deployment: Fully serverless using AWS Lambda, ensuring cost efficiency and scalability.
Groq: Used APIs to caluclate some interative elements like carbon emissions, fun summary, and speech-to-text for location.
Built on a serverless, event-driven microservices architecture, ensuring scalability, security, and cost efficiency while reducing infrastructure management.

Lambda functions are invoked by API Gateway, handling tasks like updating DynamoDB, triggering other Lambdas, publishing events on buses, uploading to S3, and monitoring via CloudWatch.

Cognito manages authentication, generating access tokens for secure API access across all endpoints.

EventBridge enables event-driven workflows, primarily for notifications, ensuring real-time alerts for ride updates, bookings, and status changes. 🔔

For ride matching, we use OSRM (Open Source Routing Machine) to optimize routes, converting waypoints into geohashes for efficient spatial indexing. Matches are ranked using a scoring algorithm that considers proximity, detours, and ride availability, along with rider preferences such as time flexibility, pet-friendliness, available seats, wheelchair accessibility, and trunk space.

Challenges we ran into
🚗 Ride Matching & Geohash Optimization: Initial Geohash calculations were inefficient. We dynamically adjusted step size based on route distance, reducing geohashes while maintaining accuracy. This sped up ride matching and kept data lightweight.

🚀 Deployment & AWS Lambda Module Issues: Faced module dependency errors due to Lambda’s size limits. We used AWS Lambda Layers for external dependencies, improving deployment efficiency, scalability, and stability.

🤖 AI-Generated Avatars: Backend integration with DeepAI, OpenAI, ReplicateAI, and Hugging Face was completed. While testing via Postman, we realized billing was required. Due to time constraints, we couldn’t fully implement a working solution.

Accomplishments that we're proud of
Built Something We Can Use & Enjoy – We created an app that we ourselves can use, test, and have fun with, making daily commutes more affordable and convenient.
Designed a Scalable, Event-Driven System – Built an efficient architecture that enables real-time ride matching, instant notifications, and seamless interactions, ensuring a smooth experience even as demand grows.
Fostered Community & Sustainability – Worked towards building a student-driven carpooling network, reducing costs, cutting carbon emissions, and making commuting more social and eco-friendly.
Explored AI-powered features, including voice-enabled location input, AI-generated avatars, and ride summaries, enhancing personalization and user experience for the first time.
What we learned
🌍 Geohashes & Jaccard Similarity – Learned how geohashes optimize spatial indexing for ride matching and how Jaccard similarity helps in comparing location-based data efficiently.
⚡ Event-Driven Scalability – Learned how to design a fully event-driven system, where services connect through real-time event processing, triggering actions like ride updates and notifications asynchronously.
🧠 Exploring Generative AI – Experimented with Groq’s speech-to-text API, integrating voice input to improve accessibility and experimented with GenAI for carbon emission tracking and personalized ride insights, making eco-friendly more engaging!
What's Next for RUCarpooling
🏫 Expand Beyond Rutgers – Open the platform to college students nationwide, making carpooling accessible for all.
🚘 License ID Verification – Enable drivers to register vehicle license IDs for added security.
💰 Dynamic Fare Calculation – Use GenAI to calculate fares dynamically based on distance, demand, and ride-sharing preferences.
💬 In-App Chat – Introduce a chat feature for riders and drivers to communicate directly within the app.
⭐ Ratings & Reviews – Implement a star rating system for riders and drivers, allowing ride filtering.
📍 Live Tracking – Introduce real-time ride tracking for better visibility and coordination.
Built With
amazon-cloudwatch
amazon-dynamodb
amazon-lambda-functions
amazon-ses
amazon-web-services
api-gateway
boto3
dart
fastapi
flutter
gen-ai
groq
osrm
python
serverless
websockets
Try it out
 GitHub Repo
 GitHub Repo
 appdistribution.firebase.google.com

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
