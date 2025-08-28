dofile(minetest.get_modpath("i_have_hands") .. "/utils.lua")

-- TODO:plan on adding a formspec menu for settings

--- formspec
core.register_chatcommand("ihh", {
  params = "[ help | allow_all ]",
  description = "global settings for i_have_hands mod",
  privs = {ihh_global=true},
  func = function(name, param)
    -- core.log("player: "..name.." cmd: "..param)
    if param == nil then
      return
    end
    local fields = utils.Split(param, " ")
    local msg = "[ihh] "
    if fields[1] == "help" then
      msg = msg .. "commands are: help, allow_all"
    elseif fields[1] == "allow_all" then
      if fields[2] == nil then
        Allow_all = not Allow_all
      else
        Allow_all = fields[2]
      end
      if Allow_all == true then
        msg = msg .. "You can pickup just about every block/node"
      else
        msg = msg .. "Can only pickup most blocks/nodes that have an inventory"
      end
    else
      msg = msg .. "commands are: help, allow_all"
    end
    core.chat_send_player(name, core.colorize("YELLOW", msg))
  end
})

core.register_privilege("ihh_global", "set global settings for i_have_hands")
