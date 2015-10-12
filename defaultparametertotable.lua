local G = ...
local id = G.ID("defaultparametertotable.defaultparametertotable")
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

local function defaultParameterToTable()
  local editor = GetEditor()
  local lineNumber = editor:GetCurrentLine()
  local currentLine = editor:GetLine(lineNumber)
  
  local addedText = ""
  
  local selection = editor:GetSelectedText()
  
  local nothingSelected = selection == ""
  
  if nothingSelected then
    selection = "options"
  end
  
  local inParameterList = string.match(currentLine, "%)")
  if inParameterList then
    editor:GotoLine(lineNumber + 1)
    addedText = addedText .. "  "
  end
  
  if inParameterList or nothingSelected then
    addedText = addedText .. selection
  else
    editor:SetCurrentPos(editor:GetSelectionEnd())
  options = options or {}
  end

  addedText = addedText .. " = " .. selection .. " or {}" .. getEOLCharacter()
  
  editor:InsertText(-1, addedText)
  editor:LineEnd()
end

return {
  name = "defaultparametertotable",
  description = "require a module with a filename equal to selected fragment.",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.10, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "Default parameter to table\tCtrl-Shift-D")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, defaultParameterToTable)
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
    menu:Append(id, "Default parameter to table")

    -- attach a function to the added menu item
    editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, defaultParameterToTable)
  end
}
