local UnitDeviceManager = {}
UnitDeviceManager.__index = UnitDeviceManager

function newUnitDeviceManager(inventory) 
	return UnitDeviceManager.new(inventory)
end

function UnitDeviceManager.new(inventory) 
	local self = setmetatable({}, UnitDeviceManager)
	self:set_inventory(inventory)
	return self
end

function UnitDeviceManager.set_inventory(self, inventory) 
	self.inventory = inventory
end

function UntiDeviceManager.get_inventory(self)
	return self.inventory
end
