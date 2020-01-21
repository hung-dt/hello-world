:: Name    : build_llvm.bat
:: Purpose : Build LLVM in Windows using MinGW
:: Author  : dotuanhung@gmail.com
:: Revision:

@echo off

rem Check if cmake can be found
where cmake >nul 2>&1 || ( echo ERROR: cmake not found! && exit /B 1 )

rem Check if ninja can be found
where ninja >nul 2>&1 || ( echo ERROR: ninja not found! && exit /B 1 )

rem Check if python can be found
where python >nul 2>&1 || ( echo ERROR: python not found! && exit /B 1 )

rem Check if g++ can be found
where g++ >nul 2>&1 || ( echo ERROR: g++ not found! && exit /B 1 )

rem Check if 7z can be found
where 7z >nul 2>&1 || ( echo ERROR: 7z not found! && exit /B 1 )

set ver=7.0.1
set llvm_url=http://releases.llvm.org/%ver%
rem set llvm_url=https://github.com/llvm/llvm-project/releases/download/llvmorg-%ver%/

set cwd=%cd%
set llvm=llvm-%ver%
set llvmsrc=llvm-%ver%.src

echo INFO: Building LLVM %ver%

rem All are done in subdirectory llvm-%ver% of the current directory
mkdir %llvm%
cd %llvm%

:extract
if not exist %llvmsrc%.tar.xz (
    echo Downloading %llvmsrc%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%llvmsrc%.tar.xz', '%llvmsrc%.tar.xz')" || ( cd %cwd% && exit /B 1 )
    echo.  Done!
)
echo INFO: Extracting %llvmsrc%.tar.xz ...
7z x %llvmsrc%.tar.xz -so | 7z x -aoa -si -ttar
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %llvmsrc%.tar.xz!
    cd %cwd% && exit /B 1
)

set srcfile=cfe-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || ( cd %cwd% && exit /B 1 )
    echo.  Done!
)
echo INFO: Extracting %srcfile% to %llvmsrc%\tools\ ...
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %srcfile%.tar.xz!
    cd %cwd% && exit /B 1
)
rename %llvmsrc%\tools\%srcfile% clang || ( cd %cwd% && exit /B 1 )

set srcfile=clang-tools-extra-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || ( cd %cwd% && exit /B 1 )
    echo.  Done!
)
echo INFO: Extracting %srcfile%.tar.xz to %llvmrc%\tools\clang\tools\ ...
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools\clang\tools"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %srcfile%.tar.xz!
    cd %cwd% && exit /B 1
)
rename %llvmsrc%\tools\clang\tools\%srcfile% extra || ( cd %cwd% && exit /B 1 )

set srcfile=lld-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || ( cd %cwd% && exit /B 1 )
    echo.  Done!
)
echo INFO: Extracting %srcfile%.tar.xz to %llvmrc%\tools\ ...
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %srcfile%.tar.xz!
    cd %cwd% && exit /B 1
)
rename %llvmsrc%\tools\%srcfile% lld || ( cd %cwd% && exit /B 1 )

:build
set llvmdir=%cd%\%llvmsrc%
for /f %%i in ('where g++') do set RESULT=%%i
set gccpath=%RESULT:~0,-7%
set installpath=D:\Dev\Tools\LLVM

echo LLVM source dir: %llvmdir%

mkdir _build_static_win64
cd _build_static_win64

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
-DCMAKE_CXX_FLAGS=-std=c++14 ^
-DGCC_INSTALL_PREFIX=%gccpath% ^
-DCMAKE_INSTALL_PREFIX=%installpath% ^
-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -static -lstdc++ -lpthread" ^
-DBUILD_SHARED_LIBS=OFF ^
-DLLVM_PARALLEL_COMPILE_JOBS=4 ^
-DLLVM_PARALLEL_LINK_JOBS=4

cmake --build .

strip bin\*.exe

rem make install

:end
cd %cwd%
echo on
@exit /B 0
