function Main {
    Clear-Host
    # Check for administrator permissions
    $userIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $userPrincipal = [Security.Principal.WindowsPrincipal] $userIdentity
    $isAdmin = $userPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Display-Logo
        Display-Options
    } else {
        Write-Host "Insufficient permissions! Make sure you are running as administrator!" -ForegroundColor Red
        $userInput = Read-Host
        Exit
    }
}

function Display-Logo {
    Write-Host "-----------------------------------------------------" -foregroundColor Blue
    Write-Host "`|               Unity Comment Cleaner               `|" -foregroundColor Blue
    Write-Host "`| https://github.com/KingSlme/unity-comment-cleaner `|" -foregroundColor Blue
    Write-Host "-----------------------------------------------------" -foregroundColor Blue
}

function Display-Options {
    Write-Host "`nWhat would you like to do?" -f Blue
    Write-Host "[" -f White -NoNewline; Write-Host "1" -f Green -NoNewline; Write-Host "] " -f White -NoNewline;
    Write-Host "Automatically detect running Unity Editor processes"
    Write-Host "[" -f White -NoNewline; Write-Host "2" -f Green -NoNewline; Write-Host "] " -f White -NoNewline;
    Write-Host "Manually input path to Unity Editor"
    Write-Host "[" -f White -NoNewline; Write-Host "3" -f Green -NoNewline; Write-Host "] " -f White -NoNewline;
    Write-Host "Exit"
    Write-Host "-> " -f Yellow -NoNewline
    $userInput = Read-Host
    if ($userInput -eq 1) {
        Handle-AutomaticPath
    } elseif ($userInput -eq 2) {
        Handle-ManualPath
    } elseif ($userInput -eq 3) {
        Exit 
    } else {
        Write-Host "$userInput " -f Red -NoNewline; Write-Host "is not a valid choice!" -f White;
        Display-Options
    }
}

function Handle-AutomaticPath {
    # Only include processes where MainWindowTitle is not empty to avoid including background/subprocesses
    $unityProcesses = Get-Process -Name "Unity" -ea SilentlyContinue | Where-Object { $_.MainWindowTitle -ne '' }
    if ($unityProcesses) {
        $unityDictionary = @{}
        $index = 1
        foreach ($unityProcess in $unityProcesses) {
            $unityPath = $unityProcess.Path
            $unityPID = $unityProcess.Id
            $unityString = "$unityPath | PID: $unityPID"
            $unityDictionary[$index] = $unityString
            $index++
        }
        Write-Host "`nWhich process is correct?" -f Blue
        foreach ($key in $unityDictionary.Keys | Sort-Object) {
            Write-Host "[" -f White -NoNewline; Write-Host "$key" -f Green -NoNewline; Write-Host "] " -f White -NoNewline;
            Write-Host "$($unityDictionary[$key])"
        }
        Write-Host "[" -f White -NoNewline; Write-Host "$index" -f Green -NoNewline; Write-Host "] " -f White -NoNewline;
        Write-Host "None"
        Write-Host "-> " -f Yellow -NoNewline
        $userInput = Read-Host
        try {
            $userInput = [int]$userInput
            if ($unityDictionary.ContainsKey($userInput)) {
                $pathToFile = $unityDictionary[$userInput]
                $lastBackslashIndex = $pathToFile.LastIndexOf("\")
                $pathToFile = $pathToFile.Substring(0, $lastBackslashIndex)
                $pathToFile = $pathToFile + "\Data\Resources\ScriptTemplates\81-C# Script-NewBehaviourScript.cs.txt"
                if (Test-Path $pathToFile) {
                    Remove-Comments -pathToFile $pathToFile
                    Display-Options
                } else {
                    Write-Host "Could not find NewBehaviourScript template! " -f Red
                    Display-Options
                }
            } elseif ($userInput -eq $index) {
                Display-Options
            } else {
                Write-Host "$userInput " -f Red -NoNewline; Write-Host "is not a valid choice!" -f White;
                Handle-AutomaticPath
            }
        }
        catch {
            Write-Host "$userInput " -f Red -NoNewline; Write-Host "is not a valid choice!" -f White;
            Handle-AutomaticPath
        }
    } else {
        Write-Host "No Unity Editor processes found" -ForegroundColor Red
        Display-Options
    }
}

function Handle-ManualPath {
    Write-Host "`nEnter the path to your Unity Editor" -f Blue
    Write-Host "-> " -f Yellow -NoNewline
    $pathInput = Read-Host
    if (Test-Path $pathInput) {
        $pathToFile = $pathInput + "\Data\Resources\ScriptTemplates\81-C# Script-NewBehaviourScript.cs.txt"
        if (Test-Path $pathToFile) {
            Remove-Comments -pathToFile $pathToFile
            Display-Options
        } else {
            Write-Host "Could not find NewBehaviourScript template! " -f Red
            Write-Host "Ensure the path looks similar to X:\Program Files\Unity\Hub\Editor\XXXX.X.XXf1\Editor" -f White
            Display-Options
        }
    } else {
        Write-Host "$pathInput " -f Red -NoNewline; Write-Host "is not a valid path!" -f White;
        Display-Options
    }
}

function Remove-Comments {
    param (
        [Parameter(Mandatory=$true)]
        [string]$pathToFile
    )

    $fileContent = Get-Content $pathToFile
    $pattern = "// Start is called before the first frame update|// Update is called once per frame"
    $matchedLines = $fileContent -match $pattern
    if ($matchedLines.Count -gt 0) {
        Write-Host "Removed comments:" -f Green
        $matchedLines | ForEach-Object {
            Write-Host $_ -f White
        }
        $newFileContent = $fileContent -notmatch $pattern
        $newFileContent | Set-Content $pathToFile
    } else {
        Write-Host "No comments to remove!" -f Red
    }
}

Main