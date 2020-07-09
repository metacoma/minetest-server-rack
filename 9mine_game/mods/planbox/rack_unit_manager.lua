local RackUnitManager = {}
RackUnitManager.__index = RackUnitManager

function newRackUnitManager(rack)
  return RackUnitManager.new(rack)
end

function RackUnitManager.new(rack)
  local self = setmetatable({}, RackUnitManager)
  self.rack = rack
  self.units = {}
  self:units_init() 

  return self
end

function RackUnitManager.set_rack(self, rack)
  self.rack = rack
end

function RackUnitManager.get_rack(self)
  return self.rack
end

function RackUnitManager.set_unit_count(self, unit_count)
  self.unit_count = unit_count
end

function RackUnitManager.get_unit_count(self)
  return self.unit_count
end


function RackUnitManager.calc_unit_size(self)
  for i, rack in pairs(self:get_rack():get_inventory()['parameters']['hardware']['racks']) do
    self:set_unit_count(#rack['units'])
    print("units is " .. self:get_unit_count()) 
    for n, unit in pairs(rack['units']) do
      local rackUnit = newRackUnit(self:get_rack(), n, unit)
      table.insert(self.units, rackUnit)
    end
  end
end

function RackUnitManager.allocate_unit(self, n, unit_device)
  local unit = self:get_unit(n)  
  unit:allocate()
end

function RackUnitManager.units_init(self)
  self:calc_unit_size()
end

function RackUnitManager.get_units(self)
  return self.units
end

function RackUnitManager.get_unit(self, n)
  assert(n <= self:get_unit_count())
  return self:get_units()[n]
end

function RackUnitManager.draw(self) 

  for n, unit in pairs(self:get_units()) do 
    if unit:is_allocated() then
      unit:draw()
    end
  end
end
