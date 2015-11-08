local G = ...
local id = G.ID("downcaseselection.downcaseselection")
local menuid

local function downcaseSelection()
  local editor = GetEditor()
  
  local selection = editor:GetSelectedText()
    
  editor:ReplaceSelection(string.lower(selection))
end

return {
  name = "downcaseselection",
  description = "Downcase the selected piece of text",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.20, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "downcase selected text\tCtrl-Alt-Shift-D")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, downcaseSelection)
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
    editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, downcaseSelection)
  end
}
