local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

core.register_chatcommand("dropinv",{
  param = "",
  -- Short parameter description.  See the below note.
  description = "Make the player drop what they are carrying.",
  -- General description of the command's purpose.
  -- privs = {},
  -- Required privileges to run. See `core.check_player_privs()` for
  -- the format and see [Privileges] for an overview of privileges.
  func = function(player_name, param)
    local player_ref = core.get_player_by_name(player_name)
    local pos = player_ref:get_pos()
    local new_pos = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
    local pointed_thing = {type="node",under=new_pos,above=new_pos}
    core.log("dropping now..")
    I_have_hands.putDownInv(player_name,pointed_thing)
  end,
})
