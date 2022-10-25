return {
    acceptInput=false, --flag to restrict inputs to one state at a time
    stack={},
    addState=function(self,newState)
        for i=1,#self.stack do --prevent duplicates
            if newState==self.stack[i] then 
                print('That state is already on the stack')
                return 
            end
        end
        table.insert(self.stack,newState)
    end,
    update=function(self)
        local stackLength=#self.stack
        for i,gameState in ipairs(self.stack) do 
            self.acceptInput=(i==stackLength) --used to restrict inputs to top gameState
            --run each state in the stack, remove any that return false
            if gameState:update()==false then table.remove(self.stack,i) end
        end
    end,
    draw=function(self)
        for i=1, #self.stack do 
            if self.stack[i].draw then self.stack[i]:draw() end 
        end
    end,
}