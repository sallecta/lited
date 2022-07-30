# Object implementation in lited 0.x

## Using object from module

1. Create local object table and assign its value to table returned by object module using require function.

```lua
local SomeObject = require("someobject")
```

2. Create an instance of object by assigning return value of **directry called local object table** to some local variable or table

```lua
local some_object_instance1 = SubObj()
-- or
local some_table = {}
some_table.some_object_instance2 = SomeObject()
```

3. Use the instantinated object

```lua
some_object_instance1:some_function()
local some_var1 = some_object_instance1.some_field1
-- or
some_table.some_object_instance2.some_function()
some_table.some_var1 = some_table.some_object_instance2.some_field1
```
