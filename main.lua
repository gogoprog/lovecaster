local objects = {}
local world
local function vector2(x, y)
    return {x=x, y=y}
end
local camera = {
    position = vector2(0, 0),
    direction = vector2(0, 0),
    lateral = vector2(0, 0),
    angle = 0,
    hfov = math.pi * 0.25
}
local viewport = {
    width = 800,
    height = 600
}
local wallH = 16

local lastMouseX = 0

function love.load()
    love.window.setTitle("lovecaster")
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true) 
    objects = {}

    addObject(128, 64, 50, 100)
    addObject(300, 128, 50, 50)
    addObject(64, 300, 10, 500)
    addObject(64, 300, 500, 10)
    addObject(200, 400, 500, 10)

    love.graphics.setBackgroundColor(0, 0, 0)
    love.window.setMode(viewport.width, viewport.height)
    camera.position.x = 400
    camera.position.y = 300
end

function love.update(dt)
    world:update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    elseif love.keyboard.isDown("q") then
        camera.angle = camera.angle - 3 * dt
    elseif love.keyboard.isDown("e") then
        camera.angle = camera.angle + 3 * dt
    end


    local mouseX = love.mouse.getX()

    if love.mouse.isDown(1) then
        local dx = mouseX - lastMouseX
        camera.angle = camera.angle + dx / 100
    end

    lastMouseX = mouseX


    local a = camera.angle
    camera.direction.x = math.cos(a)
    camera.direction.y = math.sin(a)
    camera.lateral.x = math.cos(a + 1.57)
    camera.lateral.y = math.sin(a + 1.57)
    local m = vector2(0, 0)

    if love.keyboard.isDown("w") then
        m.y = 1
    elseif love.keyboard.isDown("s") then
        m.y = -1
    end

    if love.keyboard.isDown("d") then
        m.x = 1
    elseif love.keyboard.isDown("a") then
        m.x = -1
    end

    if m.y ~= 0 then
        local p = camera.position
        local d = camera.direction
        local s = 100 * m.y
        p.x = p.x + d.x * dt * s
        p.y = p.y + d.y * dt * s
    end

    if m.x ~= 0 then
        local p = camera.position
        local d = camera.lateral
        local s = 100 * m.x
        p.x = p.x + d.x * dt * s
        p.y = p.y + d.y * dt * s
    end
end

function love.draw()
    local p = camera.position

    if love.keyboard.isDown("tab") then
        love.graphics.setColor(72, 160, 14)
        for k, v in ipairs(objects) do
          love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
        end

        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("fill", p.x, p.y, 4)

        local s = 10
        local d = camera.direction
        love.graphics.line(p.x, p.y, p.x + d.x * s, p.y + d.y * s)
    else
        love.graphics.setBlendMode("replace")
        drawSky()
        drawGround()
        drawWalls()
    end
end

function drawSky()
    love.graphics.setColor(100, 255, 255)
    love.graphics.rectangle("fill", 0, 0, viewport.width, viewport.height / 2)
end

function drawGround()
    love.graphics.setColor(139, 69, 19)
    love.graphics.rectangle("fill", 0, viewport.height / 2, viewport.width, viewport.height / 2)
end

function drawWalls()
    local p = camera.position
    local vw = viewport.width
    local vh = viewport.height
    local farPlane = 1000
    local d = (vw/2) / math.tan(camera.hfov)

    for x=-vw/2,vw/2 do
        local a2 = math.atan2(x, d)
        local a = camera.angle + a2
        local dx = math.cos(a) * farPlane
        local dy = math.sin(a) * farPlane
        local minFraction = 1
        local xn, yn

        world:rayCast(p.x, p.y, p.x + dx, p.y + dy, function(fixture, tx, ty, _xn, _yn, fraction)
            if fraction < minFraction then
                xn = _xn
                yn = _yn
                minFraction = fraction
            end
            return 1
        end)

        if minFraction < 1 then
            local h = (vh / wallH) / minFraction
            local xx = x + vw/2

            xn = xn * 0.5 + 0.5
            yn = yn * 0.5 + 0.5

            love.graphics.setColor(yn * 255, xn * 255, 128)
            love.graphics.line(xx, vh/2 + h * 0.3, xx, vh/2 - h * 0.7)
        end
    end
end

function addObject(x, y, w, h, r)
    obj = {}
    obj.body = love.physics.newBody(world, x, y)
    obj.shape = love.physics.newRectangleShape(w, h)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)

    table.insert(objects, obj)
end
