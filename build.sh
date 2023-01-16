#!/bin/bash

path0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

dir_build_obj="build/obj"
dir_build_exe="build/exe"
dir_src="src/code_c"
cflags="-Wall -O3 -g -std=gnu11 -fno-strict-aliasing -I$dir_src"
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
	printf "\n\nCleaning up...\n"
	rm $dir_build_obj/*.o
	fn_stoponerror $? $LINENO
	if [ "$platform" = "windows" ]; then
		rm $dir_build_obj/res.res 2>/dev/null
		fn_stoponerror $? $LINENO
	fi
	rm -d $dir_build_obj
	fn_stoponerror $? $LINENO
}

if [[ $* == *windows* ]]; then
	echo "Warning: the windows platform not tested."
	platform="windows"
	echo "$platform not implemented"
	exit
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
else
	printf "\n Wrong argument. Please type:
	./build.sh unix \n
	or \n
	./build.sh windows\n\n"
	exit
fi

if [ ! -d "$dir_build_obj" ]; then
	echo "$LINENO: Creating object build directory..."
	mkdir -p $dir_build_obj
	fn_stoponerror $? $LINENO
fi

echo "$LINENO: Compiling for $platform..."


if command -v ccache >/dev/null; then
	compiler="ccache $compiler"
	echo "$LINENO: Using ccache."
else
	printf "$LINENO: Warning ccache not found."
fi


for f in `find src/code_c -name "*.c"`; do
	#src_file=${f:2}
	src_file=$f
	echo "$LINENO: Compiling \"$src_file\""
	$compiler -c $cflags $src_file -o "$path0/$dir_build_obj/${src_file//\//_}.o"
	if [[ $? -ne 0 ]]; then
		printf "\n\n$LINENO: error compiling \"$src_file\" file.\n"
		exit
	fi
done

if [ ! -d "$dir_build_exe" ]; then
	echo "$LINENO: Creating build directory..."
	mkdir -p $dir_build_exe
	fn_stoponerror $? $LINENO
fi

echo "$LINENO: Linking $outfile..."
$compiler $dir_build_obj/*.o $lflags -o $outfile
fn_stoponerror $? $LINENO

if [[ $* != *debug* ]]; then
	echo "$LINENO: Stripping $outfile..."
	strip $outfile
	fn_stoponerror $? $LINENO
fi

echo "$LINENO: Copying data folder..."
cp -r ./src/data ./$dir_build_exe
fn_stoponerror $? $LINENO

echo "$LINENO: Applying desktop integration..."

file_content="app_name=$app_name
"
file_content="$file_content""$(<./src/desktop_integration/fix_desktop_file.sh)"
fn_stoponerror $? $LINENO
echo "$file_content">"$dir_build_exe/fix_desktop_file.sh"
fn_stoponerror $? $LINENO
chmod +x "$dir_build_exe/fix_desktop_file.sh"
fn_stoponerror $? $LINENO
cp "./src/desktop_integration/lited.desktop.template" "$dir_build_exe/lited.desktop"
fn_stoponerror $? $LINENO
cp "./src/img/icon.png" "$dir_build_exe"
fn_stoponerror $? $LINENO

fn_clean_obj

printf "\nYour build located in $dir_build_exe directory\n"


printf "\nDone.\n\n"


