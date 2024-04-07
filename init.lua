--gloabl options
--idea, chisel to make it so you dont have to craft stairs
--craft stone into bits.. than can then be used in a mneu to choose to place
--stairs,slabs,walls,etc
--maybe have the player place the full block in the item's inv and when it
--gets used it will instead place the block it's self or what other type they selected
--have the item update to show both the "chisel" and selected block

--FIXME: not sure why but, the held distance decreases when holding something
--TODO(prevent data loss): if object is not attached to anything add its node and set the data
--will have to use mod storage
--storage needs to store and objects
--DONE: inv to storage {owner=POS,data=metadata}
--TODO: when dropping inv remove data from storage
--TODO: on restart if object is not attached load from storage and place it down in world with its metadata

local data_storage = minetest.get_mod_storage()

local RayDistance = 1 -- Adjust as needed

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

-- minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
--   -- if placer:get_player_control()["sneak"] == true then
--     minetest.debug(minetest.colorize("yellow","howdy mate, ive got the shits"))
--   -- end
-- end)
-- local hand = minetest.registered_items[""]


local handdef = minetest.registered_items[""]
local on_place = handdef and handdef.on_place
minetest.override_item("", {
  on_place = function(itemstack, placer, pointed_thing)
    -- local range = minetest.registered_nodes[itemstack.name].range
    -- minetest.debug(minetest.colorize("yellow", dump(itemstack:get_definition())))
    if placer:get_player_control()["sneak"] == true then
      minetest.debug(minetest.colorize("yellow", "howdy mate, ive got the shits"))

      if obj ~= nil then
        local buildable = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
        local above = pointed_thing.above
        if buildable.buildable_to == true then
          above = pointed_thing.under
        end
        local held_item_name = minetest.registered_nodes[obj:get_properties().wield_item].name
        minetest.swap_node(above, { name = held_item_name })

        local meta = minetest.get_meta(above)
        -- local found_meta = data_storage:get_string(obj:get_properties().nametag)
        local found_meta = data_storage:get_string(dump(obj))

        -- minetest.debug(minetest.colorize("yellow",
        --   "meta: \n" .. dump(meta:to_table())))

        minetest.debug(minetest.colorize("cyan",
          "not yet clean: \n" .. dump(minetest.deserialize(found_meta))))

        local deserialized_inv = {}
        for i, v in pairs(minetest.deserialize(found_meta)["inventory"]) do
          -- minetest.debug(minetest.colorize("yellow",
          --   "found: \n" .. i .. ":" .. dump(v)))
          for section_index, section in pairs(v) do
            local part = {}
            -- minetest.debug(minetest.colorize("cyan",
            --   "found: \n" .. section_index .. ":" .. dump(section)))
            for slot, item in pairs(section) do
              -- minetest.debug(minetest.colorize("pink",
              --   "found: \n" .. slot .. ":" .. dump(minetest.deserialize(item))))
              local item_string = minetest.deserialize(item)
              table.insert(part, slot, item_string)
              -- ItemStack(item_string)
              --NOTE: i now have the item
            end
            -- table.insert(deserialized_inv, { [section_index] = part })
            deserialized_inv[section_index] = part
          end
        end

        minetest.debug(minetest.colorize("gray",
          "found: \n" .. dump(deserialized_inv)))

        meta:from_table({
          inventory = deserialized_inv,
          fields = meta["fields"],
        })

        data_storage:set_string(dump(obj), "") --clear it

        -- local deserialized_inv = {}
        -- minetest.debug(minetest.colorize("magenta", dump(minetest.deserialize(found_meta)["inventory"])))
        -- for i, v in pairs(minetest.deserialize(found_meta)) do
        --   -- minetest.debug(minetest.colorize("cyan",
        --   --   "found: \n" .. i))
        --   local inv_section = {}
        --   for slot, item in pairs(v) do
        --     table.insert(inv_section,{[slot] = minetest.deserialize(dump(item))})
        --     minetest.debug(minetest.colorize("cyan", type(item).." "..minetest.deserialize(dump(item))))
        --     end
        --   table.insert(deserialized_inv, inv_section)
        -- end
        -- minetest.debug(minetest.colorize("pink", dump(deserialized_inv)))

        obj:remove()
        obj = nil
      else
        if obj == nil then
          local meta = minetest.get_meta(pointed_thing.under)
          -- minetest.debug(minetest.colorize("yellow", "\n" .. dump(meta:to_table())))
          local count = 0
          for _ in pairs(meta:to_table()["inventory"]) do count = count + 1 end
          if count < 1 then
            --DOES NOT HAVE AN INVENTORY
            goto done
          end
          obj = minetest.add_entity(placer:get_pos(), "i_have_hands:held")
          obj:set_attach(placer, "", { x = 0, y = 8.8, z = 3.2 }, { x = 0, y = math.rad(90), z = 0 })
          -- obj:set_attach(p, "", { x = 0, y = 10.8, z = 4.2 }, { x = 0, y = math.rad(90), z = 0 })
          -- obj:set_attach(p, "", { x = 0, y = 10.5, z = -3 }, { x = 0, y = math.rad(90), z = 0 })

          obj:set_properties({ wield_item = minetest.get_node(pointed_thing.under) })

          --TODO: name the object with a uuid or by how many entries are in storage
          --then on load have object search for their name in the storage and grab the data there to then place spawn it on the floor
          --ON DETACH

          -- local formatted_table = {}
          -- minetest.debug(minetest.colorize("cyan",dump(obj:get_id())))
          -- for i, v in pairs(meta:to_table()) do
          --   minetest.debug(string.format("[%s] -> %s", i, v))
          -- end

          --TODO: i need to pass all of it not just inventory

          minetest.debug(minetest.colorize("blue", "all: \n"..dump(meta:to_table())))

          --all the invs with the node
          local node_inventory = {}
          for i, v in pairs(meta:to_table()["inventory"]) do
            -- minetest.debug(string.format("[%s] -> %s",i,v))
            -- minetest.debug(dump(v:to_table()))
            --each inv container
            -- minetest.debug(minetest.colorize("gold", i))
            local found_inv = {}
            -- table.insert(,"inventory",)
            for slot, item in pairs(v) do
              -- table.insert(found_inv, slot, minetest.serialize(item:to_table()))
              table.insert(found_inv, slot, minetest.serialize(item:to_string()))
              -- minetest.debug(minetest.colorize("red",dump(item:to_table())))
            end
            table.insert(node_inventory, { [i] = found_inv })
          end


          minetest.debug(minetest.colorize("pink", dump(node_inventory)))
          obj:set_properties({ nametag = placer:get_player_name() .. 0 })
          -- data_storage:set_string(obj:get_properties().nametag, minetest.serialize({ inventory = node_inventory }))
          data_storage:set_string(dump(obj), minetest.serialize({ inventory = node_inventory }))

          -- local ok = minetest.write_json(dump(meta:to_table()))
          -- minetest.debug(ok)

          -- data_storage:set_string(obj:get_properties().nametag, ok)

          -- data_storage:set_string(obj:get_properties().nametag, minetest.serialize(meta))

          -- minetest.debug(minetest.parse_json(data_storage:get_string(obj:get_properties().nametag)))
          -- minetest.debug(minetest.colorize("magenta",
          --   "saving: \n" .. dump(meta_table)))

          -- obj:get_luaentity().metadata = meta_table

          minetest.remove_node(pointed_thing.under)
        end
      end
      ::done::
    end
    itemstack = on_place(itemstack, placer, pointed_thing)
    return itemstack
  end,
})

