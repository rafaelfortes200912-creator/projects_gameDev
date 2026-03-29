-- Arena Combat 2D - RESTAURAÇÃO DE MECÂNICAS E AVISOS
local player, enemy
local GRAVITY = 1800
local FLOOR_Y = 550
local JUMP_FORCE = -800

function love.load()
    resetGame()
end

function resetGame()
    player = {
        x = 100, y = 490, w = 40, h = 60,
        hp = 100, maxHp = 100, color = {0, 0.4, 1},
        velY = 0, speed = 300, dir = 1,
        damage = 15,
        isStunned = false, stunTimer = 0,
        isAttacking = false, attackTimer = 0, attackCooldown = 0,
        isParrying = false, parryActiveTimer = 0, parryCooldown = 0,
        canJump = true, landTimer = 0,
        estusFlasks = 6,
        isHealing = false, healTimer = 0
    }

    enemy = {
        x = 650, y = 470, w = 50, h = 80,
        hp = 1000, maxHp = 1000, color = {1, 0.2, 0.2},
        velY = 0, speed = 140, dir = -1,
        isStunned = false, stunTimer = 0,
        isAttacking = false, attackTimer = 0, attackCooldown = 1.5,
        isWarning = false, warningTimer = 0,
        isSpecial = false, specialStage = "", specialTimer = 0,
        proximityTimer = 0, isExploding = false, explosionTimer = 0, explosionSize = 0,
        damage = 30 
    }
    gameOver = false; winner = ""
end

function love.keypressed(key)
    if gameOver and key == "r" then resetGame() return end
    if player.isStunned or player.isHealing then return end

    if key == "space" and player.canJump then
        player.velY = JUMP_FORCE; player.canJump = false; player.landTimer = 0
    end

    if player.landTimer <= 0 then
        if key == "j" and player.attackCooldown <= 0 and not player.isParrying then
            player.isAttacking = true; player.attackTimer = 0.2; player.attackCooldown = 0.4
            checkCombat(player, enemy, player.damage)
        end
        if key == "k" and player.parryCooldown <= 0 and not player.isAttacking then
            player.isParrying = true; player.parryActiveTimer = 0.25; player.parryCooldown = 0.5
        end
        if key == "f" and player.estusFlasks > 0 and player.hp < player.maxHp then
            player.isHealing = true; player.healTimer = 0.8; player.estusFlasks = player.estusFlasks - 1
            player.hp = math.min(player.maxHp, player.hp + 40)
        end
    end
end

function love.update(dt)
    if gameOver then return end

    -- Movimento Player
    if not player.isStunned and not player.isHealing and player.landTimer <= 0 then
        if love.keyboard.isDown("a") and player.x > 0 then player.x = player.x - player.speed * dt; player.dir = -1
        elseif love.keyboard.isDown("d") and player.x < 760 then player.x = player.x + player.speed * dt; player.dir = 1 end
    end

    -- Física
    player.velY = player.velY + GRAVITY * dt
    player.y = player.y + player.velY * dt
    if player.y >= FLOOR_Y - player.h then
        local caiu = player.velY > 100
        player.y = FLOOR_Y - player.h; player.velY = 0; player.canJump = true
        if caiu and player.landTimer <= 0 then player.landTimer = 0.2 end
    end

    updateBossLogic(dt)

    -- Timers Player
    player.landTimer = math.max(0, player.landTimer - dt)
    player.attackCooldown = math.max(0, player.attackCooldown - dt)
    player.parryCooldown = math.max(0, player.parryCooldown - dt)
    player.stunTimer = math.max(0, player.stunTimer - dt)
    if player.stunTimer <= 0 then player.isStunned = false end
    player.attackTimer = math.max(0, player.attackTimer - dt)
    if player.attackTimer <= 0 then player.isAttacking = false end
    player.parryActiveTimer = math.max(0, player.parryActiveTimer - dt)
    if player.parryActiveTimer <= 0 then player.isParrying = false end
    if player.isHealing then player.healTimer = player.healTimer - dt; if player.healTimer <= 0 then player.isHealing = false end end

    if player.hp <= 0 then gameOver = true; winner = "O BOSS VENCEU" end
    if enemy.hp <= 0 then gameOver = true; winner = "VOCÊ VENCEU" end
end

