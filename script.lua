if getgenv().MidgardLoaded then return end
getgenv().MidgardLoaded = true
getgenv().MidgardRunning = true

if not game:IsLoaded() then game.Loaded:Wait() end
while not game.Players.LocalPlayer do game.Players.PlayerAdded:Wait() end

-- =========================
--   DETECÇÃO DE PLATAFORMA
-- =========================
local UserInputService = game:GetService("UserInputService")
local IS_MOBILE = UserInputService:GetPlatform() == Enum.Platform.IOS or UserInputService:GetPlatform() == Enum.Platform.Android
local IS_DESKTOP = UserInputService:GetPlatform() == Enum.Platform.Windows or UserInputService:GetPlatform() == Enum.Platform.OSX or UserInputService:GetPlatform() == Enum.Platform.UWP or UserInputService:GetPlatform() == Enum.Platform.Linux

print("[Platform] Plataforma detectada: " .. (IS_MOBILE and "MOBILE" or IS_DESKTOP and "DESKTOP" or "UNKNOWN"))

-- Desabilitar todos os sons do jogo
for _, sound in pairs(game:GetDescendants()) do
    if sound:IsA("Sound") then
        sound.Volume = 0
        sound:Stop()
    end
end

game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound") then
        descendant.Volume = 0
        descendant:Stop()
    end
end)

-- =========================
--     REJOIN + ANTI AFK
-- =========================

_G.Rejoin = true
_G.Anti_AFK = true

local _Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local _localPlayer = _Players.LocalPlayer

local function RejoinServer()
    if not _G.TP_Ser and _G.Rejoin then
        -- FIX LAG/KICK: aguarda mais tempo antes de tentar reconectar em internet ruim
        task.wait(3)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, _localPlayer)
        end)
    end
end

task.spawn(function()
    CoreGui:WaitForChild("RobloxPromptGui")
    CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" and _G.Rejoin then
            -- FIX LAG: aumentado de 2s para 5s para dar tempo ao servidor de responder
            task.wait(5)
            RejoinServer()
        end
    end)
end)

_localPlayer.Idled:Connect(function()
    if IS_MOBILE then
        -- No celular, usar VirtualUser
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        -- No PC, usar alternativa: mover mouse ou usar Input
        pcall(function()
            local currentCamera = workspace.CurrentCamera
            if currentCamera then
                currentCamera.CFrame = currentCamera.CFrame * CFrame.new(0, 0, 0)
            end
        end)
    end
end)

-- Configurações
getgenv().Setting = {
    ["Hunt"] = {
        ["Team"] = "Pirates",
        ["Min"] = 0,
        ["Max"] = 30000000,
    },
    ["Webhook"] = {
        ["Enabled"] = true, 
        ["Url"] = "https://discord.com/api/webhooks/1490160691334615161/1MuHiE8DkNG644FNkDHn_tABCw6n78gUwmZcry-1JakgDJbmTdOHv2JgSU4PWOGMV6W0"
    },
    ["Skip"] = {
        ["V4"] = false,
        ["Fruit"] = false,
        ["FruitList"] = {
            "Leopard",
            "Venom",
            "Dough",
            "Portal"
        }
    },
    ["Chat"] = {
        ["Enabled"] = false,
        ["List"] = {""},
    },
    ["Click"] = {
        ["AlwaysClick"] = true,
        ["FastClick"] = true
    },
    ["Another"] = {
        ["V3"] = true,
        ["CustomHealth"] = true,
        ["Health"] = 18000,
        ["V4"] = true,
        ["LockCamera"] = true,
        ["FPSBoots"] = true,
        ["WhiteScreen"] = false,
        ["BypassTp"] = true,
        ["ResetBeforeTp"] = true  -- reseta personagem antes de cada TP para limpar posição no servidor
    },
    ["SafeHealth"] = {
        ["Health"] = 3000,   -- ATIVA SafeMode quando HP <= 3000
        ["Deactivate"] = 3500, -- DESATIVA SafeMode quando HP >= 3500 (novo campo)
        ["HighY"] = 1200
    },
    ["Melee"] = {
        ["Enable"] = true,
        ["Delay"] = 0.3,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 0},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0},
        ["C"] = {["Enable"] = true, ["HoldTime"] = 0},
        ["V"] = {["Enable"] = false, ["HoldTime"] = 0}
    },
    ["Fruit"] = {
        ["Enable"] = true,
        ["Delay"] = 0.15,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 0},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0},
        ["C"] = {["Enable"] = true, ["HoldTime"] = 1.25},
        ["V"] = {["Enable"] = true, ["HoldTime"] = 1.25},
        ["F"] = {["Enable"] = false, ["HoldTime"] = 0}
    },
    ["Sword"] = {
        ["Enable"] = true,
        ["Delay"] = 0.3,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 1.2},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0}
    },
    ["Gun"] = {
        ["Enable"] = true,
        ["GunMode"] = false, 
        ["Delay"] = 0.5,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 1.2},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0}
    }
}

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main") or game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")

print("[Auto Bounty] Iniciando...")

-- =========================
--   TEAM SELECTION FUNCTION
-- =========================
local function SelectTeam(teamName)
    local LocalPlayer = game.Players.LocalPlayer
    local TEAM = teamName or getgenv().Team or "Pirates"
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    task.wait(1)

    do
        local waitStart = clock()
        repeat task.wait(0.5)
        until PlayerGui:FindFirstChild("Main (minimal)") or PlayerGui:FindFirstChild("Main") or LocalPlayer.Character or (clock() - waitStart > 30)

        if PlayerGui:FindFirstChild("Main (minimal)") or PlayerGui:FindFirstChild("Main") then
            task.wait(5)
            pcall(function()
                local CommF_ = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                if CommF_ then
                    local attempts = 0
                    repeat
                        attempts += 1
                        CommF_:InvokeServer("SetTeam", TEAM)
                        task.wait(0.5)
                    until not (PlayerGui:FindFirstChild("Main (minimal)") or PlayerGui:FindFirstChild("Main")) or attempts >= 10
                end
            end)
        end

        if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
        LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        task.wait()
    end
end

do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")

    -- Entrar no time rapidamente: espera apenas até o ChooseTeam aparecer (máx 2s)
    local waitStart = tick()
    repeat task.wait(0.1) until (pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)")) and ((pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)")):FindFirstChild("ChooseTeam")) or (tick() - waitStart > 2)

    local mainGui = pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)")
    if mainGui and mainGui:FindFirstChild("ChooseTeam") then
        -- Tenta entrar no time imediatamente em loop rápido
        for attempt = 1, 10 do
            local choose = mainGui:FindFirstChild("ChooseTeam")
            if choose and choose.Visible then
                local desiredTeam = (getgenv().Setting and getgenv().Setting.Hunt and getgenv().Setting.Hunt.Team) or "Pirates"
                if desiredTeam == "Pirates" or desiredTeam == "Marines" then
                    pcall(function()
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", desiredTeam)
                    end)
                end
            end
            if lp.Team ~= nil then break end
            task.wait(0.3)
        end
        -- Fallback: loop até confirmar time
        repeat task.wait(0.2) until lp.Team ~= nil and game:IsLoaded()
    end
end

if game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
    World3 = true
else
    game.Players.LocalPlayer:Kick("Only Support BF Sea 3")
end 

if World3 then 
    distbyp = 5000
    island = {
        ["Port Town"] = CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375),
        ["Hydra Island"] = CFrame.new(5749.7861328125 + 50, 611.9736938476562, -276.2497863769531),
        ["Mansion"] = CFrame.new(-12471.169921875 + 50, 374.94024658203, -7551.677734375),
        ["Castle On The Sea"] = CFrame.new(-5085.23681640625 + 50, 316.5072021484375, -3156.202880859375),
        ["Haunted Island"] = CFrame.new(-9547.5703125, 141.0137481689453, 5535.16162109375),
        ["Great Tree"] = CFrame.new(2681.2736816406, 1682.8092041016, -7190.9853515625),
        ["Candy Island"] = CFrame.new(-1106.076416015625, 13.016114234924316, -14231.9990234375),
        ["Cake Island"] = CFrame.new(-1903.6856689453125, 36.70722579956055, -11857.265625),
        ["Loaf Island"] = CFrame.new(-889.8325805664062, 64.72842407226562, -10895.8876953125),
        ["Peanut Island"] = CFrame.new(-1943.59716796875, 37.012996673583984, -10288.01171875),
        ["Cocoa Island"] = CFrame.new(147.35205078125, 23.642955780029297, -12030.5498046875),
        ["Tiki Outpost"] = CFrame.new(-16234,9,416)
    } 
end

local p = game.Players
local lp = p.LocalPlayer
local rs = game.RunService
local hb = rs.Heartbeat
local rends = rs.RenderStepped

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- ============================================================
-- PING ADAPTATIVO (suporte a 400ms+)
-- Escala todos os waits críticos baseado no ping real do cliente
-- ============================================================
local _cachedPing = 100
local _lastPingUpdate = 0

local function GetPing()
    local now = tick()
    if now - _lastPingUpdate > 0.5 then -- atualiza a cada 0.5s (era 1s)
        _lastPingUpdate = now
        local ok = false
        -- Fonte primária: GetNetworkPing() — mais preciso e sempre disponível
        pcall(function()
            _cachedPing = Players.LocalPlayer:GetNetworkPing() * 1000
            ok = true
        end)
        -- Fallback: Stats do servidor
        if not ok then
            pcall(function()
                _cachedPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"].Value
            end)
        end
    end
    return _cachedPing
end

-- Retorna multiplicador baseado no ping atual
-- 0–150ms  → 1.0x  (normal, sem alteração)
-- 151–200ms → 4.0x  ← salto agressivo a partir de 150ms
-- 201–250ms → 5.5x
-- 251–300ms → 7.0x  ← 290ms cai aqui
-- 301–350ms → 8.5x
-- 350ms+   → 10.0x
local function PingMult()
    local ping = GetPing()
    if ping <= 150 then return 1.0
    elseif ping <= 200 then return 1.5
    elseif ping <= 250 then return 2.0
    elseif ping <= 300 then return 2.5
    elseif ping <= 350 then return 3.0
    else return 3.5 end
end

-- Substituto para task.wait() em pontos críticos de sincronização com servidor
local function AdaptiveWait(base)
    task.wait(base * PingMult())
end

print("[Allan Hub X] Sistema de ping adaptativo ativo. Ping atual: " .. tostring(GetPing()) .. "ms")

local player = Players.LocalPlayer
_G.Seriality = true

-- ============================================================
--  TP ENTRE ILHAS (BFS) - script corrigido
-- ============================================================

local function TpLog(msg)
    pcall(function()
        print("[Auto Bounty TP] " .. tostring(msg))
    end)
end

local ISLAND_GRAPH = {
    ["Port Town"]         = {"Haunted Island", "Castle On The Sea"},
    ["Haunted Island"]    = {"Port Town", "Tiki Outpost", "Castle On The Sea"},
    ["Tiki Outpost"]      = {"Haunted Island", "Mansion", "Floating Turtle"},
    ["Mansion"]           = {"Tiki Outpost", "Castle On The Sea"},
    ["Castle On The Sea"] = {"Haunted Island", "Port Town", "Mansion", "Hydra Island", "Great Tree"},
    ["Hydra Island"]      = {"Castle On The Sea", "Great Tree"},
    ["Great Tree"]        = {"Castle On The Sea", "Hydra Island", "Sea of Treats"},
    ["Sea of Treats"]     = {"Great Tree", "Candy Island", "Cake Island", "Loaf Island", "Peanut Island", "Cocoa Island"},
    ["Candy Island"]      = {"Sea of Treats", "Cake Island", "Loaf Island", "Peanut Island", "Cocoa Island"},
    ["Cake Island"]       = {"Sea of Treats", "Candy Island", "Loaf Island", "Peanut Island", "Cocoa Island"},
    ["Loaf Island"]       = {"Sea of Treats", "Candy Island", "Cake Island", "Peanut Island", "Cocoa Island"},
    ["Peanut Island"]     = {"Sea of Treats", "Candy Island", "Cake Island", "Loaf Island", "Cocoa Island"},
    ["Cocoa Island"]      = {"Sea of Treats", "Candy Island", "Cake Island", "Loaf Island", "Peanut Island"},
    ["Floating Turtle"]   = {"Tiki Outpost"},
    ["Haunted Castle"]    = {"Tiki Outpost"},
}