-- minetest.override_item("", {
--   on_place = function(itemstack, placer, pointed_thing)
--     if placer:get_player_control()["sneak"] == true then
--       minetest.debug(minetest.colorize("yellow","howdy mate, ive got the shits"))
--     end
--   end,
-- })


minetest.register_entity("i_have_hands:held", {
  selectionbox = { -0.0, -0.0, -0.0, 0.0, 0.0, 0.0, rotate = false },
  pointable = false,
  physical = false,
  collide_with_objects = false,
  visual = "item",
  wield_item = "",
  -- visual_size = { x = 0.3, y = 0.3, z = 0.3 },
  visual_size = { x = 0.3, y = 0.3, z = 0.3 },
  _metadata = {},
  on_activate = function(self, staticdata, dtime_s)
    -- local meta = self._metadata
    -- minetest.debug("obj_data: " .. dump(meta))
  end,

})

minetest.register_on_joinplayer(function(ObjectRef, last_login)
  --load detached invs when a player joins
  -- minetest.debug(minetest.colorize("gold", dump(data_storage:to_table())))
  -- if #data_storage:to_table() < 1 then
  --   else
  -- minetest.debug(minetest.colorize("gold", minetest.parse_json(dump(data_storage:to_table()))))
  -- end
  -- for x=0,#data_storage,1 do
  --   minetest.debug(minetest.colorize("magenta",data_storage[x]))
  -- end
end)

-- minetest.register_globalstep(function(dtime)
--   perform_raycast()
--   if cool_down > 0 then
--     cool_down = cool_down - 1
--   end
-- end)
