return {
    table={}, --holds all objects
    shortCircuit=false, --used to immediately stop updating objects
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
            if self.shortCircuit then self.shortCircuit=false return end 
        end
    end,
    draw=function(self)
        for i=1, #self.table do 
            self.table[i]:draw() 
        end        
    end,
    clear=function(self) --destroys everthing except the Player
        local items,len=World:getItems()
        for i=1,len do World:remove(items[i]) end
        World:addItem(Player)
        self.table={Player} 
        self.shortCircuit=true 
    end,
    clearAll=function(self) --destroys everything
        local items,len=World:getItems()
        for i=1,len do World:remove(items[i]) end 
        self.table={}
        self.shortCircuit=true 
    end,
}