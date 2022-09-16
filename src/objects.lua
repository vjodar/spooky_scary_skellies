return {
    table={}, --holds all objects
    ySort=function(obj1,obj2) return obj1.y<obj2.y end, --sort function
    update=function(self)
        --sort objects by y-position to provide semi-3D perspective.
        table.sort(self.table,self.ySort)

        --update object. If it returns false, remove it from table
        for i,obj in ipairs(self.table) do 
            if obj:update()==false then 
                World:remove(obj)
                table.remove(self.table,i) 
            end
        end  
    end,
    draw=function(self)
        for i=1, #self.table do 
            --testing----------------------------------
            -- World:drawItem(self.table[i])
            --testing----------------------------------
            self.table[i]:draw() 
        end        
    end,
    clear=function(self) 
        for i=1,#self.table do World:remove(self.table[i]) end
        World:addItem(Player)
        self.table={Player} 
    end,
}