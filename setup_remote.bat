@echo off
echo ========================================
echo   AssureFix Git Remote Setup
echo ========================================
echo.
echo This script will help you connect to a NEW remote Git repository.
echo.
echo IMPORTANT: Before running this script:
echo Step 1: Create a new repository on GitHub/GitLab/Bitbucket
echo Step 2: DO NOT initialize with README, .gitignore, or license
echo Step 3: Copy the repository URL (HTTPS or SSH)
echo.
echo ========================================
echo.
set /p remote_url="Enter your NEW remote repository URL: "
if "%remote_url%"=="" (
    echo Error: No URL provided
    pause
    exit /b 1
)
echo.
echo Verifying .gitignore is properly configured...
if not exist ".gitignore" (
    echo WARNING: .gitignore file not found!
    pause
)
echo.
echo Checking for node_modules in Git tracking...
git ls-files | findstr /C:"node_modules" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: node_modules appears to be tracked by Git!
    echo This should not happen. Please check your .gitignore file.
    pause
) else (
    echo ✓ node_modules is NOT tracked (Good!)
)
echo.
echo Adding remote origin...
git remote add origin %remote_url%
if %errorLevel% neq 0 (
    echo.
    echo Note: Remote 'origin' might already exist. Removing old remote...
    git remote remove origin
    git remote add origin %remote_url%
)
echo.
echo Setting up main branch...
git branch -M main
echo.
echo Pushing to remote repository...
echo This may take a few moments...
git push -u origin main
if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo ✓ Successfully connected to remote repository!
    echo ========================================
    echo ✓ Your code is now backed up on: %remote_url%
    echo ✓ node_modules is NOT included (as expected)
    echo.
    echo Next steps:
    echo 1. Your repository is now connected
    echo 2. Future commits can be pushed with: git push
    echo 3. To pull changes: git pull
    echo 4. Verify on GitHub/GitLab that node_modules folder is NOT there
) else (
    echo.
    echo ========================================
    echo ✗ Failed to push to remote repository
    echo ========================================
    echo Please check:
    echo 1. Repository URL is correct
    echo 2. You have access to the repository
    echo 3. Repository exists and is empty (no README, no files)
    echo 4. You are logged in to Git (run: git config --list)
    echo.
    echo To retry, run this script again or use:
    echo git push -u origin main
)
echo.
pause