local ISLAND_POSITIONS = {
    ["Port Town"]         = Vector3.new(-290,   6,    5343),
    ["Haunted Island"]    = Vector3.new(-9547,  141,  5535),
    ["Castle On The Sea"] = Vector3.new(-5085,  316, -3156),
    ["Tiki Outpost"]      = Vector3.new(-16234, 9,    416),
    ["Mansion"]           = Vector3.new(-12471, 374, -7551),
    ["Hydra Island"]      = Vector3.new(5749,   611, -276),
    ["Great Tree"]        = Vector3.new(2681,   1682,-7190),
    ["Sea of Treats"]     = Vector3.new(147,    23,  -12030),
    ["Candy Island"]      = Vector3.new(-1106,  13,  -14231),
    ["Cake Island"]       = Vector3.new(-1903,  36,  -11857),
    ["Loaf Island"]       = Vector3.new(-889,   64,  -10895),
    ["Peanut Island"]     = Vector3.new(-1943,  37,  -10288),
    ["Cocoa Island"]      = Vector3.new(147,    23,  -12030),
    ["Floating Turtle"]   = Vector3.new(-12001, 332, -8861),
    ["Haunted Castle"]    = Vector3.new(-9515,  142,  6075),
}

local function GetIslandNameFromPos(pos)
    local closest, closestDist = nil, math.huge
    for name, center in pairs(ISLAND_POSITIONS) do
        local d = (pos - center).Magnitude
        if d < closestDist then
            closestDist = d
            closest = name
        end
    end
    return closest
end

