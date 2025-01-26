# roadmap

Make it nice.

## TODO

## DOING:

--NOTE: MCL_furnace, breaks if picked up.. lets just blacklist it

- [ ] #BUG right after loading and trying to lift inv **inv items are safe**

  > item_OnPlace(): /home/surv/.minetest/mods/i_have_hands/init.lua:266: attempt to index a nil value
  > stack traceback:[C]: ?
  > /home/surv/.minetest/mods/i_have_hands/init.lua:266: in function 'hands'
  > /home/surv/.minetest/mods/i_have_hands/init.lua:373: in function </home/surv/.minetest/mods/i_have_hands/init.lua:371>

## BACKLOG:

- [ ] prevent switching hotbar slot
- [ ] prevent slot from being filled.
      make it so that when an inventory gets picked up a new, un fillable hot bar container gets created.
      if the player moves to another hotbar.. drop the inventory
      if when the inventory gets placed down, move over to the previous hotbar.
- [ ] somehow let the player know if a mod is interfering with this mod or just say not its not compatible
- [ ] smoother animations
- [ ] better sound effects
- [ ] rewrite description. carry nodes & blocks that have an inventory without breaking them.
- [ ] crashes sometimes when a player spams picking up/down

## DONE:

### 1.0.7

- [x] add a short delay to the hud popup
  - seeing the hud message constantly is not great
- [x] add support for mineclonia
- [x] don't show the hud when the player is already holding a "chest/inventory"

---

### 1.0.6

- [|] (nvm no real reason to implement this) MCL support for picking up double chests
- [x] update gif **make it look nice**
- [x] hover over in-game inventory show player hud
- [x] #BUG (this is a bad thing, the worst): on drop the node will remove any node in its way
- [x] #BUG the held inv should be dropped on death

---

- [x](prevent data loss): if object is not attached to anything add
  its node and set the data will have to use mod storage storage
  needs to store and objects
- [x]: inv to storage {owner=POS,data=metadata}
- [x]: drop/place node when the player leaves
- [x]: need to check if node has protection
- [x]: placing is eating blocks at times, need to check if node is empty
- [x]: view in first person
- [x](issue could be that obj pos is float): detached should appear as
  close as possible to the last location
- [x]_kinda_: add a fall back a node's visual is nil
- [x](audio:good enough,visual:good): add some effects
- [x]: figure out double chests
- [x]: add support for storage drawers mod
