## TODO

## DOING:

- [ ] #LUANTI I_have_hands: sometimes crashes when placing down -> ++
  - funky stuff seems to happen when the player drops INV node in protected area (switches hotbar or item gets in hotbar slot)
  - ^^ can be fixed by adding an item to hold hotbar slot

- [ ] (wtf does this mean??) instead of _get_properties_ do **initial_properties**
- [ ] (was fixed?) #BUG right after loading and trying to lift inv **inv items are safe**
  > item_OnPlace(): /home/surv/.minetest/mods/i_have_hands/init.lua:266: attempt to index a nil value
  > stack traceback:[C]: ?
  > /home/surv/.minetest/mods/i_have_hands/init.lua:266: in function 'hands'
  > /home/surv/.minetest/mods/i_have_hands/init.lua:373: in function </home/surv/.minetest/mods/i_have_hands/init.lua:371>

## BACKLOG:

- [ ] settings menu, for adjusting hud element
- [ ] make them throw-able
- [ ] pick up mobs?
- [ ] (mayeb not) prevent slot from being filled.
  * plays into fixing the next bug
      make it so that when an inventory gets picked up a new, un fillable hot bar container gets created.
      if the player moves to another hotbar.. drop the inventory
      if when the inventory gets placed down, move over to the previous hotbar.
  - issue: if i add this, it would have to inherit how "hand" works
- [ ] __clumsy__.. maybe i make it so that if the player jumps when they are holding something there is a chance they drop it. -> once i added a weight system to it(if i do) maybe make it so that the player has a chance of dropping after holding it for a while.
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
- [ ] somehow let the player know if a mod is interfering with this mod or just say not its not compatible
- [ ] better sound effects
- [ ] rewrite description. carry nodes & blocks that have an inventory without breaking them.
- [ ] #BUG crashes sometimes when a player spams picking up/down
- [ ] #BUG (can't be reset till the player respawns) reset the arm on death.. or whenever the chest is dropped (same logic)
- [ ] (NOPE.. there is no need for that, and it breaks things) add support for shulkers

## DONE:

- [x] #LUANTI I_have_hands: bug, picking up armor stands, infinite armor
- [x] add hud indicator
- [x] add privs (70% sure anyone can change the allow_all settings)
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
