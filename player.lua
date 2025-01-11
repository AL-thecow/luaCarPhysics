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
player.fLateral = Vector.new(0,0)
player.fLongitudinal = Vector.new(0,0)
player.forceNet = Vector.new(0,0)
player.forceFriction = Vector.new(0,0)
player.forceCentripetal = Vector.new(0,0)
player.forceNormal = player.mass * 9.81 * .05
player.lateralOffset = 1
player.longitudinalOffset = 1.5
player.aV = 0
player.term1 = 0
player.term2 = 0

function player:updatePlayer(dt)

    --local magnitudeOfVelocity = math.sqrt(player.v.x * player.v.x + player.v.y * player.v.y)
    
    mapMouseToSteerAngle()
    mapKeystoAcceleration()
    self:updateLongitudinalForce(dt)
    self:updateCentripetalForce(dt)
    self:updateLateralForce()
    self:updateForceFriction()
    --self:updateForceCentripetal()
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
    self.forceNet = self.fLongitudinal + self.forceCentripetal --+ self.fLateral

    
end



function player:updateForceFriction()
    if abs(self.v.m) * scale > 0 and self.accel == 0 then
        self.forceFriction = (- self.v:u()) * self.forceNormal
    else
        self.forceFriction = (- self.v:u()) * 0
    end
end


function player:carDirection(dt)
    --self.angularVelocity = self.angularVelocity + self.angularAcceleration * dt
    --self.direction = self.direction + self.angularVelocity * dt

    --self.direction = self.direction + self.aV * dt
    
    self.direction = self.v.d
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
    --[[local hB = self.wheelbase / 2
    local theta = math.pi/2 - abs(self.steerAngle)
    local inputToSqrt = hB ^ 2 + radiusFront ^ 2 - 2 * hB * radiusFront * math.cos(theta)
    if inputToSqrt < 0 then
        error("negative in sqrt")
    end
    local realRadius = math.sqrt(inputToSqrt)]]
    local magnitude = self.mass * self.v.m * self.v.m / radiusFront
    self.aV = self.v.m / radiusFront
    self.forceCentripetal.m = magnitude
    self.forceCentripetal.d = self.direction + self.steerAngle + math.pi/2
end -- a2 = root(b2 + c2 - 2bcCosA), A = 90 - steerAngle, b = hB, c = radiusFront

function player:updateLateralForce()
    local directionVector = Vector.new(1,self.direction)
    self.term2 = math.acos(dot(self.v,directionVector) / self.v.m) * 180 / math.pi -- front
    directionVector.d = directionVector.d + self.steerAngle
    self.term1 = math.acos(dot(self.v,directionVector) / self.v.m) * 180 / math.pi -- back

    local frontLat = Vector.new(getSlipForceCurve(self.term1),self.direction + self.steerAngle + math.pi/2)
    local backLat = Vector.new(getSlipForceCurve(self.term2),self.direction + math.pi/2)
    self.fLateral = frontLat + backLat

    self.torque = frontLat.m * math.cos(self.steerAngle) * self.wheelbase * 0.5 - backLat.m * self.wheelbase * 0.5
    self.angularAcceleration = self.torque / self.inertia
end

function getSlipForceCurve(slipAngle)
    local B, C, D, E = -0.3, 2.5, 5000, 1
    local magnitude = D * math.sin(C * math.atan(B * (1 - E) * slipAngle + E * math.atan(B * slipAngle)))
    return magnitude
end