local world=bump.newWorld(8)

function world:addItem(item) self:add(item,item.x,item.y,item.w,item.h) end
function world:drawItem(item) 
   love.graphics.rectangle('line',item.x,item.y,item.w,item.h)
end

--collision filters
world.collisionFilters={
   ally=function(item,other)
      local class=other.collisionClass
      if class=='enemy' then return 'bounce'
      elseif class=='ally' then return 'cross' 
      elseif class=='solid' then return 'slide' 
      end 
   end,
   enemy=function(item,other)
      local class=other.collisionClass 
      if class=='ally' then return 'bounce'
      elseif class=='enemy' then return 'cross'
      elseif class=='solid' then return 'slide'
      end
   end,
   allyProjectile=function(item,other)
      local class=other.collisionClass
      if class=='enemy' then return 'touch'
      elseif class=='solid' then return 'bounce'
      end
   end,
   enemyProjectile=function(item,other)
      local class=other.collisionClass
      if class=='ally' then return 'touch'
      elseif class=='solid' then return 'bounce'
      end
   end,
}

world.queryFilters={
   ally=function(item) 
      local class=item.collisionClass 
      if class=='enemy' then return true end 
   end,
   enemy=function(item) 
      local class=item.collisionClass 
      if class=='ally' then return true end
   end,
}

return world