# lited
![screenshot](doc/screenshot.lited0.8.png)

A lightweight text editor written in Lua (forked from [lite by rxi](https://github.com/rxi/lite)).

## Usage
A quick usage instaructions located at [doc/usage.md](doc/usage.md).

## Overview
lited is a lightweight text editor written mostly in Lua — it aims to provide
something practical, pretty, *small* and fast, implemented as simply as
possible; easy to modify and extend, or to use without doing either.

## Customization
### Syntax highlighting
Syntax highlighting support for additional languages can be added by copying language plugins (named 'language_{languageName}.lua) to [src/data/plugins/highliter/languages](src/data/plugins/highliter/languages) directory.

### Plugins
Additional functionality can be added through plugins which are available from
the foloowing sources:
- [rxi/lite-plugins](https://github.com/rxi/lite-plugins);
- [lite-xl-plugins](https://github.com/lite-xl/lite-xl-plugins);
- [rxi/lite source code](https://github.com/rxi/lite/tree/master/data/plugins);
- [lite-xl sorce code](https://github.com/lite-xl/lite-xl/tree/master/data/plugins).

### Color themes
Additional color themes can be found in the following sources:
- [rxi/lite-colors](https://github.com/rxi/lite-colors);
- [lite-xl-colors](https://github.com/lite-xl/lite-xl-colors).

The editor can be customized by making changes to the
[user module](src/data/user/init.lua).

## Building
You can build the project yourself on Linux using the `build.sh` script
~~or on Windows using the `build.bat` script *([MinGW](https://nuwen.net/mingw.html) is required)*~~.
Note that the project does not need to be rebuilt if you are only making changes
to the Lua portion of the code (located at src/data directory).

~~## Contributing
Any additional functionality that can be added through a plugin should be done
so as a plugin, after which a pull request to the
[plugins repository](https://github.com/rxi/lite-plugins) can be made. In hopes
of remaining lightweight, pull requests adding additional functionality to the
core will likely not be merged. Bug reports and bug fixes are welcome~~.

## License
This project is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
