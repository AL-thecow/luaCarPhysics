--command l to launch code
 -- vector metatable:
 local Vector = {}
 Vector.__index = Vector
 
 -- vector constructor:
 function Vector.new(x, y)
   local v = {x = x or 0, y = y or 0}
   setmetatable(v, Vector)
   return v
 end
 
 -- vector addition:
 function Vector.__add(a, b)
   return Vector.new(a.x + b.x, a.y + b.y)
 end
 
 -- vector subtraction:
 function Vector.__sub(a, b)
   return Vector.new(a.x - b.x, a.y - b.y)
 end
 
 -- multiplication of a vector by a scalar:
 function Vector.__mul(a, b)
   if type(a) == "number" then
     return Vector.new(b.x * a, b.y * a)
   elseif type(b) == "number" then
     return Vector.new(a.x * b, a.y * b)
   else
     error("Can only multiply vector by scalar.")
   end
 end
 
 -- dividing a vector by a scalar:
 function Vector.__div(a, b)
    if type(b) == "number" then
       return Vector.new(a.x / b, a.y / b)
    else
       error("Invalid argument types for vector division.")
    end
 end
 
 -- vector equivalence comparison:
 function Vector.__eq(a, b)
     return a.x == b.x and a.y == b.y
 end
 
 -- vector not equivalence comparison:
 function Vector.__ne(a, b)
     return not Vector.__eq(a, b)
 end
 
 -- unary negation operator:
 function Vector.__unm(a)
     return Vector.new(-a.x, -a.y)
 end
 
 -- vector < comparison:
 function Vector.__lt(a, b)
      return a.x < b.x and a.y < b.y
 end
 
 -- vector <= comparison:
 function Vector.__le(a, b)
      return a.x <= b.x and a.y <= b.y
 end
 
 -- vector value string output:
 function Vector.__tostring(v)
      return "(" .. v.x .. ", " .. v.y .. ")"
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

function mapMouseToSteerAngle(dt, currentAngle)--angles are in radians
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

function updateNetForce()
    player.forceNet = player.forceApplied + player.forceCentripetal + player.forceFriction
end

function updateForceApplied(accel,angle)
    player.forceApplied.x = accel * math.cos(angle) * player.mass
    player.forceApplied.y = accel * math.sin(angle) * player.mass
end

function updateForceFriction(magnitudeOfVelocity)
    if abs(magnitudeOfVelocity) * scale > 0 and player.accel == 0 then
        player.forceFriction = -player.v * player.forceNormal / magnitudeOfVelocity
    else
        player.forceFriction = player.forceFriction * 0
    end
    --[[if abs(magnitudeOfVelocity) * scale < 1 then 
        player.forceFriction = player.forceFriction / player.forceNormal
    end
    if magnitudeOfVelocity == 0 then
        player.forceFriction = player.forceFriction * 0
    end]]
end

function updateForceCentripetal(magnitudeOfVelocity)
    if player.steerAngle == 0 then
        return 0
    end
    local radius = player.wheelbase / math.sin(player.steerAngle)
    local forceMagnitude = player.mass * magnitudeOfVelocity * magnitudeOfVelocity / abs(radius)
    local forceAngle = player.direction + player.steerAngle + math.pi/2 * player.steerAngle / abs(player.steerAngle)
    local newForce = Vector.new(math.cos(forceAngle),math.sin(forceAngle))
    player.forceCentripetal =  newForce * forceMagnitude
end

function carDirection(velocityVector,magnitudeOfVelocity, currentDirection)
    
    if magnitudeOfVelocity == 0 then
        return currentDirection
    end

    local newDirection = 0  
    newDirection = math.atan2(velocityVector.y,velocityVector.x)

    if abs(currentDirection - newDirection) > math.pi * 170 / math.pi then
        return newDirection - math.pi
    else
        return newDirection
    end

    
end

function updatePlayer(dt)

    local magnitudeOfVelocity = math.sqrt(player.v.x * player.v.x + player.v.y * player.v.y)
    mapMouseToSteerAngle()
    mapKeystoAcceleration()
    updateForceApplied(player.accel,player.steerAngle + player.direction)
    updateForceFriction(magnitudeOfVelocity)
    updateForceCentripetal(magnitudeOfVelocity)
    updateNetForce()
    if magnitudeOfVelocity == 0 then
        --player.direction = player.direction
    else
        --player.direction = math.atan(player.v.y/player.v.x)
        player.direction = carDirection(player.v, magnitudeOfVelocity, player.direction)
    end
    player.v = player.v + player.forceNet * dt / player.mass
    player.x = (player.x + player.v.x * dt * scale)
    player.y = (player.y + player.v.y * dt * scale) 
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
    printVectors(player.x,player.y)
    drawPedal()
    
end