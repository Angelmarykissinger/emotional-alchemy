import urllib.request
import urllib.parse
import json
import time
import subprocess
import sys
import os

def run_verification():
    # Start server
    print("Starting backend server...")
    server_process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "backend.main:app", "--port", "8000"],
        cwd="c:/Users/VICTUS/emotional_alchemy",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    print("Waiting for server to start...")
    time.sleep(5) # Wait for startup
    
    base_url = "http://127.0.0.1:8000"
    
    try:
        # 1. Test Root
        try:
            with urllib.request.urlopen(f"{base_url}/") as response:
                print(f"Root endpoint: {response.getcode()} - {response.read().decode()}")
        except Exception as e:
            print(f"Failed to connect to root: {e}")
            # print stderr from server if failed
            print("Server Stderr:")
            print(server_process.stderr.read().decode())
            return

        # 2. Test Analyze Mood
        url = f"{base_url}/analyze_mood"
        data = json.dumps({"text": "I am feeling a bit stressed today but I know I can handle it."}).encode('utf-8')
        req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})
        
        try:
            with urllib.request.urlopen(req) as response:
                print(f"\nAnalyze Mood:")
                print(response.read().decode())
        except urllib.error.HTTPError as e:
            print(f"Error analyze_mood: {e.code} - {e.read().decode()}")

        # 3. Test Chat
        url = f"{base_url}/chat"
        data = json.dumps({"message": "I'm feeling very lonely and sad."}).encode('utf-8')
        req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})
        
        try:
            with urllib.request.urlopen(req) as response:
                print(f"\nChat:")
                print(response.read().decode())
        except urllib.error.HTTPError as e:
             print(f"Error chat: {e.code} - {e.read().decode()}")

    finally:
        print("\nStopping server...")
        server_process.terminate()
        try:
            outs, errs = server_process.communicate(timeout=2)
        except subprocess.TimeoutExpired:
            server_process.kill()
            outs, errs = server_process.communicate()
            
if __name__ == "__main__":
    run_verification()
