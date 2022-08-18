local objects={}
objects.table={} --holds all objects
objects.inDrawDistanceTable={} --objects within draw distance
objects.drawDistance={x=400,y=300}
objects.sort=function(obj1,obj2) return obj1.y<obj2.y end --sort function

function objects:update() 
    self.inDrawDistanceTable={} --clear table

    --fill inDrawDistanceTable with objects within draw distance
    for i=1, #self.table do
        if abs(Camera.target.x-self.table[i].x)<self.drawDistance.x
        and abs(Camera.target.y-self.table[i].y)<self.drawDistance.y 
        then table.insert(self.inDrawDistanceTable,self.table[i]) end
    end

    table.sort(self.inDrawDistanceTable,self.sort) --sort by y position

    --update object. If it returns false, remove it from table
    for i=1, #self.inDrawDistanceTable do 
        if self.inDrawDistanceTable[i]:update()==false then 
            self:removeObject(self.inDrawDistanceTable[i]) 
        end
    end
end

function objects:draw() 
    for i=1, #self.inDrawDistanceTable do self.inDrawDistanceTable[i]:draw() end
end

function objects:removeObject(obj1)
    for i=1, #self.table do 
        if self.table[i]==obj1 then table.remove(self.table,i) end
    end
end

function objects:clear() self.table={} end 

return objects