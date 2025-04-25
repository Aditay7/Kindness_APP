🌱 Kindness App
A sustainable solution to bridge the gap between surplus food and hungry mouths.

📖 Overview
Kindness App is a food-saving platform that connects restaurants with non-profit organizations (NGOs) to reduce food waste and combat hunger. By streamlining the food donation process, the app promotes environmental sustainability and enhances community welfare.

🚀 Key Features
🏢 Restaurant–NGO Partnerships: Links local restaurants with NGOs to distribute surplus food.

🚚 Efficient Donation Logistics: Enables easy listing, claiming, and coordination of food pickups.

🔔 Real-Time Notifications: Keeps donors and recipients updated on donation statuses.

📊 Impact Tracking: Visual dashboards and analytics to show contribution and reach.

🛠️ Tech Stack
Frontend
Framework: Flutter (Cross-platform support for Android, iOS, Web, and Desktop)

Key Features:

Modular screen and service structure

State management with models

Rich UI and native performance

Backend
Runtime: Node.js

Framework: Express.js

Database: MongoDB

Others:

JWT for authentication

RESTful APIs

Cloudinary for image/file storage (planned)

👤 User Roles
🏨 Restaurants (Donors)
List surplus food (type, quantity, expiration)

Monitor impact through dashboards

Real-time alerts for claimed donations

🏢 NGOs (Recipients)
Claim available food with a single click

Track past donations and community impact

Access analytics for reporting and transparency

🧩 Core Functionalities

Feature	Description
Food Listing	Restaurants add surplus food to the system
Claiming Donations	NGOs browse and claim listed food
Notifications	Real-time alerts for availability and pickups
Dashboard	Overview of impact, history, and analytics
Documentation	Handles food safety compliance and secure records
🧱 Data Models
Restaurant
json
Copy
Edit
{
  "id": "unique_id",
  "name": "Restaurant Name",
  "location": "Address",
  "contact": "Phone/Email"
}
NGO
json
Copy
Edit
{
  "id": "unique_id",
  "name": "NGO Name",
  "mission": "Helping underprivileged",
  "contact": "Phone/Email"
}
Donation
json
Copy
Edit
{
  "id": "donation_id",
  "foodDetails": {
    "type": "Cooked Rice",
    "quantity": "10 kg",
    "expiry": "2025-04-25"
  },
  "restaurantId": "linked_restaurant_id",
  "claimedBy": "ngo_id",
  "status": "claimed/pending",
  "pickupDate": "2025-04-26"
}
🔄 User Flow
App Launch → Register/Login

Onboarding → Select role (Restaurant/NGO)

Restaurants → List surplus food → Track pickups

NGOs → Receive alerts → Claim donations → Arrange pickups

Dashboard → View history, stats, impact

🌍 Social & Environmental Impact
✅ Food Waste Reduction: Redirects edible food from landfills to those in need.

♻️ Resource Optimization: Real-time pickups reduce storage and transport costs.

❤️ Community Engagement: Impact stories and stats encourage continued participation.

🔐 Transparency & Trust: All donations tracked with secure updates and verifications.

📦 Project Structure (Backend)
pgsql
Copy
Edit
kindness-backend/
├── controllers/
│   └── donationController.js
├── models/
│   ├── Restaurant.js
│   ├── NGO.js
│   └── Donation.js
├── routes/
│   └── donationRoutes.js
├── middleware/
│   └── auth.js
├── app.js
└── server.js
📱 Project Structure (Frontend - Flutter)
css
Copy
Edit
kindness-frontend/
├── screens/
│   ├── HomeScreen.dart
│   ├── DashboardScreen.dart
│   └── ClaimScreen.dart
├── models/
│   ├── Restaurant.dart
│   ├── NGO.dart
│   └── Donation.dart
├── services/
│   └── ApiService.dart
└── main.dart
🛡️ Security
🔐 JWT Authentication for secure login and API access

✅ Role-Based Access to limit functionality by user type

☁️ Cloud Storage (Planned) for image/file uploads

📚 Future Enhancements
AI-based prediction for food spoilage

Map-based pickup coordination

Ratings & reviews for restaurant-NGO partnerships

Integration with Government/CSR databases

🤝 Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

bash
Copy
Edit
# Clone the repository
git clone https://github.com/your-username/kindness-app.git
📬 Contact
For any inquiries or collaborations:

📧 Email: innovationzone32@gmail.com

🌐 GitHub: github.com/Aditay7

⭐ Show your support
If you like this project, give it a ⭐ and share with your network to help reduce food waste and uplift communities.
