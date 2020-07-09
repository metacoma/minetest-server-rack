box_size = 5

function createbox(x, y, z, size)
  local node_type = "default:cobble"


  for i=0,size-1,1 do
    for j=0,size-1,1 do
	-- ground
    	minetest.set_node({x = x + j, y = y, z = z + i}, { name = node_type })
	-- top
    	minetest.set_node({x = x + j, y = y + size - 1, z = z + i}, { name = node_type })
	-- east wall
    	minetest.set_node({x = x, y = y + i, z = z + j}, { name = node_type })
	-- west wall
    	minetest.set_node({x = x + size - 1, y = y + i, z = z + j}, { name = node_type })
	-- south wall
    	minetest.set_node({x = x + j, y = y + i, z = z + size - 1}, { name = node_type })
	-- north wall
    	minetest.set_node({x = x + j, y = y + i, z = z}, { name = node_type })
    end
  end

end

function matrix()
    for j=0,30*15,10 do
    	for i=0,30*15,40 do
      		createbox(j, 9, i, box_size)
	end
    end
end

minetest.register_on_joinplayer(function(player)
    local pos = {x = 10, y = 10, z = 10}
    print("register_on_joinplayer") 
end)