local function BfsPath(startIsland, endIsland)
    if startIsland == endIsland then return { startIsland } end
    if not ISLAND_GRAPH[startIsland] or not ISLAND_GRAPH[endIsland] then return nil end

    local queue = { { startIsland } }
    local visited = { [startIsland] = true }

    while #queue > 0 do
        local path = table.remove(queue, 1)
        local current = path[#path]
        for _, neighbor in ipairs(ISLAND_GRAPH[current] or {}) do
            if not visited[neighbor] then
                visited[neighbor] = true
                local newPath = {}
                for _, v in ipairs(path) do table.insert(newPath, v) end
                table.insert(newPath, neighbor)
                if neighbor == endIsland then
                    return newPath
                end
                table.insert(queue, newPath)
            end
        end
    end
    return nil
end

local function GetSpawns()
    local spawns = {}
    pcall(function()
        local origin = workspace:FindFirstChild("_WorldOrigin")
        local ps = origin and origin:FindFirstChild("PlayerSpawns")
        if not ps then return end
        for _, folder in pairs(ps:GetChildren()) do
            for _, model in pairs(folder:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChildWhichIsA("BasePart") then
                    local cf = model:GetModelCFrame()
                    table.insert(spawns, { name = model.Name, position = cf.p })
                end
            end
        end
    end)
    return spawns
end

local function GetSpawnOnIsland(islandName, spawns)
    local islandCenter = ISLAND_POSITIONS[islandName]
    if not islandCenter then return nil end
    local closest, closestDist = nil, math.huge
    for _, spawn in ipairs(spawns) do
        local d = (spawn.position - islandCenter).Magnitude
        if d < closestDist then
            closestDist = d
            closest = spawn
        end
    end
    return closest
end

local function GetClosestSpawnToPos(targetPos, spawns)
    local closest, closestDist = nil, math.huge
    for _, spawn in ipairs(spawns) do
        local d = (spawn.position - targetPos).Magnitude
        if d < closestDist then
            closestDist = d
            closest = spawn
        end
    end
    return closest
end

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")

local function SetLastSpawn(spawnName)
    pcall(function()
        Remote:InvokeServer("SetLastSpawnPoint", spawnName)
    end)
end

-- Confirma com o servidor que estamos na posição atual.
-- Com ping alto faz até 3 tentativas com intervalo crescente.
local function CommitPositionToServer()
    local ping = GetPing()
    local retries = ping > 250 and 5 or ping > 150 and 4 or 1
    for i = 1, retries do
        pcall(function()
            Remote:InvokeServer("SetSpawnPoint")
        end)
        if i < retries then task.wait(0.12 * i) end
    end
end

-- ============================================================
-- TP LIMPO COM CONFIRMAÇÃO DE SERVIDOR (V31)
-- Problema anterior: CFrame movia o cliente mas o servidor
-- ainda considerava o jogador na ilha antiga → hits não registravam.
-- Solução: após mover o CFrame para o spawn, chama SetSpawnPoint
-- para o servidor registrar a nova ilha, depois aguarda 1 frame
-- de confirmação antes de continuar.
-- ============================================================
local function CleanTpToSpawn(spawnPos, spawnName)
    pcall(function()
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Passo 1: define o spawn point pelo nome antes de mover
        if spawnName then
            SetLastSpawn(spawnName)
            AdaptiveWait(0.1)
        end

        -- Passo 2: move o CFrame (aplica 2x para garantir com ping alto)
        hrp.CFrame = CFrame.new(spawnPos.X, spawnPos.Y + 3, spawnPos.Z)
        AdaptiveWait(0.05)
        if hrp and hrp.Parent then
            hrp.CFrame = CFrame.new(spawnPos.X, spawnPos.Y + 3, spawnPos.Z)
        end

        -- Passo 3: espera extra proporcional ao ping antes do commit
        -- Garante que o servidor recebeu o CFrame antes de invocar SetSpawnPoint
        local ping = GetPing()
        if ping > 150 then
            task.wait((ping / 1000) * 2.0) -- ex: 290ms → ~0.58s de estabilização
        end

        -- Passo 4: CRÍTICO — notifica o servidor da nova posição física
        CommitPositionToServer()
        AdaptiveWait(0.15)
    end)
end

local ISLAND_RADIUS = 2500

-- ============================================================
-- RESET ANTES DO TP
-- Mata o personagem para o servidor registrar posição limpa
-- via sistema nativo de respawn antes de qualquer teleporte.
-- Mais confiável que SetSpawnPoint sozinho com ping alto.
-- ============================================================
local function ResetBeforeTp()
    if not getgenv().Setting.Another.ResetBeforeTp then return end
    pcall(function()
        local char = lp.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        hum.Health = 0  -- força respawn e retorna imediatamente, sem esperar
    end)
end

-- ============================================================
-- TP AND RESET (V14)
-- Versão agressiva: TP imediato dentro do inimigo + reset.
-- Chamado tanto pelo loop principal quanto pelo CharacterAdded.
-- targChar: character do alvo (pode ser nil, neste caso usa getgenv().targ)
-- forcedPos: Vector3 capturado ANTES do respawn para usar quando
--            o CharacterAdded dispara antes do char estar pronto
-- ============================================================
local function TpAndReset(targChar, forcedPos)
    task.spawn(function()
        pcall(function()
            local destPos = forcedPos
            if not destPos then
                local tHRP = targChar and targChar:FindFirstChild("HumanoidRootPart")
                if not tHRP then return end
                destPos = tHRP.Position
            end

            -- Equipa fruta antes de tudo
            pcall(function() equip("Blox Fruit") end)

            -- Helper: TP no char atual para uma posição
            local function doTPTo(dest)
                pcall(function()
                    local char = lp.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(dest.X, dest.Y, dest.Z) end
                    if char and char.PrimaryPart then
                        char.PrimaryPart.CFrame = CFrame.new(dest.X, dest.Y, dest.Z)
                    end
                end)
            end

            -- Reseta imediatamente
            local char4 = lp.Character
            local hum   = char4 and char4:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                hum.Health = 0
            end

            -- TP no alvo principal imediatamente após o reset
            local mainDest = destPos
            pcall(function()
                local tHRP = targChar and targChar:FindFirstChild("HumanoidRootPart")
                if tHRP then mainDest = tHRP.Position end
            end)
            doTPTo(mainDest)

            -- Spam de TP DURANTE o respawn, rotacionando entre TODOS os alvos válidos
            local oldChar  = lp.Character
            local elapsed  = 0
            local tpIndex  = 1  -- índice para rotacionar entre alvos

            while elapsed < 3 do
                task.wait(0.01)
                elapsed = elapsed + 0.01

                pcall(function()
                    local allTargets = GetAllValidTargets()
                    if #allTargets == 0 then
                        -- Sem outros alvos: fica no alvo principal
                        local tHRP = targChar and targChar:FindFirstChild("HumanoidRootPart")
                        doTPTo((tHRP and tHRP.Position) or destPos)
                        return
                    end

                    -- Rotaciona entre todos os alvos a cada TP
                    tpIndex = (tpIndex % #allTargets) + 1
                    local nextTarget = allTargets[tpIndex]
                    local nHRP = nextTarget and nextTarget.Character and nextTarget.Character:FindFirstChild("HumanoidRootPart")
                    if nHRP then
                        doTPTo(nHRP.Position)
                    end
                end)

                -- Ao renascer: equipa fruta + volta para o alvo principal + TPs extras
                if lp.Character ~= oldChar and lp.Character then
                    pcall(function() equip("Blox Fruit") end)
                    -- Volta para o alvo principal ao nascer
                    local tHRP = targChar and targChar:FindFirstChild("HumanoidRootPart")
                    local finalDest = (tHRP and tHRP.Position) or destPos
                    for _ = 1, 4 do
                        doTPTo(finalDest)
                        task.wait(0.01)
                        -- Atualiza posição do alvo principal (ele pode ter se movido)
                        pcall(function()
                            local t2 = targChar and targChar:FindFirstChild("HumanoidRootPart")
                            if t2 then finalDest = t2.Position end
                        end)
                    end
                    pcall(function() equip("Blox Fruit") end)
                    break
                end
            end
        end)
    end)
end

local function StopStick() end -- mantido para não quebrar chamadas existentes

local function GetCurrentIsland()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position
    local closest, closestDist = nil, math.huge
    for name, center in pairs(ISLAND_POSITIONS) do
        local d = (pos - center).Magnitude
        if d < closestDist then
            closestDist = d
            closest = name
        end
    end
    if closestDist > ISLAND_RADIUS then
        TpLog("Você está no mar, usando ilha mais próxima: " .. tostring(closest))
    end
    return closest
end

local BFS_RISK_COOLDOWN = 25
local _bfsTpBusy = false

-- Verifica se o servidor reconhece que estamos na ilha esperada.
-- Faz até 'maxRetries' tentativas de re-confirmar se necessário.
local function VerifyAndCommitIsland(expectedIsland, spawnPos, spawnName, maxRetries)
    local ping = GetPing()
    maxRetries = maxRetries or (ping > 250 and 6 or ping > 150 and 5 or 3)
    for attempt = 1, maxRetries do
        local currentIsland = GetCurrentIsland()
        if currentIsland == expectedIsland then
            -- Posição física OK — confirma com servidor
            CommitPositionToServer()
            task.wait(0.1)
            TpLog("✓ Ilha confirmada: " .. expectedIsland .. " (tentativa " .. attempt .. ")")
            return true
        end
        -- Posição divergiu (servidor puxou de volta ou CFrame não aplicou)
        -- Re-aplica o CFrame e tenta confirmar novamente
        TpLog("⚠ Tentativa " .. attempt .. ": esperado " .. expectedIsland .. ", atual " .. tostring(currentIsland) .. ". Re-aplicando...")
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if spawnName then SetLastSpawn(spawnName) end
            AdaptiveWait(0.05)
            hrp.CFrame = CFrame.new(spawnPos.X, spawnPos.Y + 3, spawnPos.Z)
            AdaptiveWait(0.05)
            CommitPositionToServer()
            AdaptiveWait(0.15)
        end
    end
    TpLog("✗ Não foi possível confirmar ilha: " .. expectedIsland)
    return false
end

local function TpToPositionByIslands(destPos)
    if not World3 then return end
    if _bfsTpBusy then return end
    _bfsTpBusy = true

    local lastRisk = getgenv().LastRiskTime or 0
    if tick() - lastRisk < BFS_RISK_COOLDOWN then
        _bfsTpBusy = false
        return
    end

    -- Reset antes do TP: servidor registra posição limpa via respawn nativo
    ResetBeforeTp()

    local spawns = GetSpawns()  -- declarado aqui, não antes
    if #spawns == 0 then
        _bfsTpBusy = false
        return
    end

    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        _bfsTpBusy = false
        return
    end

    local myIsland     = GetCurrentIsland()
    local targetIsland = GetIslandNameFromPos(destPos)

    if not myIsland or not targetIsland then
        _bfsTpBusy = false
        return
    end

    if myIsland == targetIsland then
        CommitPositionToServer()
        _bfsTpBusy = false
        return
    end

    local path = BfsPath(myIsland, targetIsland)
    if not path or #path <= 1 then
        local best = GetClosestSpawnToPos(destPos, spawns)
        if best then
            CleanTpToSpawn(best.position, best.name)
            VerifyAndCommitIsland(targetIsland, best.position, best.name, 3)
        end
        _bfsTpBusy = false
        return
    end

    TpLog("Rota (" .. (#path - 1) .. " pulo(s)): " .. table.concat(path, " -> "))

    for i = 2, #path do
        local nextIsland = path[i]
        local nextSpawn  = GetSpawnOnIsland(nextIsland, spawns)

        if nextSpawn then
            CleanTpToSpawn(nextSpawn.position, nextSpawn.name)
            VerifyAndCommitIsland(nextIsland, nextSpawn.position, nextSpawn.name, 3)
            spawns = GetSpawns()
        else
            TpLog("Sem spawn em: " .. nextIsland .. " — pulando passo")
        end
    end

    -- Posicionamento final: TP dentro do inimigo → equipa fruta → reseta
    -- Captura posição do alvo agora para passar como forcedPos
    local targChar = getgenv().targ and getgenv().targ.Character
    local targHRP  = targChar and targChar:FindFirstChild("HumanoidRootPart")
    if targHRP then
        local snapPos = targHRP.Position
        TpAndReset(targChar, snapPos)
        TpLog("✓ TP + Reset em: " .. tostring(getgenv().targ and getgenv().targ.Name))
    else
        local finalRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if finalRoot then
            finalRoot.CFrame = CFrame.new(destPos.X, destPos.Y + 3, destPos.Z)
            TpLog("✓ Chegou em: " .. tostring(targetIsland))
        end
    end

    _bfsTpBusy = false
end

local function TpFastToTargetIsland()
    local t = getgenv().targ
    if not t or not t.Character then return end
    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    TpToPositionByIslands(hrp.Position)
end

local function GetMainGui()
    local lp = Players.LocalPlayer
    if not lp then return nil end
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    return pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)")
end

pcall(function()
    lp.CharacterAdded:Connect(function(char)
        -- ============================================================
        -- V14: captura a posição do alvo AGORA, antes de qualquer wait.
        -- O CharacterAdded dispara enquanto o char ainda está nascendo —
        -- se esperarmos, perdemos a janela ideal de TP.
        -- ============================================================
        local snapPos = nil
        local snapChar = nil
        pcall(function()
            local t = getgenv().targ
            if t and t.Character then
                local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    snapPos  = tHRP.Position  -- posição capturada antes de qualquer wait
                    snapChar = t.Character
                end
            end
        end)

        task.spawn(function()
            pcall(function()
                -- Reseta estados do ciclo anterior
                getgenv().SafeMode  = false
                getgenv().ForceSafe = false
                getgenv().LastTargetHealth = nil
                getgenv().TargetStartTime = nil
                getgenv().NoTargetCount = 0
                getgenv().HpSnapshot = nil
                getgenv().HpSnapshotTime = nil
                _tpResetCount = 0  -- reinicia contagem para o novo ciclo de resets

                local t = getgenv().targ

                if snapPos and t and t.Character and t.Character:FindFirstChild("Humanoid") and t.Character.Humanoid.Health > 0 then
                    -- Alvo ainda vivo: TP imediato usando posição capturada acima.
                    -- Passa forcedPos para TpAndReset não depender de ler o alvo de novo
                    -- (o alvo pode ter se movido entre o spawn e agora)
                    TpAndReset(snapChar, snapPos)
                else
                    getgenv().targ = nil
                    pcall(function() target() end)
                end
            end)
        end)
    end)
end)

local function IsEntityAlive(entity)
    if not entity then return false end
    local humanoid = entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetEnemiesInRange(character, range)
    local targets = {}
    if not character then return targets end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return targets end
    
    local playerPos = root.Position
    
    if not Workspace:FindFirstChild("Enemies") then
        return targets
    end

    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        if enemyRoot and IsEntityAlive(enemy) then
            if (enemyRoot.Position - playerPos).Magnitude <= range then
                table.insert(targets, enemy)
            end
        end
    end
    
    return targets
end

-- ============================================================
-- SISTEMA DE HIT (script corrigido)
-- Ataca inimigos do Workspace via RegisterAttack/RegisterHit
-- ============================================================
local function AttackNoCoolDown()
    local character = player.Character
    if not character then return end

    local equippedWeapon = character:FindFirstChildOfClass("Tool")
    if not equippedWeapon then return end

    local enemies = GetEnemiesInRange(character, 100)
    if #enemies == 0 then return end

    local modules = ReplicatedStorage:FindFirstChild("Modules")
    if not modules then return end

    local net = modules:FindFirstChild("Net")
    if not net then return end

    local registerAttack = net:FindFirstChild("RE/RegisterAttack")
    local registerHit    = net:FindFirstChild("RE/RegisterHit")

    if not registerAttack or not registerHit then return end

    local targets = {}
    local mainTarget = nil

    for _, enemy in ipairs(enemies) do
        if not enemy:GetAttribute("IsBoat") then
            local part = enemy:FindFirstChild("Head") or enemy.PrimaryPart
            if part then
                table.insert(targets, {enemy, part})
                mainTarget = part
            end
        end
    end

    if not mainTarget then return end

    registerAttack:FireServer(0)
    registerHit:FireServer(mainTarget, targets)
end

-- Auto click no Heartbeat (versão ALLANCLICANOBOTAODOMINI)
-- Roda a cada frame — funciona porque o personagem está dentro do inimigo
-- o servidor registra o hit sem precisar de delay artificial
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if not _G.Seriality then return end
        if getgenv().SafeMode then return end

        pcall(function()
            local character = player.Character
            if not character then return end

            -- Garante que a fruta está na mão SEMPRE antes de clicar
            local tool = character:FindFirstChildOfClass("Tool")
            local hasFruit = tool and tool.ToolTip == "Blox Fruit"
            if not hasFruit then
                pcall(function() equip("Blox Fruit") end)
                -- Relê depois de equipar
                tool = character:FindFirstChildOfClass("Tool")
            end
            if not tool then return end

            if tool:FindFirstChild("LeftClickRemote") then
                AttackNoCoolDown()
                tool.LeftClickRemote:FireServer(Vector3.new(0.01, -500, 0.01), 1, true)
                tool.LeftClickRemote:FireServer(false)
            end
        end)
    end)
end)

getgenv().weapon = nil
getgenv().targ = nil 
getgenv().lasttarrget = nil
getgenv().checked = {}
getgenv().blacklist = getgenv().blacklist or {}
getgenv().pl = p:GetPlayers()
getgenv().LastTargetHealth = nil
getgenv().LastDamageTime = tick()
getgenv().NoTargetCount = 0
getgenv().SafeMode = false
getgenv().ForceSafe = false
getgenv().UsedServers = getgenv().UsedServers or {}
getgenv().LastAttackTime = 0
getgenv().EnvDamageCount = 0
getgenv().OurDamageCount = 0
getgenv().TargetStartTime = nil
-- FIX: substitui HpUpCount por HpSnapshot (sistema mais preciso do script corrigido)
getgenv().HpSnapshot = nil
getgenv().HpSnapshotTime = nil
getgenv().LastOurDamageTime = 0
local ScriptStartTime = tick()

-- ============================================================
-- PERSISTÊNCIA JSON (tempo acumulado + bounty farmado)
-- Arquivo salvo: AutoBountyData.json (via writefile/readfile)
-- ============================================================
local SAVE_FILE = "AutoBountyData.json"

local _saveData = {
    totalElapsed = 0,
    totalFarmed  = 0,
    sessionStart = 0,
    lastBounty   = 0,
}

local _sessionStartTick = tick()

local function SaveData()
    pcall(function()
        local sessionTime = tick() - _sessionStartTick
        local currentBounty = 0
        pcall(function()
            currentBounty = game.Players.LocalPlayer.leaderstats["Bounty/Honor"].Value
        end)
        local gained = math.max(0, currentBounty - _saveData.sessionStart)
        local dataToWrite = {
            totalElapsed = (_saveData.totalElapsed or 0) + sessionTime,
            totalFarmed  = (_saveData.totalFarmed  or 0) + gained,
            sessionStart = _saveData.sessionStart,
            lastBounty   = currentBounty,
        }
        local json = game:GetService("HttpService"):JSONEncode(dataToWrite)
        writefile(SAVE_FILE, json)
    end)
end

local function LoadData()
    pcall(function()
        if isfile(SAVE_FILE) then
            local raw = readfile(SAVE_FILE)
            if raw and raw ~= "" then
                local decoded = game:GetService("HttpService"):JSONDecode(raw)
                if decoded then
                    _saveData.totalElapsed = decoded.totalElapsed or 0
                    _saveData.totalFarmed  = decoded.totalFarmed  or 0
                    _saveData.lastBounty   = decoded.lastBounty   or 0
                    print("[Auto Bounty] Save carregado: " .. math.floor(_saveData.totalElapsed) .. "s acumulados | " .. math.floor(_saveData.totalFarmed) .. " bounty farmado total.")
                end
            end
        else
            print("[Auto Bounty] Nenhum save encontrado, iniciando do zero.")
        end
    end)
end

LoadData()

-- Captura bounty de início da sessão atual
task.spawn(function()
    local lp_sv = game.Players.LocalPlayer
    for i = 1, 30 do
        local ok = false
        pcall(function()
            if lp_sv.leaderstats and lp_sv.leaderstats["Bounty/Honor"] then
                _saveData.sessionStart = lp_sv.leaderstats["Bounty/Honor"].Value
                ok = true
            end
        end)
        if ok then break end
        task.wait(0.5)
    end
    _sessionStartTick = tick()
end)

-- Salva a cada 15 segundos
task.spawn(function()
    while task.wait(15) do
        SaveData()
    end
end)

wait(1)

--- Funções principais ---
local tween = nil
local stopbypass = false

function bypass(Pos)   
    if not lp or not lp.Character then return end
    if not lp.Character:FindFirstChild("Head") or not lp.Character:FindFirstChild("HumanoidRootPart") or not lp.Character:FindFirstChild("Humanoid") then return end
    
    dist = math.huge
    is = nil
    for i, v in pairs(island) do
        if (Pos.Position-v.Position).magnitude < dist then
            is = v 
            dist = (Pos.Position-v.Position).magnitude 
        end
    end 
    if is == nil then return end
    if lp:DistanceFromCharacter(Pos.Position) > distbyp then 
        if (lp.Character.Head.Position-Pos.Position).magnitude > (is.Position-Pos.Position).magnitude then
            if tween then
                pcall(function() tween:Destroy() end)
            end

            if (is.X == 61163.8515625 and is.Y ==11.6796875 and is.Z == 1819.7841796875) or is == CFrame.new(-12471.169921875 + 50, 374.94024658203, -7551.677734375) or is == CFrame.new(-5085.23681640625 + 50, 316.5072021484375, -3156.202880859375) or is == CFrame.new(5749.7861328125 + 50, 611.9736938476562, -276.2497863769531) then
                if tween then
                   pcall(function() tween:Cancel() end)
                end
                -- FIX PING ALTO: delay mínimo de 0.08s mesmo em ping baixo, cresce até ~0.3s em 300ms
                local _bypassDelay = math.max(0.08, 0.05 * PingMult())
                local _bypassAttempts = 0
                repeat
                    task.wait(_bypassDelay)
                    _bypassAttempts = _bypassAttempts + 1
                    if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        lp.Character.HumanoidRootPart.CFrame = is
                        -- A cada 3 tentativas força commit com servidor
                        if _bypassAttempts % 3 == 0 then
                            pcall(function()
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                            end)
                        end
                    end
                until (lp and lp.Character and lp.Character:FindFirstChild("PrimaryPart") and lp.Character.PrimaryPart.CFrame == is) or _bypassAttempts >= 30
                AdaptiveWait(0.1)
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                end)
            else
                -- TP LIMPO: sem destruir a Head, direto via CFrame
                -- Evita death loop, respawn delay e detecção de morte repetida
                if not stopbypass then
                    if tween then
                       pcall(function() tween:Cancel() end)
                    end
                    pcall(function()
                        if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                            lp.Character.HumanoidRootPart.CFrame = is
                            AdaptiveWait(0.1) -- era task.wait(0.1)
                            if lp.Character:FindFirstChild("HumanoidRootPart") then
                                lp.Character.HumanoidRootPart.CFrame = is
                            end
                        end
                    end)
                    AdaptiveWait(0.3) -- era task.wait(0.3) — com 400ms vira ~1.14s
                end 
            end
        end
    end
end

function CheckNearestTeleporter(aI)
    local vcspos = aI.Position
    local min = math.huge
    local min2 = math.huge
    -- FIX: não redefine World1/2/3 localmente; usa o World3 já definido globalmente
    local TableLocations = {}
    if World3 then
        TableLocations = {
            ["Mansion"] = Vector3.new(-12471, 374, -7551),
            ["Hydra"] = Vector3.new(5659, 1013, -341),
            ["Caslte On The Sea"] = Vector3.new(-5092, 315, -3130),
            ["Floating Turtle"] = Vector3.new(-12001, 332, -8861),
            ["Beautiful Pirate"] = Vector3.new(5319, 23, -93),
            ["Temple Of Time"] = Vector3.new(28286, 14897, 103)
        }
    end

    if World3 then
        local function near(pos, center, radius)
            return (pos - center).Magnitude <= radius
        end

        local turtlePos = TableLocations["Floating Turtle"]
        if turtlePos and near(vcspos, turtlePos, 4000) then
            return turtlePos
        end

        local mansionPos = TableLocations["Mansion"]
        if mansionPos and near(vcspos, mansionPos, 3500) then
            return mansionPos
        end

        local castlePos = TableLocations["Caslte On The Sea"]
        -- Castle On The Sea: raio maior pois funciona como hub intermediário central
        if castlePos and near(vcspos, castlePos, 5000) then
            return castlePos
        end

        local hydraPos = TableLocations["Hydra"]
        if hydraPos and near(vcspos, hydraPos, 3500) then
            return hydraPos
        end
    end

    local TableLocations2 = {}
    for r, v in pairs(TableLocations) do
        TableLocations2[r] = (v - vcspos).Magnitude
    end
    for r, v in pairs(TableLocations2) do
        if v < min then
            min = v
            min2 = v
        end
    end
    local choose
    for r, v in pairs(TableLocations2) do
        if v <= min then
            choose = TableLocations[r]
        end
    end
    local min3 = (vcspos - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

    if min2 <= min3 then
        return choose
    end
end    

function requestEntrance(aJ)
    local args = {"requestEntrance", aJ}
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))    
    local oldcframe = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    local char = game.Players.LocalPlayer.Character.HumanoidRootPart
    char.CFrame = CFrame.new(oldcframe.X, oldcframe.Y + 50, oldcframe.Z)    
    AdaptiveWait(0.5) -- era task.wait(0.5) — com 400ms vira ~1.9s
