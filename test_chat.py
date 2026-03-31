from backend.emotion_engine import EmotionEngine

engine = EmotionEngine()

test_inputs = [
    "I feel so lonely today",
    "I am very happy!",
    "I'm just tired of everything",
    "Nothing special happened today",
    "I am anxious about my exam"
]

print("--- Testing Chat Responses ---")
for text in test_inputs:
    response = engine.generate_chat_response(text)
    print(f"Input: {text}")
    print(f"Response: {response}")
    print("-" * 20)
