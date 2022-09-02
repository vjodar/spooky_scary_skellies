function love.conf(t)
    t.title="Spooky Scary Skellies"          --The title of the window the game is in (string)
    t.version="11.4"            --The LOVE version this game was made for (string)
    t.console=true              --Attach a console (boolean, Windows only)
    t.window.width=1000         --The window width (number)
    t.window.height=750         --The window height (number)
    t.window.resizable=true

    --testing---------------
    -- t.window.vsync=false 
    --testing---------------

    t.modules.physics=false
    t.modules.joystick=false 
    t.modules.thread=false 
    t.modules.video=false 
end