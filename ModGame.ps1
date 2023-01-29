# **********************************************************************************************************************
# Icarus Real Time Mod Tool
# Description: This script will find and replace strings in all unpacked data files for Icarus
# Author: SirFrostingham
# License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License
# **********************************************************************************************************************

# **********************************************************************************************************************
# Init
# **********************************************************************************************************************

$Source = @'
using System;
using System.Collections.Generic;


    namespace IcarusModDataNamespace
    {
        public class ModDataObject
        {
            public ModDataObject()
            {
                ListReplaceTargets = new List<ModData>();
                ListReplaceAlls = new List<ModData>();
            }

            public List<ModData> ListReplaceTargets { get; set; }
            public List<ModData> ListReplaceAlls { get; set; }

            public void AddModData(string type, string path, string desc, string index, string find, string replace, string foundIndex, string isReplaced)
            {
                if (type == "ReplaceTarget")
                {
                    // Check if path already exists and update it
                    var modData = ListReplaceTargets.Find(x => x.Path == path);
                    if (modData != null)
                    {
                        modData.AddReplaceTarget(path, desc, index, find, replace, Convert.ToBoolean(foundIndex), Convert.ToBoolean(isReplaced));
                        return;
                    }
                    else
                    {
                        ListReplaceTargets.Add(new ModData
                        {
                            Path = path,
                            ListReplaceTarget = new List<ReplaceTarget>
                            {
                                new ReplaceTarget
                                {
                                    Desc = desc,
                                    Index = index,
                                    Find = find,
                                    Replace = replace,
                                    FoundIndex = Convert.ToBoolean(foundIndex),
                                    IsReplaced = Convert.ToBoolean(isReplaced)
                                }
                            }
                        });
                    }
                }
                else if (type == "ReplaceAll")
                {
                    // Check if path already exists and update it
                    var modData = ListReplaceAlls.Find(x => x.Path == path);
                    if (modData != null)
                    {
                        modData.AddReplaceAll(path, desc, index, find, replace);
                        return;
                    }
                    else
                    {
                        ListReplaceAlls.Add(new ModData
                        {
                            Path = path,
                            ListReplaceAll = new List<ReplaceAll>
                            {
                                new ReplaceAll
                                {
                                    Desc = desc,
                                    Index = index,
                                    Find = find,
                                    Replace = replace
                                }
                            }
                        });
                    }
                }
                else
                {
                    throw new Exception("Invalid type: " + type);
                }
            }
        }

        public class ModData
        {
            public ModData()
            {
                ListReplaceTarget = new List<ReplaceTarget>();
                ListReplaceAll = new List<ReplaceAll>();
            }

            public string Path { get; set; }
            public List<ReplaceTarget> ListReplaceTarget { get; set; }
            public List<ReplaceAll> ListReplaceAll { get; set; }

            public void AddReplaceTarget(string path, string desc, string index, string find, string replace, bool foundIndex = false, bool isReplaced = false)
            {
                Path = path;
                ListReplaceTarget.Add(new ReplaceTarget
                {
                    Desc = desc,
                    Index = index,
                    Find = find,
                    Replace = replace,
                    FoundIndex = foundIndex,
                    IsReplaced = isReplaced
                });
            }

            public void AddReplaceAll(string path, string desc, string index, string find, string replace)
            {
                Path = path;
                ListReplaceAll.Add(new ReplaceAll
                {
                    Desc = desc,
                    Index = index,
                    Find = find,
                    Replace = replace
                });
            }
        }

        public class ReplaceTarget
        {
            public string Desc { get; set; }
            public string Index { get; set; }
            public string Find { get; set; }
            public string Replace { get; set; }
            public bool FoundIndex { get; set; }
            public bool IsReplaced { get; set; }
        }

        public class ReplaceAll
        {
            public string Desc { get; set; }
            public string Index { get; set; }
            public string Find { get; set; }
            public string Replace { get; set; }
        }
    }
