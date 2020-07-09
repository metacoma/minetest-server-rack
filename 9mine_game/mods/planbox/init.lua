local lyaml   = require "lyaml"
local pprint  = require("pprint")

print("This file will be run at load time!")

local Planbox = {}
Test_server_pos = {
  x = 10,
  y = 10,
  z = 10
}
Planbox.__index = Planbox

function Planbox.new() 
  local self = setmetatable({}, Planbox)
  self.config = {
    player_speed = 4,
    start_pos = {
	    x = 0,
	    y = 0,
	    z = 0,
    },
    start_ground_size = {
	    x = 20,
	    y = 1,
	    z = 20,
    }, 
    unit_size = 2,
    materials = {
      rack = "default:cobble"
    } 
  }
  return self
end

function Planbox.get_config(self) 
  return self.config
end

Mine9 = Planbox.new()

dofile(minetest.get_modpath("planbox") .. "/rack.lua")

default_rack_size = {
  x = 40,
  y = 40,
  z = 20,
} 

walk=function(self,speed)
   local yaw = self.object:get_yaw()
   local speed = speed or 1
   local x = math.sin(yaw) * -1
   local z = math.cos(yaw) * 1
   local y = self.object:get_velocity().y
   self.object:set_velocity({
      x = x*speed,
      y = y,
      z = z*speed
   })
   return self
end

local timer = 0
local y_direction = 1
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		-- Send "Minetest" to all players every 5 seconds
		local demo_user = minetest.get_player_by_name("demo_user")
		if (demo_user) then
			print("move user")
			local pos = demo_user:get_pos()
			demo_user:set_pos({
				x = pos.x,
				y = pos.y + y_direction,
				z = pos.z,
			})
      if (pos.y + y_direction < 10) then
        y_direction = 1
      end
      if (pos.y + y_direction > 90) then
        y_direction = -1
      end
		  minetest.chat_send_all("x = " .. pos.x .. ", y = " .. pos.y .. ", z = " .. pos.z)
      else
      print("no user found in game")
		end
		timer = 0
	end
end)

lookat=function(self,pos2)
   local pos1=self.object:get_pos()
   local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
   local yaw = math.atan(vec.z/vec.x)-math.pi/2
   if pos1.x >= pos2.x then yaw = yaw+math.pi end
   self.object:set_yaw(yaw)
end

run_away=function(self,pos)
   lookat(self,pos)
   self.object:get_yaw()
   self.object:set_yaw(yaw+math.pi)
   walk(self,2)
end


