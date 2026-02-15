# Dinomite

A game made with HaxeFlixel.

## Installation

### Prerequisites

- **Haxe** - Download and install from [haxe.org](https://haxe.org/download/)

#### Platform-Specific Requirements

**Windows:**
- Install [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe)
- Select "MSVC v143 - VS 2022 C++ x64/x86 build tools"
- Select "Windows 10/11 SDK"

**macOS:**
- Xcode Command Line Tools: `xcode-select --install`

**Linux (Debian/Ubuntu):**
```bash
sudo apt install g++ gcc libc6-dev libx11-dev libgl1-mesa-dev libxi-dev
```

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/dinomite.git
cd dinomite
```

2. Install hmm (Haxe dependency manager):
```bash
haxelib --global install hmm
haxelib --global run hmm setup
```

3. Install dependencies:
```bash
hmm install
```

4. Build and run:
```bash
lime test html5
```

> **Note:** Due to the use of [tink_sql](https://lib.haxe.org/p/tink_sql/), this project can only be compiled for HTML5.

### Build Flags

- Add `-debug` for debug builds: `lime test html5 -debug`
- Add `-release` for optimized release builds: `lime test html5 -release`

## Inspirations

- **Chrome Dino Game** - Game concept
- **Geometry Dash** - Platforming mechanics
- **Friday Night Funkin'** - Source code "borrowing"
