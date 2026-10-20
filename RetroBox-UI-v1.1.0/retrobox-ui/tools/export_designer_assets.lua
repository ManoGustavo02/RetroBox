dofile('tests/mock_roblox.lua')
local L=dofile('RetroBox.lua')
local result={Themes={},Icons={},Catalog=L:GetDesignerCatalog()}
for _,name in ipairs(L:GetThemeNames()) do
 local palette={}
 for role,color in pairs(L.Themes[name]) do palette[role]=string.format('#%02x%02x%02x',math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5)) end
 result.Themes[name]=palette
end
for _,name in ipairs(L:GetIconNames()) do result.Icons[name]=L:GetIcon(name) end
print(game:GetService('HttpService'):JSONEncode(result))
