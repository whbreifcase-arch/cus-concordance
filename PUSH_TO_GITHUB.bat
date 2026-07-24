@echo off
REM ============================================================
REM  Double-click to upload to GitHub using the DEVICE CODE flow.
REM  No popup needed -- it prints a short code, you type it into
REM  a GitHub page in your browser (Vivaldi is fine), and you're in.
REM ============================================================
cd /d "C:\Users\WH407\Downloads\forge\CUS_KERNEL_REBUILD"
set GCM_GITHUB_AUTHMODES=device

echo.
echo   ============================================================
echo   In a moment this window will show something like:
echo.
echo       To continue, open  https://github.com/login/device
echo       and enter code:  ABCD-1234
echo.
echo   DO THIS:
echo     1. Open that link in your browser (you're already logged in)
echo     2. Type the 8-character code, click Continue / Authorize
echo     3. Come back here -- it uploads automatically.
echo   ============================================================
echo.

git push origin main

echo.
if %errorlevel%==0 (
  echo   SUCCESS -- it is live at:
  echo   https://github.com/whbreifcase-arch/cus-kernel-rebuild
) else (
  echo   Did not finish. Copy the text above and send it to Claude.
)
echo.
pause
