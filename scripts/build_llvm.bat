@echo off
SET ver=6.0.1

rem Check if cmake can be found
where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: cmake not found!
    exit /B 1
)

rem Check if ninja can be found
where ninja >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: ninja not found!
    exit /B 1
)

rem Check if python can be found
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: python not found!
    exit /B 1
)

rem Check if g++ can be found
where g++ >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: g++ not found!
    exit /B 1
)

rem Check if 7z can be found
where 7z >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: 7z not found!
    exit /B 1
)

echo Building LLVM %ver%

set cwd=%cd%
set llvm=llvm-%ver%
set llvmsrc=llvm-%ver%.src

rem goto :build

:extract
if not exist %llvmsrc%.tar.xz (
    echo Downloading %llvmsrc%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('http://releases.llvm.org/%ver%/%llvmsrc%.tar.xz', '%llvmsrc%.tar.xz')" || exit /B 1
)
echo *** Extracting %llvmsrc%.tar.xz ...
7z x %llvmsrc%.tar.xz -so | 7z x -aoa -si -ttar
if %errorlevel% neq 0 (
    echo Error: Failed to extract %llvmsrc%.tar.xz!
    exit /B 1
)

set srcfile=cfe-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('http://releases.llvm.org/%ver%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || exit /B 1
)
echo *** Extracting %srcfile% to %llvmsrc%\tools\ ...
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools"
if %errorlevel% neq 0 (
    echo Error: Failed to extract %srcfile%.tar.xz!
    exit /B 1
)
move %llvmsrc%\tools\%srcfile% %llvmrc%\tools\clang

set srcfile=clang-tools-extra-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('http://releases.llvm.org/%ver%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || exit /B 1
)
echo *** Extracting %srcfile%.tar.xz to %llvmrc%\tools\clang\tools\ ...
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools\clang\tools"
if %errorlevel% neq 0 (
    echo Error: Failed to extract %srcfile%.tar.xz!
    exit /B 1
)
move %llvmsrc%\tools\clang\tools\%srcfile% %llvmrc%\tools\clang\tools\extra

set srcfile=lld-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('http://releases.llvm.org/%ver%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || exit /B 1
)
echo *** Extracting %srcfile%.tar.xz to %llvmrc%\tools\ ...
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools"
if %errorlevel% neq 0 (
    echo Error: Failed to extract %srcfile%.tar.xz!
    exit /B 1
)
move %llvmsrc%\tools\%srcfile% %llvmrc%\tools\lld

:build
set llvmdir=%cd%\%llvmsrc%
set gccpath=D:\Dev\Tools\MinGW
set installpath=D:\Dev\Tools\LLVM

echo LLVM source dir: %llvmdir%

mkdir _build\%llvm%_static_win64
cd _build\%llvm%_static_win64

cmake %llvmdir% -G Ninja ^
-DCMAKE_BUILD_TYPE=Release ^
-DLLVM_TARGETS_TO_BUILD=X86 ^
-DLLVM_BUILD_TOOLS=ON ^
-DLLVM_INCLUDE_EXAMPLES=OFF ^
-DLLVM_BUILD_TESTS=OFF ^
-DLLVM_INCLUDE_TESTS=OFF ^
-DLLVM_ENABLE_EH=ON ^
-DLLVM_ENABLE_RTTI=ON ^
-DCMAKE_C_COMPILER=gcc ^
-DCMAKE_CXX_COMPILER=g++ ^
-DGCC_INSTALL_PREFIX=%gccpath% ^
-DCMAKE_INSTALL_PREFIX=%installpath% ^
-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -static -lstdc++ -lpthread" ^
-DBUILD_SHARED_LIBS=OFF ^
-DLLVM_PARALLEL_COMPILE_JOBS=4 ^
-DLLVM_PARALLEL_LINK_JOBS=4

cmake --build .

strip bin\*.exe

:cleanup
cd %cwd%
