dir0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

echo $na$me "Fixing .desktop launcher..."
desktop_file="start-lited.desktop"
sed -i -e "s,^Icon=.*,Icon=$dir0/etc/cons.png,g" $desktop_file
fn_stoponerror $? $LINENO
sed -i -e "s,^Exec=.*,Exec=$dir0/start-conswine.sh,g" $desktop_file
fn_stoponerror $? $LINENO
sed -i -e "s,^Path=.*,Path=$dir0,g" $desktop_file
fn_stoponerror $? $LINENO
