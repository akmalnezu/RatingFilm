@echo off
echo Menjalankan FastAPI MBD Film Database Server...
where uvicorn >nul 2>nul
if %ERRORLEVEL% equ 0 (
    uvicorn main:app --reload --host 0.0.0.0 --port 8000
) else (
    "%LOCALAPPDATA%\Programs\Python\Python314\python.exe" -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
)
pause
