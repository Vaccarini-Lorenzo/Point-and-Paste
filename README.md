# Point & Paste
Point & Paste is a simple macOS tool that makes the research for the right color easier: **Just point your cursor to a color you like and copy its hex code to your clipboard.**

![PPGif](Resources/PP.gif)

# Requisites

1. XCode
2. Automator

# Installation

1. Clone this repository

2. Execute the install.sh script `chmod +x install.sh && . install.sh`

3. Bind whatever key you like to the **pp** service

![KeyboardScreen](Resources/KeyboardScreen.jpg)

# Usage

**Simply point to the color you want to capture and press the key previously chosen to copy it!**

# Open issues
Since this project is very new there are a list of issues that are not fixed yet:
1. Sometimes, if the mouse gets moved, it will be copied the hex color of adjacent pixels

2. It requires the permission to record your screen from the applications subject to the pixel capture (a pop-up request will be shown). Unfortunately if the permission is not given, the application will result transparent and the only color that will be captured is the one of the background

3. It can be hard to find a key-binding not used by all the applications. One that looks to be working is `⌃ ⌥ ⌘ -`

**Please feel free to contact me if you find any other issue or a solution to the above problems: I appreciate every pull request.**

# TO-DO list

1. Add brew installation

2. Fix the above issues
