# **********************************************************************************************************************
# Description: This script will find and replace strings in all unpacked data files for Icarus
# **********************************************************************************************************************

Write-Output "Starting Icarus Real Time Mod Tool..."

# Config:
$shouldDownloadURTools = $false
$shouldCleanUp = $false

# App set up
$root = ""
$currentAppPath = Get-Location
Set-Location $root
Set-Location $currentAppPath
Write-Output "Current OPERATING PATH: $currentAppPath"
$currentGamePakDataDirectory = "$currentAppPath\Icarus\Content\Data"
$currentModsDirectory = "$currentAppPath\Icarus\Content\Paks\mods"
$currentModToolsDirectory = "$currentAppPath\ModTools"
$tempPackageDirectory = "$currentAppPath\TEMPModsPackage"

# **********************************************************************************************************************
# Validate
# **********************************************************************************************************************

# Get mod files
$FileList = Get-ChildItem -Path $currentAppPath -Filter "mod_*.json" -File

# If $FileList is null, exit the script
if ($null -eq $FileList) {
    Write-Output "No mod files found in $currentAppPath"
    Write-Output "Be sure this directory contains mod files that start with 'mod_' and end with '.json'"
    exit
}

# Check if $currentGamePakDataDirectory exists
If (Test-Path $currentGamePakDataDirectory) {
    Write-Output "Current Game Pak Data Directory: $currentGamePakDataDirectory"
} Else {
    Write-Output "Current Game Pak Data Directory: $currentGamePakDataDirectory does not exist"
    Write-Output "Be sure you downloaded the game ICARUS, and this script is running from the game's root directory"
    exit
}

# **********************************************************************************************************************
# Set up
# **********************************************************************************************************************

# Create Temp Storage for Package
If (Test-Path $tempPackageDirectory) {
    Remove-Item $tempPackageDirectory -Recurse
}
New-Item -ItemType directory -Path $tempPackageDirectory

# Check if $currentModsDirectory exists, if not, create it
If (Test-Path $currentModsDirectory) {
    Write-Output "Current Mods Directory: $currentModsDirectory"
} Else {
    Write-Output "Current Mods Directory: $currentModsDirectory does not exist"
    New-Item -ItemType directory -Path $currentModsDirectory
    Write-Output "Created $currentModsDirectory"
}

# Copy ...\Data\* to Temp Storage
Copy-Item -Path "$currentGamePakDataDirectory\*" -Destination $tempPackageDirectory -Recurse

# Download UnrealPak tools

# Check if $currentModToolsDirectory exists, if not, create it
If (Test-Path $currentModToolsDirectory) {
    Write-Output "Current Mod Tools Directory: $currentModToolsDirectory"
} Else {
    Write-Output "Current Mod Tools Directory: $currentModToolsDirectory does not exist"
    New-Item -ItemType directory -Path $currentModToolsDirectory
}

# Check if $currentModToolsDirectory\UnrealPak.zip exists, if not, download it
If (Test-Path "$currentModToolsDirectory\UnrealPak.zip") {
    Write-Output "UnrealPak.zip exists"
} Else {
    Write-Output "UnrealPak.zip does not exist, downloading..."
    $shouldDownloadURTools = $true
}

if ($shouldDownloadURTools) {
    $tool = "UnrealPak.zip"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading $tool mod -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    Expand-Archive -Path "$currentModToolsDirectory\$tool" -DestinationPath $currentModToolsDirectory
    
    $tool = "_Repack.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading $tool mod -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    
    $tool = "_RepackDirectory.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading $tool mod -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    
    $tool = "_Unpack.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading $tool mod -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    
    $tool = "_Unpackall.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading $tool mod -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
} else {
    Write-Output "Skipping download of UnrealPak tools"
}

# Recursively copy .\ModTools\* to TempPackageDirectory
Copy-Item -Path "$currentModToolsDirectory\*" -Destination $tempPackageDirectory -Recurse

# Run unpackall.cmd
Write-Output "Unpacking all data files..."
& "$tempPackageDirectory\_Unpackall.cmd"

# **********************************************************************************************************************
# Find and Replace strings in all data files
# **********************************************************************************************************************

# Loop through each mod file and replace content
Write-Output "Processing mod files..."
foreach ($modfile in $FileList) {

    # Import the JSON file containing the string to replace
    $json = Get-Content -Path "$currentAppPath\$modfile" | ConvertFrom-Json

    # If $json is null, exit the script
    if ($null -eq $json) {
        Write-Output "JSON file ($currentAppPath\$modfile) is empty"
        Write-Output "Be sure this file exists and contains the find and replace data"
        exit
    }

    # For each of the json objects, find and replace the string
    foreach ($jsonObject in $json) {
        if ($jsonObject.Type -eq "ReplaceTarget") {
            $fileTarget = "$tempPackageDirectory\data\$($jsonObject.Path)"

            # Read the contents of the file
            $fileContent = Get-Content -Path "$fileTarget"

            # Delete file
            Remove-Item -Path "$fileTarget"

            # Iterate through $fileContent for a target and replace a single string literal target
            $foundIndexLine = $false
            $replacedLine = $false
            foreach ($line in $fileContent) {
                if ($line -match $jsonObject.Index) {
                    $foundIndexLine = $true
                }
                if (($foundIndexLine) -and ($replacedLine -eq $false) -and ($line -match [regex]::escape($jsonObject.Find))) {
                    $newLine = $line -replace [regex]::escape($jsonObject.Find), $jsonObject.Replace
                    Add-Content "$fileTarget" $newLine
                    $replacedLine = $true
                } else {
                    Add-Content "$fileTarget" $line
                }
            }
        }
        if ($jsonObject.Type -eq "ReplaceAll") {

            # Get all files in the directory and subdirectories
            $files = Get-ChildItem -Recurse -Path "$tempPackageDirectory\data" -File

            # Loop through each file
            foreach ($file in $files) {
                # Read the contents of the file
                $fileContent = Get-Content -Path $file.FullName

                # Replace the string
                $fileContent = $fileContent -replace [regex]::escape($jsonObject.Find), $jsonObject.Replace

                # Write the modified content back to the file
                $fileContent | Set-Content -Path $file.FullName
            }
        }
    }
}
Write-Output "Finished processing mod files"

# **********************************************************************************************************************
# Pack all data files
# **********************************************************************************************************************
Write-Output "Packing all data files..."
$scriptPath = "$tempPackageDirectory\_RepackDirectory.cmd"
& "$scriptPath" Modpack

# **********************************************************************************************************************
# Copy ModPack to Mods Directory
# **********************************************************************************************************************
Write-Output "Copying ModPack to Mods Directory..."
Copy-Item -Path "$tempPackageDirectory\Modpack_P.pak" -Destination $currentModsDirectory -Recurse

# **********************************************************************************************************************
# Clean up
# **********************************************************************************************************************
if ($shouldCleanUp) {
    Write-Output "Cleaning up..."
    Remove-Item $tempPackageDirectory -Recurse
}

Write-Output "Icarus Real Time Mod Tool Done!"