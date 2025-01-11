--command l to launch code
 -- vector metatable:
 Vector = {}
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

 function dot(a,b)
    if type(a) == "number" or type(b) == "number" then
        error("invalid input to dot product")
    end
    return a:x() * b:x() + a:y() * b:y()
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

function sign(input)
    if type(input) ~= "number" then
        error("not a number in sign function")
    end
    if input == 0 then
        return 1
    end
    return abs(input) / input
end