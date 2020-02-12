# My Journal

## Compile SFML-2.5.1 in Linux Mint 19.3
- Download SFML source
- Install dependencies:
```
sudo apt-get install libx11-dev
sudo apt-get install xorg-dev
sudo apt-get install freeglut3-dev
sudo apt-get install libudev-dev
sudo apt-get install libopenal-dev
sudo apt-get install libvorbis-dev
sudo apt-get install libflac-dev
```
- Compile with cmake and install to `$HOME/opt/SFML`:
```
cd <SFML_source_dir>
mkdir build && cd build
cmake .. \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=~/opt/SFML-2.5.1 \
-DBUILD_SHARED_LIBS=ON \
-DSFML_BUILD_EXAMPLES=OFF
make -j 4
make install
```
- Add to LD_LIBRARY_PATH:
```
export LD_LIBRARY_PATH=$HOME/opt/SFML-2.5.1/lib:$LD_LIBRARY_PATH
```
- Create an environment variable `SFML_HOME` set to `$HOME/opt/SFML-2.5.1`
```
export SFML_HOME=$HOME/opt/SFML-2.5.1
```
## Compile and install SFML-2.5.1 in Windows using MinGW
- Download SFML source: [https://www.sfml-dev.org/files/SFML-2.5.1-sources.zip]
- Compile with cmake and install to `D:\Dev\sfml-2.5.1`
```
cd <SFML_source_dir>
mkdir build && cd build
cmake .. -G Ninja ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=D:\Dev\sfml-2.5.1 ^
-DBUILD_SHARED_LIBS=ON ^
-DSFML_BUILD_EXAMPLES=OFF
ninja -j 8
cmake --build . --target install
```
- Add `D:\Dev\sfml-2.5.1\bin` to %PATH% so dynamic libs can be found:
- Create an environment variable `SFML_HOME` set to `D:\Dev\sfml-2.5.1`
```
setx SFML_HOME D:\Dev\sfml-2.5.1
```

## Compile a sample SFML app with cmake
- Create a sample SFML app:
```cpp
#include <SFML/Graphics.hpp>

int main()
{
    sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works!");
    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear();
        window.draw(shape);
        window.display();
    }

    return 0;
}
```
- Create a `CMakeLists.txt`:
```
cmake_minimum_required(VERSION 3.10)

project(sfml-app)

list(APPEND CMAKE_MODULE_PATH $ENV{SFML_HOME}/lib/cmake/SFML)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS "${CMAXE_CXX_FLAGS} -Wall -O2")

find_package(SFML COMPONENTS graphics window system)

set(INC_DIRS
    $ENV{SFML_HOME}/include
)

set(SRC
    test.cpp
)

add_executable(test01 ${SRC})
target_include_directories(test01
    PRIVATE ${INC_DIRS}
)
target_link_libraries(test01
    PRIVATE sfml-graphics sfml-window sfml-system
)
```
- Build:
```
mkdir build && cd build
cmake ..
make
./sfml-app
```
- If everything works, you should see this in a new window:

![sfml-app](https://www.sfml-dev.org/tutorials/2.5/images/start-linux-app.png "sfml-app window")

## Compile SFML app manually

If you installed SFML to a non-standard path `$HOME/opt/SFML-2.5.1` for example, you'll need to tell the linker where to find the SFML libraries (.so files):

```
g++ test.cpp -o sfml-app -L<sfml-install-path>/lib -lsfml-graphics -lsfml-window -lsfml-system
```

If SFML is not installed in a standard path, you need to tell the dynamic linker where to find the SFML libraries first by specifying LD_LIBRARY_PATH:
```
export LD_LIBRARY_PATH=<sfml-install-path>/lib
```
