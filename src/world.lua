local world=wf.newWorld

world=wf.newWorld()
world:addCollisionClass('player')
world:addCollisionClass('skeleton')
world:addCollisionClass('enemy')
world:addCollisionClass('projectile',
   {ignores={'projectile','player','skeleton','enemy'}}
)
world:addCollisionClass('solid')
--testing--------------------------------
-- world:setQueryDebugDrawing(true)
--testing--------------------------------

return world