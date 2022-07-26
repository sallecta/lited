# fsutils

This plugin introduces a few commands related to the filesystem (rename / move, recursive delete (`rm -r`), recursive create directory (`mkdir -p`)) to lited.

It also exports a few wrapper filesystem functions so that other plugins may use it.

Based on [lite-fsutils](https://github.com/takase1121/lite-fsutils) by takase1121.

This plugin is required for builtin plugin menucontext to work with TreeView.

### Note : 

fsutils.delete() depends on os.remove() for deleting files and directories. While this works for files everywhere, it doesnot delete directories on Windows.

