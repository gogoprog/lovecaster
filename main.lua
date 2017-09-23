local objects
local world
local function vector2(x, y)
    return {x=x, y=y}
end
local camera = {
    position = vector2(0, 0),
    direction = vector2(0, 0),
    angle = 0,
    hfov = math.pi * 0.25
}
local viewport = {
    width = 640,
    height = 480
}
local wallH = 40

function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true) 
    objects = {}
    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 128, 64)
    objects.ground.shape = love.physics.newRectangleShape(50, 100)
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)

    love.graphics.setBackgroundColor(0, 0, 0)
    love.window.setMode(viewport.width, viewport.height)
    camera.position.x = 300
    camera.position.y = 300
end


function love.update(dt)
    world:update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    elseif love.keyboard.isDown("a") then
        camera.angle = camera.angle - 3 * dt
    elseif love.keyboard.isDown("d") then
        camera.angle = camera.angle + 3 * dt
    end

    local a = camera.angle
    camera.direction.x = math.cos(a)
    camera.direction.y = math.sin(a)
    local f = 0

    if love.keyboard.isDown("w") then
        f = 1
    elseif love.keyboard.isDown("s") then
        f = -1
    end

    if love.keyboard.isDown("up") then
        wallH = wallH + 1
        print(wallH)
    elseif love.keyboard.isDown("down") then
        wallH = wallH - 1
        print(wallH)
    end

    if f ~= 0 then
        local p = camera.position
        local d = camera.direction
        local s = 100* f
        p.x = p.x + d.x * dt * s
        p.y = p.y + d.y * dt * s
    end
end

function love.draw()
    local p = camera.position

    if love.keyboard.isDown("tab") then
        love.graphics.setColor(72, 160, 14)
        love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("fill", p.x, p.y, 4)

        local s = 10
        local d = camera.direction
        love.graphics.line(p.x, p.y, p.x + d.x * s, p.y + d.y * s)
    else
        love.graphics.setBlendMode("replace")
        love.graphics.setColor(100, 255, 255)
        love.graphics.rectangle("fill", 0, 0, viewport.width, viewport.height / 2)
        love.graphics.setColor(139, 69, 19)
        love.graphics.rectangle("fill", 0, viewport.height / 2, viewport.width, viewport.height / 2)

        rayCast()
    end
end


function rayCast()
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

        world:rayCast(p.x, p.y, p.x + dx, p.y + dy, function(fixture, tx, ty, xn, yn, fraction)
            local h = wallH / fraction
            local xx = x + vw/2

            love.graphics.setColor(yn * 255, xn * 255, 0)

            love.graphics.line(xx, vh/2 + h * 0.3, xx, vh/2 - h * 0.7)

            return 0
        end)

    end
end


