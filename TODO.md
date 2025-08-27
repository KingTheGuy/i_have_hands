## TODO

## DOING:

- [x] make sounds a but louder
- [x] furnace timer resumes
- [x] implement moving just about anything that is a container... and
      take into account it's on_place function (or what is in the timer)
- [x] add CHANGELOG file
- [x] hud_elem_type to type
- [x] have two entities main one will handle the animation
  - second one will handle displaying the *held inventory

- [ ] (wtf does this mean??) instead of _get_properties_ do **initial_properties**

- [ ] #BUG right after loading and trying to lift inv **inv items are safe**
  > item_OnPlace(): /home/surv/.minetest/mods/i_have_hands/init.lua:266: attempt to index a nil value
  > stack traceback:[C]: ?
  > /home/surv/.minetest/mods/i_have_hands/init.lua:266: in function 'hands'
  > /home/surv/.minetest/mods/i_have_hands/init.lua:373: in function </home/surv/.minetest/mods/i_have_hands/init.lua:371>

## BACKLOG:

- [ ] add dust particle, to play right when the chest angles back down.
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
- [ ] #BUG (can't be reset till the player respawns) reset the arm on death.. or whenever the chest is dropped (same logic)

