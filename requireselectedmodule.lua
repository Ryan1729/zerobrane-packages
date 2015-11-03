local match = string.match
local G = ...
local id = G.ID("requireselectedmodule.requireselectedmodule")
local menuid

local function getEOLCharacter()
  -- it would be nice if I could reference the
  -- mode constants directly but AFAICT I can't
  local EOLMode = GetEditor():GetEOLMode()
  
  if EOLMode == 0 then
    return "\r\n"
  elseif EOLMode == 1 then
    return "\r"
  else
    return "\n"
  end

end

local function requireSelectedModule()
  local editor = GetEditor()
  
  local lineNumber = editor:GetCurrentLine()
  local currentLine = editor:GetLine(lineNumber)
  
  --scan upwards for any require statements
  while lineNumber > 0 
  and not (match(currentLine, "require%s+%(?\"")) do
    lineNumber = lineNumber - 1
    currentLine = editor:GetLine(lineNumber)
  end
  
  local selection = editor:GetSelectedText()
  local requireText = "local " .. selection .. " = require(\"" .. selection .. "\")" .. getEOLCharacter()
  
  editor:GotoLine(lineNumber)
  editor:InsertText(-1, requireText)
  editor:LineEnd()
end

return {
  name = "requireselectedmodule",
  description = "require a module with a filename equal to selected fragment.",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.10, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "Require selected module\tCtrl-M")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, requireSelectedModule)
  end,

  onUnRegister = function(self)
    -- remove added menu item when plugin is unregistered
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    ide:GetMainFrame():Disconnect(id, wx.wxID_ANY, wx.wxEVT_COMMAND_MENU_SELECTED)
    if menuid then menu:Destroy(menuid) end
  end,

  onMenuEditor = function(self, menu, editor, event)
    -- add a separator and a sample menu item to the popup menu
    menu:AppendSeparator()
    menu:Append(id, "Require selected module")

    -- attach a function to the added menu item
    editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, requireSelectedModule)
  end
}
