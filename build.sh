#!/bin/bash

dir0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

dir_build_obj="build_obj"
dir_build_exe="build"
cflags="-Wall -O3 -g -std=gnu11 -fno-strict-aliasing -Isrc"
lflags="-lSDL2 -lm"
app_name="lited"

fn_stoponerror ()
{
	# Usage:
	# fn_stoponerror $? $LINENO
	error_code=$1
	line=$2
	if [ $error_code -ne 0 ]; then
		printf "\n"$line": error ["$error_code"]\n\n"
		exit $error_code
	fi
}

fn_clean_obj ()
{
	echo "Cleaning up..."
	rm $dir_build_obj/*.o
	fn_stoponerror $? $LINENO
	if [ "$platform" = "windows" ]; then
		rm $dir_build_obj/res.res 2>/dev/null
		fn_stoponerror $? $LINENO
	fi
	rm -d $dir_build_obj
	fn_stoponerror $? $LINENO
}
fn_exit ()
{
	printf "\nDone.\n\n"
	exit
}


if [[ $* == *windows* ]]; then
	printf "Warning: the windows platform not tested."
  platform="windows"
  outfile="$dir_build_exe/$app_name"".exe"
  compiler="x86_64-w64-mingw32-gcc"
  cflags="$cflags -DLUA_USE_POPEN -Iwinlib/SDL2-2.0.10/x86_64-w64-mingw32/include"
  lflags="$lflags -Lwinlib/SDL2-2.0.10/x86_64-w64-mingw32/lib"
  lflags="-lmingw32 -lSDL2main $lflags -mwindows -o $outfile $dir_build_obj/res.res"
  x86_64-w64-mingw32-windres src/res.rc -O coff -o $dir_build_obj/res.res
elif [[ $* == *unix* ]]; then
  platform="unix"
  outfile="$dir_build_exe/$app_name"
  compiler="gcc"
  cflags="$cflags -DLUA_USE_POSIX"
  lflags="$lflags -o $outfile"
else
  printf "\n Wrong argument. Please type:
  ./build.sh unix \n
  or \n
  ./build.sh windows\n\n"
  exit
fi

if command -v ccache >/dev/null; then
	compiler="ccache $compiler"
	printf "\nUsing ccache.\n"
else
	printf "\nWarning ccache not found.\n"
fi

if [ ! -d "$dir_build_obj" ]; then
	echo "Creating object build directory..."
	mkdir -p $dir_build_obj
	fn_stoponerror $? $LINENO
fi



echo "Compiling ($platform)..."
for f in `find src -name "*.c"`; do
	$compiler -c $cflags $f -o "$dir_build_obj/${f//\//_}.o"
	if [[ $? -ne 0 ]]; then
		printf "\n\n$LINENO: error compiling \"$f\" file.\n"
		fn_clean_obj
		fn_exit
	fi
done

if [ ! -d "$dir_build_exe" ]; then
	echo "Creating build directory..."
	mkdir -p $dir_build_exe
	fn_stoponerror $? $LINENO
fi

echo "Linking..."
$compiler $dir_build_obj/*.o $lflags
fn_stoponerror $? $LINENO

if [[ $* != *debug* ]]; then
	echo "Striping..."
	strip $outfile
	fn_stoponerror $? $LINENO
fi

echo "Copying data folder..."
cp -r ./src/data ./$dir_build_exe
fn_stoponerror $? $LINENO

echo "Applying desktop integration..."

file_content="app_name=$app_name
"
file_content="$file_content""$(<./src/fix_desktop_file.sh)"
fn_stoponerror $? $LINENO
echo "$file_content">"$dir_build_exe/fix_desktop_file.sh"
fn_stoponerror $? $LINENO
chmod +x "$dir_build_exe/fix_desktop_file.sh"
fn_stoponerror $? $LINENO
cp "./src/start-lited.desktop.template" "$dir_build_exe/start-lited.desktop"
fn_stoponerror $? $LINENO
cp "./src/icon.ico" "$dir_build_exe"
fn_stoponerror $? $LINENO


printf "Your build is in $dir_build_exe directory\n"

fn_clean_obj

fn_exit


