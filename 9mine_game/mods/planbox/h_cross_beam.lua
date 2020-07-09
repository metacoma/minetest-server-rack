local CrossBeam = {}
CrossBeam.__index = CrossBeam

function newCrossBeam(rack, y)
  return CrossBeam.new(rack, y) 
end

function CrossBeam.new(rack, y) 
  local self = setmetatable({}, CrossBeam)
  print("CrossBeam.new( " .. y .. ")")
  self:set_y(y)
  return self
end

function CrossBeam.set_y(self, y)
  print("CrossBeam.set_y( " .. y .. ")")
  self.y = y
end

function CrossBeam.get_y(self)
  return self.y
end

