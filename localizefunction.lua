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
  
  --is the thing that was selected a function
  -- for instance "math.random"
  local isFunction = string.match(selection, "%.") and true or false
  

  local lineNumber = editor:GetCurrentLine()
  local currentLine = editor:GetLine(lineNumber)
  
  --scan upwards for any require statements or other localized functions
  while lineNumber > 0 
  and not (string.match(currentLine, "local%s*([^%s]*)%s*=%s*require%s*%(?%s*\"")) do
    lineNumber = lineNumber - 1
    currentLine = editor:GetLine(lineNumber)
  end
  
  --unless we're at the top, go to the next line
  lineNumber = lineNumber > 0 and lineNumber + 1 or lineNumber
  
  local name = isFunction and string.match(selection, "%.([^%s]*)") or selection
  
  editor:ReplaceSelection(name)
  
  local localizeLine = "local " .. name .. " = " .. (isFunction and selection or "") .. getEOLCharacter()
  
  editor:GotoLine(lineNumber)
  editor:InsertText(-1, localizeLine)
  editor:LineEnd()
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
