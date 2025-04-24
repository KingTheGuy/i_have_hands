dofile(minetest.get_modpath("i_have_hands") .. "/utils.lua")

--moving a hot furnace with just your hands.. i don't this so buddy
local RayDistance = 4;                     --this should be changed to the players reach
--invs to block
local blacklist = { "furnace", "shulker" } --if the name contains any of

local data_storage = core.get_mod_storage()

---@class Animate
---@field player table The damn player
---@field rotation integer Not sure if this is vector
---@field object table Is this a table?
---@field frame integer Not sure if frame is the correct term here
---@field item_name string This is probabliy the only thing that is correct
local to_animate = {}

---@param this_string string the string
---@param split string sub to split at
function Split(this_string, split)
  local new_word = {}
  local index = string.find(this_string, split)
  if index == nil then
    return nil
  end
  local split_index = index
  local split_start = ""
  for x = 0, split_index - 1, 1 do
    split_start = split_start .. string.sub(this_string, x, x)
  end
  new_word[1] = split_start

  local split_end = ""
  for x = split_index + #split, #this_string, 1 do
    split_end = split_end .. string.sub(this_string, x, x)
  end
  new_word[2] = split_end
  return new_word
end

local function placeDown(placer, rot, obj, above, frame, held_item_name)
  table.insert(to_animate,
    { player = placer, rot = rot, obj = obj, pos = above, frame = frame, item = held_item_name })
end

local function quantize_direction(yaw)
  local angle = math.deg(yaw) % 360 -- Convert yaw to degrees and get its modulo 360
  if angle < 45 or angle >= 315 then
    return math.rad(0)              -- Facing North
  elseif angle >= 45 and angle < 135 then
    return math.rad(90)             -- Facing East
  elseif angle >= 135 and angle < 225 then
    return math.rad(180)            -- Facing South
  else
    return math.rad(270)            -- Facing West
  end
end

--object, pos, frame
--not in use atm
local function animatePlace()
  for i, v in pairs(to_animate) do
    if v.frame == 0 then
      v.obj:set_detach()
      v.obj:set_yaw(v.rot)
      local obj_rot = v.obj:get_rotation()
      v.obj:set_rotation({ x = math.rad(-20), y = obj_rot.y, z = obj_rot.z })
      v.obj:set_properties({ visual_size = { x = 0.5, y = 0.5, z = 0.5 } })
      v.obj:set_pos(v.pos)
      v.obj:set_properties({ pointable = true })
      core.sound_play({ name = "i_have_hands_pickup_node" }, { pos = v.pos, pitch = 0.7 }, true)
    end
    if v.frame == 1 then
      local obj_rot = v.obj:get_rotation()
      v.obj:set_rotation({ x = math.rad(0), y = obj_rot.y, z = obj_rot.z })
      v.obj:set_properties({ visual_size = { x = 0.6, y = 0.6, z = 0.6 } })
    end
    if v.frame == 2 then
      v.obj:set_properties({ visual_size = { x = 0.65, y = 0.65, z = 0.65 } })
    end
    if v.frame == 1 then
      local found_meta = data_storage:get_string(v.obj:get_luaentity().initial_pos)
      data_storage:set_string(v.obj:get_luaentity().initial_pos, "") --clear it
      core.set_node(v.pos, { name = v.item, param2 = core.dir_to_fourdir(core.yaw_to_dir(v.rot)) })
      core.sound_play({ name = "i_have_hands_place_down_node" }, { pos = v.pos }, true)
      local meta = core.get_meta(v.pos)

      local node_containers = {}
      for i, v in pairs(core.deserialize(found_meta)["data"]) do
        local found_container = {}
        for container, container_items in pairs(v) do
          local found_inv = {}
          if type(container_items) == "string" then
            found_container[container] = container_items
          else
            for slot, item in pairs(container_items) do
              found_inv[slot] = item
            end
            found_container[container] = found_inv
          end
        end
        node_containers[i] = found_container
      end
      meta:from_table(node_containers)

      --NOTE(COMPAT): this adds support for the storage_drawers mod
      if core.get_modpath("drawers") and drawers then
        drawers.spawn_visuals(v.pos)
      end
      --NOTE(COMPAT): pipeworks update pipe, on place down
      if core.get_modpath("pipeworks") and pipeworks then
    		pipeworks.after_place(v.pos)
      end
    end
    v.frame = v.frame + 1
    if v.frame >= 6 then
      v.obj:remove()
      v.obj = nil
      table.remove(to_animate, i)
    end
  end
end

---@param pos table
---@param user table
---@return boolean
local function checkProtection(pos, user)
  local protected = core.is_protected(pos, user:get_player_name())
  local owner = core.get_meta(pos):get_string("owner")
  local player_name = user:get_player_name()
  if owner ~= "" then
    if owner ~= player_name then
      core.chat_send_player(player_name, core.colorize("pink", "You are not the owner."))
      return true
    end
  end
  if protected then
    core.chat_send_player(player_name, core.colorize("pink", "This is protected"))
    return true
  end
  return false