'@

# Add-Type -TypeDefinition $Source -Language CSharp -PassThru
if (-not ([System.Management.Automation.PSTypeName]'IcarusModDataNamespace.ModDataObject').Type)
{
    Add-Type -TypeDefinition $Source
}

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
$currentPakModsDirectory = "$currentAppPath\Icarus\Content\Paks\mods"
$currentModToolsDirectory = "$currentAppPath\ModTools"
$currentRootModDirectory = "$currentAppPath\Mods"
$tempPackageDirectory = "$currentAppPath\TEMPModsPackage"

# **********************************************************************************************************************
# Validate
# **********************************************************************************************************************

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

# Check if $currentRootModsDirectory exists, if not, create it
If (Test-Path $currentRootModDirectory) {
    Write-Output "Current Root Mod Directory: $currentRootModDirectory"
} Else {
    Write-Output "Current Root Mod Directory: $currentRootModDirectory does not exist"
    New-Item -ItemType directory -Path $currentRootModDirectory
    Write-Output "Created $currentRootModDirectory"
}

# Get mod files
$FileList = Get-ChildItem -Path $currentRootModDirectory -Filter "mod_*.json" -File -Recurse

# If $FileList is null, exit the script
if ($null -eq $FileList) {
    Write-Output "No mod files found in $currentRootModDirectory"
    Write-Output "Be sure this directory contains mod files that start with 'mod_' and end with '.json'"
    
    # Ask if user wants to download the example mod
    Write-Output "Would you like to download an example mod? (y/n)"
    $userInput = Read-Host
    if ($userInput -eq "y") {
        Write-Output "Downloading example mod..."
        $tool = "mod_Example_MyCoolMod.json"
        $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/Mods/$tool"
        Write-Host "Downloading mod $tool -  $($link)"
        Invoke-WebRequest -Uri $link -OutFile "$currentRootModDirectory\$tool"
    } Else {
        Write-Out "Since no mods were found, exiting..."
        exit
    }
}

