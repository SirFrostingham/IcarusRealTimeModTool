# IcarusRealtimeModTool
Realtime find and replace approach to modifying the game ICARUS

# Why use this?
- There is no longer a need to distribute PAK files of your mods per ICARUS game releases. No matter when the ICARUS game updates are released, this will always work.
- No more merging your "modded content" with new game releases with different versions of your json updates. The system does game modding in real-time, any time you run the `ModGame.ps1` script.
- It's fast. Since this is Powershell, it runs on top of Microsoft .Net Framework.
- It's safe. The code is simple and clearly commented with no surprises.
- It's easy to use. Find stuff you want to change, make a json block that uses one of the find/replace mechanisms and this system does the heavy lifting for you as a mod creator and your clients.
- If this system is used, it will work with many mods. The mod files would just be placed in the game root directory `./Mods`, and the system puts them all together in real-time.
- It can be easily integrated with other scripts or launching mechanisms.

# How does it work?
- Run a single script `[Icarus_game_directory]\GameMod.ps1` to run the mods process.
- The system looks in `[Icarus_game_directory]\Mods` directory for any `mod_*.json` config files, which tell this system how to mod the game.
   - It supports many `mod_*.json` files (example: `mod_Example_MyCoolMod.json`, `mod_YourCoolMod.json`, `mod_TheirCoolMod.json`, etc.)
- Per the config data, it will find and replace all targets in the UNPACKED `[Icarus_game_directory]\Icarus\Content\Data\data.pak` json files (see below for more info)
   - It currently supports 2 types of find and replace: `ReplaceAll` and `ReplaceTarget`
- It does all work in `[Icarus_game_directory]\TEMPModsPackage` directory.
- After the mods are done, a file called `Modpack_P.pak` is placed in `[Icarus_game_directory]\Icarus\Content\Paks\mods\` directory.
   - This is a full repack of the original ICARUS game data.pak file.
- The `[ICARUS_game_directory]\TEMPModsPackage` directory is purposefully left in the game root directory, so mod developers can review the json file game updates.

# Example config (also provided in this repo)
```
[
    {
       "Desc":"Remove all negative experience values",
       "Type":"ReplaceAll",
       "Path":"",
       "Index":"",
       "Find":"Experience_+%\\\")\": -",
       "Replace":"Experience_+%\\\")\": "
    },
    {
       "Desc":"Remove a specfic negative movement speed value",
       "Type":"ReplaceTarget",
       "Path":"Modifiers\\D_ModifierStates.json",
       "Index":"DamageOverTime_Physical",
       "Find":"BaseMovementSpeed_+\\\")\": -",
       "Replace":"BaseMovementSpeed_+\\\")\": "
    }
]
```

# ReplaceAll
- This will find (using the `Find` string value) and replace (using the `Replace` string value) across ALL game data json files.

# ReplaceTarget
- Using `Path`, the system locates this file target, searches for `Index` string, then finds the closest `Find` string value and replaces it with the `Replace` string value.

# Json Escape characters
- You must escape certain characters in your `mod_*.json` files, or the system will fail. The following examples are listed in the above `Example config` section.
   - Examples:
   - Back slash: `\\` = `\`
   - Double quotes: `\"` = `"`
- In other words: If you find something like `Experience_+%")": -10` in some game data json file, it needs to be put in the mod config file as `Experience_+%\\\")\": -10`.
- Search around the internet for Powershell Escape characters.

# How to install
1. Install game ICARUS (probably through Steam)
2. Copy 1 files from this repo (`ModGame.ps1`) to the root game directory (example: D:\SteamLibrary\steamapps\common\ICARUS)
   - The script will download any missing components, including asking you if you want to download an example mod.
   - It needs at least 1 mod for the system to work.
3. Set up your PC to be able to run Powershell scripts: Run `cmd.exe` -> execute: `powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`
4. From the root ICARUS game directory, run: `ModGame.ps1`

Screenshots of before/after each of the above examples:
![image](https://user-images.githubusercontent.com/4725943/212524939-86b0315c-bc20-4194-b4af-a6714dd8bfb5.png)
![image](https://user-images.githubusercontent.com/4725943/212524955-284675ff-a7e9-4cd2-95b7-895b3e67c213.png)

# Important people and communities
- ICARUS Official - https://discord.com/invite/surviveICARUS
   - Thanks RocketWerkz devs and Dean Hall for the amazing game!
   - Thanks Dean Hall for work you did on DayZ Mod (and eventually DayZ SA) that got me into the survival game genre
- Inkarus - ICARUS Modding - https://discord.gg/2UrWDXjxUk
   - TheOrangeFloof - Inkarus discord owner and modder
   - Jimk72 - Mod manager creator, modder and very helpful person
   - Donovan - Very welcoming, helpful modder that pointed me in some interesting mods directions
   - M. Becile - Extremely helpful, selfless modder that was willing to help me with stuff without asking
   - CK_Dexerhaven - Knowledgeable vetran modder, and questions answerer on Inkarus
- Without these key gaming communities, I would not have done any of this...
- Sorry if I didn't fully describe all you do for ICARUS or gaming communities. I gave it my best. I'll happily adjust anything you want; please just ask.

# How to contact me
- Website: https://moosepuncher.com
- Discord: https://discordapp.com/invite/wqH6PHts

Enjoy!

# Support the developer
---
If you would like to support development of this software, you can contribute with a donation by clicking on the Donate Icon below. Thank you for your support!

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PXV8MLB5KR5WG)


This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
  - https://creativecommons.org/licenses/by-nc-sa/4.0/
