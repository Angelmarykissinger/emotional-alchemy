<<<<<<< HEAD
# 💜 Emotional Alchemy

**Emotional Alchemy** is a comprehensive emotional wellness and self-reflection application built with Flutter and Firebase. The app is designed to help users track their emotional journey, maintain daily productivity, and improve sleep hygiene through intuitive journaling, supportive chat, and advanced analytics.

---

## 🌟 Core Features

### 1. 🔐 User Authentication & Custom Profiles
- Seamless sign-up and login utilizing **Firebase Authentication**.
- **User Profiles**: Users can customize their name, bio, gender, date of birth, and profile picture, all persistently stored in **Cloud Firestore**.
- **Support Alerts**: Settings to notify predefined contacts if the user's mood stays consistently low over a chosen timeline (e.g., 7 or 14 days).

### 2. 📝 Reflective Journaling & Mood Analysis
- Users can log daily text entries explaining their feelings.
- The app automatically performs **sentiment analysis** on keywords (e.g., happy, sad, stressed, grateful) to assign a numerical **Mood Score (1-10)** for the entry.

### 3. 💬 Supportive Chat Interface
- A built-in chat UI where users can express themselves in real-time.
- Messages sent by the user are saved and evaluated for sentiment, ensuring that even quick conversations contribute to the user's overall emotional profile.

### 4. ✅ Daily Productivity Tracker (Tasks)
- Simple and effective to-do list system.
- Users can add, toggle completion, and delete daily tasks.
- Tracks the ratio of completed tasks to total tasks, linking productivity directly to emotional well-being.

### 5. 🌙 Sleep Cycle Tracking
- Users log their daily **Bedtime** and **Wake-up Time**.
- The app intelligently calculates the sleep duration (handling overnight calculation automatically).
- Cross-checks device activity to encourage resting the phone before sleep.

---

## 📊 Advanced Emotional Analytics & Gamification

The heart of Emotional Alchemy is the **Analytics Screen**, which acts as a dynamic dashboard summarizing the user’s well-being over the past 5 days.

- **📈 Mood Progress Graph**: A beautiful line chart (powered by `fl_chart`) plotting the user's average daily mood score based on their combined Journal entries and Chat messages.
- **🎯 Task Efficiency**: A dedicated card displaying the percentage of daily tasks successfully completed ($Completed / Total$).
- **⚖️ Sleep Balance**: Calculates and displays the user's average sleep duration over the past 5 days, indicating whether their rest is "Optimal" (7-9 hours), "Needs Rest" (<7 hours), or "Over-resting" (>9 hours).
- **🔮 Alchemy Points (AP)**: Gamifies the wellness journey. Users earn AP by engaging in healthy habits:
  - **+10 AP** per Journal logged
  - **+5 AP** per Chat initiated
  - **+15 AP** per Task completed
  - **+20 AP** per Sleep log
- **💡 Dynamic Weekly Insights**: The app acts as an automated coach. By analyzing the mood trend (e.g., comparing the last 2 days to the previous 3 days), task efficiency, and sleep averages, the app generates personalized text insights and actionable tips (e.g., "Great news! Your mood is trending upwards," or "Your sleep has been a bit short recently. Try going to bed 30 minutes earlier tonight.").

---

## 🛠️ Technology Stack

- **Frontend**: Flutter / Dart
- **Backend & Database**: Firebase (Authentication, Cloud Firestore)
- **State Management**: StatefulWidgets & Real-time Firestore Streams
- **Charting**: `fl_chart` for dynamic mood graphs
- **Time/Date Parsing**: `intl` package for accurate sleep duration calculation
- **UI Design**: Pastel aesthetics, Google Fonts (`Playfair Display`, `Lato`), rich gradients, and glassmorphism elements.

---

## 🚀 Setup & Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd emotional_alchemy
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   Ensure your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are correctly placed in the respective folders, and that `firebase_options.dart` is correctly configured for Web/macOS/Windows if running on those platforms.

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📌 Future Enhancements
- Integration with AI APIs (like Gemini or OpenAI) for deeper, NLP-driven journal analysis and dynamic chat responses.
- Push notifications to remind users to log their sleep and tasks.
- Social sharing features for accountability partners.

---
*Created with 💜 for better emotional wellness.*
=======
# emotional-alchemy
Emotional Alchemy Transform your thoughts into clarity. A Flutter and Firebase based emotional wellness app featuring journaling, mood analytics, productivity tracking, and sleep monitoring with personalized insights.
>>>>>>> 31200a72fa0a6a08c53d4282efda4bb4e3e1ae1c
