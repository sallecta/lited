local syntax = require "core.syntax"

syntax.add {
files = { "%.desktop" },
comment = "#",
patterns = {
	{ pattern = "#.-\n", 				type = "comment"},
	{ pattern = "%[Desktop% Entry%]", 	type = "keyword" },
	{ pattern = "Type%=", 				type = "keyword2" },
	{ pattern = "Name%=", 				type = "keyword2" },
	{ pattern = "GenericName%=", 		type = "keyword2" },
	{ pattern = "Comment%=", 			type = "keyword2" },
	{ pattern = "Categories%=",			type = "keyword2" },
	{ pattern = "StartupNotify%=",		type = "keyword2" },
	{ pattern = "Path%=",				type = "keyword2" },
	{ pattern = "Exec%=",				type = "keyword2" },
	{ pattern = "Icon%=",				type = "keyword2" },
	{ pattern = "%=",					type = "operator" },
},
symbols = {
	["true"] = "literal",
	["false"] = "literal",
},
}
