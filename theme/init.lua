local math = math
local beautiful    = require( "beautiful"               )

local module = {
  colors_by_id = {}
}

-- Do some magic to cache the highest state
local function return_data(tab, key)
  return tab._real_table[key]
end
local function change_data(tab, key,value)
  if not value and key == rawget(tab,"_current_key") then
    -- Loop the array to find a new current_key
    local win = math.huge
    for k,v in pairs(tab._real_table) do
      if k < win and k ~= key then
        win = k
      end
    end
    rawset(tab,"_current_key",win ~= math.huge and win or nil)
  elseif value and (rawget(tab,"_current_key") or math.huge) > key then
    rawset(tab,"_current_key",key)
  end
  tab._real_table[key] = value
end
function module.init_state()
  local mt = {__newindex = change_data,__index=return_data}
  return setmetatable({_real_table={}},mt)
end

-- Util to help match colors to states
local theme_colors = {}
function module.register_color(state_id,name,beautiful_name,allow_fallback)
  theme_colors[name] = {id=state_id,beautiful_name=beautiful_name,fallback=allow_fallback}
  module.colors_by_id[state_id] = name
end
function module.setup_colors(data,args)
  local priv = data._internal.private_data
  for k,v in pairs(theme_colors) do
      priv["fg_"..k] = args["fg_"..k] or beautiful["menu_fg_"..v.beautiful_name] or beautiful["fg_"..v.beautiful_name] or (v.fallback and "#ff0000")
      priv["bg_"..k] = args["bg_"..k] or beautiful["menu_bg_"..v.beautiful_name] or beautiful["bg_"..v.beautiful_name] or (v.fallback and "#00ff00")
  end
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;