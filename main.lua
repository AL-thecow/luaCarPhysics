--command l to launch code
 -- vector metatable:
 local Vector = {}
 Vector.__index = Vector
 
 -- vector constructor:
 function Vector.new(m, d)--magnitude and direction
   local v = {m = m or 0, d = d or 0}
   setmetatable(v, Vector)
   return v
 end
 
 -- vector addition:
 function Vector.__add(a, b)
    if type(a) == "number" or type(b) == "number" then
        error("cannot add scalar to vector")
    end
    local x = a:x() + b:x()
    local y = a:y() + b:y()
    local newMagnitude = math.sqrt(x * x + y * y)
    local newDirection = math.atan2(y,x)
    return Vector.new(newMagnitude,newDirection)
 end
 
 -- vector subtraction:
 function Vector.__sub(a, b)
    local x = a:x() - b:x()
    local y = a:y() - b:y()
    local newMagnitude = math.sqrt(x * x + y * y)
    local newDirection = math.atan2(y,x)
    return Vector.new(newMagnitude,newDirection)
 end
 
 -- multiplication of a vector by a scalar:
 function Vector.__mul(a, b)
   if type(a) == "number" then
     return Vector.new(b.m * a, b.d)
   elseif type(b) == "number" then
     return Vector.new(a.m * b, a.d)
   else
     error("Can only multiply vector by scalar.")
   end
 end
 
 -- dividing a vector by a scalar:
 function Vector.__div(a, b)
    if type(b) == "number" then
       return Vector.new(a.m / b,a.d)
    else
       error("Invalid argument types for vector division.")
    end
 end
 
 -- vector equivalence comparison:
 function Vector.__eq(a, b)
     return a.m == b.m and a.d == b.d
 end
 
 -- vector not equivalence comparison:
 function Vector.__ne(a, b)
     return not Vector.__eq(a, b)
 end
 
 -- unary negation operator:
 function Vector.__unm(a)
     --return Vector.new(-a.x, -a.y)
    if a.d < math.pi then
        return Vector.new(a.m,a.d + math.pi)
    else
        a.d = a.d - math.pi
        return Vector.new(a.m,a.d - math.pi)
    end
 end
 
 -- vector < comparison:
 function Vector.__lt(a, b)
      error("cannot compare vectors")
 end
 
 -- vector <= comparison:
 function Vector.__le(a, b)
      error("cannot compare vectors")
 end
 
 -- vector value string output:
 function Vector.__tostring(v)
      return "(" .. v.m .. ", " .. v.d .. ")"
 end

 function Vector:x ()
    return self.m * math.cos(self.d)
 end
 
 function Vector:y ()
    return self.m * math.sin(self.d)
 end

 function Vector:u ()
    return Vector.new(1,self.d)
 end
 
 function checkKeys()

    if love.keyboard.isDown("up")  or love.keyboard.isDown("w")then
        keys.up = true
    else 
        keys.up = false
    end
    
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        keys.down = true
    else 
        keys.down = false
    end

    if love.keyboard.isDown("space") then
        keys.space = true
    else 
        keys.space = false
    end

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        keys.right = true
    else 
        keys.right = false
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        keys.left = true
    else 
        keys.left = false
    end

    if love.keyboard.isDown("g") then
        keys.g = true
    else 
        keys.g = false
    end

end

function wallCollision()
    if player.x < 0 then
        player.x = 0
        player.v = 0
    end
    if player.y < 0 then
        player.y = 0
        player.v = 0
    end
    if player.x > w then
        player.x = w
        player.v = 0
    end
    if player.y > h then
        player.y = h
        player.v = 0
    end
end

function abs(input)
    if type(input) ~= "number" then
        error("cannot use absolute function on non-numbers")
    end
    if input < 0 then
        return input * -1
    end
    return input
end

function drawPedal()
    love.graphics.setColor(love.math.colorFromBytes(227, 252, 236))--gray227, 252, 236
    love.graphics.rectangle("fill",pedal.x - pedal.w/2, pedal.y - pedal.h/2, pedal.w, pedal.h)

    if player.steerAngle > 0 then--change colour to green or red depending on acceleration
        love.graphics.setColor(love.math.colorFromBytes(129, 252, 170))--green 129, 252, 170
    else 
        love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))--yellow 240, 238, 146
    end
    love.graphics.rectangle("fill", pedal.x, pedal.y - pedal.innerHeight/2,pedal.innerWidth,pedal.innerHeight)
end

function updatePedal()
    pedal.innerWidth = player.steerAngle * pedal.maxWidth / maxSteerAngle 
end

function mapMouseToSteerAngle()--angles are in radians
    player.steerAngle = (mouseX - pedal.x) * 0.2 * math.pi / 180
    if abs(player.steerAngle) > maxSteerAngle then
        player.steerAngle = maxSteerAngle * player.steerAngle / abs(player.steerAngle)
    end
end

function mapKeystoAcceleration()
    if keys.up then
        player.accel = 2
    elseif keys.down then 
        player.accel = -2
    else
        player.accel = 0
    end
end

