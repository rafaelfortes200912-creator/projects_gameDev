-- variáveis ___________________________________________________________________________________________________

local tilesize = 32 -- tamanho do bloco

local player = {
  x = 100, y = 100,
  w = tilesize, h = tilesize,
  speed_x = 200,
  speed_y = 0,
  jump_power = -450,
  onGround = false,
  dir = 1,  -- 1 = direita, -1 = esquerda

  --dash
  isDashing = false,
  dashTime = 0,
  dashDuration = 0.2,   -- tempo do dash (segundos)
  dashSpeed = 550,       -- velocidade do dash
  dashDir = 0,           -- direção (1 direita, -1 esquerda)
  canDash = true,        -- para evitar spam (reseta ao pousar, por ex.)

}

-- câmara
local screenW, screenH = 1200, 800
local cameraX = 0

-- gravidade
local gravity = 800
local floorY = 590

blocos_plataforma = {
  { x1 = 3000, x2 = 3460, y = floorY - 80,  h = 80 },
  { x1 = 3460, x2 = 3960, y = (floorY - 120) -32, h = 120 + 32},
  { x1 = 4100, x2 = 4560, y = floorY - 100, h = 100 },
}


local ivs_wall = {
  x1 = -3200,          -- lado esquerdo
  x2 = -3168,          -- lado direito (largura de 32 px)
  y  = 0,              -- começa no topo da tela
  h  = floorY          -- altura até o chão
}

local plataforma = {
  x1 = 200,  -- início
  x2 = 400,  -- fim
  y  = floorY - 110,  -- topo da plataforma
  h  = 32,    -- espessura
}




-- fim das variaveis ___________________________________________________________________________________________________


-- função love.load serve para:
--[[
Dentro dela você coloca coisas que precisam ser preparadas antes do jogo começar:

Carregar imagens (sprites, fundos, personagens).

Carregar sons e músicas.

Definir variáveis iniciais (posição do jogador, pontuação, vidas).

Configurar a janela (título, tamanho da tela, ícone).

Preparar fontes de texto (tipografia que vai usar no jogo).
]]

function love.load()
  love.window.setMode(screenW, screenH)
  love.window.setTitle("JOGO DE PLATAFORMA EM QUADRADINHOS")
end

  function love.update(dt)
  if player.isDashing then
    -- movimento horizontal rápido
    player.x = player.x + player.dashDir * player.dashSpeed * dt
    player.dashTime = player.dashTime - dt

    -- dash terminou?
    if player.dashTime <= 0 then
      player.isDashing = false
    end
  else
    -- movimento normal
    local move = 0
    if love.keyboard.isDown("right", "d") then 
      move = move + 1
      player.dir = 1  -- virado para a direita
    end

    if love.keyboard.isDown("left", "a") then 
      move = move - 1 
      player.dir = -1 -- virado para a esquerda
    end

      player.x = player.x + move * player.speed_x * dt

    -- gravidade
    player.speed_y = player.speed_y + gravity * dt
    player.y = player.y + player.speed_y * dt
  end

  -- colisão com o chão (exemplo simples)
  if player.y + player.h > floorY then
    player.y = floorY - player.h
    player.speed_y = 0
    player.onGround = true
    player.canDash = true -- reset do dash ao tocar no chão
  else
    player.onGround = false
  end

  --colisões: ___________________________________________________________________________________________________

  -- colisão com o chão (global)
  if player.y + player.h > floorY then
    player.y = floorY - player.h
    player.speed_y = 0
    player.onGround = true
  end
  -- colisão com plataforma (apenas topo, entre x1 e x2)
  if player.x + player.w > plataforma.x1 and
     player.x < plataforma.x2 and
     player.y + player.h > plataforma.y and
     player.y + player.h < plataforma.y + plataforma.h and
     player.speed_y >= 0   -- só se estiver a cair
  then
     player.y = plataforma.y - player.h   -- corrige posição
     player.speed_y = 0
     player.onGround = true
     player.canDash = true 
  end

  -- colisão com plataforma baixo
  if player.x + player.w > plataforma.x1 and
   player.x < plataforma.x2 and
   player.y < plataforma.y + plataforma.h and
   player.y > plataforma.y and
   player.speed_y < 0
then
   player.y = plataforma.y + plataforma.h   -- corrige posição (bateu a cabeça)
   player.speed_y = 0
end

-- colisão lado esquerdo
if player.y + player.h > plataforma.y and
   player.y < plataforma.y + plataforma.h and
   player.x + player.w > plataforma.x1 and
   player.x + player.w < plataforma.x1 + player.w then
   player.x = plataforma.x1 - player.w
end

-- colisão lado direito
if player.y + player.h > plataforma.y and
   player.y < plataforma.y + plataforma.h and
   player.x < plataforma.x2 and
   player.x > plataforma.x2 - player.w then
   player.x = plataforma.x2
end

-- colisão lado esquerdo (parede invisível)
if player.y + player.h > ivs_wall.y and
   player.y < ivs_wall.y + ivs_wall.h and
   player.x + player.w > ivs_wall.x1 and
   player.x + player.w < ivs_wall.x1 + player.w then
   player.x = ivs_wall.x1 - player.w
end

-- colisão lado direito (parede invisível)
if player.y + player.h > ivs_wall.y and
   player.y < ivs_wall.y + ivs_wall.h and
   player.x < ivs_wall.x2 and
   player.x > ivs_wall.x2 - player.w then
   player.x = ivs_wall.x2
end

-- colisão lado esquerdo blocos_plataforma(1)
if player.y + player.h > blocos_plataforma[1].y and
   player.y < blocos_plataforma[1].y + blocos_plataforma[1].h and
   player.x + player.w > blocos_plataforma[1].x1 and
   player.x + player.w < blocos_plataforma[1].x1 + player.w then
   player.x = blocos_plataforma[1].x1 - player.w