minetest.register_on_joinplayer(function(player)
    print("register_on_joinplayer") 
    local start_pos = Mine9:get_config()["start_pos"]
    player:set_pos(random_pos_on_start_ground(10))
    local player_inventory = player:get_inventory()
    player:set_physics_override({
      speed = Mine9:get_config()["player_speed"],
      -- free_move = false, 
    }) 



    local srv_node = minetest.get_node(
      Test_server_pos
    )
    if (srv_node == nil) then
      print("No srv node")
    else
      pprint(srv_node)
    end
    --print("ItemStack in srv node = " .. #srv_inventory:get_lists())

		--player:add_player_velocity({ x = 300, y = 250, z = 0}) 	

		-- player:move_to({ x = 10, y = 20, z = -50}) 	


		--run_away(player, { x = 20, y = 20, z = 20}) 
end)

function random_pos_on_start_ground(height) 
    local start_pos = Mine9:get_config()["start_pos"]
    local start_ground_size = Mine9:get_config()["start_ground_size"] 
    return {x = (start_pos.x + 1) + (math.random(1, start_ground_size.x) - 2), y = start_pos.y + height, z = (start_pos.z + 1) + ( math.random(1,start_ground_size.z) - 2) }
end

minetest.register_node("planbox:rack", {
  tiles = { "default_brick.png" },
  diggable = false,
}) 

minetest.register_node("planbox:magnifier", {
  tiles = { "planbox_magnifier.png" },
  diggable = false
})


minetest.register_node("planbox:inventory", {
  tiles = { "planbox_inventory.png" },
  diggable = false,
  on_construct = function(pos)
    print("on construct")
  end,
  on_use = function(itemstack, user, pointed_thing) 
    if (pointed_thing.type == "object") then 
      print("draw rack")
      local rack = newRack("/tmp/inventory.yml", {x = 20, y = 10, z = 40}, default_rack_size);
      rack:draw() 
    end
  end,
})

minetest.register_node("planbox:server", {
  tiles = { "default_lava.png" },
  after_place_node = function(pos, placer, itemstack, pointed_thing)
    print("planbox:server construct")
  end,
  after_place_node = function(pos, placer, itemstack, pointed_thing)
    print("planbox:server construct")
  end,
  on_punch = function(pos, node, puncher, pointed_thing)
    print("planbox:server onpunch")
  end,
}) 

minetest.register_node("planbox:node", {
	drawtype = "glasslike_framed",
	tiles = { "default_glass.png" },
  inventory_image = minetest.inventorycube("default_glass.png"),
  paramtype = "light",
  sunlight_propagates = true, -- Sunlight can shine through block
  groups = {cracky = 3, oddly_breakable_by_hand = 3},
  sounds = default.node_sound_glass_defaults()
})

minetest.register_node("planbox:v_crossbeam", {
	tiles = { "default_steel_block.png" },
  diggable = false,
})

minetest.register_node("planbox:unit", {
	tiles = { "default_ice.png" },
  diggable = false,
})



minetest.register_on_generated(function(minp, maxp, seed)
  local start_pos = Mine9:get_config()["start_pos"]
  local start_ground_size = Mine9:get_config()["start_ground_size"] 
	if (minp.x <= start_pos.x and start_pos.x <= maxp.x and minp.y <= start_pos.y and start_pos.y <= maxp.y and minp.z <= start_pos.z and start_pos.z <= maxp.z) then
    --local rack = newRack("/tmp/inventory.yml", {x = 20, y = 10, z = 40}, default_rack_size);
    --rack:draw() 
	  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})

    local inventory_item_pos = random_pos_on_start_ground(start_pos.y + 20) 
    local rack_item_pos = random_pos_on_start_ground(start_pos.y + 20) 
    local magnifier_item_pos = random_pos_on_start_ground(start_pos.y + 20) 

    minetest.add_item(vector.new(inventory_item_pos), "planbox:inventory 1"):get_inventory()
    minetest.add_item(vector.new(rack_item_pos), "planbox:rack 1")
    minetest.add_item(vector.new(magnifier_item_pos), "planbox:magnifier 1")

	  --data[area:index(Test_server_pos.x, Test_server_pos.y, Test_server_pos.z)]	= minetest.get_content_id("planbox:server")


		for x = start_pos.x, start_pos.x + start_ground_size.x - 1 do
			for y = start_pos.y, start_pos.y + start_ground_size.y - 1 do
				for z = start_pos.z, start_pos.z + start_ground_size.z - 1 do
					data[area:index(x,y,z)]	= minetest.get_content_id("planbox:node")
				end
			end
		end
		vm:set_data(data)
		vm:write_to_map()

    minetest.set_node(Test_server_pos, { name = "planbox:server" })
	end
end)

function Planbox.generate_z_line(self, pos, size) 
  local p = {} 
  for z = pos.z, pos.z + size.z do
    table.insert(p, ({
      x = pos.x,
      y = pos.y,
      z = z
    }))
  end
  return p
end

function Planbox.generate_y_line(self, pos, size) 
  local p = {} 
  for y = pos.y, pos.y + size.y do
    table.insert(p, ({
      x = pos.x,
      y = y,
      z = pos.z
    }))
  end
  return p
end

function Planbox.generate_x_line(self, pos, size) 
  local p = {} 
  for x = pos.x, pos.x + size.x do
    table.insert(p, ({
      x = x,
      y = pos.y,
      z = pos.z,
    }))
  end
  return p
end

function Planbox.generate_area(self, pos, size) 
  local p = {} 
  for x = pos.x, pos.x + size.x - 1 do
    for y = pos.y, pos.y + size.y - 1 do
      for z = pos.z, pos.z + size.z - 1 do
        table.insert(p, ({
        x = x,
        y = y,
        z = z,
      }))
      end
    end
  end
  return p
end

function Planbox.draw_z_line(self, pos, size, node) 
  local p = Planbox:generate_z_line(pos, size)
  minetest.bulk_set_node(p, node)
end

function Planbox.draw_x_line(self, pos, size, node) 
  local p = Planbox:generate_x_line(pos, size)
  minetest.bulk_set_node(p, node)
end

function Planbox.draw_area(self, pos, size, node) 
  local p = Planbox:generate_area(pos, size)
  minetest.bulk_set_node(p, node)
end

-- util
function Planbox.concat_tables(self, t1, t2)
  for _,v in ipairs(t2) do 
    table.insert(t1, v)
  end
  return t1
end