end   

function topos(Tween_Pos)
    pcall(function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        -- TP direto, sem tween
        local aM = CheckNearestTeleporter(Tween_Pos)
        if aM then requestEntrance(aM) end

        hrp.CFrame = CFrame.new(Tween_Pos.X, Tween_Pos.Y, Tween_Pos.Z)
        AdaptiveWait(0.05)
        CommitPositionToServer()
    end)
end

function StopTween(target)
    pcall(function()
        if not target then
            getgenv().StopTween = true            
            if tween then
                tween:Cancel()
                tween = nil
            end            
            local player = game:GetService("Players").LocalPlayer
            local character = player and player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Anchored = true
                task.wait(0.1)
                humanoidRootPart.CFrame = humanoidRootPart.CFrame
                humanoidRootPart.Anchored = false
            end
            local bodyClip = humanoidRootPart and humanoidRootPart:FindFirstChild("BodyClip")
            if bodyClip then
                bodyClip:Destroy()
            end
            getgenv().StopTween = false
            getgenv().Clip = false
        end
    end)
end

function to(Pos)
    pcall(function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        if hum.Sit then hum.Sit = false end
        -- TP puro: só CFrame, sem bypass, sem tween, sem seguir
        hrp.CFrame = CFrame.new(Pos.X, Pos.Y, Pos.Z)
    end)
end

function buso()
    if (not (game.Players.LocalPlayer.Character:FindFirstChild("HasBuso"))) then
        local rel = game.ReplicatedStorage
        rel.Remotes.CommF_:InvokeServer("Buso")
    end
end

pcall(function() buso() end)

function Ken()
    if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and game.Players.LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") then
        buoi = true
    else
        if IS_MOBILE then
            pcall(function()
                game:service("VirtualUser"):CaptureController()
                game:service("VirtualUser"):SetKeyDown("0x65")
                game:service("VirtualUser"):SetKeyUp("0x65")
            end)
        else
            -- Em Desktop, usar down() ao invés
            pcall(function()
                down(Enum.KeyCode.E)
            end)
        end
    end
end

local l = 0.1
function down(use)
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true,use,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
        task.wait(l)
        game:GetService("VirtualInputManager"):SendKeyEvent(false,use,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
    end)
end

function equip(tooltip)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:wait()
    if not character or not character:FindFirstChildOfClass("Humanoid") then return false end
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item and item:IsA("Tool") and item.ToolTip == tooltip then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and not humanoid:IsDescendantOf(item) then
                pcall(function()
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(item)
                end)
                return true
            end
        end
    end
    return false
end

function EquipWeapon(Tool)
    pcall(function()
        if game.Players.LocalPlayer.Backpack:FindFirstChild(Tool) then
            local ToolHumanoid = game.Players.LocalPlayer.Backpack:FindFirstChild(Tool)
            if ToolHumanoid and game.Players.LocalPlayer.Character then
                ToolHumanoid.Parent = game.Players.LocalPlayer.Character
            end
        end
    end)
end

function Click()
    if IS_MOBILE then
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,1,0,1))
        end)
    else
        -- Em Desktop, usar ataque remoto ao invés
        pcall(function()
            local CommF_ = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
            if CommF_ and game.Players.LocalPlayer.Character then
                CommF_:InvokeServer("Attack", game.Players.LocalPlayer.Character.HumanoidRootPart)
            end
        end)
    end
end

function AimAndClick()
    pcall(function()
        local targ = getgenv().targ
        if not targ or not targ.Character then Click() return end
        local targHRP = targ.Character:FindFirstChild("HumanoidRootPart")
        if not targHRP then Click() return end

        local myChar = game.Players.LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then Click() return end

        -- FIX LAG/FPS: usa offset Y=2 para compensar latência e FPS baixo
        local targetPos = targHRP.Position + Vector3.new(0, 2, 0)

        local lookCF = CFrame.lookAt(myHRP.Position, targetPos)
        local _, yRot, _ = lookCF:ToEulerAnglesYXZ()
        myHRP.CFrame = CFrame.new(myHRP.Position) * CFrame.Angles(0, yRot, 0)

        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPos)
        end

        local function tryFire()
            if not IS_MOBILE then
                -- Em desktop, usar chamadas remotas em vez de VirtualUser
                pcall(function()
                    local CommF_ = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                    if CommF_ and getgenv().targ and getgenv().targ.Character then
                        CommF_:InvokeServer("AttackPlayer", getgenv().targ.Character:FindFirstChild("HumanoidRootPart"))
                    end
                end)
                return
            end
            
            local screenPos, onScreen = cam:WorldToScreenPoint(targetPos)
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                if onScreen then
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(screenPos.X, screenPos.Y))
                    AdaptiveWait(0.05)
                    game:GetService("VirtualUser"):Button1Up(Vector2.new(screenPos.X, screenPos.Y))
                else
                    if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPos) end
                    local sp2, os2 = cam:WorldToScreenPoint(targetPos)
                    if os2 then
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(sp2.X, sp2.Y))
                        AdaptiveWait(0.05)
                        game:GetService("VirtualUser"):Button1Up(Vector2.new(sp2.X, sp2.Y))
                    else
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 1, 0, 1))
                        AdaptiveWait(0.05)
                        game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 1, 0, 1))
                    end
                end
            end)
        end

        -- ANTI-KICK FIX: removido segundo tryFire — double fire em 0.05s é detectável como spam
        tryFire()
    end)
end

-- No Clip
task.spawn(function()
    while true do
        local ping = GetPing()
        -- Acima de 150ms throttle bem agressivo — no-clip a 60fps com lag alto é detectado
        local noclipDelay = ping > 150 and (0.08 * PingMult()) or 0
        if noclipDelay > 0 then task.wait(noclipDelay) else game:GetService("RunService").Heartbeat:Wait() end
        pcall(function()
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, v in pairs(character:GetChildren()) do
                    if v and v:IsA("BasePart") and v.Parent then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- FPS Boost
if getgenv().Setting.Another.FPSBoots then
    local g = game
    local w = g.Workspace
    local l_light = g.Lighting
    local t = w.Terrain
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    l_light.GlobalShadows = false
    l_light.FogEnd = 9e9
    l_light.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
end

if getgenv().Setting.Another.WhiteScreen then
    game.RunService:Set3dRenderingEnabled(false)
end

getgenv().LastRiskTime = getgenv().LastRiskTime or 0
local RISK_HOP_COOLDOWN = 6  -- FIX V22: reduzido de 10 para 6s — espera menos após Risk sair

local function IsRiskActive()
    local lp = game.Players.LocalPlayer
    if not lp then return false end
    local gui = lp:FindFirstChild("PlayerGui")
    if not gui then return false end

    for _, inst in ipairs(gui:GetDescendants()) do
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then
            local text = string.lower(inst.Text or "")
            if text ~= "" and (string.find(text, "bounty") and string.find(text, "risk") or string.find(text, "bounty at risk") or string.find(text, "risk")) then
                local visible = inst.Visible
                local parent = inst.Parent
                while visible and parent and parent ~= gui do
                    if parent:IsA("GuiObject") and not parent.Visible then
                        visible = false
                        break
                    end
                    parent = parent.Parent
                end
                if visible then
                    return true
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if IsRiskActive() then
                getgenv().LastRiskTime = tick()
            end
        end)
    end
end)

-- ============================================================
-- MONITOR DE HP + SAFEMODE V33
-- Arquitetura: dois loops separados
--
--   Loop 1 — HP MONITOR (nunca para, sem pcall externo)
--     Roda a 0.01s, só lê humanoid.Health e seta SafeMode.
--     Não faz nada além disso. Não pode ser engolido por erro.
--     ATIVA  : HP <= safeHp   (3000)
--     DESATIVA: HP >= deactHp  (3500) E sem ForceSafe/IsHopping
--
--   Loop 2 — AÇÕES DE SAFE (sobe, cura, etc.)
--     Roda a 0.05s, reage ao estado SafeMode definido pelo Loop 1.
--     Erros aqui não derrubam o monitor.
-- ============================================================
local _lastHealTime      = 0
local _lastFruitHealTime = 0

