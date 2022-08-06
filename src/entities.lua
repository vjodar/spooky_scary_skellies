local entities={}

function entities:load() 
    self.table={} --all entites
    self.inDrawDistanceTable={} --entities within draw distance
    self.drawDistance={x=400,y=300}
    self.sort=function(e1,e2) return e1.y<e2.y end --sort function
end

function entities:update() 
    self.inDrawDistanceTable={} --clear table

    for _,e in pairs(self.table) do 
        if abs(Camera.target.x-e.x)<self.drawDistance.x
        and abs(Camera.target.y-e.y)<self.drawDistance.y 
        then table.insert(self.inDrawDistanceTable,e) end
    end

    table.sort(self.inDrawDistanceTable,self.sort) --sort by y position

    --update entity. If it returns false, remove it from table
    for _,e in pairs(self.inDrawDistanceTable) do 
        if e:update()==false then self:removeEntity(e) end
    end
end

function entities:draw() 
    for _,e in pairs(self.inDrawDistanceTable) do e:draw() end 
end

function entities:removeEntity(_e)
    for i,e2 in pairs(self.table) do 
        if e2==_e then table.remove(self.table,i) end
    end
end

return entities