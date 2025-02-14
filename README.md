# luaCarPhysics
2D car engine on love2D framework. WIP
## Key simulations: 
* tire dynamics
* rotational dynamics
## Outcomes:  
* drifting
* oversteer
* understeer
## Issues
* Steering is based on centripetal force instead of torque
    * causes unnecessary rotation when parked
* Slip angle formula does not align with coordinate system
<img width="996" alt="Screenshot 2025-02-10 at 11 09 47 AM" src="https://github.com/user-attachments/assets/658e9c6f-a04e-4532-af81-f3c1ae44d61b" />
Description: the bottom bar is a steering wheel and the lines drawn from the car represent the vectors that are related to it. Green = Velocity, Yellow & Orange = Forces.
