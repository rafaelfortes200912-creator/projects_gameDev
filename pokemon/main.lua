function love.load() --variáveis globais

    anim8 = require 'libraries/anim8' --importa a biblioteca anim8
    fundo = love.graphics.newImage('sprites/fundo2.png') --carrega o sprite

    largura, altura = love.graphics.getDimensions() --pega as dimensões da tela
    love.graphics.setDefaultFilter("nearest", "nearest") --mantém o pixel art nítido

    player = {} --cria uma tabela que armazena variáveis do player
    player.x = 400 --x nome reservado que indica posição x
    player.y = 200 --y nome reservado que indica posição y
    player.speed = 5
    background = love.graphics.newImage('sprites/background.png') --carrega o fundo
    player.spritesheet = love.graphics.newImage('sprites/spriteSkins.png') --carrega o sprite
    player.grid = anim8.newGrid(64, 64, player.spritesheet:getWidth(), player.spritesheet:getHeight()) --define a grid de animação

    player.animation = {} --cria uma tabela que armazena as animações do player
    player.animation.down = anim8.newAnimation(player.grid('1-4', 1), 0.2) --pega o 1º bloco da imagem para fazer a animação em 0.2s
    player.animation.left = anim8.newAnimation(player.grid('1-4', 2), 0.2) --pega o 2º bloco da imagem para fazer a animação em 0.2s
    player.animation.right = anim8.newAnimation(player.grid('1-4', 3), 0.2) --pega o 3º bloco da imagem para fazer a animação em 0.2s
    player.animation.up = anim8.newAnimation(player.grid('1-4', 4), 0.2) --pega o 4º bloco da imagem para fazer a animação em 0.2s

    player.anim = player.animation.down --define a animação padrão
end

function love.update(dt) --executa um código a cada quadro

local ismoving = false --player se movendo é falso

    if love.keyboard.isDown("d") then --se a tecla direita for pressionada faça
        player.x = player.x + player.speed --move o player para a direita
        player.anim = player.animation.right --muda a animação para a direita
        ismoving = true --player se movendo é verdadeiro
    
    elseif love.keyboard.isDown("a") then
        player.x = player.x - player.speed --move o player para a esquerda
        player.anim = player.animation.left --muda a animação para a esquerda
        ismoving = true
    
    elseif love.keyboard.isDown("s") then
        player.y = player.y + player.speed --move o player para baixo
        player.anim = player.animation.down --muda a animação para baixo
        ismoving = true
    
    elseif love.keyboard.isDown("w") then
        player.y = player.y - player.speed --move o player para cima
        player.anim = player.animation.up --muda a animação para cima
        ismoving = true

    elseif ismoving == false then --se player se movendo for falso volta para o frame 2
       player.anim:gotoFrame(1)
    end

    player.anim:update(dt) --atualiza a animação atual
end

function love.draw() --desenha algo na tela
    love.graphics.draw(fundo, -120, -120,nil,1.4)
    player.anim:draw(player.spritesheet, player.x, player.y, nil, 2, 2) --desenha a animação na posição x e y
    

    -- Mostra os FPS
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)

    -- Mostra o tamanho da tela
    love.graphics.print("Largura: " .. largura, 10, 30)
    love.graphics.print("Altura: " .. altura, 10, 50)
end