-- LOOP 1: monitor de HP puro — define SafeMode, nada mais
task.spawn(function()
    while true do
        -- SEM pcall aqui: se der erro, o loop recomeça no próximo ciclo
        -- A única coisa que pode falhar é FindFirstChild, tratada com "and"
        local ok, err = pcall(function()
            local char     = lp.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not humanoid then return end

            local hp       = humanoid.Health

            -- Se HP == 0 é morte intencional do ResetBeforeTp, ignora
            if hp <= 0 then return end

            local safeHp   = (getgenv().Setting.SafeHealth and getgenv().Setting.SafeHealth.Health)     or 3000
            local deactHp  = (getgenv().Setting.SafeHealth and getgenv().Setting.SafeHealth.Deactivate) or 3500
            local isHopping = getgenv().IsHopping == true
            local forceSafe = getgenv().ForceSafe  == true

            local lastRisk       = getgenv().LastRiskTime or 0
            local inRiskCooldown = lastRisk > 0 and (tick() - lastRisk) < RISK_HOP_COOLDOWN
            local hasTarget      = getgenv().targ ~= nil and IsValidPlayerTarget(getgenv().targ)
            local waitingForHop  = inRiskCooldown and not hasTarget

            -- ATIVA SafeMode
            if hp <= safeHp or forceSafe or isHopping or waitingForHop then
                if not getgenv().SafeMode then
                    -- Log motivo
                    if isHopping then
                        print("[SafeMode] ATIVADO — Hop em andamento")
                    elseif waitingForHop then
                        print("[SafeMode] ATIVADO — aguardando Hop (Risk)")
                    else
                        print("[SafeMode] ATIVADO — HP: " .. math.floor(hp) .. " / " .. safeHp)
                    end
                    getgenv().targ          = nil
                    getgenv().TargetStartTime = nil
                end
                getgenv().SafeMode = true
                return
            end

            -- DESATIVA SafeMode: HP >= deactHp E nenhuma flag de bloqueio ativa
            if getgenv().SafeMode and hp >= deactHp and not forceSafe and not isHopping and not waitingForHop then
                print("[SafeMode] DESATIVADO — HP: " .. math.floor(hp) .. " >= " .. deactHp)
                getgenv().SafeMode = false
            end
        end)

        if not ok then
            -- Erro no monitor: loga e mantém SafeMode como estava (não altera)
            print("[SafeMode ERRO] " .. tostring(err))
        end

        task.wait(0.01)
    end
end)

-- LOOP 2: ações enquanto SafeMode está ativo (subir, curar)
-- Separado do monitor para que erros aqui não afetem a detecção de HP
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if not getgenv().SafeMode then return end

            local char     = lp.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            local hrp      = char and char:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end

            local hp        = humanoid.Health
            local safeHp    = (getgenv().Setting.SafeHealth and getgenv().Setting.SafeHealth.Health) or 3000
            local safeY     = (getgenv().Setting.SafeHealth and getgenv().Setting.SafeHealth.HighY)  or 1200
            local isHopping = getgenv().IsHopping == true
            local isEmerg   = hp > 0 and hp < math.floor(safeHp * 0.5)

            -- Altitude alvo: Hop > Emergência > Normal
            local targetY
            if isHopping then
                targetY = safeY + 500
            elseif isEmerg then
                targetY = safeY + 500
            else
                targetY = safeY + 200
            end

            -- Sobe se estiver abaixo da altitude alvo
            if hrp.Position.Y < targetY then
                hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
            end

            local now = tick()

            -- Cura V3 (tecla T)
            local healCd = isEmerg and 0.3 or 0.8
            if getgenv().Setting.Another.V3
                and getgenv().Setting.Another.CustomHealth
                and hp < getgenv().Setting.Another.Health
                and (now - _lastHealTime) > healCd then
                _lastHealTime = now
                pcall(function() down("T") end)
            end

            -- Cura com Fruta a cada 2s
            if getgenv().Setting.Fruit.Enable and (now - _lastFruitHealTime) > 2 then
                _lastFruitHealTime = now
                pcall(function()
                    equip("Blox Fruit")
                    task.wait(0.05)
                    if getgenv().Setting.Fruit.C.Enable and getgenv().Setting.Fruit.C.HoldTime > 0 then
                        down("C")
                    elseif getgenv().Setting.Fruit.V.Enable and getgenv().Setting.Fruit.V.HoldTime > 0 then
                        down("V")
                    end
                end)
            end

            -- Emergência: força Buso
            if isEmerg then
                pcall(function() buso() end)
            end
        end)
    end
end)

function hasValue(array, targetString)
    for _, value in ipairs(array) do
        if value == targetString then
            return true
        end
    end
    return false
end

local function IsValidPlayerTarget(plr)
    if not plr then return false end
    if plr.Parent ~= game:GetService("Players") then return false end
    local char = plr.Character
    if not char then return false end
    return true
end

-- Retorna todos os jogadores inimigos válidos no servidor
local function GetAllValidTargets()
    local result = {}
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= lp and v.Team ~= nil
            and (tostring(lp.Team) == "Pirates" or (tostring(v.Team) == "Pirates" and tostring(lp.Team) ~= "Pirates"))
            and IsValidPlayerTarget(v) then
            local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
            local hum = v.Character and v.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0
                and not IsInSafeZone(hrp.Position)
                and hrp.Position.Y <= 12000 then
                table.insert(result, v)
            end
        end
    end
    return result
end
local SAFEZONE_RADIUS = 150

