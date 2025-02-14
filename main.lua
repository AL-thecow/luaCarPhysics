w = 1280
h = 720
scale = 10  --pixels per meter
require ("constants")
require ("player")
require ("draw")





function mapKeystoAcceleration()
    if keys.up then
        player.accel = 10
    elseif keys.down then 
        player.accel = -10
    else
        player.accel = 0
    end
end

function love.load()
    
    

    
    keys = {}

    pedal = {}
    pedal.x = 640
    pedal.y = 680
    pedal.w = 180
    pedal.h = 40
    pedal.innerWidth = 0
    pedal.innerHeight = 30
    maxSteerAngle = math.pi * 0.33
    pedal.maxWidth = (pedal.w - 10) / 2

    tireWidth = scale/2
    tireHeight = scale
end

function love.update(dt) 
    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    
    
    checkKeys()
    updatePedal()
    player:updatePlayer(dt)
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
        love.graphics.rectangle("fill", -tireHeight/2, -player.width/2 - tireWidth/2, tireHeight, tireWidth)
        love.graphics.rectangle("fill", -tireHeight/2, player.width/2 - tireWidth/2, tireHeight, tireWidth)
        --love.graphics.rectangle("fill", 0, -player.width/2, player.height, player.width)

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
    printStats(10,10)
    drawPedal()
    
end