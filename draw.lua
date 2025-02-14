function printVectors(x,y)
    love.graphics.setColor(love.math.colorFromBytes(129, 252, 170))
    love.graphics.line(x,y,x + player.v:x() * scale,y + player.v:y() * scale)
    love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))
    love.graphics.line(x,y,x + scale * player.fLongitudinal:x() / player.mass, y + scale * player.fLongitudinal:y()/player.mass )
    love.graphics.line(x,y,x + scale * player.forceFriction:x() / player.mass, y + scale * player.forceFriction:y()/player.mass)
    love.graphics.line(x,y,x + scale * player.forceCentripetal:x() / player.mass, y + scale * player.forceCentripetal:y()/player.mass)
    love.graphics.line(x,y,x + scale * player.forceDrag:x() / player.mass, y + scale * player.forceDrag:y() / player.mass)
    love.graphics.setColor(love.math.colorFromBytes(235, 133, 53))
    love.graphics.line(x,y,x + scale * player.fLateral:x() / player.mass, y + scale * player.fLateral:y()/player.mass )
end

function printStats(x,y)
    love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))
    love.graphics.print("                   Velocity:", x, y); love.graphics.print(player.v.m,x + 130,y)
    love.graphics.print("      Centripetal force:", x, y + 20); love.graphics.print(player.forceCentripetal.m,x + 130,y + 20)
    love.graphics.print("         Front slipangle:", x, y + 40); love.graphics.print(player.frontSlip,x + 130,y + 40)
    love.graphics.print("          Rear slipangle:", x, y + 60); love.graphics.print(player.backSlip,x + 130,y + 60)
    love.graphics.print("            Lateral force:", x, y + 80); love.graphics.print(player.fLateral.m,x + 130,y + 80)
    love.graphics.print("Angular acceleration:", x, y + 100); love.graphics.print(player.angularAcceleration * 180 / math.pi,x + 130,y + 100)
    love.graphics.print("               Drag force:", x, y + 120); love.graphics.print(player.forceDrag.m,x + 130,y + 120)
    local i = player.frontSlip / player.backSlip
    if i > 1 then
        love.graphics.print("understeer",550,640)
    elseif i < 1 then
        love.graphics.print("oversteer",550,640)
    else
        love.graphics.print("neutralsteer",550,640)
    end
    
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