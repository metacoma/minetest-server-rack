local RackUnit = {}
RackUnit.__index = RackUnit

function newRackUnit(rack, n, unit)
  return RackUnit.new(rack, n, unit)
end

function RackUnit.new(rack, n, unit) 
	local self = setmetatable({}, RackUnit)
  print("Create unit " .. n .. " description " .. unit["description"]) 
  self.unit = unit
  self:set_n(n)
  self:set_rack(rack)
  --self:calculate_pos()
  --self:set_allocate(false)
  local is_allocated = true
  for n, tag in pairs(self.unit['tag']) do
    if (tag == "emptyRackUnit") then
      is_allocated = false
      break
    end
  end
  self:set_allocate(is_allocated)
  return self
end

function RackUnit.set_n(self, n)
  self.n = n
end
function RackUnit.get_n(self, n)
  return self.n
end

function RackUnit.allocate(self)
  assert(not self:get_allocate())
  self.allocated = true
end

function RackUnit.set_allocate(self, state)
  self.allocated = state
end

function RackUnit.is_allocated(self)
  return self:get_allocate()
end

function RackUnit.get_allocate(self)
  return self.allocated 
end

function RackUnit.set_rack(self, rack)
  self.rack = rack
end

function RackUnit.get_rack(self)
  return self.rack
end

function RackUnit.set_pos(self, pos)
  self.pos = pos
end

function RackUnit.get_pos(self, pos)
  return self.pos
end

function RackUnit.set_size(self, size)
  self.size = size
end

function RackUnit.get_size(self)
  return self.size
end

function RackUnit.calculate_geometry(self)
  local v_bottom_right_top_pos = self:get_rack():get_v_cross_beam()["bottom_right"]:get_top_pos()
  self:set_pos({
    x = v_bottom_right_top_pos.x,
    y = v_bottom_right_top_pos.y - (self:get_n() - 1) * Rack_config["unit_size"],
    z = v_bottom_right_top_pos.z + 1
  }) 

  -- XXX move this code to RackUnitManager, calculate it once time
  local v_bottom_left_top_pos = self:get_rack():get_v_cross_beam()["bottom_left"]:get_top_pos()

  local v_top_right_top_pos = self:get_rack():get_v_cross_beam()["top_right"]:get_top_pos()

  self:set_size({
    x = v_top_right_top_pos.x - v_bottom_right_top_pos.x,
    y = Mine9:get_config().unit_size,
    -- XXX -v_cross_beam.width instead -2
    z = (v_bottom_left_top_pos.z - v_bottom_right_top_pos.z) - 1

  }) 


end

function RackUnit.draw(self)
  self:calculate_geometry()
  local pos = self:get_pos()
  local size = self:get_size() 

  Mine9:draw_area(pos, size, { name = Rack_config.materials.unit }) 
  print("Draw unit .. " .. self:get_n() ) 
end
