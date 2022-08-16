local objects={}
objects.table={} --all entites
objects.inDrawDistanceTable={} --objects within draw distance
objects.drawDistance={x=400,y=300}
objects.sort=function(obj1,obj2) return obj1.y<obj2.y end --sort function

function objects:update() 
    self.inDrawDistanceTable={} --clear table

    for _,obj in pairs(self.table) do 
        if abs(Camera.target.x-obj.x)<self.drawDistance.x
        and abs(Camera.target.y-obj.y)<self.drawDistance.y 
        then table.insert(self.inDrawDistanceTable,obj) end
    end

    table.sort(self.inDrawDistanceTable,self.sort) --sort by y position

    --update entity. If it returns false, remove it from table
    for _,obj in pairs(self.inDrawDistanceTable) do 
        if obj:update()==false then self:removeEntity(obj) end
    end
end

function objects:draw() 
    for _,obj in pairs(self.inDrawDistanceTable) do obj:draw() end 
end

function objects:removeEntity(obj1)
    for i,obj2 in pairs(self.table) do 
        if obj2==obj1 then table.remove(self.table,i) end
    end
end

return objects