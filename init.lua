--DONE(prevent data loss): if object is not attached to anything add its node and set the data
--will have to use mod storage
--storage needs to store and objects
--DONE: inv to storage {owner=POS,data=metadata}
--DONE: drop/place node when the player leaves
--DONE: need to check if node has protection
--DONE: placing is eating blocks at times, need to check if node is empty
--DONE: view in first person
--DONE(issue could be that obj pos is float): dettached should appear as close as possible to the last location
--DONE(kinda): add a fall back a node's visual is nil
--DONE(audio:good enough,visual:good): add some effects
--DONE: figure out double chests

--FIXME(this is a bad thing, the worst): on drop the node will remove any node in its way
--======--

local data_storage = minetest.get_mod_storage()

function Distance(x1, y1, z1, x2, y2, z2)
  local dx = x2 - x1
  local dy = y2 - y1
  local dz = z2 - z1
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function stringContains(str, find)
  str = string.upper(str)
  find = string.upper(find)
  local i, _ = string.find(str, find)
  return i
end

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

local function serializeMetaData(data)
  local node_containers = {}
  for i, v in pairs(data:to_table()) do
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
  return minetest.serialize(node_containers)
end

local function deserializeMetaData(data)
  local node_containers = {}
  for i, v in pairs(data) do
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
  return node_containers
end

local function quantize_direction(yaw)
  local angle = math.deg(yaw) % 360 -- Convert yaw to degrees and get its modulo 360
  if angle < 45 or angle >= 315 then
    return math.rad(0)             -- Facing North
  elseif angle >= 45 and angle < 135 then
    return math.rad(90)            -- Facing East
  elseif angle >= 135 and angle < 225 then
    return math.rad(180)           -- Facing South
  else
    return math.rad(270)           -- Facing West
  end
end

--object, pos, frame
--not in use atm
local to_animate = {}
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
      minetest.sound_play({ name = "i_have_hands_pickup_node" }, { pos = v.pos , pitch = 0.7}, true)
    end
    if v.frame == 1 then
      local obj_rot = v.obj:get_rotation()
      v.obj:set_rotation({ x = math.rad(0), y = obj_rot.y, z = obj_rot.z })
      v.obj:set_properties({ visual_size = { x = 0.6, y = 0.6, z = 0.6 } })
    end
    if v.frame == 2 then
      v.obj:set_properties({ visual_size = { x = 0.65, y = 0.65, z = 0.65 } })
    end
    if v.frame == 3 then
      local found_meta = data_storage:get_string(v.obj:get_luaentity().initial_pos)
      data_storage:set_string(v.obj:get_luaentity().initial_pos, "") --clear it
      minetest.set_node(v.pos, { name = v.item, param2 = minetest.dir_to_fourdir(minetest.yaw_to_dir(v.rot)) })
      minetest.sound_play({ name = "i_have_hands_place_down_node" }, { pos = v.pos }, true)
      local meta = minetest.get_meta(v.pos)

      local node_containers = {}
      for i, v in pairs(minetest.deserialize(found_meta)["data"]) do
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
  local protected = minetest.is_protected(pos, user:get_player_name())
  local owner = minetest.get_meta(pos):get_string("owner")
  local player_name = user:get_player_name()
  if owner ~= "" then
    if owner ~= player_name then
      minetest.chat_send_player(player_name, minetest.colorize("pink", "You are not the owner."))
      return true
    end
  end
  if protected then
    minetest.chat_send_player(player_name, minetest.colorize("pink", "This is protected"))
    return true
  end
  return false
end


