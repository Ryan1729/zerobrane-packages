# zerobrane-packages
some packages (plugins) for [Zerobrane Studio](http://studio.zerobrane.com/)


# Usage
See [zerobrane's docs](http://studio.zerobrane.com/doc-plugin#plugin-installation) for installation instructions.

Each package adds an entry to the edit menu and has a keyboard shortcut.

##makeafunction.lua

```lua

local function some_function()
  function_to_be_written(param1, param2)
end

```

select ```function_to_be_written(param1, param2)``` and activate the command and the file becomes

```lua

local function function_to_be_written(param1, param2)
  
end

local function someFunction()
  function_to_be_written(param1, param2)
end

```

##defaultparametertotable.lua

```lua

local function some_function(param_with_default)
  
end
```

select ```param_with_default``` and activate the command and the file becomes

```lua

local function some_function(param_with_default)
  param_with_default = param_with_default or {}
end

```

If nothing is selected the name defaults to ```options```

##returnatable.lua

```lua

local function some_function()
  resulting_table
end

```

select ```resulting_table``` and activate the command and the file becomes

```lua
local function some_function()
  local resulting_table = {}
  
  return resulting_table
end
```

If nothing is selected the name defaults to ```result```

##requireselectedmodule.lua

```lua

local some_lib = require("some_lib") 
 
some_other_lib


```

select ```some_other_lib``` and activate the command and the file becomes

```lua

local some_lib = require("some_lib") 
local some_other_lib = require("some_other_lib")

some_other_lib


```