function printVectors(x,y)
    love.graphics.setColor(love.math.colorFromBytes(129, 252, 170))
    love.graphics.line(x,y,x + player.v.x * scale,y + player.v.y * scale)
    love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))
    love.graphics.line(x,y,x + scale * player.forceApplied.x / player.mass, y + scale * player.forceApplied.y/player.mass )
    love.graphics.line(x,y,x + scale * player.forceFriction.x / player.mass, y + scale * player.forceFriction.y/player.mass )
    love.graphics.line(x,y,x + scale * player.forceCentripetal.x / player.mass, y + scale * player.forceCentripetal.y/player.mass)
end

function updateNetForce(target)
    return target.forceApplied + target.forceCentripetal + target.forceFriction
end

function updateForceApplied(target)
    local magnitude = target.accel * target.mass
    local direction = target.steerAngle + target.direction
    return Vector.new(magnitude,direction)
end

function updateForceFriction(target)
    if abs(target.v.m) * scale > 0 and target.accel == 0 then
        return (- target.v:u()) * target.forceNormal
    else
        return (- target.v:u()) * 0
    end
end

function updateForceCentripetal(target)
    if target.steerAngle == 0 then
        return Vector.new(0,target.steerAngle)
    end
    local radius = target.wheelbase / math.sin(target.steerAngle)
    local forceMagnitude = target.mass * target.v.m * target.v.m / abs(radius)
    local forceAngle = target.direction + target.steerAngle + math.pi/2 * target.steerAngle / abs(target.steerAngle)
    local newForce = Vector.new(forceMagnitude,forceAngle)
    return newForce 
end


function carDirection(target)
    
    --[[if magnitudeOfVelocity == 0 then
        return currentDirection
    end

    local newDirection = 0  
    newDirection = math.atan2(velocityVector.y,velocityVector.x)

    if abs(currentDirection - newDirection) > math.pi * 170 / math.pi then
        return newDirection - math.pi
    else
        return newDirection
    end]]
    return target.v.d
    
end

function updatePlayer(dt)

    --local magnitudeOfVelocity = math.sqrt(player.v.x * player.v.x + player.v.y * player.v.y)
    mapMouseToSteerAngle()
    mapKeystoAcceleration()
    player.forceApplied = updateForceApplied(player)
    player.forceFriction = updateForceFriction(player)
    player.forceCentripetal = updateForceCentripetal(player)
    player.forceNet = updateNetForce(player)
    --if magnitudeOfVelocity == 0 then
        --player.direction = player.direction
    --else
        --player.direction = math.atan(player.v.y/player.v.x)
    player.direction = carDirection(player)
    --end
    player.v = player.v + player.forceNet * dt / player.mass
    player.x = (player.x + player.v:x() * dt * scale)
    player.y = (player.y + player.v:y() * dt * scale) 
end
function love.load()
    w = 1000
    h = 750
    scale = 20 --pixels per meter
    --local v1 = Vector.new(2, 3)
    --local v2 = Vector.new(4, 6)

    player = {}
    player.x = w/2--initial position
    player.y = h/2--initial position
    player.mass = 1000
    player.width = 40
    player.height = 60
    player.wheelbase = 3
    player.steerAngle = 0
    player.direction = 0
    player.accel = 0
    player.v = Vector.new(0,0)
    player.forceNet = Vector.new(0,0)
    player.forceApplied = Vector.new(0,0)
    player.forceFriction = Vector.new(0,0)
    player.forceCentripetal = Vector.new(0,0)
    player.forceNormal = player.mass * 9.81 * .05
    keys = {}

    pedal = {}
    pedal.x = 500
    pedal.y = 700
    pedal.w = 180
    pedal.h = 40
    pedal.innerWidth = 0
    pedal.innerHeight = 30
    maxSteerAngle = math.pi * 0.33
    pedal.maxWidth = (pedal.w - 10) / 2

    tireWidth = 10
    tireHeight = 20
end

function love.update(dt) 
    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    
    
    checkKeys()
    updatePedal()
    updatePlayer(dt)
end

function love.draw()
    
    love.graphics.setColor(200, 200, 200)
    love.graphics.setColor(255, 0, 0)

    love.graphics.push()--227, 252, 236
        love.graphics.translate(player.x, player.y)
       
        love.graphics.rotate(player.direction)
        --love.graphics.rectangle("fill", - player.width/2, -player.height, player.width, player.height)
        
        love.graphics.rectangle("fill", 0, -player.width/2, player.height, player.width)
        
        love.graphics.setColor(love.math.colorFromBytes(227, 252, 236))

        love.graphics.push()--left tire
            love.graphics.translate(player.height, - player.width/2)
            love.graphics.rotate(player.steerAngle)
            love.graphics.rectangle("fill",-tireHeight/2,-tireWidth/2,tireHeight,tireWidth)
        love.graphics.pop()
        love.graphics.push()--right tire
            love.graphics.translate(player.height,player.width/2)
            love.graphics.rotate(player.steerAngle)
            love.graphics.rectangle("fill",-tireHeight/2,- tireWidth/2,tireHeight,tireWidth)
        love.graphics.pop()
    love.graphics.pop()
    --printVectors(player.x,player.y)
    drawPedal()
    
end