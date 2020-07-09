local lyaml   = require "lyaml"
local Rack = {} 
Rack.__index = Rack

dofile(minetest.get_modpath("planbox") .. "/h_cross_beam.lua")
dofile(minetest.get_modpath("planbox") .. "/v_cross_beam.lua")
dofile(minetest.get_modpath("planbox") .. "/unit.lua")
dofile(minetest.get_modpath("planbox") .. "/rack_unit_manager.lua")
--dofile(minetest.get_modpath("planbox") .. "/unit_device.lua")
--dofile(minetest.get_modpath("planbox") .. "/unit_device_manager.lua")

Rack_config = {
  unit_size = Mine9:get_config()["unit_size"],
  v_cross_beam_offset = {
    x = 4,
    y = 3,
    z = 3,
  },
  materials = {
    unit = "default:ice"
  }, 
}

function get_config() 
  return Rack_config
end

function readAll(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

function newRack(inventory, pos, size) 
  return Rack.new(inventory, pos, size)
end

function Rack.new(inventory, pos, size)
	local self = setmetatable({}, Rack)

  self.materials = {
    top = "default:cobble",
    bottom = "default:cobble",
    v_cross_beam = "default:cobble"
  } 

  self.sides = {
    "bottom_left",
    "bottom_right",
    "top_left",
    "top_right",
  }

  self:load_inventory(inventory)

  self:set_rack_unit_manager(newRackUnitManager(self))

	self:setPos(pos)
  self:setSize({ 
    x = 40,
    -- y = self:get_rack_unit_manager():get_unit_count() * 2,
    y = self:get_rack_unit_manager():get_unit_count() * Mine9:get_config()["unit_size"],
    z = 24 + 4 * 2 
  }) 
  --self:set_cross_beam_node_name("planbox:crossbeam")

  self:set_h_cross_beam()
  self:set_v_cross_beam() 


	return self
end

function Rack.set_h_cross_beam(self)
  local pos = self:getPos()
  local size = self:getSize()
  self.h_cross_beams = {
    newCrossBeam(self, pos.y + 4),
    newCrossBeam(self, pos.y + size.y - 4),
    newCrossBeam(self, (pos.y + size.y) / 2)
  } 
end

function Rack.get_h_cross_beams(self) 
  return self.h_cross_beams
end

function Rack.set_v_cross_beam(self)
  self.v_cross_beam = { }
  for n, side in ipairs(self.sides) do
    print("Rack.set_v_cross_beam: Generate # " .. n .. " side = " .. side)
    self.v_cross_beam[side] = newvCrossBeam(self, side)
  end
end

function Rack.get_v_cross_beam(self) 
  return self.v_cross_beam
end

function Rack.load_inventory(self, inventory_path)
  self.raw_inventory = readAll(inventory_path)
  self.inventory =  lyaml.load(self.raw_inventory)
end

function Rack.get_inventory(self)
  return self.inventory
end


function Rack.setPos(self, pos)
	self.pos = pos
end

function Rack.getPos(self)
	return self.pos
end

function Rack.setSize(self, size)
	self.size = size
end

function Rack.getSize(self)
	return self.size
end

function Rack.draw(self) 
  local p = {}
  p = self:draw_struct(self:getPos(), self:getSize())
  p = Mine9:concat_tables(p, self:draw_top()) 
  p = Mine9:concat_tables(p, self:draw_bottom()) 
  p = Mine9:concat_tables(p, self:draw_v_cross_beam())
  minetest.bulk_set_node(p, { name = "default:cobble" })
  p = self:draw_h_cross_beams()
  minetest.bulk_set_node(p, { name = "planbox:v_crossbeam" })
  self:get_rack_unit_manager():draw()
end


function Rack.draw_h_cross_beam(self, pos, size) 
  --local node_name = self:get_cross_beam_node_name() 
  local p = {}
  p = Mine9:generate_area(
    -- pos
    {
      x = pos.x,
      y = pos.y,
      z = pos.z + 1,

    },
    -- size
    {
      x = size.x,
      y = 3,
      z = 1,
    }
  ) 

  p = Mine9:concat_tables(p, Mine9:generate_area(
    -- pos
    {
      x = pos.x,
      y = pos.y,
      z = pos.z + size.z - 1,

    },
    -- size
    {
      x = size.x,
      y = 3,
      z = 1,
    }
    )
  )
  return p
  
end

function Rack.draw_h_cross_beams(self) 
  local pos = self:getPos()
  local size = self:getSize() 
  local p = {}
  for n, crossbeam in pairs(self:get_h_cross_beams()) do
    print("Rack.draw_cross_beams(" .. crossbeam:get_y() .. ")")
    p = Mine9:concat_tables(
      p,
      self:draw_h_cross_beam(
        {
          x = pos.x, 
          y = crossbeam:get_y(), 
          z = pos.z 
        },
        size
      )
    )
  end
  return p
end


function Rack.draw_v_cross_beam(self) 
  local p = {}
  for n, side in ipairs(self.sides) do
    local v_crossbeam = self:get_v_cross_beam()[side]
    local bottom_pos = v_crossbeam:get_bottom_pos()
    local top_pos = v_crossbeam:get_top_pos()
    p = Mine9:concat_tables(p, Mine9:generate_y_line(
      -- pos
      bottom_pos,
      -- size 
      {
        y = top_pos.y - bottom_pos.y
      } 
      )
   )
  end

  for n, cross_beam in pairs(self:get_h_cross_beams()) do
    local y = cross_beam:get_y()
    for n, side in ipairs(self.sides) do
      local v_crossbeam = self:get_v_cross_beam()[side]
      local shift = 1
      if side == "top_right" or side == "bottom_right" then
        shift = -1
      end
      p = Mine9:concat_tables(p, { 
        {
          x = v_crossbeam:get_bottom_pos().x, 
          y = y + 1,
          z = v_crossbeam:get_bottom_pos().z + shift
        }
      })
    end
  end

  return p
end

function Rack.draw_bottom(self)
  local pos = self:getPos()
  local size = self:getSize()

  local p = Mine9:generate_area(
    -- pos
    {
      x = pos.x + 1,
      y = pos.y,
      z = pos.z + 1,
    },
    -- size
    {
      x = size.x,
      y = 1,
      z = size.z,
    }
  )
  return p
end


function Rack.draw_top(self)
  local pos = self:getPos()
  local size = self:getSize()
  local p = Mine9:generate_area(
    -- pos
    {
      x = pos.x + 1,
      y = pos.y + size.y,
      z = pos.z + 1,
    },
    -- size
    {
      x = size.x,
      y = 1,
      z = size.z,
    }
  )
  return p
end


function Rack.draw_struct(self, pos, skeleton_size) 
    local node_name = "default:cobble"
    local p = {}

    -- bottom x1
    p = Mine9:generate_x_line({
        x = pos.x,
        y = pos.y,
        z = pos.z,
      },
      skeleton_size
    )
    -- upper x1
    p = Mine9:concat_tables(p, Mine9:generate_x_line({
        x = pos.x,
        y = pos.y + skeleton_size.y,
        z = pos.z,
      },
      skeleton_size
      )
    )
    -- bottom x2
    p = Mine9:concat_tables(p, Mine9:generate_x_line({
        x = pos.x,
        y = pos.y,
        z = pos.z + skeleton_size.z,
      },
      skeleton_size
      )
    )
    -- upper x2
    p = Mine9:concat_tables(p, Mine9:generate_x_line({
        x = pos.x,
        y = pos.y + skeleton_size.y,
        z = pos.z + skeleton_size.z,
      },
      skeleton_size
      )
    ) 


    -- draw z 
    -- bottom front z1
    p = Mine9:concat_tables(p, Mine9:generate_z_line({
        x = pos.x,
        y = pos.y,
        z = pos.z,
      },
      skeleton_size
      ) 
   )

    -- upper front z1
    p = Mine9:concat_tables(p, Mine9:generate_z_line({
        x = pos.x,
        y = pos.y + skeleton_size.y,
        z = pos.z,
      },
      skeleton_size
      )
    )
    -- bottom front z2
    p = Mine9:concat_tables(p, Mine9:generate_z_line({
        x = pos.x + skeleton_size.x,
        y = pos.y,
        z = pos.z,
      },
      skeleton_size
      )
    )
    -- upper front z2
    p = Mine9:concat_tables(p, Mine9:generate_z_line({
        x = pos.x + skeleton_size.x,
        y = pos.y + skeleton_size.y,
        z = pos.z,
      },
      skeleton_size
      )
    )

    -- front y1
    p = Mine9:concat_tables(p, Mine9:generate_area(
      -- pos
      {
        x = pos.x,
        y = pos.y,
        z = pos.z
      }, 
      -- size
      {
        x = 3,
        y = skeleton_size.y,
        z = 1,
      }
      )
    )

    -- front y2
    p = Mine9:concat_tables(p, Mine9:generate_area(
      -- pos
      {
        x = pos.x,
        y = pos.y,
        z = pos.z + skeleton_size.z
      }, 
      -- size
      {
        x = 3,
        y = skeleton_size.y,
        z = 1,
      }
      )
    )

    -- back y1
    p = Mine9:concat_tables(p, Mine9:generate_area(
      -- pos
      {
        x = pos.x + skeleton_size.x - 2,
        y = pos.y,
        z = pos.z 
      }, 
      -- size
      {
        x = 3,
        y = skeleton_size.y,
        z = 1,
      }
      )
    )

    -- back y2
    p = Mine9:concat_tables(p, Mine9:generate_area(
      -- pos
      {
        x = pos.x + skeleton_size.x - 2,
        y = pos.y,
        z = pos.z + skeleton_size.z
      }, 
      -- size
      {
        x = 3,
        y = skeleton_size.y,
        z = 1,
      }
      )
    )

    return p
end

function Rack.set_cross_beam_node_name(self, node_name)
  self.cross_beam_node_name = node_name
end

function Rack.get_cross_beam_node_name(self)
  return self.cross_beam_node_name
end

function Rack.set_rack_unit_manager(self, rack_unit_manager)
  self.rack_unit_manager = rack_unit_manager
end

function Rack.get_rack_unit_manager(self)
  return self.rack_unit_manager
end



local myRack = Rack.new("/tmp/inventory.yml", { x = 1, y = 2, z = 3 }, { x = 11, y = 12, z = 13 })
--myRack:draw()
