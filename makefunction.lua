local G = ...
local id = G.ID("makefunction.makefunction")
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

local function makeFunction()
  local editor = GetEditor()
  
  local lineNumber = editor:GetCurrentLine()
  local currentLine = editor:GetLine(lineNumber)
  
  while lineNumber > 0 
  and not (string.match(currentLine, "^local%s+function")) 
  and not (string.match(currentLine, "^function")) do
    lineNumber = lineNumber - 1
    currentLine = editor:GetLine(lineNumber)
  end
  
  local selectedText = editor:GetSelectedText()
  local functionText
  
  local functionName = string.gsub(selectedText, "%b()", "")
  
  if functionName:match("%.") or functionName:match(":") then  
    functionText = ""
  else
    functionText = "local "
  end
  
  local EOL = getEOLCharacter()
  
  functionText = functionText .. "function " .. selectedText .. EOL
  .. EOL
  .. "end" .. EOL
  .. EOL
  
  editor:GotoLine(lineNumber)
  editor:InsertText(-1, functionText)
  editor:LineEnd()
end

return {
  name = "makefunction",
  description = "Makes a function with a signature based on the selected fragment.",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.10, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "Make function\tCtrl-Shift-E")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, makeFunction)
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
    menu:Append(id, "Make function")

    -- attach a function to the added menu item
    editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, makeFunction)
  end
}
