local G = ...
local id = G.ID("returnatable.returnatable")
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

local function returnATable()
  local editor = GetEditor()
  
  local selection = editor:GetSelectedText()
  
  editor:Clear()
  
  if selection == "" then
    selection = "result"
  end

  local EOL = getEOLCharacter()

  local addedText = "local " .. selection .. " = {}" .. EOL
  .. "  " .. EOL
  .. "  return " .. selection .. EOL
  
  editor:InsertText(-1, addedText)
  editor:LineEnd()
end

return {
  name = "returnatable",
  description = "make a local table and return it, based on the selected fragment.",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.10, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "Return a table\tCtrl-Alt-R")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, returnATable)
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
    menu:Append(id, "Return a table")

    -- attach a function to the added menu item
    editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, returnATable)
  end
}
