function printVectors(x,y)
    love.graphics.setColor(love.math.colorFromBytes(129, 252, 170))
    love.graphics.line(x,y,x + player.v:x() * scale,y + player.v:y() * scale)
    love.graphics.setColor(love.math.colorFromBytes(240, 238, 146))
    love.graphics.line(x,y,x + scale * player.forceApplied:x() / player.mass, y + scale * player.forceApplied:y()/player.mass )
    love.graphics.line(x,y,x + scale * player.forceFriction:x() / player.mass, y + scale * player.forceFriction:y()/player.mass )
    love.graphics.line(x,y,x + scale * player.forceCentripetal:x() / player.mass, y + scale * player.forceCentripetal:y()/player.mass)
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