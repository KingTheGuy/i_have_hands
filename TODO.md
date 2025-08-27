## TODO

## DOING:

- [ ] add perms (70% sure anyone can change the allow_all settings)
- [ ] (wtf does this mean??) instead of _get_properties_ do **initial_properties**

- [ ] (was fixed?) #BUG right after loading and trying to lift inv **inv items are safe**
  > item_OnPlace(): /home/surv/.minetest/mods/i_have_hands/init.lua:266: attempt to index a nil value
  > stack traceback:[C]: ?
  > /home/surv/.minetest/mods/i_have_hands/init.lua:266: in function 'hands'
  > /home/surv/.minetest/mods/i_have_hands/init.lua:373: in function </home/surv/.minetest/mods/i_have_hands/init.lua:371>

## BACKLOG:

- [ ] make them throw-able
- [ ] add hud indicator
- [ ] pick up mobs?
- [ ] (may be over kill considering this is a chest re-locating mode)
  - add my own type of orientation fixing item?
  - I can pop open a menu and have the player orient it that way.
  - node in the center with buttons around it.
  - up,down,left,right:rotate clockwise,counter-clockwise. button
  - (open menu)sneak+punch. maybe if the player punches with the node in hand it will
    have the menu popup.. kinda like a "FUCK you, i want you placed like
    this not like that!"

- [ ] add dust particle, to play right when the chest angles back down.
- [ ] prevent switching hotbar slot
- [ ] prevent slot from being filled.
      make it so that when an inventory gets picked up a new, un fillable hot bar container gets created.
      if the player moves to another hotbar.. drop the inventory
      if when the inventory gets placed down, move over to the previous hotbar.
- [ ] somehow let the player know if a mod is interfering with this mod or just say not its not compatible
- [ ] better sound effects
- [ ] rewrite description. carry nodes & blocks that have an inventory without breaking them.
- [ ] #BUG crashes sometimes when a player spams picking up/down
- [ ] #BUG (can't be reset till the player respawns) reset the arm on death.. or whenever the chest is dropped (same logic)
- [ ] (NOPE.. there is no need for that, and it breaks things) add support for shulkers

## DONE:

- [x] change the banner image
- [.] (somewhat) add support for age of mending
- [x] fix up/ add the create_release script
- [x] add commands (help/allow_all)
- [x] play node's place sound on drop
- [x] make sounds a bit louder
- [x] furnace timer resumes
- [x] implement moving just about anything that is a container... and
      take into account it's on_place function (or what is in the timer)
- [x] add CHANGELOG file
- [x] hud_elem_type to type
- [x] have two entities main one will handle the animation
  - second one will handle displaying the *held inventory
