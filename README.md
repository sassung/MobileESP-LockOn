Mobile ESP + FOV Lock-On

A mobile-friendly ESP and FOV lock-on system made for Roblox games.

Features

- 📱 Mobile touch controls
- 👁️ Player ESP
- 🤖 NPC ESP
- 🎯 Adjustable FOV circle
- 🖐️ Draggable FOV circle
- 🔒 Camera lock-on
- 🎮 Automatically detects players and NPCs inside the FOV
- 📦 Minimize button with circular menu icon
- ⚙️ Configurable FOV and lock-on smoothness

Mobile Controls

Control| Function
"LOCK"| Toggle camera lock-on
"ESP"| Toggle ESP
"FOV -"| Decrease FOV
"FOV +"| Increase FOV
"≡"| Minimize controls
"＋"| Expand controls
Drag FOV| Move the FOV targeting area

ESP

Players

Displays the player's Roblox username.

NPCs

Displays the NPC model's name.

Configuration

You can change these settings near the top of the script:

local FOV_RADIUS = 180
local MIN_FOV = 60
local MAX_FOV = 400
local LOCK_SMOOTHNESS = 0.15

FOV

- Default: "180"
- Minimum: "60"
- Maximum: "400"

Lock Smoothness

Higher values make the camera follow the target faster.

local LOCK_SMOOTHNESS = 0.15

Installation

1. Open your Roblox Studio project.
2. Go to "StarterPlayer > StarterPlayerScripts".
3. Create a "LocalScript".
4. Copy the contents of "MobileESP_LockOn.lua" into the LocalScript.
5. Test the system using Roblox Studio's mobile/device emulator.

Requirements

- Roblox Studio
- A Roblox experience you own or have permission to develop
- A character/NPC with a "Humanoid"
- NPCs should have a "Head" or "HumanoidRootPart" for ESP positioning.

Important

This project is intended for use in your own Roblox experiences or experiences where you have permission to develop.

The system handles visual ESP, target selection, FOV, and client-side camera movement. Important gameplay systems such as damage and hit detection should remain server-authoritative.

License

No license specified.

All rights reserved unless otherwise stated.
