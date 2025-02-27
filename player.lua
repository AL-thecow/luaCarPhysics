player = {}
player.x = w/2--initial position
player.y = h/2--initial position
player.mass = 1000
player.width = 2 * scale
player.height = 3 * scale
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
player.fLateral = Vector.new(0,0)
player.fLongitudinal = Vector.new(0,0)
player.forceNet = Vector.new(0,0)
player.forceFriction = Vector.new(0,0)
player.forceCentripetal = Vector.new(0,0)
player.forceNormal = player.mass * 9.81 * .1
player.downforce = player.mass * 9.81
player.forceDrag = Vector.new(0,0)
player.lateralOffset = 1
player.longitudinalOffset = 1.5
player.aV = 0
player.frontSlip = 0
player.backSlip = 0

function player:updatePlayer(dt)
    
    mapMouseToSteerAngle()
    mapKeystoAcceleration()
    self:updateLongitudinalForce(dt)
    self:updateCentripetalForce(dt)
    self:updateLateralForce()
    self:updateForceFriction()
    --self:updateDragForce()
    self:updateNetForce()
    
    
    self:carDirection(dt)
    self:updatePosition(dt)
end

function player:updatePosition(dt)
    self.v = self.v + self.forceNet * dt / self.mass
    self.x = (self.x + self.v:x() * dt * scale)
    self.y = (self.y + self.v:y() * dt * scale) 
end

function player:updateNetForce() 
    self.forceNet = self.fLongitudinal + self.fLateral --+ self.forceFriction --+ self.forceCentripetal --+ self.fLateral
    if keys.left then
    self.forceNet = self.fLongitudinal 
    end
end

function player:updateForceFriction()
    --if abs(self.v.m) * scale > 0 and self.accel == 0 then
        self.forceFriction = (- self.v:u()) * self.forceNormal
   -- else
       -- self.forceFriction = (- self.v:u()) * 0
    --end
end


function player:carDirection(dt)
    self.angularVelocity = self.angularVelocity + self.angularAcceleration * dt
    self.direction = self.direction + self.angularVelocity * dt

    self.direction = self.direction + self.aV * dt
    
    --self.direction = self.v.d
end

function player:updateLongitudinalForce(dt)
    self.fLongitudinal.d = self.direction
    self.fLongitudinal.m = self.accel * self.mass  
end

function player:updateCentripetalForce(dt)
    if steerAngle == 0 then
        --return 0
    end
    local radiusFront = self.wheelbase / math.sin(self.steerAngle)
    local magnitude = self.mass * self.v.m * self.v.m / radiusFront
    self.aV = self.v.m / radiusFront
    self.forceCentripetal.m = magnitude
    self.forceCentripetal.d = self.direction + self.steerAngle + math.pi/2
end -- a2 = root(b2 + c2 - 2bcCosA), A = 90 - steerAngle, b = hB, c = radiusFront

function player:updateDragForce()
    local fDrag = self.v.m ^ 2 * (- unit(self.v))
    self.forceDrag = fdrag
end

function player:updateLateralForce()--wigggle cart ahh physics
    player:slipAngle()

    local frontLat = Vector.new(getSlipForceCurve(self.frontSlip,player.downforce * 0.5),self.direction + self.steerAngle - math.pi/2 )--* sign(self.frontSlip)
    local backLat = Vector.new(getSlipForceCurve(self.backSlip,player.downforce * 0.5),self.direction - math.pi/2 ) --* sign(self.backSlip)
    self.fLateral = frontLat + backLat

    self.torque = frontLat.m * math.cos(self.steerAngle) * self.wheelbase * 0.5 - backLat.m * self.wheelbase * 0.5
    self.angularAcceleration = self.torque / self.inertia
end

function player:slipAngle()
    local directionVector = Vector.new(1,self.v.d - self.direction)  
    self.backSlip = math.atan(directionVector:y()/abs(directionVector:x())) * 180 / math.pi
    directionVector.d = directionVector.d + self.steerAngle
    self.frontSlip = math.atan(directionVector:y()/abs(directionVector:x())) * 180 / math.pi
end

function getSlipForceCurve(slipAngle,downForce)
    local B, C, D, E = 0.6, 1.4, 1.1, -1.2
    local magnitude = downForce * D * math.sin(C * math.atan(B * (1 - E) * slipAngle + E * math.atan(B * slipAngle)))
    return magnitude
end