function updateBossLogic(dt)
    if enemy.isStunned then
        enemy.stunTimer = math.max(0, enemy.stunTimer - dt); if enemy.stunTimer <= 0 then enemy.isStunned = false end
        return
    end

    local dist = player.x - enemy.x
    enemy.dir = dist > 0 and 1 or -1

    -- 1. BOLA DE ENERGIA (AVISO CIANO)
    if math.abs(dist) < 100 and not enemy.isExploding and not enemy.isSpecial then
        enemy.proximityTimer = enemy.proximityTimer + dt
        if enemy.proximityTimer > 2.0 then enemy.isExploding = true; enemy.explosionTimer = 0.8; enemy.proximityTimer = 0 end
    else
        enemy.proximityTimer = math.max(0, enemy.proximityTimer - dt)
    end

    if enemy.isExploding then
        enemy.explosionTimer = enemy.explosionTimer - dt
        enemy.explosionSize = 130 
        if enemy.explosionTimer <= 0 then
            if math.abs(player.x - enemy.x) < 110 then
                if player.isParrying then 
                    enemy.isStunned = true; enemy.stunTimer = 2.0; player.x = player.x + (enemy.dir * -120)
                else 
                    player.hp = math.max(0, player.hp - 30); player.isStunned = true; player.stunTimer = 0.5; player.x = player.x + (enemy.dir * -180) 
                end
            end
            enemy.isExploding = false; enemy.attackCooldown = 1.5
        end
        return 
    end

    -- 2. ATAQUES E GROUND SLAM
    if not enemy.isWarning and not enemy.isSpecial then
        if math.abs(dist) > 70 then enemy.x = enemy.x + (enemy.speed * enemy.dir * dt) end
        enemy.attackCooldown = math.max(0, enemy.attackCooldown - dt)
        if math.abs(dist) < 150 and enemy.attackCooldown <= 0 then
            if math.random() < 0.3 then enemy.isSpecial = true; enemy.specialStage = "JUMPING"; enemy.specialTimer = 0.8
            else enemy.isWarning = true; enemy.warningTimer = 0.6 end
        end
    end

    -- Lógica Ground Slam (Aviso Verde/Roxo)
    if enemy.isSpecial then
        enemy.specialTimer = enemy.specialTimer - dt
        if enemy.specialStage == "JUMPING" and enemy.specialTimer <= 0 then
            enemy.specialStage = "IMPACT"; enemy.specialTimer = 0.4
            if player.y >= FLOOR_Y - player.h - 10 then
                player.hp = math.max(0, player.hp - 50); player.isStunned = true; player.stunTimer = 0.6
                player.x = player.x + ((player.x > enemy.x and 1 or -1) * 60)
            end
        elseif enemy.specialStage == "IMPACT" and enemy.specialTimer <= 0 then enemy.isSpecial = false; enemy.attackCooldown = 2.0 end
    end

    -- Ataque de Espada (Aviso Branco)
    if enemy.isWarning then
        enemy.warningTimer = enemy.warningTimer - dt
        if enemy.warningTimer <= 0 then
            enemy.isWarning = false; enemy.isAttacking = true; enemy.attackTimer = 0.2; enemy.attackCooldown = 1.5
            checkCombat(enemy, player, enemy.damage)
        end
    end
    enemy.attackTimer = math.max(0, enemy.attackTimer - dt); if enemy.attackTimer <= 0 then enemy.isAttacking = false end
end

function checkCombat(attacker, defender, dmg)
    local atkX = attacker.x + (attacker.dir == 1 and attacker.w or -40)
    if checkCollision(atkX, attacker.y + 25, 40, 10, defender.x, defender.y, defender.w, defender.h) then
        if defender.isParrying then 
            attacker.isStunned = true; attacker.stunTimer = 1.5; attacker.isAttacking = false
        else
            defender.hp = math.max(0, defender.hp - dmg)
            if defender == player then player.x = player.x + (attacker.dir * 40); player.isStunned = true; player.stunTimer = 0.1 end
        end
    end
end

function love.draw()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, FLOOR_Y, 800, 50)
    
    -- Desenho Especial Boss (Bola de Energia)
    if enemy.isExploding then
        love.graphics.setColor(0, 1, 1, 0.4); local s = enemy.explosionSize
        love.graphics.rectangle("fill", enemy.x - s/2 + enemy.w/2, enemy.y - s/2 + enemy.h/2, s, s)
    end

    -- Cor do Player
    if player.isStunned then love.graphics.setColor(1, 1, 0)
    elseif player.isParrying then love.graphics.setColor(0, 1, 1)
    elseif player.isHealing then love.graphics.setColor(1, 0.8, 0)
    else love.graphics.setColor(player.color) end
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

    -- COR DO BOSS (RESTORED)
    if enemy.isStunned then love.graphics.setColor(1, 1, 0) -- Amarelo Stun
    elseif enemy.isWarning then love.graphics.setColor(1, 1, 1) -- Branco Aviso Espada
    elseif enemy.isExploding then love.graphics.setColor(0, 1, 1) -- Ciano Aviso Energia
    elseif enemy.isSpecial then
        if enemy.specialStage == "JUMPING" then love.graphics.setColor(0, 1, 0) -- Verde Pulando
        else love.graphics.setColor(0.6, 0, 1) end -- Roxo Impacto
    else love.graphics.setColor(enemy.color) end -- Vermelho Normal
    love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.w, enemy.h)

    -- Espadas
    love.graphics.setColor(1, 1, 1)
    if player.isAttacking then
        local px = player.dir == 1 and (player.x + player.w) or (player.x - 40)
        love.graphics.rectangle("fill", px, player.y + 25, 40, 10)
    end
    if enemy.isAttacking then
        local ex = enemy.dir == 1 and (enemy.x + enemy.w) or (enemy.x - 40)
        love.graphics.rectangle("fill", ex, enemy.y + 25, 40, 10)
    end

    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HP: " .. player.hp .. " (" .. math.floor((player.hp/player.maxHp)*100) .. "%)", 50, 510)
    love.graphics.print("ESTUS: " .. player.estusFlasks, 200, 510)
    love.graphics.setColor(0.2, 0.2, 0.2); love.graphics.rectangle("fill", 50, 530, 200, 15)
    love.graphics.setColor(0, 1, 0); love.graphics.rectangle("fill", 50, 530, (player.hp/player.maxHp) * 200, 15)
    
    love.graphics.setColor(1, 1, 1); love.graphics.print("BOSS HP: "..enemy.hp, 360, 15)
    love.graphics.setColor(1, 0, 0); love.graphics.rectangle("fill", 200, 35, (enemy.hp/enemy.maxHp)*400, 15)
    
    if gameOver then love.graphics.printf(winner.."\n'R'", 0, 250, 800, "center") end
end

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2) return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1 end