end

local function isInventory(meta)
  local count = 0
  for _ in pairs(meta:to_table()["inventory"]) do count = count + 1 end
  if count < 1 then --inve have a value of 1 or greater
    return false
  end
  return true
end

local function isBlacklisted(pos)
  for _, v in ipairs(blacklist) do
    if utils.StringContains(core.get_node(pos).name, v) then
      return true
    end
  end
  return false
end

local function find_empty_position(pos, radius)
  local x, y, z = pos.x, pos.y, pos.z
  local found = false
  local empty_pos = nil

  for r = 0, radius do
    for a = 0, 360, 10 do
      local dx = math.floor(r * math.cos(math.rad(a)))
      local dz = math.floor(r * math.sin(math.rad(a)))
      local nx, nz = x + dx, z + dz
      local ny = y

      while ny < 100 and not found do
        local node = minetest.get_node({ x = nx, y = ny, z = nz })
        if node.name == "air" then
          empty_pos = { x = nx, y = ny, z = nz }
          found = true
        end
        ny = ny + 1
      end
    end
  end

  return empty_pos
end

local handdef = core.registered_items[""]
local on_place = handdef and handdef.on_place

local function hands(itemstack, placer, pointed_thing)
  local contains = false
  if placer:get_player_control()["sneak"] == true then
    -- core.debug("what is this?",core.get_node(pointed_thing.under).name)
    -- core.debug(string.format("location: %s", dump(core.get_modpath("drawers"))))
    -- core.debug(core.colorize("yellow", "howdy mate, ive got the shits"))
    if #placer:get_children() > 0 then --this is getting all connect objects
      for index, obj in pairs(placer:get_children()) do
        -- core.debug(dump(obj:get_luaentity().name))
        -- core.debug("got something: "..obj.name)
        -- end
        -- for index, value in pairs(placer:get_children()) do
        local above = pointed_thing.above
        -- core.debug("node: "..core.get_node(above).name)
        if checkProtection(above, placer) == false then
          if obj:get_luaentity().name == "i_have_hands:held" then
            contains = true
            -- core.debug("ok: "..type(held).."-"..held.."-")
            local try_inside = core.registered_nodes[core.get_node(pointed_thing.under).name]
            -- core.debug("buildabled? ",try_inside.buildable_to)
            if core.get_node(above).name ~= "air" then
              -- if core.get_node(above).name == "water" then
              if utils.StringContains(core.get_node(above).name, "water") then
                --do nothing
              else
                return itemstack
              end
            end
            if #core.get_objects_inside_radius(above, 0.5) > 0 then
              return itemstack
            end
            if try_inside.buildable_to == true then
              above = pointed_thing.under
            end


            local held_item_name = core.registered_nodes[obj:get_properties().wield_item].name
            -- local player_p = core.dir_to_fourdir(placer:get_look_dir())
            -- obj:set_pos(above)
            -- animatePlace(obj,above)

            -- table.insert(to_animate,
            --   { player = placer, rot = rot, obj = obj, pos = above, frame = 0, item = held_item_name })
            local rot = quantize_direction(placer:get_look_horizontal())
            placeDown(placer, rot, obj, above, 0, held_item_name)
          end
        end
      end
    end

    if contains == false then
      local is_blacklisted = false

      if isBlacklisted(pointed_thing.under) then
        is_blacklisted = true
      end
      if is_blacklisted == false then
        if checkProtection(pointed_thing.under, placer) then
          return itemstack
        end
        local meta = core.get_meta(pointed_thing.under)
        if isInventory(meta) == false then
          return itemstack
        end
        local obj = core.add_entity(placer:get_pos(), "i_have_hands:held")
        obj:set_attach(placer, "", { x = 0, y = 9, z = 3.2 }, { x = 0, y = math.rad(90), z = 0 }, true)
        --NOTE: attaching to the head just does not look very good, so lets not do that.
        -- obj:set_attach(placer, "Head", { x = 0, y = -2, z = -3.2 }, { x = 0, y = math.rad(90), z = 0 }, true)
        obj:set_properties({
          wield_item = core.registered_nodes[core.get_node(pointed_thing.under).name]
              .name
        })
        obj:get_luaentity().initial_pos = vector.to_string(obj:get_pos())

        --NOTE(COMPAT): this takes care of voxelibre chests
        if utils.StringContains(core.registered_nodes[core.get_node(pointed_thing.under).name].name, "mcl_chests") then
          obj:set_properties({ wield_item = "mcl_chests:chest" })
        end

        -- core.debug(core.colorize("yellow",dump(core.registered_nodes[core.get_node(pointed_thing.under).name])))
        -- core.debug(core.colorize("blue", "all: \n" .. dump(meta:to_table())))
        local node_containers = {}
        for i, v in pairs(meta:to_table()) do
          local found_container = {}
          for container, container_items in pairs(v) do
            local found_inv = {}
            if type(container_items) == "table" then
              for slot, item in pairs(container_items) do
                table.insert(found_inv, slot, item:to_string())
              end
              found_container[container] = found_inv
            else
              found_container[container] = container_items
            end
          end
          node_containers[i] = found_container
        end
        local full_data = { node = core.get_node(pointed_thing.under), data = node_containers }
        -- core.debug("full_data: ".. dump(full_data.data))

        local pos = vector.to_string(obj:get_pos())
        data_storage:set_string(pos, core.serialize(full_data))
        obj:get_luaentity().initial_pos = pos
        -- placer:get_meta():set_string("obj_obj",core.write_json(obj))
        core.remove_node(pointed_thing.under)
        core.sound_play({ name = "i_have_hands_pickup_node" }, { pos = pointed_thing.under }, true)

        --NOTE(COMPAT): pipeworks update pipe, on pickup
        if core.get_modpath("pipeworks") and pipeworks then
          pipeworks.after_place(pointed_thing.under)
        end

        -- core.sound_play({ name = "i_have_hands_pickup" }, { pos = pointed_thing.under,gain = 0.1}, true)
      end
    end
  end
  --you know, return itemstack
