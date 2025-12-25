@echo off
echo ========================================
echo  Cleaning Up Duplicate Chats
echo ========================================
echo.
echo This will remove duplicate chats and keep only
echo the most recent chat for each customer-provider pair.
echo.
pause

cd backend
node scripts/cleanup_duplicate_chats.js

echo.
echo ========================================
echo  Cleanup Complete!
echo ========================================
echo.
pause
