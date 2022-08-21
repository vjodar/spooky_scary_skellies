local world=bump.newWorld(32)

function world:addItem(item) self:add(item,item.x,item.y,item.w,item.h) end
function world:drawItem(item) 
   love.graphics.rectangle('line',item.x,item.y,item.w,item.h)
end

return world