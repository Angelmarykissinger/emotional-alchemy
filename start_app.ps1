# Start Backend in a new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd c:\Users\VICTUS\emotional_alchemy; pip install -r backend/requirements.txt; python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload"

# Wait a moment for backend to initialize
Start-Sleep -Seconds 5

# Run Flutter App
Write-Host "Starting Flutter App..."
flutter pub get
flutter run
