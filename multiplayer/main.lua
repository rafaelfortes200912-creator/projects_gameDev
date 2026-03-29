local p1, p2
local estadoGlobal = "jogando" 
local tempoP1, tempoP2 = 0, 0
local velocidadeBase = 220

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.08)
    larguraFaixa = (love.graphics.getWidth() / 2) / 4

    -- Inicializa Jogador 1
    p1 = {
        ativo = true, faixa = 2, campo_x = 0, 
        cor = {1, 0.4, 0.8}, caixas = {}, timer = 0, tempoVivo = 0
    }
    -- Inicializa Jogador 2
    p2 = {
        ativo = true, faixa = 3, campo_x = love.graphics.getWidth()/2, 
        cor = {0, 0.6, 1}, caixas = {}, timer = 0, tempoVivo = 0
    }
end

function criarCaixa(player)
    local c = {
        faixa = math.random(1, 4),
        y = -60,
        tamanho = larguraFaixa * 0.7
    }
    c.x = (c.faixa - 1) * larguraFaixa + player.campo_x + (larguraFaixa * 0.15)
    table.insert(player.caixas, c)
end

function atualizarLado(p, dt)
    if not p.ativo then return end

    p.tempoVivo = p.tempoVivo + dt
    local vel = velocidadeBase + (p.tempoVivo * 15)

    -- Gerar caixas no tempo deste player
    p.timer = p.timer - dt
    if p.timer <= 0 then
        criarCaixa(p)
        p.timer = math.max(0.4, 1.4 - (p.tempoVivo * 0.05))
    end

    -- Mover caixas e checar colisão
    for i = #p.caixas, 1, -1 do
        local c = p.caixas[i]
        c.y = c.y + vel * dt
        
        -- Colisão
        if c.y + c.tamanho > love.graphics.getHeight() - 60 and c.y < love.graphics.getHeight() - 20 then
            if p.faixa == c.faixa then
                p.ativo = false -- Este jogador perdeu, mas o outro continua
            end
        end

        if c.y > love.graphics.getHeight() then table.remove(p.caixas, i) end
    end
end

function love.update(dt)
    if not p1.ativo and not p2.ativo then
        estadoGlobal = "fim"
        return
    end

    atualizarLado(p1, dt)
    atualizarLado(p2, dt)
end

function love.draw()
    local meio = love.graphics.getWidth() / 2
    local altura = love.graphics.getHeight()

    -- Desenhar campos
    local function desenharCampo(p, nome)
        -- Se o player morreu, escurece o campo dele
        if not p.ativo then love.graphics.setColor(0.2, 0, 0, 0.5)
        else love.graphics.setColor(1, 1, 1, 0.03) end
        love.graphics.rectangle("fill", p.campo_x, 0, meio, altura)

        -- Jogador
        if p.ativo then
            love.graphics.setColor(p.cor)
            local x = (p.faixa - 1) * larguraFaixa + p.campo_x + (larguraFaixa * 0.15)
            love.graphics.rectangle("fill", x, altura - 60, larguraFaixa * 0.7, 30, 5)
        end

        -- Caixas
        love.graphics.setColor(0.9, 0.1, 0.1)
        for _, c in ipairs(p.caixas) do
            love.graphics.rectangle("fill", c.x, c.y, c.tamanho, c.tamanho, 4)
        end

        -- Tempo individual
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.printf(string.format("%.1fs", p.tempoVivo), p.campo_x, 20, meio, "center")
    end

    desenharCampo(p1, "P1")
    desenharCampo(p2, "P2")

    -- Divisória
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(meio, 0, meio, altura)

    if estadoGlobal == "fim" then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), altura)
        love.graphics.setColor(1, 1, 1)
        local f = love.graphics.newFont(40)
        love.graphics.setFont(f)
        
        local msg = "EMPATE!"
        if p1.tempoVivo > p2.tempoVivo then msg = "JOGADOR 1 VENCEU!"
        elseif p2.tempoVivo > p1.tempoVivo then msg = "JOGADOR 2 VENCEU!" end
        
        love.graphics.printf(msg, 0, altura/2 - 40, love.graphics.getWidth(), "center")
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("P1: "..string.format("%.1f", p1.tempoVivo).."s  vs  P2: "..string.format("%.1f", p2.tempoVivo).."s", 0, altura/2 + 30, love.graphics.getWidth(), "center")
        love.graphics.printf("Aperte 'R' para reiniciar", 0, altura/2 + 80, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "a" and p1.faixa > 1 and p1.ativo then p1.faixa = p1.faixa - 1 end
    if key == "d" and p1.faixa < 4 and p1.ativo then p1.faixa = p1.faixa + 1 end
    if key == "left" and p2.faixa > 1 and p2.ativo then p2.faixa = p2.faixa - 1 end
    if key == "right" and p2.faixa < 4 and p2.ativo then p2.faixa = p2.faixa + 1 end
    if key == "r" then love.event.quit("restart") end
end