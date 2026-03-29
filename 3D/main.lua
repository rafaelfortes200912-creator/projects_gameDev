local angulo = 0
local cameraY = 0 
local lastY = 0 -- Guarda a posição anterior do mouse para o cálculo de arrasto

function love.load()
    love.graphics.setBackgroundColor(1, 1, 0) -- Fundo Amarelo

    local s = 100 
    vertices = {
        {x = -s, y = -s, z = -s}, {x =  s, y = -s, z = -s}, 
        {x =  s, y =  s, z = -s}, {x = -s, y =  s, z = -s}, 
        {x = -s, y = -s, z =  s}, {x =  s, y = -s, z =  s}, 
        {x =  s, y =  s, z =  s}, {x = -s, y =  s, z =  s}
    }

    faces = {
        {1, 2, 3, 4}, {5, 6, 7, 8}, {1, 5, 8, 4}, 
        {2, 6, 7, 3}, {1, 2, 6, 5}, {4, 3, 7, 8}
    }
end

function love.update(dt)
    -- Giro automático horizontal
    angulo = love.timer.getTime()

    -- Verifica se o botão ESQUERDO (1) está pressionado
    if love.mouse.isDown(1) then
        local currentY = love.mouse.getY()
        -- Se for o primeiro frame do clique, inicializamos o lastY
        if lastY == 0 then lastY = currentY end
        
        -- Calcula a diferença de movimento do mouse e ajusta a inclinação
        local dy = currentY - lastY
        cameraY = cameraY + dy * 0.01
        
        lastY = currentY
    else
        -- Reseta o rastreador quando solta o botão
        lastY = 0
    end
end

function love.draw()
    local cx, cy = love.graphics.getWidth()/2, love.graphics.getHeight()/2
    local fov = 400

    local function rotacionar_e_projetar(v)
        -- 1. Rotação Automática (Eixo Y - Horizontal)
        local cosA, sinA = math.cos(angulo), math.sin(angulo)
        local rx = v.x * cosA - v.z * sinA
        local rz = v.x * sinA + v.z * cosA

        -- 2. Rotação da Câmera (Eixo X - Vertical) controlada pelo mouse
        local cosC, sinC = math.cos(cameraY), math.sin(cameraY)
        local ry = v.y * cosC - rz * sinC
        local finalZ = v.y * sinC + rz * cosC

        -- 3. Projeção 3D para 2D
        local z = finalZ + 400 
        local x = (rx * fov) / z + cx
        local y = (ry * fov) / z + cy
        return x, y
    end

    -- Desenho das faces
    for _, face in ipairs(faces) do
        local pontos = {}
        for _, vIdx in ipairs(face) do
            local x, y = rotacionar_e_projetar(vertices[vIdx])
            table.insert(pontos, x)
            table.insert(pontos, y)
        end
        
        -- Preenchimento Rosa
        love.graphics.setColor(1, 0.4, 0.8)
        love.graphics.polygon("fill", pontos)
        
        -- Contorno Azul
        love.graphics.setLineWidth(2)
        love.graphics.setColor(0, 0, 1)
        love.graphics.polygon("line", pontos)
    end
end