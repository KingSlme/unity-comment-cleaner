# unity-comment-cleaner
Tool to prevent Start and Update comment generation for new MonoBehaviour scripts.

## Key Features
* Support for automatic detection of current running Unity Editor processes
* Support for manual path input to Unity Editor directory

## How to Use
*For Script:*
1. Run powershell as administrator
2. Change the directory to the location of the script
3. Run the script with ./UnityCommentCleaner.ps1

*For Executable:*
1. Simply run as administrator

## Problems
*If you have problems running the script run this command first:*
```ps1
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```
