local objects={}
objects.table={} --holds all objects
objects.ySort=function(obj1,obj2) return obj1.y<obj2.y end --sort function

function objects:update()     
    --update object. If it returns false, remove it from table
    for i,obj in ipairs(self.table) do 
        if obj:update()==false then table.remove(self.table,i) end
    end
    
    --sort objects by y-position to provide semi-3D perspective.
    --sort after updating to preserve non-deterministic collision priority.
    table.sort(self.table,self.ySort)
end

function objects:draw() 
    for i=1, #self.table do 
        self.table[i]:draw() 
        --testing----------------------------------
        World:drawItem(self.table[i])
        --testing----------------------------------
    end
end

function objects:clear() self.table={} end 

return objects