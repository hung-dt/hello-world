# Setting Visual Studio Code for C++ Development

This is a guide to set up Visual Studio Code and other tools used for C++ development in Windows environment.
You don't need to have administration right to complete this setup.

## Directory structure
Create the following directory structure:
```
<root>\Dev
       |
       +-- Tools
       |   |
       |   +-- extra
       |
       +-- Temp
       |
       +-- Workspace
```

## Prerequisites
The following tools are needed for our development setup.

### Git for Windows
- Download [PortableGit-2.25.0](https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/PortableGit-2.25.0-64-bit.7z.exe) to `\Dev\Temp`
- Run the downloaded file to install it to `\Dev\Tools\PortableGit`
- If extract manually, must run `\Dev\Tools\PortableGit\post_install.bat`
- Add `\Dev\Tools\PortableGit\usr\bin` and `\Dev\Tools\PortableGit\mingw64\bin` to `%PATH%`

### MinGW-W64 GCC-8.1.0
- Download [MinGW-W64 GCC-8.1.0 x86_64, POSIX thread, seh runtime](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z/download) to `\Dev\Temp`
- Extract to `\Dev\Tools\mingw64`
- Add `\Dev\Tools\mingw64\bin` to `%PATH%`

Update:
[WinLibs](http://winlibs.com/) provides better builds of GCC and MinGW-w64 for Windows
- Download [WinLibs x86_64, GCC 10.2.0, POSIX thread SEH, LLVM 10.0.1, MinGW-w64 7.0.0_r4](https://github.com/brechtsanders/winlibs_mingw/releases/download/10.2.0-7.0.0-r4/winlibs-x86_64-posix-seh-gcc-10.2.0-llvm-10.0.1-mingw-w64-7.0.0-r4.7z) to `\Dev\Temp`
- Extract to `\Dev\Tools`
- Add `\Dev\Tools\mingw64\bin` to `%PATH%`

### CMake
- Download [CMake 3.16.4](https://github.com/Kitware/CMake/releases/download/v3.16.4/cmake-3.16.4-win64-x64.zip) to `\Dev\Temp`
- Extract to `\Dev\Tools\cmake-3.16.4`
- Add `\Dev\Tools\cmake-3.16.4\bin` to `%PATH%`

### Ninja build system
- Download the latest release [here](https://github.com/ninja-build/ninja/releases) to `\Dev\Temp`
- Extract to `\Dev\Tools\mingw64\bin`

### Python 2.7 (optional)

### Compile Clang (optional)
Compile Clang using MinGW, cmake and ninja.

## Download Specific Version of VSCode

Use the following URL to download .zip version of VSCode:
```
https://vscode-update.azurewebsites.net/<download version>/win32-x64-archive/stable
```

For example, to download version 1.49.3 the download link is: `https://vscode-update.azurewebsites.net/1.49.3/win32-x64-archive/stable`

Visit [VSCode updates](https://code.visualstudio.com/updates) for more info.

## Configure Visual Studio Code
### Add git bash terminal
Add the following line to `settings.json`
```json
    // Git Bash
    "terminal.integrated.shell.windows": "C:\\Dev\\Tools\\PortableGit\\bin\\bash.exe",
    // Open the terminal in the currently opened file's directory
    "terminal.integrated.cwd": "${fileDirname}"
```

### Install C/C++ extension

## Format C/C++ source files with clang-format

