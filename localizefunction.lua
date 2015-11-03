local G = ...
local id = G.ID("localizefunction.localizefunction")
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

local function localizeFunction()
  local editor = GetEditor()
  
  local selection = editor:GetSelectedText()
  
  --for this function to work as intended, we need the selection to
  --contain a name of a function stored on a table, 
  -- for instance "math.random"
  if string.match(selection, "%.") then
    local lineNumber = editor:GetCurrentLine()
    local currentLine = editor:GetLine(lineNumber)
    
    --scan upwards for any require statements or other localized functions
    while lineNumber > 0 
    and not (string.match(currentLine, "require%s+%(?\"")) 
    and not (string.match(currentLine, "local%s*([^%s]*)%s*=%s*([^%s]*)%.%1")) do
      lineNumber = lineNumber - 1
      currentLine = editor:GetLine(lineNumber)
    end
    
    local functionName = string.match(selection, "%.([^%s]*)")
    
    editor:ReplaceSelection(functionName)
    
    local localizeLine = "local " .. functionName .. " = " .. selection .. getEOLCharacter()
    
    editor:GotoLine(lineNumber)
    editor:InsertText(-1, localizeLine)
    editor:LineEnd()
  end
end

return {
  name = "localizefunction",
  description = "Make a local reference to a function stored on a (presumably global) table.",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.20, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "Localize function\tCtrl-Alt-L")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, localizeFunction)
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
    editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, localizeFunction)
  end
}
