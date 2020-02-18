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

rem Check if curl can be found
where curl >nul 2>&1 || ( echo ERROR: curl not found! && exit /B 1 )

rem Check if tee can be found
where tee >nul 2>&1 || ( echo ERROR: tee not found! && exit /B 1 )

set ver=9.0.1
set "valid=false"
for %%v in ( "9.0.0" "8.0.0" "7.0.1" "7.0.0" "6.0.1" "6.0.0" "5.0.2" "5.0.1" "5.0.0" ) do (
    if "%ver%"==%%v (
        set llvm_url=http://releases.llvm.org/%ver%
        set valid=true
    )
)

for %%v in ( "9.0.1" "8.0.1" "7.1.0" ) do (
    if "%ver%"==%%v (
        set llvm_url=https://github.com/llvm/llvm-project/releases/download/llvmorg-%ver%/
        set valid=true
    )
)

if "%valid%"=="true" (
    echo Valid LLVM version %ver%
    echo URL: %llvm_url%
) else (
    echo ERROR: Invalid LLVM version %ver% && exit /B 1
)

set root_dir=%cd%
set llvm=llvm-%ver%
set llvmsrc=llvm-%ver%.src

rem All are done in subdirectory llvm-%ver% of the script directory
if not exist %llvm%\ mkdir %llvm%
cd %llvm%

set log_file=%root_dir%\%llvm%\build_%ver%_%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%h%TIME:~3,2%m%TIME:~6,2%s.log
echo [%date% %time%] INFO: Building LLVM %ver% in %root_dir%\%llvm% | tee -a %log_file%

:extract

rem *** Download and extract llvm source ***
if not exist %llvmsrc%.tar.xz (
    echo Downloading %llvmsrc%.tar.xz ...
    rem powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%llvmsrc%.tar.xz', '%llvmsrc%.tar.xz')" || ( cd %root_dir% && exit /B 1 )
    curl -sOL %llvm_url%/%llvmsrc%.tar.xz || ( cd %root_dir% && exit /B 1 )
    echo.  Done!
)
echo [%date% %time%] INFO: Extracting %llvmsrc%.tar.xz ... | tee -a %log_file%
7z x %llvmsrc%.tar.xz -so | 7z x -aoa -si -ttar
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %llvmsrc%.tar.xz!
    cd %root_dir% && exit /B 1
)

rem *** Download and extract clang source ***
set srcfile=cfe-%ver%.src
if "%ver%"=="9.0.1" (
	set srcfile=clang-%ver%.src
)
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    rem powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || ( cd %root_dir% && exit /B 1 )
    curl -sOL %llvm_url%/%srcfile%.tar.xz || ( cd %root_dir% && exit /B 1 )
    echo.  Done!
)
echo [%date% %time%] INFO: Extracting %srcfile% to %llvmsrc%\tools\ ... | tee -a %log_file%
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %srcfile%.tar.xz!
    cd %root_dir% && exit /B 1
)
rename %llvmsrc%\tools\%srcfile% clang || ( cd %root_dir% && exit /B 1 )

rem *** Download and extract clang tools source ***
set srcfile=clang-tools-extra-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    rem powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || ( cd %root_dir% && exit /B 1 )
    curl -sOL %llvm_url%/%srcfile%.tar.xz || ( cd %root_dir% && exit /B 1 )
    echo.  Done!
)
echo [%date% %time%] INFO: Extracting %srcfile%.tar.xz to %llvmsrc%\tools\clang\tools\ ... | tee -a %log_file%
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools\clang\tools"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %srcfile%.tar.xz!
    cd %root_dir% && exit /B 1
)
rename %llvmsrc%\tools\clang\tools\%srcfile% extra || ( cd %root_dir% && exit /B 1 )

rem *** Download and extract lld source ***
set srcfile=lld-%ver%.src
if not exist %srcfile%.tar.xz (
    echo Downloading %srcfile%.tar.xz ...
    rem powershell -Command "(New-Object Net.WebClient).DownloadFile('%llvm_url%/%srcfile%.tar.xz', '%srcfile%.tar.xz')" || ( cd %root_dir% && exit /B 1 )
    curl -sOL %llvm_url%/%srcfile%.tar.xz || ( cd %root_dir% && exit /B 1 )
    echo.  Done!
)
echo [%date% %time%] INFO: Extracting %srcfile%.tar.xz to %llvmsrc%\tools\ ... | tee -a %log_file%
7z x %srcfile%.tar.xz -so | 7z x -aoa -si -ttar -o"%llvmsrc%\tools"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract %srcfile%.tar.xz!
    cd %root_dir% && exit /B 1
)
rename %llvmsrc%\tools\%srcfile% lld || ( cd %root_dir% && exit /B 1 )

:build
set llvmdir=%cd%\%llvmsrc%

for /f %%i in ('where g++') do set RESULT=%%i
set gccpath=%RESULT:~0,-12%
set installpath=D:\Dev\Tools\LLVM-%ver%

set build_dir=_build_static_win64
if not exist %build_dir%\ (
    echo [%date% %time%] INFO: Create build folder %build_dir% | tee -a %log_file%
    mkdir %build_dir%
)
cd %build_dir%

echo [%date% %time%] INFO:   GCC path         : %gccpath% | tee -a %log_file%
echo [%date% %time%] INFO:   LLVM source dir  : %llvmdir% | tee -a %log_file%
echo [%date% %time%] INFO:   LLVM install path: %installpath% | tee -a %log_file%
echo [%date% %time%] INFO:   Build dir        : %build_dir% | tee -a %log_file%

set answer=y
set /P answer="Continue with the building? [Y/n] "
if /I "%answer%" neq "Y" goto end

echo [%date% %time%] INFO: Run cmake in %build_dir% for configuration... | tee -a %log_file%
(cmake %llvmdir% -G Ninja ^
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
-DLLVM_PARALLEL_LINK_JOBS=4 2>&1 & call echo cmakeReturnCode: %%^^errorlevel%%) | tee -a %log_file%
for /f "tokens=2" %%A in ('findstr /b "cmakeReturnCode:" %log_file%') do (
    if %%A neq 0 goto end
)

echo [%date% %time%] INFO: Start building LLVM... | tee -a %log_file%
(cmake --build . 2>&1 & call echo cmakeBuildReturnCode: %%^^errorlevel%%) | tee -a %log_file%
for /f "tokens=2" %%A in ('findstr /b "cmakeBuildReturnCode:" %log_file%') do (
    if %%A neq 0 goto end
)

echo [%date% %time%] INFO: Strip executables... | tee -a %log_file%
strip -v bin\*.exe 2>&1 | tee -a %log_file%

echo [%date% %time%] INFO: Install LLVM to %installpath%... | tee -a %log_file%
cmake --build . --target install 2>&1 | tee -a %log_file%

echo [%date% %time%] INFO: Building completed! | tee -a %log_file%
echo.

:end
echo Check %log_file% for more details of the building process!
cd %root_dir%
echo on
@exit /B 0
