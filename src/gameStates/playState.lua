local startTitleScreen=function(self)
    GameScale=2
    Camera:zoomTo(GameScale)
    love.graphics.setPointSize(GameScale)
    love.graphics.setLineWidth(GameScale)

    LevelManager:buildTitleScreenLevel()
    TitleScreenState:start()
end

local startGame=function(self)
    local buildStartingLevel=function()
        World:addItem(Player)
        table.insert(Objects.table,Player)
        Camera.smoother=Camera.smooth.damped(10)
        Camera.target=Player.center    
        LevelManager.currentLevel.boundaries={}
        Objects:clear()
        LevelManager.update=LevelManager.updateStandard
        LevelManager:buildTutorialLevel()
        CutsceneState:tutorialCutscene()
    end
    FadeState:fadeBoth({fadeTime=0.4,afterFn=buildStartingLevel,holdTime=0.4})
end

return { --The Module
    startTitleScreen=startTitleScreen,
    startGame=startGame,
    update=function(self)
        Camera:update()
        LevelManager:update()
        Objects:update()
        SpecialAttacks:update()
        ParticleSystem:update()
        UI:update()
        Hud:update()
    end,
    draw=function(self)
        LevelManager:draw()
        Objects:draw()
        SpecialAttacks:draw()
        LevelManager:drawForeground()
        ParticleSystem:draw()
        UI:draw()
        Hud:draw()
    end,
}