local SafeZones = {
    CFrame.new(-5097.72656, 311.696777, -2189.77832, 0.374604106, 0, -0.92718488, 0, 1, 0, 0.92718488, 0, 0.374604106),
    CFrame.new(-265.647003, 3.42700195, 5223.68799, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-5012.70996, 398.437012, -3007.46411, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-16173.8379, 7.90499878, 453.493988, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-5238.39697, 311.619934, -2132.94409, 0.374604106, 0, -0.92718488, 0, 1, 0, 0.92718488, 0, 0.374604106),
    CFrame.new(-12547.71, 290.139008, -7487.06494, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

local function IsInSafeZone(pos)
    for _, cf in ipairs(SafeZones) do
        if (pos - cf.Position).Magnitude <= SAFEZONE_RADIUS then
            return true
        end
    end
    return false
end

if getgenv().Setting.Click.FastClick then
    pcall(function()
        local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
        CameraShaker:Stop()
    end)
    pcall(function()
        local fastattack = true
        local CombatFrameworkR = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
        local y_cf = debug.getupvalues(CombatFrameworkR)[2]
        task.spawn(function()
            game:GetService("RunService").RenderStepped:Connect(function()
                if fastattack then
                    if typeof(y_cf) == "table" then
                        pcall(function()
                            y_cf.activeController.timeToNextAttack = 0
                            y_cf.activeController.hitboxMagnitude = 60
                            y_cf.activeController.active = false
                            y_cf.activeController.timeToNextBlock = 0
                            y_cf.activeController.focusStart = 1655503339.0980349
                            y_cf.activeController.increment = 1
                            y_cf.activeController.blocking = false
                            y_cf.activeController.attacking = false
                            y_cf.activeController.humanoid.AutoRotate = true
                        end)
                    end
                end
            end)
        end)
    end)
end

function SkipPlayer()
    StopStick()
    _tpResetCount = 0
    _lastTpTarget = nil
    getgenv().killed = getgenv().targ 
    table.insert(getgenv().checked, getgenv().targ)
    table.insert(getgenv().blacklist, getgenv().targ)
    getgenv().targ = nil
    getgenv().TargetStartTime = nil
    -- FIX: limpa HpSnapshot ao pular player
    getgenv().HpSnapshot = nil
    getgenv().HpSnapshotTime = nil
    getgenv().OurDamageCount = 0
    getgenv().EnvDamageCount = 0
    target()
end

-- ============================================================
-- SERVER HOP SYSTEM
-- ============================================================
local EXECUTOR_SIGNAL_FN = (type(firesignal) == "function" and firesignal)
    or (type(syn) == "table" and type(syn.signal_fire) == "function" and syn.signal_fire)
    or (type(fluxus) == "table" and type(fluxus.fire_signal) == "function" and fluxus.fire_signal)
    or (type(xeno) == "table" and type(xeno.fire_signal) == "function" and xeno.fire_signal)

local function EXECUTOR_SIGNAL_FIRE(signal, ...)
    if EXECUTOR_SIGNAL_FN then pcall(EXECUTOR_SIGNAL_FN, signal, ...) end
end

local _HOP_FAILED  = false
local _HOP_SUCCESS = false
local _HOP_ABORT   = false

game:GetService("TeleportService").TeleportInitFailed:Connect(function()
    _HOP_FAILED  = true
    _HOP_SUCCESS = false
end)

local function SERVER_BROWSER_OPEN()
    local PlayerGui = lp:WaitForChild("PlayerGui")
    local gui = PlayerGui:FindFirstChild("ServerBrowser")
    if gui and not gui.Enabled then gui.Enabled = true end

    if not gui then
        pcall(function()
            local btn = PlayerGui:FindFirstChild("Topbar")
                and PlayerGui.Topbar:FindFirstChild("Frame")
                and PlayerGui.Topbar.Frame:FindFirstChild("ServerBrowserButton")
            if btn then EXECUTOR_SIGNAL_FIRE(btn.MouseButton1Click) end
        end)
        local elapsed = 0
        repeat task.wait(0.1); elapsed += 0.1
            gui = PlayerGui:FindFirstChild("ServerBrowser")
        until gui or elapsed >= 5
    end

    if not gui then return end
    if not gui.Enabled then gui.Enabled = true end

    local totalLabel = gui.Frame and gui.Frame:FindFirstChild("Total")
    if totalLabel then
        local elapsed = 0
        repeat task.wait(0.1); elapsed += 0.1
        until (totalLabel.Text:match("%d+/%d+") ~= nil) or elapsed >= 5
    end
end

local function SERVER_BROWSER_UNLOCK(refreshBtn)
    if type(getconnections) == "function" and type(getupvalues) == "function" and type(setupvalue) == "function" then
        for _, conn in ipairs(getconnections(refreshBtn.MouseButton1Click)) do
            pcall(function()
                local upvals = getupvalues(conn.Function)
                for i, val in pairs(upvals) do
                    if val == true then setupvalue(conn.Function, i, false); break end
                end
            end)
        end
    end
    pcall(function() refreshBtn.Text = "Refresh" end)
    task.wait(0.2)
end

local BUTTON_EVENTS = {"MouseButton1Click", "MouseButton1Up", "Activated"}

local function BUTTON_FIRE(btn)
    local fired = false
    if type(getconnections) == "function" then
        for _, evName in ipairs(BUTTON_EVENTS) do
            local ok, sig = pcall(function() return btn[evName] end)
            if ok and sig then
                local ok2, conns = pcall(getconnections, sig)
                if ok2 and conns and #conns > 0 then
                    for _, conn in ipairs(conns) do
                        task.spawn(function()
                            if not pcall(conn.Function) then pcall(conn.Fire, conn) end
                        end)
                    end
                    fired = true
                    break
                end
            end
        end
    end
    if not fired then
        EXECUTOR_SIGNAL_FIRE(btn.MouseButton1Click)
        EXECUTOR_SIGNAL_FIRE(btn.MouseButton1Up)
    end
end

local function SERVER_BROWSER_REFRESH()
    local PlayerGui = lp:WaitForChild("PlayerGui")
    local gui = PlayerGui:FindFirstChild("ServerBrowser")
    if not gui then return end
    local frame = gui:FindFirstChild("Frame")
    local refreshBtn = frame and frame:FindFirstChild("Refresh")
    if not refreshBtn then return end

    if refreshBtn.Text == "Refreshing..." then
        local e = 0
        repeat task.wait(0.2); e += 0.2 until refreshBtn.Text == "Refresh" or e >= 8
        if refreshBtn.Text == "Refreshing..." then
            SERVER_BROWSER_UNLOCK(refreshBtn)
            task.wait(0.2)
        end
    end

    BUTTON_FIRE(refreshBtn)
    local e = 0
    repeat task.wait(0.1); e += 0.1 until refreshBtn.Text == "Refreshing..." or e >= 2
    e = 0
    repeat task.wait(0.5); e += 0.5 until refreshBtn.Text == "Refresh" or e >= 8
    if refreshBtn.Text == "Refreshing..." then SERVER_BROWSER_UNLOCK(refreshBtn) end
end

local function SERVER_LIST_GET()
    local PlayerGui = lp:WaitForChild("PlayerGui")
    local gui = PlayerGui:FindFirstChild("ServerBrowser")
    if not gui then return {} end
    local inside = gui.Frame
        and gui.Frame:FindFirstChild("FakeScroll")
        and gui.Frame.FakeScroll:FindFirstChild("Inside")
    if not inside then return {} end
    local children = inside:GetChildren()
    local jobs = {}
    for _, i in ipairs({4, 5, 6, 7, 8}) do
        local entry = children[i]
        if entry and entry:IsA("Frame") then
            local btn = entry:FindFirstChild("Join")
            local job = btn and btn:GetAttribute("Job")
            if job and job ~= "" and btn.Text == "Join" then
                table.insert(jobs, job)
            end
        end
    end
    return jobs
end

local function SERVER_TELEPORT_TRY(jobId)
    _HOP_FAILED = false
    local ServerBrowser = game:GetService("ReplicatedStorage"):FindFirstChild("__ServerBrowser")
    if not ServerBrowser then return false end
    pcall(function() ServerBrowser:InvokeServer("teleport", jobId) end)
    local elapsed = 0
    repeat task.wait(0.1); elapsed += 0.1 until _HOP_FAILED or elapsed >= 2
    return not _HOP_FAILED
end

function HopServer()
    if getgenv().IsHopping then return end

    if IsRiskActive() then
        getgenv().LastRiskTime = tick()
        return
    end

    local lastRisk = getgenv().LastRiskTime or 0
    if tick() - lastRisk < RISK_HOP_COOLDOWN then return end

    getgenv().IsHopping  = true
    getgenv().ForceSafe  = true  -- bloqueia combate e mantém SafeMode ativo durante todo o Hop
    getgenv().targ       = nil   -- cancela alvo imediatamente para o Heartbeat parar de mover

    local ServerBrowser = game:GetService("ReplicatedStorage"):FindFirstChild("__ServerBrowser")
    if not ServerBrowser then
        print("[SERVER HOP] ServerBrowser não encontrado")
        getgenv().IsHopping = false
        getgenv().ForceSafe = false
        return
    end

    local safeY = (getgenv().Setting.SafeHealth and getgenv().Setting.SafeHealth.HighY) or 1200
    local hopY  = safeY + 500  -- altura exclusiva do Hop — mais alto que o SafeMode normal

    -- Loop dedicado que mantém o personagem no ar DURANTE TODO O HOP
    -- Roda em paralelo e só para quando o teleporte for confirmado
    local hopGuardActive = true
    task.spawn(function()
        while hopGuardActive do
            pcall(function()
                local char = lp.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < hopY then
                    hrp.CFrame = CFrame.new(hrp.Position.X, hopY, hrp.Position.Z)
                end
            end)
            task.wait(0.01)  -- mesma frequência do SafeMode loop — não deixa nada abaixar
        end
    end)

    _HOP_SUCCESS = false
    _HOP_ABORT   = false

    print("[SERVER HOP] Iniciando... (personagem travado em Y=" .. hopY .. ")")
    SERVER_BROWSER_OPEN()

    task.spawn(function()
        while not _HOP_SUCCESS and not _HOP_ABORT do
            task.wait(3)
            if not _HOP_SUCCESS and not _HOP_ABORT then
                SERVER_BROWSER_REFRESH()
            end
        end
    end)

    while not _HOP_SUCCESS do
        local jobs = SERVER_LIST_GET()
        if #jobs > 0 then
            for _, jobId in ipairs(jobs) do
                if _HOP_SUCCESS then break end
                print("[SERVER HOP] Tentando:", jobId)
                if SERVER_TELEPORT_TRY(jobId) then
                    _HOP_SUCCESS = true
                    print("[SERVER HOP] Teleporte iniciado!")
                    break
                end
            end
        end
        if not _HOP_SUCCESS then task.wait(0.5) end
    end

    _HOP_ABORT = true

    -- Hop concluído: para o guard loop e limpa as flags
    hopGuardActive       = false
    getgenv().IsHopping  = false
    -- ForceSafe permanece true até o servidor trocar — o rejoin vai resetar o script
    -- mas caso o teleporte falhe silenciosamente, reseta após 10s como safety net
    task.delay(10, function()
        if not getgenv().IsHopping then
            getgenv().ForceSafe = false
        end
    end)
end

function target() 
    pcall(function()
        local myChar = game.Players.LocalPlayer.Character
        local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        local bestTarget = nil
        local bestDist   = math.huge
        local current = getgenv().targ
        local lockOn  = false
        if IsValidPlayerTarget(current) and current.Character then
            local ch  = current.Character
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp and not IsInSafeZone(hrp.Position) and hrp.Position.Y <= 12000 then
                bestTarget = current
                bestDist   = (hrp.Position - myHrp.Position).Magnitude
                local timeSinceAttack = tick() - (getgenv().LastAttackTime or 0)
                local inCombatActive = (function()
                    local ok, v = pcall(function()
                        return game.Players.LocalPlayer.PlayerGui.Main.InCombat.Visible
                    end)
                    return ok and v
                end)()
                if (getgenv().OurDamageCount or 0) > 0 or timeSinceAttack < 6 or inCombatActive then
                    lockOn = true
                end
            end
        end

        for _, v in pairs(game.Players:GetPlayers()) do 
            if v ~= lp and v.Team ~= nil and (tostring(lp.Team) == "Pirates" or (tostring(v.Team) == "Pirates" and tostring(lp.Team) ~= "Pirates")) then
                if v:FindFirstChild("Data") and ((getgenv().Setting.Skip.Fruit and hasValue(getgenv().Setting.Skip.FruitList, v.Data.DevilFruit.Value) == false) or not getgenv().Setting.Skip.Fruit) then
                    local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
                    if IsValidPlayerTarget(v)
                       and hrp
                       and not IsInSafeZone(hrp.Position)
                       and hrp.Position.Y <= 12000 then
                        if (tonumber(game.Players.LocalPlayer.Data.Level.Value) - 300) < v.Data.Level.Value then
                            if v.leaderstats["Bounty/Honor"].Value >= getgenv().Setting.Hunt.Min and v.leaderstats["Bounty/Honor"].Value <= getgenv().Setting.Hunt.Max then
                                if (getgenv().Setting.Skip.V4 and not v.Character:FindFirstChild("RaceTransformed")) or not getgenv().Setting.Skip.V4 then
                                    if hasValue(getgenv().checked, v) == false and hasValue(getgenv().blacklist, v) == false then
                                        if not (lockOn and bestTarget == current and v ~= current) then
                                            local dist = (hrp.Position - myHrp.Position).Magnitude
                                            if dist < bestDist then
                                                bestDist   = dist
                                                bestTarget = v
                                                if getgenv().Setting.Chat.Enabled then
                                                    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(getgenv().Setting.Chat.List[math.random(1, #getgenv().Setting.Chat.List)], "All")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestTarget == nil then
            getgenv().targ = nil
            getgenv().TargetStartTime = nil
            getgenv().NoTargetCount = (getgenv().NoTargetCount or 0) + 1

            -- FIX V22: Se saiu do Risk recentemente e não há alvo, faz Hop IMEDIATAMENTE
            -- sem precisar esperar NoTargetCount >= 10
            local lastRisk = getgenv().LastRiskTime or 0
            local timeSinceRisk = tick() - lastRisk
            local riskJustEnded = lastRisk > 0 and timeSinceRisk >= RISK_HOP_COOLDOWN and timeSinceRisk < (RISK_HOP_COOLDOWN + 3)

            if riskJustEnded then
                print("[Auto Bounty] Risk acabou e sem alvo no server, fazendo Hop agora!")
                task.spawn(HopServer)
            elseif tick() - ScriptStartTime > 19 and getgenv().NoTargetCount >= 10 then
                HopServer()
            end
        else
            getgenv().NoTargetCount = 0
            local oldTarget = getgenv().targ

            if oldTarget ~= bestTarget then
                getgenv().targ = bestTarget
                getgenv().TargetStartTime = tick()

                if bestTarget.Character and bestTarget.Character:FindFirstChild("Humanoid") then
                    getgenv().LastTargetHealth  = bestTarget.Character.Humanoid.Health
                    getgenv().LastDamageTime    = tick()
                    getgenv().EnvDamageCount    = 0
                    getgenv().OurDamageCount    = 0
                    -- FIX: zera LastOurDamageTime ao trocar de alvo para não herdar histórico do alvo anterior
                    getgenv().LastOurDamageTime = 0
                    getgenv().HpSnapshot        = nil
                    getgenv().HpSnapshotTime    = nil
                    print("[Auto Bounty] Novo alvo: " .. tostring(bestTarget.Name))
                else
                    getgenv().LastTargetHealth  = nil
                    getgenv().LastOurDamageTime = 0
                end
            else
                getgenv().targ = bestTarget
            end
        end
    end)
end

game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == getgenv().targ then
        StopStick()
        print("[Auto Bounty] Alvo saiu do servidor, procurando novo...")
        getgenv().targ = nil
        target()
    end
    for i, v in ipairs(getgenv().checked) do
        if v == plr then table.remove(getgenv().checked, i) break end
    end
    for i, v in ipairs(getgenv().blacklist) do
        if v == plr then table.remove(getgenv().blacklist, i) break end
    end
end)

-- ============================================================
-- MONITOR DE DANO: sistema HpSnapshot (do script corrigido)
-- Mais preciso que HpUpCount: compara o HP no momento do ataque
-- com o HP atual, descontando regen natural
-- ============================================================
local REGEN_RATE      = 2     -- HP/s regenerado naturalmente
local ATTACK_WINDOW   = 1.0   -- FIX LAG: aumentado de 0.5 para 1.0s — internet ruim tem delay de hit
local NO_DAMAGE_LIMIT = 5    -- FIX LAG: aumentado de 5 para 10s — mais tempo para registrar dano
local ENV_SKIP_COUNT  = 5     -- FIX LAG: aumentado de 3 para 5 — evita skip falso por lag

local function TakeHpSnapshot()
    local t = getgenv().targ
    if not t or not t.Character then return end
    local hum = t.Character:FindFirstChild("Humanoid")
    if not hum then return end
    getgenv().HpSnapshot     = hum.Health
    getgenv().HpSnapshotTime = tick()
end

-- Observa mudanças em LastAttackTime para tirar snapshot automaticamente
local _lastObservedAttackTime = getgenv().LastAttackTime or 0
task.spawn(function()
    while task.wait(0.05) do
        local cur = getgenv().LastAttackTime or 0
        if cur ~= _lastObservedAttackTime then
            _lastObservedAttackTime = cur
            TakeHpSnapshot()
        end
    end
end)

local function DidWeDamageTarget()
    local t = getgenv().targ
    if not t or not t.Character then return false end
    local hum = t.Character:FindFirstChild("Humanoid")
    if not hum then return false end

    local snap     = getgenv().HpSnapshot
    local snapTime = getgenv().HpSnapshotTime
    if not snap or not snapTime then return false end

    local elapsed  = tick() - snapTime
    local maxRegen = REGEN_RATE * elapsed
    local netDrop  = snap - hum.Health

    return netDrop > maxRegen
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local t  = getgenv().targ
            local me = game.Players.LocalPlayer

            if t and not IsValidPlayerTarget(t) then
                getgenv().targ             = nil
                getgenv().LastTargetHealth = nil
                getgenv().HpSnapshot       = nil
                getgenv().HpSnapshotTime   = nil
                return
            end

            if not t or not t.Character then return end
            local hum   = t.Character:FindFirstChild("Humanoid")
            local hrp   = t.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or not myHrp then return end

            if hum.Health <= 0 then
                print("[Auto Bounty] Alvo morreu! Procurando próximo...")
                StopStick()
                getgenv().HpSnapshot = nil
                getgenv().HpSnapshotTime = nil
                SkipPlayer()
                return
            end

            local currentHealth = hum.Health
            local distance      = (hrp.Position - myHrp.Position).Magnitude

            if distance > 80 then
                getgenv().LastTargetHealth = currentHealth
                getgenv().LastDamageTime   = tick()
                -- FIX: não zera OurDamageCount ao ficar longe — se já demos dano, mantém
                if (getgenv().OurDamageCount or 0) == 0 then
                    getgenv().EnvDamageCount = 0
                end
                return
            end

            -- FIX: checa se ficamos perto sem dar dano
            -- Só pula se OurDamageCount == 0 E nunca demos dano nesse alvo
            if distance <= 25 then
                local inCombatNow = false
                pcall(function()
                    inCombatNow = game.Players.LocalPlayer.PlayerGui.Main.InCombat.Visible
                end)
                if not inCombatNow then
                    local lastOur = getgenv().LastOurDamageTime or 0
                    local startTime = getgenv().TargetStartTime or 0
                    -- Só troca se: nunca demos dano (OurDamageCount==0) E ficou 15s sem dano
                    -- FIX LAG: aumentado de 8s para 15s — internet ruim demora para registrar hit
                    if (getgenv().OurDamageCount or 0) == 0 and lastOur == 0 and startTime > 0 and (tick() - startTime) > 15 then
                        print("[Auto Bounty] 15s em cima do alvo sem dar dano nenhum, trocando...")
                        getgenv().HpSnapshot = nil
                        getgenv().HpSnapshotTime = nil
                        SkipPlayer()
                        return
                    end
                end
            end

            if getgenv().LastTargetHealth == nil then
                getgenv().LastTargetHealth = currentHealth
                getgenv().LastDamageTime   = tick()
                return
            end

            local delta = currentHealth - getgenv().LastTargetHealth
            getgenv().LastTargetHealth = currentHealth

            if math.abs(delta) > 1 then
                getgenv().LastDamageTime = tick()

                local weDidDamage = DidWeDamageTarget()
                if not weDidDamage then
                    local attackWindow = tick() - (getgenv().LastAttackTime or 0)
                    weDidDamage = (delta < -1) and (attackWindow <= ATTACK_WINDOW) and (distance <= 25)
                end

                if weDidDamage then
                    getgenv().OurDamageCount = (getgenv().OurDamageCount or 0) + 1
                    getgenv().EnvDamageCount = 0
                    getgenv().LastOurDamageTime = tick()
                    getgenv().HpSnapshot = nil
                    getgenv().HpSnapshotTime = nil
                else
                    getgenv().EnvDamageCount = (getgenv().EnvDamageCount or 0) + 1

                    if (getgenv().OurDamageCount or 0) == 0 and getgenv().EnvDamageCount >= ENV_SKIP_COUNT then
                        print("[Auto Bounty] Alvo tomando dano externo sem dano nosso, pulando...")
                        getgenv().EnvDamageCount = 0
                        getgenv().HpSnapshot = nil
                        getgenv().HpSnapshotTime = nil
                        SkipPlayer()
                        return
                    end
                end
            else
                if tick() - (getgenv().LastDamageTime or 0) > NO_DAMAGE_LIMIT
                    and (getgenv().OurDamageCount or 0) == 0 then
                    print("[Auto Bounty] Vida do alvo estável por " .. NO_DAMAGE_LIMIT .. "s, trocando...")
                    getgenv().HpSnapshot = nil
                    getgenv().HpSnapshotTime = nil
                    SkipPlayer()
                end
            end
        end)
    end
end)

-- Sistema de armas
local gunmethod = getgenv().Setting.Gun.GunMode

-- Loop de mira: acima de 150ms fica bem mais lento
task.spawn(function()
    while true do
        local aimDelay = math.max(0.05, 0.05 * PingMult())
        task.wait(aimDelay)
        pcall(function()
            local targ = getgenv().targ
            if not targ or not targ.Character then return end
            local targHRP = targ.Character:FindFirstChild("HumanoidRootPart")
            if not targHRP then return end

            local myChar = game.Players.LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end

            local targetPos = targHRP.Position

            local lookCF = CFrame.lookAt(myHRP.Position, targetPos)
            local _, yRot, _ = lookCF:ToEulerAnglesYXZ()
            myHRP.CFrame = CFrame.new(myHRP.Position) * CFrame.Angles(0, yRot, 0)

            local cam = workspace.CurrentCamera
            if cam then
                local aimPos = targetPos + Vector3.new(0, 1, 0)
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, aimPos)
            end
        end)
    end
end)

-- Loop de seleção de armas
task.spawn(function()
    while true do
        task.wait(math.max(0.1, 0.08 * PingMult()))
        pcall(function()
            if getgenv().targ and getgenv().targ.Character and getgenv().targ.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if (getgenv().targ.Character:WaitForChild("HumanoidRootPart").CFrame.Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame.Position).Magnitude < 150 then 
                    if not gunmethod then
                        if getgenv().Setting.Fruit.Enable then
                            getgenv().weapon = "Blox Fruit"
                            wait(0.01)
                        end
                    else
                        EquipWeapon("Blox Fruit")
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- LOOP PRINCIPAL: TP direto no inimigo → reseta → repete (máx 4x)
-- ============================================================
local _tpResetCount  = 0   -- quantas vezes já fez TP+reset no alvo atual
local _lastTpTarget  = nil -- alvo do último TP para resetar contador ao trocar
local MAX_TP_RESETS  = 8

task.spawn(function()
    while true do
        task.wait(math.max(0.1, 0.1 * PingMult()))

        if not IsValidPlayerTarget(getgenv().targ) then
            getgenv().targ = nil
        end
        target()

        pcall(function()
            if getgenv().SafeMode then return end
            if getgenv().IsHopping then return end

            local t = getgenv().targ
            if not t or not t.Character then return end

            local targHRP = t.Character:FindFirstChild("HumanoidRootPart")
            local targHum = t.Character:FindFirstChild("Humanoid")
            local myHRP   = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local myHum   = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if not targHRP or not targHum then return end
            if targHum.Health <= 0 then return end
            -- NÃO retorna se myHum.Health <= 0 — continua spammando TP mesmo durante o respawn

            -- Reseta contador ao trocar de alvo
            if _lastTpTarget ~= t then
                _lastTpTarget = t
                _tpResetCount = 0
            end

            -- Ainda dentro do limite: reseta → spam TP durante respawn
            if _tpResetCount < MAX_TP_RESETS then
                -- Só reseta se estiver vivo — se já morto, apenas spam TP
                local jaEstaMorto = not myHum or myHum.Health <= 0
                if not jaEstaMorto then
                    _tpResetCount = _tpResetCount + 1
                    print("[Auto Bounty] Reset+SpamTP " .. _tpResetCount .. "/" .. MAX_TP_RESETS .. " em " .. t.Name)

                    -- Equipa fruta antes de resetar
                    pcall(function() equip("Blox Fruit") end)

                    -- Reseta e faz TP imediatamente junto
                    if myHum and myHum.Health > 0 then
                        myHum.Health = 0
                    end
                end

                -- Helper TP para uma posição
                local function doTPTo(dest)
                    pcall(function()
                        local curChar = lp.Character
                        local curHRP  = curChar and curChar:FindFirstChild("HumanoidRootPart")
                        if curHRP then curHRP.CFrame = CFrame.new(dest.X, dest.Y, dest.Z) end
                        if curChar and curChar.PrimaryPart then
                            curChar.PrimaryPart.CFrame = CFrame.new(dest.X, dest.Y, dest.Z)
                        end
                    end)
                end

                -- TP imediato no alvo principal assim que reseta
                local mainPos = targHRP.Position
                doTPTo(mainPos)

                -- Spam de TP durante respawn, rotacionando entre TODOS os alvos
                local oldChar  = lp.Character
                local elapsed  = 0
                local tpIndex  = 1

                while elapsed < 4 do
                    task.wait(0.01)
                    elapsed = elapsed + 0.01

                    pcall(function()
                        local allTargets = GetAllValidTargets()
                        if #allTargets == 0 then
                            -- Só o alvo principal
                            local tHRP2 = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                            doTPTo((tHRP2 and tHRP2.Position) or mainPos)
                            return
                        end
                        -- Rotaciona entre todos os alvos
                        tpIndex = (tpIndex % #allTargets) + 1
                        local next = allTargets[tpIndex]
                        local nHRP = next and next.Character and next.Character:FindFirstChild("HumanoidRootPart")
                        if nHRP then doTPTo(nHRP.Position) end
                    end)

                    -- Ao renascer: equipa fruta + volta pro alvo principal
                    if lp.Character ~= oldChar and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function() equip("Blox Fruit") end)
                        local finalPos = mainPos
                        for _ = 1, 8 do
                            pcall(function()
                                local tHRP2 = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                                if tHRP2 then finalPos = tHRP2.Position end
                            end)
                            doTPTo(finalPos)
                            task.wait(0.01)
                        end
                        pcall(function() equip("Blox Fruit") end)
                        break
                    end
                end

            -- else
            --     -- Passa de 4x: só ataca normalmente sem TP [DESABILITADO]
            --     equip(getgenv().weapon)
            --     for _, v in pairs(lp.Character:GetChildren()) do
            --         if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then
            --             if getgenv().Setting.Fruit.Enable then
            --                 getgenv().LastAttackTime = tick()
            --                 AimAndClick()
            --             end
            --         end
            --     end
            -- end

            -- Reativar PvP local
            pcall(function()
                local args1 = {
                    "HUD/Button/PvPShortcut"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/OnEventServiceActivity"):FireServer(unpack(args1))
            end)

            pcall(function()
                local args2 = {
                    "EnablePvp"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args2))
            end)
            end
        end)
    end
end)

-- PvP e habilidades defensivas/ofensivas
-- Buso verifica a 0.2s (era 0.5s) — Buso pode cair e o personagem ficava 500ms sem armadura
-- V3 de cura também verificado aqui como backup do SafeMode
-- V4 ativado proativamente assim que há alvo no range, não só quando perto
task.spawn(function()
    while task.wait(0.2) do 
        pcall(function()
            local myChar = game.Players.LocalPlayer.Character
            local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum  = myChar and myChar:FindFirstChild("Humanoid")
            if not myHrp or not myHum then return end

            -- Mantém PvP ativo sempre
            if game.Players.LocalPlayer.PlayerGui.Main.PvpDisabled.Visible == true then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EnablePvp")
            end

            -- Buso: reaplica sempre que não estiver ativo
            pcall(function() buso() end)

            local targ = getgenv().targ
            if targ and targ.Character then
                local targHrp = targ.Character:FindFirstChild("HumanoidRootPart")
                if targHrp then
                    local dist = (targHrp.Position - myHrp.Position).Magnitude

                    if dist < 150 then
                        -- V3: cura durante combate se HP < threshold configurado
                        if getgenv().Setting.Another.V3 then
                            if getgenv().Setting.Another.CustomHealth and myHum.Health <= getgenv().Setting.Another.Health then
                                l = 0.1
                                down("T")
                            end
                        end

                        -- V4: ativa assim que o alvo está no range
                        if getgenv().Setting.Another.V4 then
                            l = 0.1
                            down("Y")
                        end
                    end
                end
            end
        end)
    end
end)

-- Ken Haki — aumentado para 0.15s (era 0.3s): ativa mais rápido ao entrar em combate
task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            if getgenv().SafeMode then return end
            if getgenv().targ and getgenv().targ.Character and getgenv().targ.Character:FindFirstChild("HumanoidRootPart") and (getgenv().targ.Character.HumanoidRootPart.CFrame.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Magnitude < 150 then
                Ken()
            end
        end)
    end
end)

-- ============================================================
-- LOOP PRINCIPAL DE MOVIMENTO
-- Fase 1: teleporte direto até ficar perto do alvo (dist > 20)
-- Fase 2: Heartbeat — cola no inimigo toda frame, sempre de frente para ele
-- ============================================================

-- loop de validação/target roda a 0.05s (não move o personagem)
task.spawn(function()
    while task.wait(0.05) do
        if not IsValidPlayerTarget(getgenv().targ) then
            getgenv().targ = nil
        end
        target()

        -- timeout: se demorou demais para chegar (só quando longe)
        pcall(function()
            if getgenv().targ and getgenv().TargetStartTime
                and (getgenv().OurDamageCount or 0) == 0
                and (getgenv().LastOurDamageTime or 0) == 0 then
                local elapsed = tick() - getgenv().TargetStartTime
                if elapsed > 8 then
                    local myChar = game.Players.LocalPlayer.Character
                    local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local tChar  = getgenv().targ.Character
                    local tHrp   = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if myHrp and tHrp then
                        local dist = (tHrp.Position - myHrp.Position).Magnitude
                        if dist > 60 then
                            print("[Auto Bounty] Demorou mais de 8s para chegar no alvo, pulando...")
                            SkipPlayer()
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- LOOP PRINCIPAL DE MOVIMENTO V31
-- Heartbeat: predicao de posicao — calcula onde o inimigo VAI ESTAR
-- e copia a velocidade dele para grudar mesmo em movimento
-- ============================================================
task.spawn(function()
    RunService.Heartbeat:Connect(function(dt)
        if not _G.Seriality then return end
        if getgenv().SafeMode then return end
        if getgenv().IsHopping then return end

        pcall(function()
            local t = getgenv().targ
            if not t or not t.Character then return end

            local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
            if not tHRP then return end

            local myChar = lp.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end

            local dist = (tHRP.Position - myHRP.Position).Magnitude

            -- So move se estiver longe o suficiente (evita vibracao quando ja esta colado)
            if dist > 3 then
                -- Predicao: pega velocidade atual do inimigo e projeta posicao futura
                local targetVel    = tHRP.AssemblyLinearVelocity
                local predictedPos = tHRP.Position + targetVel * dt * 3
                local targetLook   = tHRP.CFrame.LookVector

                -- TP na posicao prevista, olhando para o inimigo
                myHRP.CFrame = CFrame.new(predictedPos + targetLook * 0.3, predictedPos)
                -- Copia a velocidade do inimigo para grudar junto no movimento dele
                myHRP.AssemblyLinearVelocity = targetVel

                if myChar.PrimaryPart and myChar.PrimaryPart ~= myHRP then
                    myChar.PrimaryPart.CFrame = myHRP.CFrame
                end
            end
        end)
    end)
end)

-- INTERFACE DE ESTATÍSTICAS (Tempo, Bounty Farmado, Bounty Atual)
-- ============================================================
pcall(function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- [[ 1. Limpeza de UI Antiga ]] --
    local pg = lp:WaitForChild("PlayerGui")
    local oldGui = pg:FindFirstChild("AutoBountyStats")
    if oldGui then oldGui:Destroy() end

    -- [[ 2. Criação da ScreenGui Principal ]] --
    local sg = Instance.new("ScreenGui")
    sg.Name = "AutoBountyStats"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999
    sg.Parent = pg

    -- [[ 3. Container Principal (Arredondado e Escuro) ]] --
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 260, 0, 220)
    mainFrame.Position = UDim2.new(0, 15, 0, 15)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = sg

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 25))
    })
    mainGradient.Rotation = 45
    mainGradient.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 100, 0)
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.4
    mainStroke.Parent = mainFrame

    -- [[ 4. Cabeçalho (Barra Laranja Arredondada) ]] --
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, -20, 0, 35)
    headerFrame.Position = UDim2.new(0, 10, 0, 10)
    headerFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = headerFrame

    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 130, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 80, 0))
    })
    headerGradient.Rotation = 90
    headerGradient.Parent = headerFrame

    local skullIcon = Instance.new("TextLabel")
    skullIcon.Name = "Skull"
    skullIcon.Size = UDim2.new(0, 30, 1, 0)
    skullIcon.Position = UDim2.new(0, 5, 0, 0)
    skullIcon.BackgroundTransparency = 1
    skullIcon.Text = "☠️"
    skullIcon.TextSize = 20
    skullIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    skullIcon.Font = Enum.Font.GothamBold
    skullIcon.Parent = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleText"
    titleLabel.Size = UDim2.new(1, -45, 1, 0)
    titleLabel.Position = UDim2.new(0, 40, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Allan Hub X Auto Bounty"
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame

    -- [[ 5. Área de Estatísticas ]] --
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsArea"
    statsFrame.Size = UDim2.new(1, -20, 0, 100)
    statsFrame.Position = UDim2.new(0, 10, 0, 55)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = mainFrame

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 6)
    uiList.Parent = statsFrame

    local function createStatRow(name, iconText, labelText, defaultVal, color, order)
        local row = Instance.new("Frame")
        row.Name = name .. "Row"
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.Parent = statsFrame

        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 24, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = iconText
        icon.TextSize = 18
        icon.Parent = row

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 65, 1, 0)
        label.Position = UDim2.new(0, 30, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText .. ":"
        label.TextSize = 14
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Size = UDim2.new(1, -100, 1, 0)
        value.Position = UDim2.new(0, 100, 0, 0)
        value.BackgroundTransparency = 1
        value.Text = defaultVal
        value.TextSize = 14
        value.TextColor3 = color
        value.Font = Enum.Font.GothamBold
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.TextTruncate = Enum.TextTruncate.AtEnd
        value.Parent = row

        return value
    end

    local valTime   = createStatRow("Time",   "⏱️", "Tempo",   "00:00:00", Color3.fromRGB(230, 230, 230), 1)
    local valFarmed = createStatRow("Farmed", "💰", "Farmado", "0.00",     Color3.fromRGB(255, 215, 0),   2)
    local valBounty = createStatRow("Bounty", "🏆", "Bounty",  "0.00",     Color3.fromRGB(255, 215, 0),   3)
    local valTarget = createStatRow("Target", "🎯", "Alvo",    "—",        Color3.fromRGB(255, 255, 255), 4)

    -- [[ 6. Área de Botões (Inferior) ]] --
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsArea"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 40)
    buttonsFrame.Position = UDim2.new(0, 10, 1, -60)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame

    local function createGamerButton(name, text, iconText, posX, baseColor, hoverColor)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 115, 1, 0)
        btn.Position = UDim2.new(0, posX, 0, 0)
        btn.BackgroundColor3 = baseColor
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = buttonsFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(240, 240, 240)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
        })
        btnGradient.Rotation = 90
        btnGradient.Parent = btn

        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 25, 1, 0)
        icon.Position = UDim2.new(0, 8, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = iconText
        icon.TextSize = 16
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.Parent = btn

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(1, -38, 1, 0)
        label.Position = UDim2.new(0, 33, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play()
        end)
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 112, 0, 38), Position = UDim2.new(0, posX + 1.5, 0, 1)}):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 115, 1, 0), Position = UDim2.new(0, posX, 0, 0)}):Play()
        end)

        return btn
    end

    local btnSkip = createGamerButton(
        "BtnSkip", "Skip Player", "⏭️", 0,
        Color3.fromRGB(200, 80, 20),
        Color3.fromRGB(230, 100, 30)
    )

    local btnReset = createGamerButton(
        "BtnReset", "Reset Stats", "🔄", 125,
        Color3.fromRGB(30, 100, 180),
        Color3.fromRGB(50, 120, 200)
    )

    -- [[ 7. Rodapé de Status ]] --
    local footerFrame = Instance.new("Frame")
    footerFrame.Name = "Footer"
    footerFrame.Size = UDim2.new(1, -20, 0, 20)
    footerFrame.Position = UDim2.new(0, 10, 1, -25)
    footerFrame.BackgroundTransparency = 1
    footerFrame.Parent = mainFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusText"
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Combate em andamento"
    statusLabel.TextSize = 13
    statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = footerFrame

    -- [[ 8. Lógica de Atualização da UI ]] --
    local function fmt(n)
        n = math.floor(n or 0)
        if n >= 1e9 then return string.format("%.2fB", n / 1e9)
        elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
        elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
        else return tostring(n) end
    end

    local function fmtTime(secs)
        secs = math.floor(secs)
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        return string.format("%02d:%02d:%02d", h, m, s)
    end

    task.spawn(function()
        while sg and sg.Parent do
            task.wait(0.5)
            pcall(function()
                local sessionTime  = tick() - _sessionStartTick
                local totalElapsed = (_saveData.totalElapsed or 0) + sessionTime
                local curBounty    = lp.leaderstats["Bounty/Honor"].Value
                local sessionStart  = _saveData.sessionStart or curBounty
                local sessionFarmed = math.max(0, curBounty - sessionStart)
                local totalFarmed   = (_saveData.totalFarmed or 0) + sessionFarmed
                local targName     = getgenv().targ and getgenv().targ.Name or "—"

                valTime.Text   = fmtTime(totalElapsed)
                valFarmed.Text = fmt(totalFarmed)
                valBounty.Text = fmt(curBounty)
                valTarget.Text = tostring(targName)

                if getgenv().SafeMode then
                    statusLabel.Text = "🛡️ SafeMode ATIVO"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                elseif getgenv().targ then
                    statusLabel.Text = "⚔️ Combate em andamento"
                    statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                else
                    statusLabel.Text = "🔍 Procurando alvo..."
                    statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
                end
            end)
        end
    end)

    -- [[ 9. Vinculação dos Botões ]] --
    btnSkip.MouseButton1Click:Connect(function()
        pcall(function()
            print("[Auto Bounty] Skip manual pelo botão!")
            SkipPlayer()
        end)
    end)

    btnReset.MouseButton1Click:Connect(function()
        pcall(function()
            print("[Auto Bounty] Reset de contadores pelo botão!")
            _saveData.totalElapsed = 0
            _saveData.totalFarmed  = 0
            _sessionStartTick = tick()
            pcall(function() _saveData.sessionStart = lp.leaderstats["Bounty/Honor"].Value end)
            SaveData()

            local resetLabel = btnReset:FindFirstChild("Text")
            local resetIcon = btnReset:FindFirstChild("Icon")
            if resetLabel and resetIcon then
                resetLabel.Text = "✅ Resetado!"
                resetIcon.Text = ""
                btnReset.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
                task.delay(1.5, function()
                    pcall(function()
                        resetLabel.Text = "Reset Stats"
                        resetIcon.Text = "🔄"
                        btnReset.BackgroundColor3 = Color3.fromRGB(30, 100, 180)
                    end)
                end)
            end
        end)
    end)

end)

-- Salva ao fechar/sair do jogo
game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function()
    SaveData()
end)

print("[Allan Hub X Auto Bounty] Farm iniciado com sucesso! (V14 - TP pre-respawn)")
print("[Allan Hub X Auto Bounty] Hub: Castle On The Sea ativo como ponto de TP intermediário!")
print("[Allan Hub X Auto Bounty] SafeMode: loop dedicado 0.01s ativo!")
print("[Allan Hub X Auto Bounty] Procurando alvos...")
print("[Allan Hub X Auto Bounty] Sistema de combate ativado!")