local handdef = minetest.registered_items[""]
local on_place = handdef and handdef.on_place
minetest.override_item("", {
  on_place = function(itemstack, placer, pointed_thing)
    local contains = false
    if placer:get_player_control()["sneak"] == true then
      -- minetest.debug(minetest.colorize("yellow", "howdy mate, ive got the shits"))
      if #placer:get_children() > 0 then
        for index, obj in pairs(placer:get_children()) do
          -- minetest.debug(dump(obj:get_luaentity().name))
          -- minetest.debug("got something: "..obj.name)
          -- end
          -- for index, value in pairs(placer:get_children()) do
          local above = pointed_thing.above
          -- minetest.debug("node: "..minetest.get_node(above).name)
          if checkProtection(above, placer) then
            goto done
          end
          if obj:get_luaentity().name == "i_have_hands:held" then
            contains = true
            -- minetest.debug("ok: "..type(held).."-"..held.."-")
            local buildable = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
            if buildable.buildable_to == true then
              above = pointed_thing.under
            end
            if minetest.get_node(above).name ~= "air" then
              goto done
            end
            if #minetest.get_objects_inside_radius(above, 0.5) > 0 then
              goto done
            end


            local held_item_name = minetest.registered_nodes[obj:get_properties().wield_item].name
            -- local player_p = minetest.dir_to_fourdir(placer:get_look_dir())
            -- obj:set_pos(above)
            -- animatePlace(obj,above)
            local rot = quantize_direction(placer:get_look_horizontal())
            table.insert(to_animate, { player = placer,rot=rot, obj = obj, pos = above, frame = 0, item = held_item_name })

          end
        end
      end
      if contains == false then
        if stringContains(minetest.get_node(pointed_thing.under).name, "furnace") ~= nil or
            -- stringContains(minetest.get_node(pointed_thing.under).name, "right") ~= nil or
            -- stringContains(minetest.get_node(pointed_thing.under).name, "left") ~= nil or
            stringContains(minetest.get_node(pointed_thing.under).name, "shulker") ~= nil
        then
        else
          if checkProtection(pointed_thing.under, placer) then
            goto done
          end
          local meta = minetest.get_meta(pointed_thing.under)
          local count = 0
          for _ in pairs(meta:to_table()["inventory"]) do count = count + 1 end
          if count < 1 then
            goto done
          end
          local obj = minetest.add_entity(placer:get_pos(), "i_have_hands:held")
          obj:set_attach(placer, "", { x = 0, y = 9, z = 3.2 }, { x = 0, y = math.rad(90), z = 0 }, true)
          obj:set_properties({ wield_item = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name].name })
          obj:get_luaentity().initial_pos = vector.to_string(obj:get_pos())

          if stringContains(minetest.registered_nodes[minetest.get_node(pointed_thing.under).name].name, "mcl_chests") then
            obj:set_properties({ wield_item = "mcl_chests:chest" })
          end
          -- minetest.debug(minetest.colorize("yellow",dump(minetest.registered_nodes[minetest.get_node(pointed_thing.under).name])))
          -- minetest.debug(minetest.colorize("blue", "all: \n" .. dump(meta:to_table())))
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
          local full_data = { node = minetest.get_node(pointed_thing.under), data = node_containers }

          local pos = vector.to_string(obj:get_pos())
          data_storage:set_string(pos, minetest.serialize(full_data))
          obj:get_luaentity().initial_pos = pos
          -- placer:get_meta():set_string("obj_obj",minetest.write_json(obj))
          minetest.remove_node(pointed_thing.under)
          minetest.sound_play({ name = "i_have_hands_pickup_node" }, { pos = pointed_thing.under }, true)
          -- minetest.sound_play({ name = "i_have_hands_pickup" }, { pos = pointed_thing.under,gain = 0.1}, true)
        end
      end
    end
    ::done::
    itemstack = on_place(itemstack, placer, pointed_thing)
    return itemstack
  end,
})

minetest.register_entity("i_have_hands:held", {
  selectionbox = { -0.0, -0.0, -0.0, 0.0, 0.0, 0.0, rotate = false },
  pointable = false,
  physical = false,
  collide_with_objects = false,
  visual = "item",
  wield_item = "",
  visual_size = { x = 0.35, y = 0.35, z = 0.35 },
  _initial_pos = "",
  on_step = function(self, dtime, moveresult)
    -- minetest.debug(minetest.colorize("cyan", "dropping: \n" .. dump(data_storage:get_keys())))

    if self.object:get_attach() == nil then
      local contains = false
      for i, v in pairs(to_animate) do
        if v.obj == self.object then
          -- minetest.debug("should not delete this yet")
          contains = true
        end
      end
      if contains == false then
        local pos = self.object:get_luaentity().initial_pos
        for i, v in pairs(data_storage:get_keys()) do
          if v == pos then
            minetest.set_node(vector.from_string(pos), minetest.deserialize(data_storage:get_string(v))["node"])
            local meta = minetest.get_meta(vector.from_string(pos))
            meta:from_table(deserializeMetaData(minetest.deserialize(data_storage:get_string(v))["data"]))
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

local function findNearestPosition(pos)
  local search_radius = 30 -- Adjust the search radius as needed
  local min_distance = math.huge
  local nearest_pos = pos

  for dx = -search_radius, search_radius do
    for dy = -search_radius, search_radius do
      for dz = -search_radius, search_radius do
        local new_pos = vector.add(pos, { x = dx, y = dy, z = dz })
        local node = minetest.get_node(new_pos)
        local node_above = minetest.get_node(vector.add(new_pos, { x = 0, y = 1, z = 0 }))
        if node_above.name == "air" then
          -- minetest.debug(string.format("%s:%s:%s",node.name,node_below.name,node_below_below.name))
          local distance = vector.distance(pos, new_pos)
          if distance < min_distance then
            min_distance = distance
            nearest_pos = node_above
          end
        end
      end
    end
  end

  return nearest_pos
end

local ran_once = false
local tick = 0
minetest.register_globalstep(function(dtime)
  tick = tick + 0.5
  if tick > 2 then
    animatePlace()
    tick = 0
  end
  if ran_once == false then
    ran_once = true
    for i, v in pairs(data_storage:get_keys()) do
      local pos = vector.from_string(v)
      minetest.set_node(pos, minetest.deserialize(data_storage:get_string(v))["node"])
      local meta = minetest.get_meta(pos)
      meta:from_table(deserializeMetaData(minetest.deserialize(data_storage:get_string(v))["data"]))
      data_storage:set_string(v, "")
    end
  end
end)
