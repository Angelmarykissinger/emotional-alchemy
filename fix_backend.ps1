try {
    # Find process on port 8000
    $tcp = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
    if ($tcp) {
        Write-Host "Stopping old backend process (PID: $($tcp.OwningProcess))..."
        Stop-Process -Id $tcp.OwningProcess -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "No old process found on port 8000."
}

# Start new backend
Start-Sleep -Seconds 2
Write-Host "Starting new backend with CORS support..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd c:\Users\VICTUS\emotional_alchemy; pip install -r backend/requirements.txt; python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload"
Write-Host "Backend restarted successfully! 💜"
