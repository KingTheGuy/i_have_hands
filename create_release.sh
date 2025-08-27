#!/bin/bash
# TODO.md

# Archive:  i_have_hands_1.0.9.zip
#   Length      Date    Time    Name
# ---------  ---------- -----   ----
#         0  02-10-2025 11:36   sounds/
#      8610  02-01-2025 06:11   sounds/i_have_hands_place_down_node.ogg
#      7447  02-01-2025 06:11   sounds/i_have_hands_pickup_node.ogg
#     19613  04-24-2025 12:27   init.lua
#      1067  02-01-2025 06:11   LICENSE
#       186  02-01-2025 06:11   mod.conf
#      1538  04-24-2025 12:31   README.md
#      1490  02-01-2025 06:11   utils.lua
# ---------                     -------
#     39951                     8 files

# /home/olrak/CODING/minetest/i_have_hands

dir_name=$(basename $(pwd))_$1
echo $dir_name

zip $dir_name.zip CHANGELOG.md LICENSE README.md init.lua menu.lua mod.conf models/* sounds/* textures/* utils.lua
