local world=bump.newWorld(8)

function world:addItem(item) self:add(item,item.x,item.y,item.w,item.h) end
function world:drawItem(item) 
   love.graphics.rectangle('line',item.x,item.y,item.w,item.h)
end

--collision filters that specify how an entity collides with another
world.collisionFilters={
   ally=function(item,other)
      local class=other.collisionClass
      if class=='enemy' then return 'bounce'
      elseif class=='ally' then return 'cross' 
      elseif class=='solid' or class=='pit' or class=='boundary' or class=='exit' then return 'slide'
      end 
   end,
   allyFlying=function(item,other)
      local class=other.collisionClass
      if class=='enemy' then return 'bounce'
      elseif class=='ally' then return 'cross' 
      elseif class=='solid' or class=='boundary' or class=='exit' then return 'slide' 
      end 
   end,
   enemy=function(item,other)
      local class=other.collisionClass 
      if class=='ally' then return 'bounce'
      elseif class=='enemy' then return 'cross'
      elseif class=='solid' or class=='pit' or class=='boundary' or class=='exit' then return 'slide' 
      end
   end,
   enemyFlying=function(item,other)
      local class=other.collisionClass 
      if class=='ally' then return 'bounce'
      elseif class=='enemy' then return 'cross'
      elseif class=='solid' or class=='boundary' or class=='exit' then return 'slide'
      end
   end,
   allyProjectile=function(item,other)
      local class=other.collisionClass
      if class=='enemy' then return 'touch'
      elseif class=='solid' or class=='exit' then return 'bounce'
      end
   end,
   enemyProjectile=function(item,other)
      local class=other.collisionClass
      if class=='ally' then return 'touch'
      elseif class=='solid' or class=='exit' then return 'bounce'
      end
   end,
   intangible=function(item,other) 
      local class=other.collisionClass 
      if class=='solid' or class=='exit' then return 'bounce' end 
   end,
}

--used for segment queries to check LOS of an attack target or moveTarget
world.queryFilters={
   ally=function(item) return item.collisionClass=='ally' end,
   enemy=function(item) return item.collisionClass=='enemy' end,
   solid=function(item) return item.collisionClass=='solid' end,
   pitOrSolid=function(item) 
      local class=item.collisionClass
      return class=='pit' or class=='solid'
   end,
   pitOrBoundary=function(item) 
      local class=item.collisionClass
      return class=='pit' or class=='boundary'
   end,
   solidOrBoundary=function(item) 
      local class=item.collisionClass
      return class=='solid' or class=='boundary'
   end,
   pitOrSolidOrBoundary=function(item) 
      local class=item.collisionClass
      return class=='pit' or class=='solid' or class=='boundary'
   end,
}

return world