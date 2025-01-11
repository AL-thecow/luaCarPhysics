function printVectors(x,y)
    love.graphics.setColor(love.math.colorFromBytes(129, 252, 170))
    love.graphics.line(x,y,x + player.v:x() * scale,y + player.v:y() * scale)
    love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))
    love.graphics.line(x,y,x + scale * player.fLongitudinal:x() / player.mass, y + scale * player.fLongitudinal:y()/player.mass )
    love.graphics.line(x,y,x + scale * player.forceFriction:x() / player.mass, y + scale * player.forceFriction:y()/player.mass)
    love.graphics.line(x,y,x + scale * player.forceCentripetal:x() / player.mass, y + scale * player.forceCentripetal:y()/player.mass)
    love.graphics.setColor(love.math.colorFromBytes(235, 133, 53))
    love.graphics.line(x,y,x + scale * player.fLateral:x() / player.mass, y + scale * player.fLateral:y()/player.mass )
end

function printStats(x,y)
    love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))
    love.graphics.print(player.v.m, x, y)
    love.graphics.print(player.forceCentripetal.m, x, y + 20)
    love.graphics.print(player.term1, x, y + 40)
    love.graphics.print(player.term2, x, y + 60)
    love.graphics.print(player.fLateral.m, x, y + 80)
    love.graphics.print(player.torque, x, y + 100)
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