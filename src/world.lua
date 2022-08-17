local world=wf.newWorld()
world:addCollisionClass('player')
world:addCollisionClass('skeleton')
world:addCollisionClass('enemy')
world:addCollisionClass('allyProjectile',{
   ignores={'allyProjectile','player','skeleton'}
})
world:addCollisionClass('enemyProjectile',{
   ignores={'enemyProjectile','allyProjectile','enemy'}
})
world:addCollisionClass('solid')

--testing--------------------------------
-- world:setQueryDebugDrawing(true)
--testing--------------------------------

return world