# Check if $currentPakModsDirectory exists, if not, create it
If (Test-Path $currentPakModsDirectory) {
    Write-Output "Current Pak Mods Directory: $currentPakModsDirectory"
} Else {
    Write-Output "Current Pak Mods Directory: $currentPakModsDirectory does not exist"
    New-Item -ItemType directory -Path $currentPakModsDirectory
    Write-Output "Created $currentPakModsDirectory"
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
    Write-Host "Downloading tool $tool -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    Expand-Archive -Path "$currentModToolsDirectory\$tool" -DestinationPath $currentModToolsDirectory
    
    $tool = "_Repack.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading tool $tool -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    
    $tool = "_RepackDirectory.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading tool $tool -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    
    $tool = "_Unpack.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading tool $tool -  $($link)"
    Invoke-WebRequest -Uri $link -OutFile "$currentModToolsDirectory\$tool"
    
    $tool = "_Unpackall.cmd"
    $link = "https://github.com/SirFrostingham/IcarusRealTimeModTool/raw/main/UnrealPakTools/$tool"
    Write-Host "Downloading tool $tool -  $($link)"
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

# Get Data: Loop through json objects and build a list of files to process and the strings to replace
# Convert flat json objects to a complex object structure
$modDataObject = New-Object 'IcarusModDataNamespace.ModDataObject'
foreach ($modfile in $FileList) {
    # Import the JSON file containing the string to replace
    $json = Get-Content -Path $modfile.PSPath | ConvertFrom-Json

    foreach ($jsonObject in $json) {
        $modDataObject.AddModData($jsonObject.Type, $jsonObject.Path, $jsonObject.Desc, $jsonObject.Index, $jsonObject.Find, $jsonObject.Replace, $false, $false)
    }
}

# Loop through each $modDataObject.ListReplaceTargets and $modDataObject.ListReplaceAlls, depending on the type
foreach ($modData in $modDataObject.ListReplaceTargets) {
    Write-Output "##############################################################################################################
    ReplaceTarget Path -  
        - Processing: $($modData.Path)
        
        "
        
    $fileTarget = "$tempPackageDirectory\data\$($modData.Path)"
    
    # Get the file content
    $fileContent = Get-Content -Path $fileTarget

    # # Delete file
    Remove-Item $fileTarget

    # Iterate through $fileContent for a target and replace a single string literal target
    foreach ($line in $fileContent) {

        foreach ($replaceItem in $modData.ListReplaceTarget) {

            if ($replaceItem.IsReplaced) {
                continue
            }
            
            # Replace the string literal
            if ($line -match $replaceItem.Index) {
                $replaceItem.FoundIndex = $true
            }

            #if ($line -match [regex]::escape($replaceItem.Find)) {
            if (($replaceItem.FoundIndex) -and ($replaceItem.IsReplaced -eq $false) -and ($line -match [regex]::escape($replaceItem.Find))) {
                Write-Output " **********************************************************************************************************************
                ReplaceTarget Item -
                    - Processing: Desc: '$($replaceItem.Desc)', Index: '$($replaceItem.Index)', Find: '$($replaceItem.Find)', Replace: '$($replaceItem.Replace)'
                    
                    "

                $line = $line -replace [regex]::escape($replaceItem.Find), $replaceItem.Replace
                $replaceItem.IsReplaced = $true
            }
            
        }
        
        Add-Content $fileTarget $line
    }

}

foreach ($modData in $modDataObject.ListReplaceAlls) {
    Write-Output "##############################################################################################################
    ReplaceAll Path -  
        - Processing: $($modData.Path)
        
        "
    
    if($modData.Path -eq "") {
        # Get all files in the directory and subdirectories
        $files = Get-ChildItem -Recurse -Path "$tempPackageDirectory\data" -File

        # Loop through each file
        foreach ($file in $files) {
            # Read the contents of the file
            $fileContent = Get-Content -Path $file.FullName

            # Loop through each $modData.ListReplaceAll
            foreach ($replaceItem in $modData.ListReplaceAll) {
                Write-Output " **********************************************************************************************************************
                ReplaceAll -> ReplaceTarget Item -  
                    - Processing: Desc: '$($replaceItem.Desc)', Index: '$($replaceItem.Index)', Find: '$($replaceItem.Find)', Replace: '$($replaceItem.Replace)'
                    
                    "
    
                # Replace the string
                $fileContent = $fileContent -replace [regex]::escape($replaceItem.Find), $replaceItem.Replace
            }

            # Write the modified content back to the file
            $fileContent | Set-Content -Path $file.FullName
        }
    } else {
        # File is supplied, only replace in that file
        $fileTarget = "$tempPackageDirectory\data\$($replaceItem.Path)"
        
        # Read the contents of the file
        $fileContent = Get-Content -Path $file.FullName
        
        # Loop through each $modData.ListReplaceAll
        foreach ($replaceItem in $modData.ListReplaceAll) {
            Write-Output " **********************************************************************************************************************
            ReplaceAll -> ReplaceTarget Item -  
                - Processing: Desc: '$($replaceItem.Desc)', Index: '$($replaceItem.Index)', Find: '$($replaceItem.Find)', Replace: '$($replaceItem.Replace)'
                
                "

            # Replace the string
            $fileContent = $fileContent -replace [regex]::escape($replaceItem.Find), $replaceItem.Replace
        }

        # Write the modified content back to the file
        $fileContent | Set-Content -Path $file.FullName
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
Copy-Item -Path "$tempPackageDirectory\Modpack_P.pak" -Destination $currentPakModsDirectory -Recurse

# **********************************************************************************************************************
# Clean up
# **********************************************************************************************************************
if ($shouldCleanUp) {
    Write-Output "Cleaning up..."
    Remove-Item $tempPackageDirectory -Recurse
}

Write-Output "Icarus Real Time Mod Tool Done!"