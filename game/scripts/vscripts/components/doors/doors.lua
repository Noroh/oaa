
if Doors == nil then
  Debug.EnabledModules['doors:doors'] = true
  DebugPrint('Creating new Doors object.')
  Doors = class({})
end

-- Constants
DOOR_STATE_UNKOWN = 0
DOOR_STATE_OPENING = 1
DOOR_STATE_OPEN = 2
DOOR_STATE_CLOSING = 3
DOOR_STATE_CLOSED = 4

function Doors:Init()
  local testgate = Doors:CreateDoors(Vector(300, 0, 0), 300, {})
  DebugPrintTable(testgate)
end

function Doors:CreateDoors(position, angle, settings)
  local gate = self:CreateEmptyGate(settings)

  gate.props = self:SpawnDoors(position, angle, settings)

  gate.Open = partial(Doors['OpenDoors'], gate, settings)
  gate.Close = partial(Doors['CloseDoors'], gate, settings)

  return gate
end

function Doors:UseDoors(name, settings)
  local gate = self:CreateEmptyGate(settings)

  gate.props.gate = FindByName(nil, name)

  gate.Open = partial(Doors['OpenDoors'], gate, settings)
  gate.Close = partial(Doors['CloseDoors'], gate, settings)

  return gate
end

--[[
settings = {
  animation = 'gate_entrance002_open',
  idle = 'gate_entrance002_idle',
  openingRate = 1,
  closingRate = 2,
}
]]
--[[function Doors.OpenAnimDoors(gate, settings)
  local animation = settings.animation or 'gate_entrance002_open'
  local idle = settings.idle or 'gate_entrance002_idle'
  local rate = settings.openingRate or 1

end

function Doors.CloseAnimDoors(gate, settings)
  local animation = settings.animation or 'gate_entrance002_open'
  local idle = settings.idle or 'gate_entrance002_idle'
  local rate = settings.closingRate or 2

end]]

--[[
settings = {
  openingSpeed = 1,
  closingSpeed = 2,
  distance = 100,
}
]]
function Doors.OpenDoors(gate, settings)
  local speed = settings.openingSpeed or 100
  local distance = settings.distance or 100
  local time = distance / speed

  gate.props.gate:SetVelocity(Vector(0, 0, speed))

  Timers:CreateTimer(time, function()
    gate.props.gate:SetVelocity(Vector(0, 0, 0))
  end)
end

function Doors.CloseDoors(gate, settings)
  local speed = settings.closingSpeed or 200
  local distance = settings.distance or 100
  local time = distance / speed

  gate.props.gate:SetVelocity(Vector(0, 0, -speed))

  Timers:CreateTimer(time, function()
    gate.props.gate:SetVelocity(Vector(0, 0, 0))
  end)
end

function Doors:CreateEmptyGate(settings)
  return {
    props = {},
    state = settings.state or DOOR_STATE_UNKOWN,
    Open = nil,
    Close = nil,
  }
end

--[[
settings = {
  jambOffset = 128,
  jambScale = Vector(1, 1, 1),
  gateScale = Vector(2, 1, 1,78)
  jambModel = 'models/props_structures/gate_entrance001.vmdl',
  gateModel = 'models/props_structures/gate_entrance002.vmdl',
  snapToGround = true,
  heightOffset = 0,
}
]]
function Doors:SpawnDoors(position, angle, settings)
  if settings == nil then
    -- prevent accessing nil
    settings = {}
  end

  local CreateProp = partial(SpawnEntityFromTableSynchronous, 'prop_dynamic')

  local jambOffset = settings.jambOffset or 172

  if settings.snapToGround == true or settings.snapToGround == nil then
    position = GetGroundPosition(position, nil)
  end

  if settings.heightOffset then
    position = position + Vector(0, 0, settings.heightOffset)
  end

  -- angle
  local jambLAngle = Vector(0, angle, 0)
  local gateAngle = Vector(0, angle, 0)
  local jambRAngle = Vector(0, angle, 0) + Vector(0, 180, 0)

  -- origin
  local jambLOrigin = position + Vector(jambOffset, 0, 0)
  local gateOrigin = position
  local jambROrigin = position - Vector(jambOffset, 0, 0)

  -- translate jamb origin
  if angle ~= 0 then
    jambLOrigin = RotateAround(jambLOrigin, gateOrigin, jambLAngle.y)
    jambROrigin = RotateAround(jambROrigin, gateOrigin, jambRAngle.y)
  end

  -- scale
  local jambScale = settings.jambScale or Vector(1, 1, 1)
  local gateScale = settings.gateScale or Vector(2, 1, 1.78)

  -- model
  local jambModel = settings.jambModel or 'models/props_structures/gate_entrance001.vmdl'
  local gateModel = settings.gateModel or 'models/props_structures/gate_entrance002.vmdl'

  DebugPrint('Spawning new Doors at ' .. VectorToString(position) .. ' angled at ' .. angle .. ' degrees.')

  -- spawn props
  local jambL = CreateProp({
    origin = jambLOrigin,
    angles = jambLAngle,
    scales = jambScale,
    model = jambModel,
  })
  local gate = CreateProp({
    origin = gateOrigin,
    angles = gateAngle,
    scales = gateScale,
    model = gateModel,
  })
  local jambR = CreateProp({
    origin = jambROrigin,
    angles = jambRAngle,
    scales = jambScale,
    model = jambModel,
  })

  return {
    jambL = jambL,
    gate = gate,
    jambR = jambR
  }
end

-- rotate point a around point p by d degrees
-- stolen from here https://stackoverflow.com/questions/2259476/rotating-a-point-about-another-point-2d#2259502
function RotateAround(a, p, d)
  local s = math.sin(d)
  local c = math.cos(d)

  -- translate point back to origin
  p.x = p.x - a.x
  p.y = p.y - a.y

  -- rotate point
  local x = p.x * c - p.y * s
  local y = p.y * s + p.x * c

  -- translate point back
  p.x = x + a.x
  p.y = y + a.y

  return p
end

function VectorToString(v)
  return v.x .. ', ' .. v.y .. ', ' .. v.z
end
