--DONE(prevent data loss): if object is not attached to anything add its node and set the data
--will have to use mod storage
--storage needs to store and objects
--DONE: inv to storage {owner=POS,data=metadata}

--TODO(audio and visuals): add some effects
--FIXME(issue could be that obj pos is float): dettached should appear as close as possible to the last location

local data_storage = minetest.get_mod_storage()
local obj = nil

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


local handdef = minetest.registered_items[""]
local on_place = handdef and handdef.on_place
minetest.override_item("", {
  on_place = function(itemstack, placer, pointed_thing)
    local p_pos = placer:get_pos()
    local n_pos = pointed_thing.under
    -- if placer:get_player_control()["sneak"] == true and Distance(p_pos.x,p_pos.y,p_pos.z,n_pos.x,n_pos.y,n_pos.z) < 2 then
    if placer:get_player_control()["sneak"] == true then
      -- minetest.debug(minetest.colorize("yellow", "howdy mate, ive got the shits"))

      if obj ~= nil then
        local buildable = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
        local above = pointed_thing.above
        if buildable.buildable_to == true then
          above = pointed_thing.under
        end
        local held_item_name = minetest.registered_nodes[obj:get_properties().wield_item].name
        local player_p = minetest.dir_to_fourdir(placer:get_look_dir())
        minetest.swap_node(above, { name = held_item_name, param2 = player_p })

        local meta = minetest.get_meta(above)
        local found_meta = data_storage:get_string(obj:get_luaentity().initial_pos)

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

        -- minetest.debug(minetest.colorize("gray",
        --   "ok: \n" .. dump(node_containers)))

        meta:from_table(node_containers)
        data_storage:set_string(obj:get_luaentity().initial_pos, "") --clear it
        obj:remove()
        obj = nil
      else
        if obj == nil then
          if stringContains(minetest.get_node(pointed_thing.under).name, "left") ~= nil or stringContains(minetest.get_node(pointed_thing.under).name, "right") ~= nil then
          else
            local meta = minetest.get_meta(pointed_thing.under)
            local count = 0
            for _ in pairs(meta:to_table()["inventory"]) do count = count + 1 end
            if count < 1 then
              goto done
            end
            obj = minetest.add_entity(placer:get_pos(), "i_have_hands:held")
            -- obj:set_attach(placer, "", { x = 0, y = 8.8, z = 3.2 }, { x = 0, y = math.rad(90), z = 0 },placer:get_rotation(),true)
            obj:set_attach(placer, "", { x = 0, y = 9, z = 3.2 }, { x = 0, y = math.rad(90), z = 0 },
              placer:get_rotation(), true)
            -- obj:set_attach(placer, "", { x = 0, y = 12, z = 6 }, { x = 0, y = math.rad(90), z = 0 },placer:get_rotation(),true)

            obj:set_properties({ wield_item = minetest.get_node(pointed_thing.under) })
            obj:get_luaentity().initial_pos = vector.to_string(obj:get_pos())

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

            minetest.remove_node(pointed_thing.under)
          end
        end
      end
      ::done::
    end
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
  -- visual_size = { x = 0.3, y = 0.3, z = 0.3 },
  visual_size = { x = 0.35, y = 0.35, z = 0.35 },
  _inicial_pos = "",
  on_step = function(self, dtime, moveresult)
    -- minetest.debug(minetest.colorize("cyan", "dropping: \n" .. dump(data_storage:get_keys())))
    if self.object:get_attach() == nil then
      local pos = self.object:get_luaentity().initial_pos
      -- if pos ~= nil then
      -- local node_containers = {}
      -- local data = data_storage:get_string(pos)
      -- if data ~= "" then
      --   minetest.debug("we got data")
      --   for i, v in pairs(minetest.deserialize(data)) do
      --     local found_container = {}
      --     for container, container_items in pairs(v) do
      --       local found_inv = {}
      --       if type(container_items) == "string" then
      --         found_container[container] = container_items
      --       else
      --         for slot, item in pairs(container_items) do
      --           minetest.add_item(self.object:get_pos(), item)
      --         end
      --         found_container[container] = found_inv
      --       end
      --     end
      --     node_containers[i] = found_container
      --   end
      --   minetest.debug(minetest.colorize("gray",
      --     "ok: \n" .. dump(node_containers)))
      -- end
      -- end
      self.object:remove()
    end
  end,
})

function findEmptySpace(pos, radius)
  for x = -radius, radius do
    for y = -1, 1 do -- Check one block above and below
      for z = -radius, radius do
        local checkPos = { x = pos.x + x, y = pos.y + y, z = pos.z + z }
        local node = minetest.registered_nodes[minetest.get_node(pos).name]
        if node.name == "" then
          return checkPos -- Found empty space
        end
        if node.buildable_to == true then
          return checkPos -- Found empty space
        end
      end
    end
  end
  return nil -- No empty space found within the specified radius
end

local ran_once = false
minetest.register_globalstep(function(dtime)
  if ran_once == false then
    ran_once = true
    -- minetest.debug("these are the keys: " .. dump(data_storage:get_keys()))
    for i, v in pairs(data_storage:get_keys()) do
      -- minetest.debug(minetest.colorize("cyan", dump(vector.from_string(v))))
      local pos = vector.from_string(v)

      pos = findEmptySpace(pos, 10)
      -- minetest.debug("placed at: " .. vector.to_string(pos))
      if pos == nil then
      else
        minetest.set_node(pos, minetest.deserialize(data_storage:get_string(v))["node"])
        local meta = minetest.get_meta(pos)
        meta:from_table(deserializeMetaData(minetest.deserialize(data_storage:get_string(v))["data"]))
      end

      data_storage:set_string(v, "")
    end
  end
end)
