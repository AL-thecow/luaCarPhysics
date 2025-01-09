player = {}
player.x = w/2--initial position
player.y = h/2--initial position
player.mass = 1000
player.width = 40
player.height = 60
player.inertia = player.mass * (player.width ^ 2 + player.height ^ 2) / 12
player.angularAcceleration = 0
player.angularVelocity = 0
player.angularTorque = 0
player.yawRate = 0
player.wheelbase = 3
player.steerAngle = 0
player.direction = 0
player.newDirection = 0
player.accel = 0
player.v = Vector.new(0,0)
player.vLateral = Vector.new(0,0)
player.vLongitudinal = Vector.new(0,0)
player.forceNet = Vector.new(0,0)
player.forceApplied = Vector.new(0,0)
player.forceFriction = Vector.new(0,0)
player.forceCentripetal = Vector.new(0,0)
player.forceNormal = player.mass * 9.81 * .05
player.lateralOffset = 1
player.longitudinalOffset = 1.5

function player:updatePlayer(dt)

    --local magnitudeOfVelocity = math.sqrt(player.v.x * player.v.x + player.v.y * player.v.y)
    
    mapMouseToSteerAngle()
    mapKeystoAcceleration()
    self:updateForceApplied(dt)
    self:updateForceFriction()
    self:updateForceCentripetal()
    self:updateNetForce()
    self:updateLateralForce()
    
    self:carDirection(dt)
    
    self.v = self.v + self.forceNet * dt / self.mass
    self.x = (self.x + self.v:x() * dt * scale)
    self.y = (self.y + self.v:y() * dt * scale) 
end

function player:updateNetForce()
    self.forceNet = self.forceApplied + self.forceCentripetal + self.forceFriction
end

function player:updateForceApplied(dt)
    local magnitude = self.accel * self.mass
    local direction = self.direction --+ target.steerAngle
    local newForce =  Vector.new(magnitude,direction)
    self.vLongitudinal = player.vLongitudinal + newForce * dt
    self.forceApplied = newForce
end

function player:updateForceFriction()
    if abs(self.v.m) * scale > 0 and self.accel == 0 then
        self.forceFriction = (- self.v:u()) * self.forceNormal
    else
        self.forceFriction = (- self.v:u()) * 0
    end
    
end

function player:updateForceCentripetal()
    if self.steerAngle == 0 then
        return Vector.new(0,self.steerAngle)
    end
    local radius = self.wheelbase / math.sin(self.steerAngle)
    local forceMagnitude = self.mass * self.v.m * self.v.m / abs(radius)
    local forceAngle = self.direction + self.steerAngle + math.pi/2 * self.steerAngle / abs(self.steerAngle)
    local newForce = Vector.new(forceMagnitude,forceAngle)

    local l = self.wheelbase/2
    local r = radius
    local s = 90 - self.steerAngle
    local m = math.sqrt(l ^ 2 + r ^ 2 - 2 * l * r * math.cos(s))
    self.yawRate = self.vLongitudinal / m
    self.forceCentripetal = newForce 
end


function player:carDirection(dt)
    self.angularVelocity = self.angularVelocity + self.angularAcceleration * dt
    self.newDirection = self.direction + self.angularVelocity * dt

    self.direction = self.v.d
    
end

function player:updateLateralForce()
    local directionVector = Vector.new(1,self.direction)
    local term1 = math.acos(dot(self.v,directionVector) / self.v.m) -- front
    directionVector.d = directionVector.d + self.steerAngle
    local term2 = math.acos(dot(self.v,directionVector) / self.v.m) -- back

    local frontLat = getSlipForceCurve(term1)
    local backLat = getSlipForceCurve(term2)
    local corneringForce = frontLat + backLat

    self.torque = frontLat * math.cos(self.steerAngle) * self.wheelbase * 0.5 - backLat * self.wheelbase * 0.5
    self.angularAcceleration = self.torque / self.inertia
    self.vLongitudinal = self.v - self.vLateral
end

function getSlipForceCurve(slipAngle)
    local B, C, D, E = -0.3, 2.5, 5000, 1
    local magnitude = D * math.sin(C * math.atan(B * (1 - E) * slipAngle + E * math.atan(B * slipAngle)))
    return magnitude
end