end

-- local original_on_place = minetest.registered_items[""].on_place

core.override_item("", {
  on_place = function(itemstack, placer, pointed_thing)
    itemstack = on_place(itemstack, placer, pointed_thing)
    hands(itemstack, placer, pointed_thing)

    -- Call the original on_place function if it exists
    -- if original_on_place then
    --   return original_on_place(itemstack, placer, pointed_thing)
    -- end
    return itemstack
  end,
  -- on_secondary_use = function(itemstack, placer, pointed_thing)
  --   hands(itemstack, placer, pointed_thing)
  -- end
})

--check if the player is holding an inventory
local function isHolding(player)
  if #player:get_children() > 0 then    --this is getting all connect objects
    for index, obj in pairs(player:get_children()) do
      if obj:get_luaentity().name == "i_have_hands:held" then
        -- core.debug("this dude is holding")
        return true
      end
      -- core.debug("nope not holding")
      return false
    end
  end
  return false
end

core.register_entity("i_have_hands:held", {
  selectionbox = { -0.0, -0.0, -0.0, 0.0, 0.0, 0.0, rotate = false },
  pointable = false,
  physical = false,
  collide_with_objects = false,
  visual = "item",
  wield_item = "",
  visual_size = { x = 0.35, y = 0.35, z = 0.35 },
  _initial_pos = "",
  on_step = function(self, dtime, moveresult)
    -- core.debug(core.colorize("cyan", "dropping: \n" .. dump(data_storage:get_keys())))

    if self.object:get_attach() == nil then
      local contains = false
      for i, v in pairs(to_animate) do
        if v.obj == self.object then
          -- core.debug("should not delete this yet")
          contains = true
        end
      end
      if contains == false then
        local pos = self.object:get_luaentity().initial_pos
        for i, v in pairs(data_storage:get_keys()) do
          if v == pos then
            core.set_node(vector.from_string(pos), core.deserialize(data_storage:get_string(v))["node"])
            local meta = core.get_meta(vector.from_string(pos))
            meta:from_table(utils.DeserializeMetaData(core.deserialize(data_storage:get_string(v))["data"]))
            data_storage:set_string(v, "")
          end
        end
        self.object:remove()
      end
    end

    --updute pos and data
    if self.object:get_luaentity() then
      if self.object:get_luaentity().initial_pos ~= nil then
        local pos = self.object:get_luaentity().initial_pos
        local data = data_storage:get_string(pos)
        data_storage:set_string(pos)
        self.object:get_luaentity().initial_pos = vector.to_string(self.object:get_pos())
        data_storage:set_string(vector.to_string(self.object:get_pos()), data)
      end
    end
  end,
})

local player_hud_id = {}

local function getPlayerFromPlayerHuds(player_name)
  for _, ph in ipairs(player_hud_id) do
    if ph.player_name == player_name then
      return ph
    end
  end
  return nil
end

