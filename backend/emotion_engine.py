from textblob import TextBlob

class EmotionEngine:
    def analyze_sentiment(self, text: str):
        blob = TextBlob(text)
        polarity = blob.sentiment.polarity
        subjectivity = blob.sentiment.subjectivity
        
        mood_score = (polarity + 1) * 5  # Normalize to 0-10 scale
        
        mood_label = "Neutral"
        if polarity > 0.5:
            mood_label = "Joyful"
        elif polarity > 0.1:
            mood_label = "Happy"
        elif polarity < -0.5:
            mood_label = "Sad"
        elif polarity < -0.1:
            mood_label = "Low"
            
        return {
            "score": round(mood_score, 2),
            "label": mood_label,
            "polarity": polarity,
            "subjectivity": subjectivity
        }

    def get_recommendation(self, mood_label: str):
        recommendations = {
            "Joyful": "Great! Keep up the good vibes. Maybe share your happiness with someone!",
            "Happy": "You're doing well. A short walk or your favorite music could make it even better.",
            "Neutral": "A balanced day. precise time for some mindfulness or a hobby.",
            "Low": "It's okay to feel low. Try a warm beverage, or talk to a trusted friend.",
            "Sad": "I hear you. Remember, this feeling is temporary. Consider reaching out to your support circle."
        }
        return recommendations.get(mood_label, "Take a deep breath and listen to your needs.")

    def generate_chat_response(self, user_message: str):
        import random
        
        analysis = self.analyze_sentiment(user_message)
        mood_label = analysis['label']
        user_text = user_message.lower()
        
        # 1. Direct Keyword Responses (for specific triggers)
        if "lonely" in user_text:
            return "I'm here with you. You're never truly alone when you have a safe space to share your thoughts. 🤗"
        if "tired" in user_text or "exhausted" in user_text:
            return "Rest is productive too. Please be gentle with yourself today."
        if "anxious" in user_text or "worry" in user_text:
            return "Take a deep breath with me... In... and Out. We'll get through this one moment at a time."
        if "thank you" in user_text or "thanks" in user_text:
            return "You're so welcome! I'm always here for you. 💜"
            
        # 2. Mood-Based Conversational Responses
        responses = {
            "Joyful": [
                "That's amazing! I'm smiling just reading this. 😄",
                "Yes!! Hold onto this feeling, you deserve it!",
                "Love that for you! What's the best part about it?",
            ],
            "Happy": [
                "Glad to hear that! sounds like a good moment.",
                "It's good to see you in high spirits.",
                "Enjoy this vibe! 🌟",
            ],
            "Neutral": [
                "I hear you. Sometimes a quiet day is exactly what we need.",
                "Thanks for sharing. What's on your mind?",
                "I'm here to listen if you want to say more.",
                "How can I support you right now?",
            ],
            "Low": [
                "I'm sorry things feel heavy right now. I'm listening.",
                "It's okay not to be okay. I'm here for you.",
                "Sending you a virtual hug. 🫂 Do you want to vent about it?",
            ],
            "Sad": [
                "I'm so sorry you're going through this. You don't have to carry it alone.",
                "That sounds really tough. I'm here to listen without judgment.",
                "Please take care of yourself. You matter so much. 💜",
            ],
        }
        
        # Default fallback if mood is somehow not in dict
        category_responses = responses.get(mood_label, responses["Neutral"])
        
        return random.choice(category_responses)
