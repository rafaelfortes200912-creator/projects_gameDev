local world
local caixas = {}
local mouseJoint = nil

function love.load()
    -- Fundo: Um cinza azulado "claro" (mais profissional e menos cansativo que o amarelo)
    love.graphics.setBackgroundColor(0.2, 0.25, 0.3)

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    -- CHÃO: Cinza escuro/Asfalto
    chao = {}
    chao.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight() - 20, "static")
    chao.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 40)
    chao.fixture = love.physics.newFixture(chao.body, chao.shape)

    -- Criar caixas iniciais
    for i = 1, 12 do
        criarCaixa(math.random(100, 700), math.random(100, 300))
    end
end

function criarCaixa(x, y)
    local c = {}
    c.body = love.physics.newBody(world, x, y, "dynamic")
    c.shape = love.physics.newRectangleShape(50, 50)
    c.fixture = love.physics.newFixture(c.body, c.shape, 2) -- Mais densas para parecerem madeira
    c.fixture:setRestitution(0.2) -- Menos "pula-pula", mais "caixa de madeira"
    c.fixture:setFriction(0.5)    -- Atrito para empilhar melhor
    table.insert(caixas, c)
end

function love.update(dt)
    world:update(dt)
    if mouseJoint then
        mouseJoint:setTarget(love.mouse.getPosition())
    end
end

function love.draw()
    -- 1. Desenhar o Chão
    love.graphics.setColor(0.1, 0.1, 0.1) -- Quase preto
    love.graphics.polygon("fill", chao.body:getWorldPoints(chao.shape:getPoints()))

    -- 2. Desenhar as Caixas
    for _, c in ipairs(caixas) do
        -- Cor da Caixa: Marrom madeira (RGB: 139, 69, 19 convertido para 0-1)
        love.graphics.setColor(0.54, 0.27, 0.07)
        love.graphics.polygon("fill", c.body:getWorldPoints(c.shape:getPoints()))
        
        -- Detalhes/Bordas: Marrom escuro
        love.graphics.setLineWidth(2)
        love.graphics.setColor(0.3, 0.15, 0.05)
        love.graphics.polygon("line", c.body:getWorldPoints(c.shape:getPoints()))
        
        -- Desenha um "X" na caixa para parecer um caixote de carga
        local points = {c.body:getWorldPoints(c.shape:getPoints())}
        love.graphics.line(points[1], points[2], points[5], points[6])
        love.graphics.line(points[3], points[4], points[7], points[8])
    end

    -- 3. Desenhar a linha do Mouse (o "fio" que puxa a caixa)
    if mouseJoint then
        love.graphics.setColor(1, 1, 1, 0.5) -- Branco transparente
        local x1, y1 = mouseJoint:getAnchors()
        local x2, y2 = love.mouse.getPosition()
        love.graphics.line(x1, y1, x2, y2)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        for _, c in ipairs(caixas) do
            if c.fixture:testPoint(x, y) then
                mouseJoint = love.physics.newMouseJoint(c.body, x, y)
                mouseJoint:setMaxForce(10000) -- Força alta para arremessos potentes
                break
            end
        end
    -- BÔNUS: Botão direito cria uma caixa nova
    elseif button == 2 then
        criarCaixa(x, y)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and mouseJoint then
        mouseJoint:destroy()
        mouseJoint = nil
    end
end