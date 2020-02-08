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
