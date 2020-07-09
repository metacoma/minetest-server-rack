local UnitDevice = {}
UnitDevice.__index = UnitDevice

function newUnitDevice() 
  return UnitDevice.new()
end

function UnitDevice.new() 
	local self = setmetatable({}, UnitDevice)
  return self
end

function UnitDevice.set_size(self, unit_size)
  self.size = unit_size
end

function UnitDevice.get_size(self)
  return self.unit_size
end

function UnitDevice.draw(self) 
  minetest.add_node({ x = 10, y = 10, z = 10 }, { name = "default:cobble"} )
end
