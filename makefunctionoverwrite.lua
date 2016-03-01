local gsub = string.gsub
local match = string.match
local G = ...
local id = G.ID("makefunctionoverwrite.makefunctionoverwrite")
local menuid

--this is the same as makefunction but it overwrites the selected text rather than making a copy.
--TODO: see if I can require files or otherwise reduce duplication.

-- patterns found at http://lua-users.org/wiki/CommonFunctions
-- Lua pattern for matching Lua single line comment.
local pat_scomment = "(%-%-[^\n]*)"

-- Lua pattern for matching Lua multi-line comment.
local pat_mcomment = "(%-%-%[(=*)%[.-%]%2%])"

local function stringMatchesComment(str)
  return (match(str, pat_scomment)) or (match(str, pat_mcomment))
end

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

local function getTargetLineNumber(editor)
  local lineNumber = editor:GetCurrentLine()
  local currentLine = editor:GetLine(lineNumber)
  
  -- scan upwards for top of file or start of function
  while lineNumber > 0 
  and not (match(currentLine, "^local%s+function")) 
  and not (match(currentLine, "^function")) do
    lineNumber = lineNumber - 1
    currentLine = editor:GetLine(lineNumber)
  end
  
  --scan past any comments 
  while lineNumber > 0 
  and (stringMatchesComment(currentLine)
  or match(currentLine, "^local%s+function") 
  or match(currentLine, "^function"))  do
    lineNumber = lineNumber - 1
    currentLine = editor:GetLine(lineNumber)
  end

  --shift back down so we dont ram into a
  --tightly placed function
  lineNumber = lineNumber + 1
  
  return lineNumber
end

local function makeFunction()
  local editor = GetEditor()
  
  local lineNumber = getTargetLineNumber(editor)
  local currentLine = editor:GetLine(lineNumber)
  
  local selectedText = editor:GetSelectedText()
  --delete selection
  editor:Clear()
  
  local functionText
  
  local functionName = gsub(selectedText, "%b()", "")
  
  local hasParentheses = functionName ~= selectedText 
  
  if functionName:match("%.") or functionName:match(":") then  
    functionText = ""
  else
    functionText = "local "
  end
  
  local EOL = getEOLCharacter()
  
  functionText = functionText .. "function " .. selectedText .. (hasParentheses and "" or "()") .. EOL
  .. EOL
  .. "end" .. EOL
  
  editor:GotoLine(lineNumber)
  editor:InsertText(-1, functionText)
  editor:LineEnd()
  
  editor:CharLeft()
end

return {
  name = "makefunctionoverwrite",
  description = "Makes a function with a signature based on the selected fragment.",
  author = "Ryan Wiedemann",
  version = 0.1,
  dependencies = 1.10, -- just the first thing I tested it on

  onRegister = function(self)
    -- add menu item that will activate popup menu
    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Edit")))
    menuid = menu:Append(id, "Make function\tCtrl-Shift-Alt-E")
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