local function getPlayerHud(player_name)
  -- core.debug("player_huds are " .. #player_hud_id .. " in length.")
  for _, ph in ipairs(player_hud_id) do
    if ph.player_name == player_name then
      if ph.player_hud == nil then return nil end
      return ph.player_hud
    end
  end
end

local function removePlayerHud(player)
  local hud_id = getPlayerHud(player:get_player_name())
  if hud_id ~= nil then
    player:hud_remove(hud_id)
    for index, ph in ipairs(player_hud_id) do
      if ph.player_name == player:get_player_name() then
        table.remove(player_hud_id, index)
      end
    end
  end
end

--FIXME: only raycast if the player's "hand" is empty (no need to cast when the player cant event pick it up to start with)
local function raycast()
  local player = core.get_connected_players()
  if #player > 0 then
    for _, p in ipairs(player) do
      local eye_height = p:get_properties().eye_height
      local player_look_dir = p:get_look_dir()
      local pos = p:get_pos():add(player_look_dir)
      local player_pos = { x = pos.x, y = pos.y + eye_height, z = pos.z }
      local new_pos = p:get_look_dir():multiply(RayDistance):add(player_pos)
      local raycast_result = core.raycast(player_pos, new_pos, false, false):next()
      if isHolding(p) then
        removePlayerHud(p)
        return
      end

      local hud_id = nil; --FIXME this need to be added to list of all player HUDS
      if raycast_result then
        local pointed_node = core.get_node(raycast_result.under)
        if isBlacklisted(raycast_result.under) then
          removePlayerHud(p)
          return
        end
        if p:get_wielded_item():get_name() ~= "" then
          removePlayerHud(p)
          return
        end
        if isInventory(core.get_meta(raycast_result.under)) then
          hud_id = getPlayerHud(p:get_player_name())
          local player_with_hud = getPlayerFromPlayerHuds(p:get_player_name())
          if player_with_hud == nil then
            local this_players_hud = { player_name = p:get_player_name(), player_hud = hud_id , hud_delay = 6, chest_location = raycast_result.under}
            table.insert(player_hud_id, this_players_hud)
          else
            -- core.debug("what do we have here? "..player_with_hud.hud_delay)
            if player_with_hud.hud_delay == 0 then
              if hud_id == nil then
                hud_id = p:hud_add({
                  hud_elem_type = "text",
                  position = { x = 0.5, y = 0.6 },
                  direction = 0,
                  name = "ihh",
                  scale = { x = 1, y = 1 },
                  -- text = "crouch & interact to lift this",
                  text = "Carry: crouch & interact",
                  number = "0xFFFFFF",
                  z_index = 0,
                })
              end
              player_with_hud.player_hud = hud_id
            end
            if player_with_hud.chest_location ~= raycast_result.under then
              removePlayerHud(p)
            end
          end
          -- core.debug("so wtf is this then? " .. tostring(hud_id))
        else
          removePlayerHud(p)
        end
        -- core.debug(string.format("what is this?",core.registered_nodes[pointed_node].name))
      else
        removePlayerHud(p)
      end
    end
  end
end

local function hotbarSlotNotEmpty()
  local player = core.get_connected_players()
  if #player > 0 then
    for _, p in ipairs(player) do
      if p:get_wielded_item():get_name() ~= "" then
        if #p:get_children() > 0 then   --this is getting all connect objects
          for index, obj in pairs(p:get_children()) do
            if obj:get_luaentity().name == "i_have_hands:held" then
              local held_item_name = core.registered_nodes[obj:get_properties().wield_item].name
              placeDown(p, 0, obj, find_empty_position(p:get_pos(), 10), 0, held_item_name)
            end
          end
        end
      end
    end
  end
end

local function tickHudDelay()
    for _,h in pairs(player_hud_id) do
      if h.hud_delay > 0 then
        h.hud_delay = h.hud_delay - 1
      end
    end
end


local ran_once = false
local tick = 0
core.register_globalstep(function(dtime)
  -- raycast()
  tick = tick + 0.5
  if tick > 2 then
    animatePlace()
    raycast()
    hotbarSlotNotEmpty()
    tickHudDelay()
    tick = 0
  end
  if ran_once == false then
    ran_once = true
    for i, v in pairs(data_storage:get_keys()) do
      local pos = vector.from_string(v)
      core.set_node(pos, core.deserialize(data_storage:get_string(v))["node"])
      local meta = core.get_meta(pos)
      meta:from_table(utils.DeserializeMetaData(core.deserialize(data_storage:get_string(v))["data"]))
      data_storage:set_string(v, "")
    end
  end
end)


core.register_on_dieplayer(function(ObjectRef, reason)
  if #ObjectRef:get_children() > 0 then --this is getting all connect objects
    for index, obj in pairs(ObjectRef:get_children()) do
      if obj:get_luaentity().name == "i_have_hands:held" then
        local held_item_name = core.registered_nodes[obj:get_properties().wield_item].name
        placeDown(ObjectRef, 0, obj, find_empty_position(ObjectRef:get_pos(), 10), 0, held_item_name)
      end
    end
  end
  -- core.debug("what death? " .. ObjectRef:get_player_name())
end)
