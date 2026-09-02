## TODO

## BACKLOG:

- [ ] settings menu, for adjusting hud element
- [ ] make them throw-able
- [ ] pick up mobs?
- [ ] (mayeb not) prevent slot from being filled.
  - plays into fixing the next bug
    make it so that when an inventory gets picked up a new, un fillable hot bar container gets created.
    if the player moves to another hotbar.. drop the inventory
    if when the inventory gets placed down, move over to the previous hotbar.
  * issue: if i add this, it would have to inherit how "hand" works
- [ ] **clumsy**.. maybe i make it so that if the player jumps when they are holding something there is a chance they drop it. -> once i added a weight system to it(if i do) maybe make it so that the player has a chance of dropping after holding it for a while.
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

## DOING:

note: function place_node() seems to be broken, use item_place_node()

- [ ] #BUG nodetimer issues
  - [ ] not the correct speed
  - [ ] does not presist on world start

- [ ] blacklist
  - [ ] shulkers
  - [x] (just set xp to nothing) furnace, because it drops xp on pickup... could cause dupe issues
  - [ ] or anything that has add_item() as its break function?

- [ ] carrying entity
  - [x] implemented
  - [ ] size needs to be per game/player model
  - [ ] voxelibre, use its drop node

- [ ] (may have been fixed) this is so broken!!
  - [ ] (which? aom furnace? things that do not want to be placed?) picking up some node types breaks placing (for sure something to do with core.item_place_node(), and the node maybe not being placeable by normal means)
  - [x] (node checking is bad, forget it) voxelibre. because the placed node is different than the held one. the node check fails.
  - [x] #COMPAT age of mending; chests need to use swap_node() instead, as to not drop/dupe the chest's contents

- [ ] (may have been fixed) issue with placement
  - p_data.inv does not seem to be clearing and its causing the player placed/interacted thing take the metadata
  - [ ] save the node that was previously there, undo placement if error happens
  - [x] #FIXME someone with putdowninv is broken causing multiple to be placeable
  - [x] #FIXME pipeworks. seem to be able to pickup pipes; is this normal or did it break while trying to place a inv node there.

- [x] voxelibre chests need to make sure they update after being placed (visual reasons)

- [ ] check this!
  - [ ] putDownInv, make sure placed node matches before setting its meta
  - [ ] putDownInv, make copy of previus node revert to it if prev message applies

- [ ] SAVING/LOADING; there may be an issue if the inv has USERDATA

## DONE:

- [x] #IMPORTANT protection, need to handle that
- [x] #BUG leaving/exiting twice in a row will not save what the player is holding
  - [x] save data on carry
- [x] seems like I did some wonky stuff with, with putDownInv()
  - [x] should pointed_thing be the same for under and above? I think once the node gets placed, both above and under should eqaul or just use a new variable with that new value
- [x] #BUG placing down on build_to nodes causes data loss.. why?
  - just needed to make sure that the data was being set on the actual pos
- [x] indicator
- [x] raycast:
  - [x] raycast objects too, but ignore self.
    - reason is drawers mod, need to be able to sneak + click to do functions
  - [x] cleanup and comments
- [x] placing, needs to also take into account built_to option
- [x] putdown when:
  - what I am currently trying is kinda broken
  - [x] player leaves
  - [x] player ides
- [x] handle save/loading
  - [x] loads
  - [x] saves
  - [x] when leaving
  - [x] on world load
  - [x] when picking up & putting down (to make sure no data will be lost)

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
  - second one will handle displaying the \*held inventory
