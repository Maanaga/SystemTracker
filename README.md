![macOS](https://img.shields.io/badge/macOS-26.2%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0%2B-orange)
![UI](https://img.shields.io/badge/UI-SwiftUI-purple)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-success)
![Dependency](https://img.shields.io/badge/Dependency-SPM-black)
![System Data](https://img.shields.io/badge/System%20Data-SystemKit-brightgreen)

SystemTracker is a lightweight macOS menu bar app for monitoring live system activity without opening Activity Monitor.

https://github.com/user-attachments/assets/85c74cd0-8ec9-4017-bf0e-21598336fb18

## Features

- Live CPU usage (general, system, user, idle)
- Memory usage with percentage ring and detailed memory fields
- Disk usage (total, used, free) for the system volume
- Battery details (charge, health, cycle count, charging state, time remaining)
- Battery temperature history chart
- App screen-time tracker (top active apps since launch)
- Customizable menu cards via Preferences (pick which metrics are shown)

## Tech stack

- Swift + SwiftUI
- MVVM architecture
- SPM dependencies:
  - [SystemKit](https://github.com/gao-sun/SystemKit)
  - [Beam](https://github.com/tornikegomareli/beam)

## Requirements

- macOS 26.2+
- Xcode 17+

## Getting started

1. Open `SystemTracker.xcodeproj` in Xcode.
2. Select the `SystemTracker` scheme.
3. Build and run (`Cmd + R`).
4. The app appears in the macOS menu bar after launch.

## Usage

- Click the menu bar icon to open the dashboard.
- Use the `Preferences` button to choose which metric cards appear in the menu.
- Click `Quit` to close the app.

## Notes

- Screen-time data is tracked in-memory and starts from app launch.
- Some metrics depend on hardware support (for example, battery temperature).
- If system values appear unavailable, grant any requested macOS permissions and relaunch the app.
