local vCrossBeam = {}
vCrossBeam.__index = vCrossBeam

function newvCrossBeam(rack, side)
  return vCrossBeam.new(rack, side) 
end

function vCrossBeam.new(rack, side) 
  local self = setmetatable({}, vCrossBeam)
  self.rack_pos = rack:getPos()
  self.rack_size = rack:getSize()

  local offset = Rack_config["v_cross_beam_offset"] 

  if (side == "bottom_right") then
    self:set_bottom_pos({
      x = self.rack_pos.x + offset.x,
      y = self.rack_pos.y + offset.y,
      z = self.rack_pos.z + offset.z 
    })
    self:set_top_pos({
      x = self.rack_pos.x + offset.x,
      y = self.rack_pos.y + self.rack_size.y - offset.y,
      z = self.rack_pos.z + offset.z 
    })
  end
  if (side == "bottom_left") then
    self:set_bottom_pos({
      x = self.rack_pos.x + offset.x,
      y = self.rack_pos.y + offset.y,
      z = self.rack_pos.z + self.rack_size.z - offset.z
    })
    self:set_top_pos({
      x = self.rack_pos.x + offset.x,
      y = self.rack_pos.y + self.rack_size.y - offset.y,
      z = self.rack_pos.z + self.rack_size.z - offset.z,
    })
  end


  if (side == "top_right") then
    self:set_bottom_pos({
      x = self.rack_pos.x + self.rack_size.x - offset.x,
      y = self.rack_pos.y + offset.y,
      z = self.rack_pos.z + offset.z, 
    })
    self:set_top_pos({
      x = self.rack_pos.x + self.rack_size.x - offset.x,
      y = self.rack_pos.y + self.rack_size.y - offset.y,
      z = self.rack_pos.z + offset.z
    })
  end
  if (side == "top_left") then
    self:set_bottom_pos({
      x = self.rack_pos.x + self.rack_size.x - offset.x,
      y = self.rack_pos.y + offset.y,
      z = self.rack_pos.z + self.rack_size.z - offset.z
    })
    self:set_top_pos({
      x = self.rack_pos.x + self.rack_size.x - offset.x,
      y = self.rack_pos.y + self.rack_size.y - offset.y,
      z = self.rack_pos.z + self.rack_size.z - offset.z
    })
  end

  return self
end

function vCrossBeam.get_bottom_pos(self)
  return self.bottom_pos
end

function vCrossBeam.set_bottom_pos(self, pos) 
  self.bottom_pos = pos
end

function vCrossBeam.get_top_pos(self)
  return self.top_pos
end

function vCrossBeam.set_top_pos(self, pos) 
  self.top_pos = pos
end