end

  -- colisão com blcos_plataforma (1)
  if player.x + player.w > blocos_plataforma[1].x1 and
     player.x < blocos_plataforma[1].x2 and
     player.y + player.h > blocos_plataforma[1].y and
     player.y + player.h < blocos_plataforma[1].y + blocos_plataforma[1].h and
     player.speed_y >= 0   -- só se estiver a cair
  then
     player.y = blocos_plataforma[1].y - player.h   -- corrige posição
     player.speed_y = 0
     player.onGround = true
     player.canDash = true 
  end

  -- colisão lado esquerdo blocos_plataforma(2)
if player.y + player.h > blocos_plataforma[2].y and
   player.y < blocos_plataforma[2].y + blocos_plataforma[2].h and
   player.x + player.w > blocos_plataforma[2].x1 and
   player.x + player.w < blocos_plataforma[2].x1 + player.w then
   player.x = blocos_plataforma[2].x1 - player.w
end

  -- colisão de cima com blcos_plataforma (2)
  if player.x + player.w > blocos_plataforma[2].x1 and
     player.x < blocos_plataforma[2].x2 and
     player.y + player.h > blocos_plataforma[2].y and
     player.y + player.h < blocos_plataforma[2].y + blocos_plataforma[2].h and
     player.speed_y >= 0   -- só se estiver a cair
  then
     player.y = blocos_plataforma[2].y - player.h   -- corrige posição
     player.speed_y = 0
     player.onGround = true
     player.canDash = true 
  end

  --fecha ___________________________________________________________________________________________________

  -- câmara segue o jogador
  cameraX = player.x - screenW / 2

end

function love.keypressed(key)
  if key == "space" and player.onGround then
    -- salto
    player.speed_y = player.jump_power
    player.onGround = false
  elseif key == "l" and player.canDash then
    -- dash (com Shift Esquerdo)
    if love.keyboard.isDown("right", "d") then
      player.dashDir = 1
    elseif love.keyboard.isDown("left", "a") then
      player.dashDir = -1
    else
      return -- sem direção não faz dash
    end

    player.isDashing = true
    player.dashTime = player.dashDuration
    player.canDash = false
    player.speed_y = 0 -- cancela queda no início do dash
    
  elseif key == "escape" then
    love.event.quit()
  end
end

-- função lovedraw serve para:
--[[
Desenhar formas geométricas: quadrados, círculos, linhas, polígonos, pontos etc.

Mostrar imagens: colocar sprites, fundos, personagens, objetos do cenário.

Escrever textos: exibir pontuação, diálogos, menus, mensagens na tela.

Mudar cores: definir a cor de um desenho, de um texto ou de uma forma.

Aplicar efeitos visuais: shaders, transparências, escalas, rotações.

Organizar a câmera: mover, aproximar ou afastar a visão do jogador (zoom, rotação da tela).

Controlar camadas de desenho: escolher o que aparece por cima ou por baixo (como HUD por cima do jogo).

Resumindo: tudo que é visual ou aparece na tela do jogo passa pelo love.draw.

Ele é como uma folha em branco que o Love2D redesenha várias vezes por segundo — e você decide o que desenhar nela.
]]

function love.draw()

  love.graphics.push()
  love.graphics.translate(-math.floor(cameraX), 0)

  -- plataforma ___________________________________________________________________________________________________

  -- chão “infinito” (apenas blocos visíveis)
  local firstTile = math.floor(cameraX / tilesize) - 2
  local lastTile  = math.floor((cameraX + screenW) / tilesize) + 2
  for i = firstTile, lastTile do
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", i * tilesize, floorY, tilesize, tilesize)
  end

  -- plataforma (desenhada corretamente)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line",
    plataforma.x1, plataforma.y,
    plataforma.x2 - plataforma.x1, plataforma.h
  )
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", -3000, 200, 460, 200)--blocos de plataforma
  love.graphics.rectangle("line", ivs_wall.x1, ivs_wall.y, ivs_wall.x2 - ivs_wall.x1, ivs_wall.h)-- paarede invisivel

  love.graphics.rectangle("line", blocos_plataforma[1].x1, blocos_plataforma[1].y, blocos_plataforma[1].x2 - blocos_plataforma[1].x1, blocos_plataforma[1].h)
 
  love.graphics.rectangle("line", blocos_plataforma[2].x1, blocos_plataforma[2].y , blocos_plataforma[2].x2 - blocos_plataforma[2].x1, blocos_plataforma[2].h)

  --love.graphics.rectangle("line", blocos_plataforma[2].x1 + 920, blocos_plataforma[2].y - 40, (blocos_plataforma[2].x2 - blocos_plataforma[2].x1) * 2, blocos_plataforma[2].h + 40)
 
  -- fim plataforma ___________________________________________________________________________________________________

-- jogador ___________________________________________________________________________________________________

-- jogador com espelhamento
love.graphics.translate(player.x + player.w/2, player.y + player.h/2)
love.graphics.scale(player.dir, 1) -- 1 = normal, -1 = espelhado
love.graphics.setColor(1, 1, 1)
love.graphics.rectangle("fill", -player.w/2, -player.h/2, player.w, player.h)

-- rosto (pequeno retângulo vermelho, sempre no “lado da frente”)
love.graphics.setColor(1, 0, 0)
love.graphics.rectangle("fill", player.w/2 - 8, -player.h/2, 8, player.h)

love.graphics.pop()

-- fim jogador ___________________________________________________________________________________________________

  -- texto ___________________________________________________________________________________________________
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("A e D para mover, SPACE para saltar, l para usar dash", 10, 10)

  -- fim texto ___________________________________________________________________________________________________
end