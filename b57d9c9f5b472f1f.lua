_ENV = (getgenv or getrenv or getfenv)()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

-- =====================================================
-- SISTEMA DE SALVAMENTO JSON
-- =====================================================
local SETTINGS_FILE = "AllanHub_Settings.json"
local DUNGEON_RUNES_FILE = "AllanHub_DungeonRunes.json"

local Settings = {
    -- Dungeon
    AutoFarm = false,
    AutoBuyTicket = false,
    MoveMode = "Tween",
    UseRunesAuto = false,
    AutoRebirth = false,
    AddStatus = false,

    -- Runas
    RuneSlot1 = "Nenhuma",
    RuneSlot2 = "Nenhuma",
    RuneSlot3 = "Nenhuma",
    RuneSlot4 = "Nenhuma",
    RuneSlot5 = "Nenhuma",

    -- Castle
    CastleInf = false,
    AutoCastle = false,
    CastleCreateOnly = false,
    CastleSpeed = "1",
    CastleSpeedEnabled = false,
    EntryFloor = 1,
    ResetFloor = 100,

    -- Event Labyrinth
    LabyrinthFloor = "180",
    LabyrinthSpeed = "3",
    LabyrinthSpeedEnabled = false,
    AutoLabyrinth = false,

    -- Shop
    AutoBuySkip2Level = false,
}

local function SaveSettings()
    if not writefile then 
        warn("Executor não suporta writefile!")
        return 
    end

    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(Settings)
        writefile(SETTINGS_FILE, encoded)
        print("Configurações salvas!")
    end)

    if not success then
        warn("Erro ao salvar:", err)
    end
end

local function LoadSettings()
    if not readfile or not isfile then
        warn("Executor não suporta readfile!")
        return
    end

    if not isfile(SETTINGS_FILE) then
        print("Criando arquivo de configuração...")
        SaveSettings()
        return
    end

    local success, err = pcall(function()
        local data = readfile(SETTINGS_FILE)
        local decoded = HttpService:JSONDecode(data)

        for key, value in pairs(decoded) do
            if Settings[key] ~= nil then
                Settings[key] = value
            end
        end

        print("Configurações carregadas!")
    end)

    if not success then
        warn("Erro ao carregar:", err)
    end
end

LoadSettings()

local function SaveDungeonRunes()
    if not writefile then return end

    local activerunes = {}
    for slot = 1, 5 do
        local runeName = Settings["RuneSlot" .. slot]
        if runeName and runeName ~= "Nenhuma" then
            activerunes["Slot" .. slot] = runeName
        end
    end

    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(activerunes)
        writefile(DUNGEON_RUNES_FILE, encoded)
        print("Runas da dungeon salvas no arquivo persistente!")
    end)

    if not success then
        warn("Erro ao salvar runas da dungeon:", err)
    end
end

local function LoadDungeonRunes()
    if not readfile or not isfile then return false end

    if not isfile(DUNGEON_RUNES_FILE) then
        print("Nenhum arquivo de runas da dungeon encontrado")
        return false
    end

    local success, err = pcall(function()
        local data = readfile(DUNGEON_RUNES_FILE)
        local decoded = HttpService:JSONDecode(data)

        print("Carregando runas salvas da dungeon...")

        for slotKey, runeName in pairs(decoded) do
            local slotNum = tonumber(string.match(slotKey, "Slot(%d+)"))
            if slotNum then
                Settings["RuneSlot" .. slotNum] = runeName
                print("  Slot " .. slotNum .. ": " .. runeName)
            end
        end

        print("Runas da dungeon carregadas com sucesso!")
    end)

    if not success then
        warn("Erro ao carregar runas da dungeon:", err)
        return false
    end

    return true
end

local function ClearDungeonRunes()
    if not delfile or not isfile then return end

    if isfile(DUNGEON_RUNES_FILE) then
        delfile(DUNGEON_RUNES_FILE)
        print("Arquivo de runas da dungeon limpo!")
    end
end

-- CARREGAR RUNAS DA DUNGEON SE EXISTIR (PRIORIDADE MÁXIMA)
if LoadDungeonRunes() then
    print("Runas da dungeon restauradas do arquivo persistente!")
end

Config = Settings

local lastNotificationTime = 0
local notificationCooldown = 10
local currentTime = tick()

if currentTime - lastNotificationTime >= notificationCooldown then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Allan Hub",
        Text = "Carregando...",
        Duration = 5
    })
    lastNotificationTime = currentTime
end

local BridgeNet2 = require(ReplicatedStorage:WaitForChild("BridgeNet2"))
local DungeonBridge = BridgeNet2.ReferenceBridge("GENERAL_EVENT")
local Remote = ReplicatedStorage.BridgeNet2.dataRemoteEvent

-- FUNÇÃO PARA PEGAR O ID DA DUNGEON ATIVA DO PLAYER
local function GetPlayerDungeonId()
    local infos = ReplicatedStorage:FindFirstChild("__Infos")
    if not infos then return nil end

    local dungeons = infos:FindFirstChild("__Dungeons")
    if not dungeons then return nil end

    for _, dungeon in ipairs(dungeons:GetChildren()) do
        local leader = dungeon:GetAttribute("Leader")
        if leader == Player.UserId then
            return leader
        end
    end

    return nil
end

local function SafeFire(payload)
    if not DungeonBridge then return end

    if payload.Event == "DungeonAction" and payload.Action ~= "Create" and payload.Action ~= "BuyTicket" then
        local dungeonId = GetPlayerDungeonId()
        if dungeonId then
            payload.Dungeon = dungeonId
        end
    end

    local ok, err = pcall(function()
        DungeonBridge:Fire(payload)
    end)
    if not ok then
        warn("SafeFire error:", err, payload)
    end
end

local function ProtectUI()
    local success = pcall(function()
        if gethui then
            return gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(CoreGui)
        end
    end)
end

ProtectUI()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/allanxsix/Teste/refs/heads/main/uiallanhub"))()

local Main = Library.CreateMain({
    Desc = " _ng.shinichi"
})

local PageDungeon = Main.CreatePage({
    Page_Name = "Dungeon",
    Page_Title = "Dungeon System"
})

local PageCastle = Main.CreatePage({
    Page_Name = "Castle",
    Page_Title = "Castelo Infernal"
})

local PageIslands = Main.CreatePage({
    Page_Name = "Islands",
    Page_Title = "Islands"
})

local PageEvent = Main.CreatePage({
    Page_Name = "Event",
    Page_Title = "Infinite Labyrinth"
})

local PageShop = Main.CreatePage({
    Page_Name = "Shop",
    Page_Title = "Shop"
})

local PageSettings = Main.CreatePage({
    Page_Name = "Settings",
    Page_Title = "Settings"
})

local SectionEventMain = PageEvent.CreateSection("Infinite Labyrinth")
local SectionDungeonMain = PageDungeon.CreateSection("Main Settings")
local SectionDungeonRunes = PageDungeon.CreateSection("Sistema de Runas")
local SectionCastleMain = PageCastle.CreateSection("Castle Settings")
local SectionIslandsMain = PageIslands.CreateSection("Islands")
local SectionShopMain = PageShop.CreateSection("Shop Automático")

local function UpdateStatus(text)
    -- Removido para deixar o script mais limpo
end

local CreatingDungeon = false
local DungeonRunning = false
local StartingDungeon = false
local Rebirthing = false
local SpawnConfirmTime = 0
local currentTween = nil

local MAX_RUNE_SLOTS = 5
local RuneSlots = {}
for i = 1, MAX_RUNE_SLOTS do RuneSlots[i] = "" end

local ItemsInfo
pcall(function()
    ItemsInfo = require(ReplicatedStorage:WaitForChild("Indexer"):WaitForChild("ItemsInfo"))
end)

local AvailableRunes = {}

local function ScanRunes()
    table.clear(AvailableRunes)
    if not ItemsInfo then 
        warn("ItemsInfo não encontrado!")
        return 
    end

    print("Escaneando runas...")
    local count = 0

    for id, data in pairs(ItemsInfo) do
        if typeof(data) == "table" then
            local t = tostring(data.Type or "")
            local n = tostring(data.Name or "")

            if string.find(string.lower(t), "rune") or string.find(string.lower(n), "rune") then
                table.insert(AvailableRunes, {
                    Id = id,
                    Name = data.Name or tostring(id)
                })
                count = count + 1
            end
        end
    end

    print("Total de runas:", count)

    if count == 0 then
        warn("Nenhuma runa detectada!")
    end
end

ScanRunes()

local RuneNames = { "Nenhuma" }
for _, r in ipairs(AvailableRunes) do
    table.insert(RuneNames, r.Name)
end

local function RestoreSavedRunes()
    local restoredCount = 0

    for slot = 1, MAX_RUNE_SLOTS do
        local savedRuneName = Settings["RuneSlot" .. slot]

        if savedRuneName and savedRuneName ~= "Nenhuma" then
            for _, rune in ipairs(AvailableRunes) do
                if rune.Name == savedRuneName then
                    RuneSlots[slot] = rune.Id
                    restoredCount = restoredCount + 1
                    print("Runa Slot " .. slot .. " restaurada: " .. savedRuneName .. " (ID: " .. rune.Id .. ")")
                    break
                end
            end
        end
    end

    if restoredCount > 0 then
        print("Total de " .. restoredCount .. " runas restauradas das configurações salvas!")
    end

    return restoredCount
end

RestoreSavedRunes()

SectionDungeonMain.CreateToggle({
    Title = "Auto Farm Dungeon",
    Default = Settings.AutoFarm
}, function(v)
    Settings.AutoFarm = v
    SaveSettings()
end)

SectionDungeonMain.CreateToggle({
    Title = "Auto Buy Ticket",
    Default = Settings.AutoBuyTicket
}, function(v)
    Settings.AutoBuyTicket = v
    SaveSettings()
end)

SectionDungeonMain.CreateDropdown({
    Title = "Movement Mode",
    List = { "Tween", "Teleport" },
    Default = Settings.MoveMode
}, function(v)
    Settings.MoveMode = v
    SaveSettings()
end)

SectionDungeonMain.CreateToggle({
    Title = "Auto Rebirth (MAX)",
    Desc = "Faz rebirth automaticamente ao atingir level máximo",
    Default = Settings.AutoRebirth
}, function(v)
    Settings.AutoRebirth = v
    SaveSettings()
end)

SectionDungeonMain.CreateToggle({
    Title = "ADD Status",
    Desc = "Adiciona PlayerExp e ShadowRange automaticamente via Remote",
    Default = Settings.AddStatus
}, function(v)
    Settings.AddStatus = v
    SaveSettings()
end)

for slot = 1, MAX_RUNE_SLOTS do
    SectionDungeonRunes.CreateDropdown({
        Title = "Runa Slot " .. slot,
        List = RuneNames,
        Default = Settings["RuneSlot" .. slot]
    }, function(v)
        Settings["RuneSlot" .. slot] = v

        if v == "Nenhuma" then
            RuneSlots[slot] = ""
        else
            for _, r in ipairs(AvailableRunes) do
                if r.Name == v then
                    RuneSlots[slot] = r.Id
                    print("Slot " .. slot .. " configurado: " .. v .. " (ID: " .. r.Id .. ")")
                    break
                end
            end
        end

        SaveSettings()

        if Settings.UseRunesAuto then
            SaveDungeonRunes()
        end
    end)
end

SectionDungeonRunes.CreateToggle({
    Title = "Usar Runas Automaticamente",
    Desc = "Aplica as runas sempre que criar uma dungeon",
    Default = Settings.UseRunesAuto
}, function(v)
    Settings.UseRunesAuto = v
    SaveSettings()

    if v then
        SaveDungeonRunes()

        local count = 0
        for i = 1, MAX_RUNE_SLOTS do
            if RuneSlots[i] ~= "" then count = count + 1 end
        end
        Library.CreateNoti({
            Title = "Runas Automáticas",
            Desc = "Ativado! " .. count .. " runas serão aplicadas",
            ShowTime = 4
        })
    else
        ClearDungeonRunes()
        Library.CreateNoti({
            Title = "Runas Automáticas",
            Desc = "Desativado! Arquivo de runas limpo.",
            ShowTime = 4
        })
    end
end)

local EnemiesServer = workspace.__Main.__Enemies.Server
local EnemiesClient = workspace.__Main.__Enemies.Client

local function GetBestEnemy()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local pos = root.Position

    local bestClient, bestClientDist = nil, math.huge
    local bestServer, bestServerDist = nil, math.huge

    for _, eServer in ipairs(EnemiesServer:GetChildren()) do
        local hp = tonumber(eServer:GetAttribute("HP"))
        if hp and hp > 0 then
            local eClient = EnemiesClient:FindFirstChild(eServer.Name)
            local hrp = eClient and eClient:FindFirstChild("HumanoidRootPart")

            if hrp then
                local d = (pos - hrp.Position).Magnitude
                if d < bestClientDist then
                    bestClientDist = d
                    bestClient = { clientModel = eClient, serverModel = eServer, name = eServer.Name }
                end
            else
                local serverPos = nil
                local px = eServer:GetAttribute("PosX")
                local py = eServer:GetAttribute("PosY")
                local pz = eServer:GetAttribute("PosZ")
                if px and py and pz then
                    serverPos = Vector3.new(px, py, pz)
                else
                    local ok, pivot = pcall(function() return eServer:GetPivot() end)
                    if ok and pivot then
                        serverPos = pivot.Position
                    end
                end

                if serverPos then
                    local d = (pos - serverPos).Magnitude
                    if d < bestServerDist then
                        bestServerDist = d
                        bestServer = { clientModel = nil, serverModel = eServer, name = eServer.Name, serverPos = serverPos }
                    end
                else
                    if not bestServer then
                        bestServer = { clientModel = nil, serverModel = eServer, name = eServer.Name, serverPos = nil }
                    end
                end
            end
        end
    end

    if bestClient then return bestClient end
    return bestServer
end

local function MoveToEnemy(enemyData)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetCFrame

    if enemyData.clientModel then
        local hrp = enemyData.clientModel:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        targetCFrame = hrp.CFrame * CFrame.new(0, 0, 3)
    elseif enemyData.serverPos then
        targetCFrame = CFrame.new(enemyData.serverPos + Vector3.new(0, 0, 3))
    else
        return
    end

    if Settings.MoveMode == "Teleport" then
        if currentTween then currentTween:Cancel() end
        root.CFrame = targetCFrame
    else
        if currentTween then currentTween:Cancel() end
        currentTween = TweenService:Create(
            root,
            TweenInfo.new(0.3, Enum.EasingStyle.Linear),
            { CFrame = targetCFrame }
        )
        currentTween:Play()
    end
end

local function AttackEnemy(enemyData)
    if enemyData.clientModel or enemyData.name then
        SafeFire({
            PetPos = {},
            AttackType = "All",
            Event = "Attack",
            Enemy = enemyData.name
        })
    end
end

local function BuyDungeonTicket()
    SafeFire({
        Event = "DungeonAction",
        Action = "BuyTicket"
    })
end

local function ApplyRunes()
    if not Settings.UseRunesAuto then 
        return 0 
    end

    local dungeonId = GetPlayerDungeonId()
    if not dungeonId then
        print("ID da dungeon não encontrado - não é possível adicionar runas")
        return 0
    end

    print("ID da Dungeon detectado:", dungeonId)

    local runesApplied = 0

    for slot = 1, MAX_RUNE_SLOTS do
        local runeId = RuneSlots[slot]
        if runeId ~= "" then
            SafeFire({
                Dungeon = dungeonId,
                Event = "DungeonAction",
                Action = "AddItems",
                Slot = slot,
                Item = runeId
            })
            runesApplied = runesApplied + 1
            print("Aplicando Runa Slot " .. slot .. ": " .. runeId)
            task.wait(0.4)
        end
    end

    return runesApplied
end

local function CreateDungeon()
    if CreatingDungeon or Rebirthing then return end

    CreatingDungeon = true
    StartingDungeon = true
    UpdateStatus("Preparing Dungeon...")

    if Settings.UseRunesAuto then
        SaveDungeonRunes()
        print("Runas salvas antes de criar a dungeon")
    end

    if Settings.AutoBuyTicket then
        BuyDungeonTicket()
        task.wait(0.8)
    end

    UpdateStatus("Creating Dungeon...")
    SafeFire({
        Event = "DungeonAction",
        Action = "Create"
    })

    task.wait(1.5)

    if Settings.UseRunesAuto then
        UpdateStatus("Applying Runes...")
        local runesApplied = ApplyRunes()

        if runesApplied > 0 then
            UpdateStatus(runesApplied .. " Runas Ready!")
            task.wait(0.5)
        end
    end

    UpdateStatus("Starting Dungeon...")
    SafeFire({
        Event = "DungeonAction",
        Action = "Start"
    })

    task.delay(2, function()
        CreatingDungeon = false
    end)
end

local PlayerGui = Player:WaitForChild("PlayerGui")
local ExpText = PlayerGui
    :WaitForChild("Hud")
    :WaitForChild("BottomContainer")
    :WaitForChild("ExpBar")
    :WaitForChild("ExpText")

local function GetRemainingEnemiesFromUI()
    local success, result = pcall(function()
        local hud = PlayerGui:FindFirstChild("Hud") or PlayerGui:FindFirstChild("HUD")
        if not hud then return nil end
        for _, label in ipairs(hud:GetDescendants()) do
            if label:IsA("TextLabel") or label:IsA("TextBox") then
                local cur, total = string.match(label.Text, "(%d+)%/(%d+)")
                if cur and total then
                    if string.find(label.Text, "nimigo") or string.find(label.Text, "nemy") then
                        return tonumber(cur), tonumber(total)
                    end
                end
            end
        end
        return nil
    end)
    if success then return result end
    return nil
end

local function CountLiveEnemies()
    local count = 0
    for _, e in ipairs(EnemiesServer:GetChildren()) do
        local hp = tonumber(e:GetAttribute("HP"))
        if hp and hp > 0 then
            count += 1
        end
    end
    return count
end

local function IsDungeonFinished()
    local ok, result = pcall(function()
        local world = workspace.__Main.__World
        for _, roomName in ipairs({"Room_9", "Room_8"}) do
            local room = world:FindFirstChild(roomName)
            if room then
                local buildings = room:FindFirstChild("Buildings")
                if buildings then
                    local folder = buildings:FindFirstChild("Folder")
                    if folder then
                        local children = folder:GetChildren()
                        if children[27] then
                            local sub = children[27]:GetChildren()
                            if sub[27] then return true end
                        end
                    end
                end
            end
        end
        return false
    end)
    return ok and result
end

RunService.Heartbeat:Connect(function(dt)
    if not Settings.AutoFarm or Rebirthing then
        DungeonRunning = false
        SpawnConfirmTime = 0
        UpdateStatus("Idle")
        return
    end

    if CreatingDungeon then return end

    local enemyData = GetBestEnemy()

    if enemyData then
        DungeonRunning = true
        StartingDungeon = false
        SpawnConfirmTime = 0

        if enemyData.clientModel then
            UpdateStatus("Farming (" .. Settings.MoveMode .. ")")
            MoveToEnemy(enemyData)
            AttackEnemy(enemyData)
        else
            UpdateStatus("Indo até inimigo em sala distante...")
            MoveToEnemy(enemyData)
            AttackEnemy(enemyData)
        end
        return
    end

    if DungeonRunning then
        local liveCount = CountLiveEnemies()
        if liveCount > 0 then
            SpawnConfirmTime = 0
            UpdateStatus("Server: " .. liveCount .. " inimigo(s)...")
            return
        end

        SpawnConfirmTime += dt
        UpdateStatus(("Finalizando Dungeon %.1fs"):format(SpawnConfirmTime))

        local dungeonEnded = IsDungeonFinished()
        if SpawnConfirmTime >= 8 or (SpawnConfirmTime >= 3 and dungeonEnded) then
            DungeonRunning = false
            SpawnConfirmTime = 0
            CreateDungeon()
        end
    else
        if not StartingDungeon then
            CreateDungeon()
        end
    end
end)

local function GetLevelInfo()
    local text = ExpText.Text
    if not text then return nil, false end
    local level = tonumber(string.match(text, "Level:%s*(%d+)"))

    if string.find(text, "MAX") or string.find(text, "MÁXIMO") then
        return level, true
    end

    local cur, need = string.match(text, "%((%d+)%/(%d+)%)")
    if cur and need and tonumber(need) == 0 then
        return level, true
    end

    return level, false
end

-- =====================================================
-- LOOP ADD STATUS (PlayerExp via Remote a cada 30s)
-- =====================================================
task.spawn(function()
    while true do
        if Settings.AddStatus then
            local args = {
                [1] = {
                    [1] = {
                        ["Stats"] = "PlayerExp",
                        ["Event"] = "StatsUp",
                        ["Points"] = 2000
                    },
                    [2] = "\017"
                }
            }
            Remote:FireServer(unpack(args))
            print("[AddStatus] PlayerExp enviado via Remote")
        end
        task.wait(30)
    end
end)

-- =====================================================
-- LOOP ADD STATUS (ShadowRange via Remote a cada 40s)
-- =====================================================
task.spawn(function()
    while true do
        if Settings.AddStatus then
            local args = {
                [1] = {
                    [1] = {
                        ["Stats"] = "ShadowRange",
                        ["Event"] = "StatsUp",
                        ["Points"] = 500
                    },
                    [2] = "\017"
                }
            }
            Remote:FireServer(unpack(args))
            print("[AddStatus] ShadowRange enviado via Remote")
        end
        task.wait(40)
    end
end)

-- LOOP LEGADO (AutoRebirth Stats via SafeFire - mantido por compatibilidade)
task.spawn(function()
    while true do
        if Settings.AutoRebirth then
            SafeFire({
                Event = "StatsUp",
                Stats = "PlayerExp",
                Points = 2000
            })
        end
        task.wait(30)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoRebirth then
            SafeFire({
                Event = "StatsUp",
                Stats = "ShadowRange",
                Points = 400
            })
        end
        task.wait(40)
    end
end)

-- Anti-AFK
task.spawn(function()
    while task.wait(600) do
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        print("Anti-AFK: Atividade simulada")
    end
end)

Player.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    print("Anti-AFK: Kickar prevenido")
end)

-- =====================================================
-- LOOP AUTO BUY SKIP2LEVEL (a cada 10 minutos)
-- =====================================================
task.spawn(function()
    while true do
        task.wait(600) -- 10 minutos
        if Settings.AutoBuySkip2Level then
            local args = {
                {
                    {
                        Name = "Skip2Level",
                        Type = "Product",
                        SubType = "Products",
                        Event = "TicketShop"
                    },
                    "\017"
                }
            }
            local ok, err = pcall(function()
                ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
            end)
            if ok then
                print("[Shop] Skip2Level comprado com sucesso!")
                Library.CreateNoti({
                    Title = "Shop Auto",
                    Desc = "Skip2Level comprado! Próxima compra em 10 minutos.",
                    ShowTime = 4
                })
            else
                warn("[Shop] Erro ao comprar Skip2Level:", err)
            end
        end
    end
end)

-- Loop de Rebirth
task.spawn(function()
    while true do
        task.wait(10)

        if not Settings.AutoRebirth then continue end
        if Rebirthing or CreatingDungeon then continue end

        local ok, lvl, isMax = pcall(GetLevelInfo)
        if not ok then
            warn("[Rebirth] Erro ao ler level:", lvl)
            continue
        end

        local expRaw = ExpText and ExpText.Text or "N/A"
        print("[Rebirth] UI:", expRaw, "| isMax:", tostring(isMax), "| lvl:", tostring(lvl))

        if isMax then
            print("[Rebirth] LEVEL MAX! Executando...")
            Rebirthing = true

            for tentativa = 1, 3 do
                local rebirthArgs = {
                    {
                        {
                            Event = "RebirthPlayer"
                        },
                        "\017"
                    }
                }
                local ok_rb, err_rb = pcall(function()
                    ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(rebirthArgs))
                end)
                if ok_rb then
                    print("[Rebirth] Fire enviado via dataRemoteEvent - tentativa " .. tentativa)
                else
                    warn("[Rebirth] Erro na tentativa " .. tentativa .. ":", err_rb)
                end
                task.wait(1.5)
            end

            task.wait(3)
            Rebirthing = false
            print("[Rebirth] Concluido, retomando farm...")
        end
    end
end)

local castleInfEnabled = false
local autoCastleEnabled = false
local castleCreateOnlyEnabled = false
local entryFloor = Settings.EntryFloor
local resetFloor = Settings.ResetFloor
local selectedCastleSpeed = Settings.CastleSpeed

local autoF2F3Enabled = false
local f2f3Mode = "8x"
local F2F3_INTERVALS = {
    ["1x"] = 60,
    ["4x"] = 15,
    ["8x"] = 7.5
}
local DELAY_F2_F3 = 1.5
local castleSpeedEnabled = Settings.CastleSpeedEnabled

local function pressKey(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

local function autoF2F3Loop()
    task.spawn(function()
        while autoF2F3Enabled do
            pressKey(Enum.KeyCode.F2)
            task.wait(DELAY_F2_F3)
            pressKey(Enum.KeyCode.F3)
            task.wait(F2F3_INTERVALS[f2f3Mode])
        end
    end)
end

local function getCurrentCastleFloor()
    local main = workspace:FindFirstChild("__Main")
    if not main then return nil end
    local world = main:FindFirstChild("__World")
    if not world then return nil end

    local current = nil
    for i = 1, 800 do
        if world:FindFirstChild("Room_" .. i) then
            current = i
        end
    end
    return current
end

local function buyCastleTicket()
    SafeFire({
        Event = "CastleAction",
        Action = "BuyTicket",
        Type = "Gems"
    })
end

local function createCastle()
    SafeFire({
        Event = "CastleAction",
        Action = "Create"
    })
    task.wait(2.5)
end

local function joinCastle(floor)
    SafeFire({
        Event = "CastleAction",
        Action = "Join",
        Floor = tostring(floor or entryFloor),
        Check = true
    })
end

local function findFirePortal()
    local main = workspace:FindFirstChild("__Main")
    if not main then return nil end
    local world = main:FindFirstChild("__World")
    if not world then return nil end

    for i = 1, 300 do
        local room = world:FindFirstChild("Room_" .. i)
        if room then
            local portal = room:FindFirstChild("FirePortal", true)
            if portal then
                return portal, i
            end
        end
    end
    return nil
end

local function teleportToFirePortal()
    local portal = findFirePortal()
    if not portal then return false end

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    hrp.CFrame = portal:GetPivot() * CFrame.new(0, 2, -3)
    hrp.Velocity = Vector3.zero
    return true
end

local function activateFirePortal()
    local portal = findFirePortal()
    if not portal then return false end

    local prompt = portal:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end

    for _ = 1, 3 do
        pcall(function()
            fireproximityprompt(prompt)
        end)
        task.wait(0.15)
    end
    return true
end

local function farmCastleMobs()
    local mobsKilled = false
    local enemiesMain = workspace:FindFirstChild("__Main")
    local serverFolder = enemiesMain and enemiesMain:FindFirstChild("__Enemies") and enemiesMain.__Enemies:FindFirstChild("Server")
    local clientFolder = enemiesMain and enemiesMain:FindFirstChild("__Enemies") and enemiesMain.__Enemies:FindFirstChild("Client")

    if serverFolder and clientFolder then
        for _, mob in pairs(serverFolder:GetChildren()) do
            if not castleInfEnabled then break end

            local hp = tonumber(mob:GetAttribute("HP"))
            local mobClient = clientFolder:FindFirstChild(mob.Name)
            local mobHRP = mobClient and mobClient:FindFirstChild("HumanoidRootPart")

            if hp and hp > 0 and mobHRP then
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    hrp.CFrame = mobHRP.CFrame * CFrame.new(0, 0, 3)

                    SafeFire({
                        PetPos = {},
                        AttackType = "All",
                        Event = "Attack",
                        Enemy = mob.Name
                    })

                    while castleInfEnabled and mob.Parent do
                        local currentHP = tonumber(mob:GetAttribute("HP"))
                        if not currentHP or currentHP <= 0 then
                            break
                        end
                        task.wait(0.2)
                    end

                    mobsKilled = true
                end
            end
        end
    end

    return mobsKilled
end

local function castleInfLoop()
    task.spawn(function()
        while castleInfEnabled do
            local hasMobs = farmCastleMobs()
            if not hasMobs then
                if teleportToFirePortal() then
                    task.wait(1)
                    activateFirePortal()
                end
            end
            task.wait(0.4)
        end
    end)
end

local function autoCastleLoop()
    task.spawn(function()
        while autoCastleEnabled do
            local currentFloor = getCurrentCastleFloor()
            if not currentFloor then
                buyCastleTicket()
                task.wait(1)
                createCastle()
                task.wait(1)
                joinCastle(entryFloor)
                task.wait(5)
            else
                if currentFloor >= resetFloor then
                    buyCastleTicket()
                    task.wait(1)
                    createCastle()
                    task.wait(1)
                    joinCastle(entryFloor)
                    task.wait(5)
                else
                    farmCastleMobs()
                end
            end
            task.wait(0.5)
        end
    end)
end

local function castleCreateOnlyLoop()
    task.spawn(function()
        while castleCreateOnlyEnabled do
            local currentFloor = getCurrentCastleFloor()
            if not currentFloor then
                buyCastleTicket()
                task.wait(1)
                createCastle()
                task.wait(1)
                joinCastle(entryFloor)
                task.wait(5)
            end
            task.wait(1)
        end
    end)
end

-- =====================================================
-- CASTLE UI
-- =====================================================
SectionCastleMain.CreateBox({
    Title = "Andar de Entrada",
    Placeholder = "Digite o andar",
    Default = tostring(Settings.EntryFloor),
    Number = true
}, function(v)
    local n = tonumber(v)
    if n then
        entryFloor = n
        Settings.EntryFloor = n
        SaveSettings()
    end
end)

SectionCastleMain.CreateBox({
    Title = "Andar de Reset",
    Placeholder = "Digite o andar",
    Default = tostring(Settings.ResetFloor),
    Number = true
}, function(v)
    local n = tonumber(v)
    if n then
        resetFloor = n
        Settings.ResetFloor = n
        SaveSettings()
    end
end)

SectionCastleMain.CreateToggle({
    Title = "Castle INF (Farm + Portal)",
    Default = Settings.CastleInf
}, function(v)
    castleInfEnabled = v
    Settings.CastleInf = v
    SaveSettings()
    if v then castleInfLoop() end
end)

SectionCastleMain.CreateToggle({
    Title = "Auto Castle (Create + Reset)",
    Default = Settings.AutoCastle
}, function(v)
    autoCastleEnabled = v
    Settings.AutoCastle = v
    SaveSettings()
    if v then autoCastleLoop() end
end)

SectionCastleMain.CreateToggle({
    Title = "Auto Castle (Criar Apenas)",
    Default = Settings.CastleCreateOnly
}, function(v)
    castleCreateOnlyEnabled = v
    Settings.CastleCreateOnly = v
    SaveSettings()
    if v then castleCreateOnlyLoop() end
end)

SectionCastleMain.CreateDropdown({
    Title = "Speed do Castelo",
    List = {"1", "2", "4"},
    Default = Settings.CastleSpeed
}, function(v)
    selectedCastleSpeed = v
    Settings.CastleSpeed = v
    SaveSettings()

    if castleSpeedEnabled then
        SafeFire({
            Event = "CastleAction",
            Action = "SpeedUp",
            Speed = tonumber(v)
        })
    end
end)

SectionCastleMain.CreateToggle({
    Title = "Ativar Speed do Castelo",
    Default = Settings.CastleSpeedEnabled
}, function(v)
    castleSpeedEnabled = v
    Settings.CastleSpeedEnabled = v
    SaveSettings()

    if v then
        SafeFire({
            Event = "CastleAction",
            Action = "SpeedUp",
            Speed = tonumber(selectedCastleSpeed)
        })
    end
end)

SectionCastleMain.CreateDropdown({
    Title = "Modo Auto F2 + F3",
    List = {"1x", "4x", "8x"},
    Default = "8x"
}, function(v)
    f2f3Mode = v
end)

SectionCastleMain.CreateToggle({
    Title = "Ativar Auto F2 + F3",
    Desc = "Pressiona F2 e F3 automaticamente"
}, function(v)
    autoF2F3Enabled = v
    if v then
        autoF2F3Loop()
        Library.CreateNoti({
            Title = "Auto F2+F3",
            Desc = "Ativado no modo " .. f2f3Mode,
            ShowTime = 3
        })
    end
end)

-- =====================================================
-- ISLANDS UI
-- =====================================================
local SelectedIslandName = nil
local IslandMap = {}

local function GetWorld()
    local extra = workspace:FindFirstChild("__Extra")
    if not extra then return nil end
    return extra:FindFirstChild("__Spawns")
end

local function GetIslandDisplayName(island)
    if island:GetAttribute("DisplayName") then return island:GetAttribute("DisplayName") end
    if island:GetAttribute("Name") then return island:GetAttribute("Name") end
    for _, child in ipairs(island:GetChildren()) do
        if child:IsA("StringValue") then
            return child.Value
        end
    end
    return island.Name
end

local function ScanIslands()
    table.clear(IslandMap)
    local World = GetWorld()
    if not World then return {} end
    local list = {}
    for _, island in ipairs(World:GetChildren()) do
        local displayName = GetIslandDisplayName(island)
        IslandMap[displayName] = island
        table.insert(list, displayName)
    end
    table.sort(list)
    return list
end

local function TeleportToIsland(islandModel)
    local char = Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if islandModel.GetPivot then
        hrp.CFrame = islandModel:GetPivot() * CFrame.new(0, 10, 0)
    elseif islandModel.PrimaryPart then
        hrp.CFrame = islandModel.PrimaryPart.CFrame * CFrame.new(0, 10, 0)
    elseif islandModel:IsA("BasePart") then
        hrp.CFrame = islandModel.CFrame * CFrame.new(0, 10, 0)
    end
end

SectionIslandsMain.CreateDropdown({
    Title = "Ilhas Detectadas",
    List = ScanIslands()
}, function(value)
    SelectedIslandName = value
end)

SectionIslandsMain.CreateButton({
    Title = "Teleportar Ilha Selecionada"
}, function()
    if not SelectedIslandName then
        Library.CreateNoti({
            Title = "Erro",
            Desc = "Nenhuma ilha selecionada",
            ShowTime = 3
        })
        return
    end
    local islandModel = IslandMap[SelectedIslandName]
    if islandModel then
        TeleportToIsland(islandModel)
        Library.CreateNoti({
            Title = "Teleport",
            Desc = "Você foi para " .. SelectedIslandName,
            ShowTime = 3
        })
    end
end)

-- =====================================================
-- EVENT UI (Infinite Labyrinth)
-- =====================================================
local selectedLabyrinthFloor = Settings.LabyrinthFloor
local selectedLabyrinthSpeed = Settings.LabyrinthSpeed
local autoLabyrinthEnabled = Settings.AutoLabyrinth
local creatingLabyrinth = false
local labyrinthSpeedEnabled = Settings.LabyrinthSpeedEnabled
local labyrinthSessionActive = false
local autoSpeedLoopLabyrinth = false

local function IsInsideLabyrinth()
    local infos = ReplicatedStorage:FindFirstChild("__Infos")
    if infos then
        local labyrinth = infos:FindFirstChild("__InfiniteLabyrinth")
        if labyrinth then
            for _, lab in ipairs(labyrinth:GetChildren()) do
                local leader = lab:GetAttribute("Leader")
                if leader == Player.UserId then
                    return true
                end
            end
        end
    end

    local main = workspace:FindFirstChild("__Main")
    if main then
        local world = main:FindFirstChild("__World")
        if world then
            if world.Name == "InfiniteLabyrinth" or world.Name == "LabyrinthInfinite" then
                return true
            end
            
            local infLab = world:FindFirstChild("InfiniteLabyrinth") or world:FindFirstChild("LabyrinthInfinite")
            if infLab and infLab:FindFirstChild("MapaCongelado") then
                return true
            end
        end
    end

    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local position = Player.Character.HumanoidRootPart.Position
        if position.Y > 5000 then
            return true
        end
    end

    return false
end

local function aplicarVelocidadeLabirinto()
    if not IsInsideLabyrinth() then return end

    SafeFire({
        Speed = tonumber(selectedLabyrinthSpeed),
        Event = "InfiniteLabyrinthAction",
        Action = "SpeedUp"
    })
end

local function iniciarAutoVelocidadeLabirinto()
    if autoSpeedLoopLabyrinth then return end
    autoSpeedLoopLabyrinth = true

    task.spawn(function()
        while labyrinthSpeedEnabled and autoSpeedLoopLabyrinth and labyrinthSessionActive do
            if IsInsideLabyrinth() then
                aplicarVelocidadeLabirinto()
            end
            task.wait(10)
        end
        autoSpeedLoopLabyrinth = false
    end)
end

local function pararAutoVelocidadeLabirinto()
    labyrinthSpeedEnabled = false
    autoSpeedLoopLabyrinth = false
end

local function monitorarSaidaLabirinto()
    task.spawn(function()
        local tentativasConsecutivas = 0
        local maxTentativas = 3

        while labyrinthSessionActive do
            local dentroDoLabirinto = IsInsideLabyrinth()

            if not dentroDoLabirinto then
                tentativasConsecutivas += 1
                print("[Labirinto] Fora do labirinto - Tentativa " .. tentativasConsecutivas .. "/" .. maxTentativas)

                if tentativasConsecutivas >= maxTentativas then
                    print("[Labirinto] Portal destruído confirmado! Recriando...")
                    labyrinthSessionActive = false
                    pararAutoVelocidadeLabirinto()

                    if autoLabyrinthEnabled then
                        task.wait(3)
                        RecreateLabyrinth()
                    end
                    break
                end
            else
                tentativasConsecutivas = 0
            end

            task.wait(3)
        end
    end)
end

local function resetarEstadoLabirinto()
    labyrinthSessionActive = false
    pararAutoVelocidadeLabirinto()
end

local function RecreateLabyrinth()
    if creatingLabyrinth then return end

    creatingLabyrinth = true
    labyrinthSessionActive = true

    print("[Labirinto] Criando labirinto no andar " .. selectedLabyrinthFloor .. "...")

    SafeFire({
        Event = "InfiniteLabyrinthAction",
        Action = "Create"
    })

    task.wait(2)

    SafeFire({
        Dungeon = Player.UserId,
        Check = selectedLabyrinthFloor,
        Event = "InfiniteLabyrinthAction",
        Action = "Start"
    })

    task.wait(3)

    local startSuccess = false
    for tentativa = 1, 3 do
        if IsInsideLabyrinth() then
            startSuccess = true
            print("[Labirinto] Entrada confirmada!")
            break
        end
        task.wait(2)
    end

    if not startSuccess then
        print("[Labirinto] Falha ao entrar. Resetando...")
        resetarEstadoLabirinto()
        creatingLabyrinth = false
        return
    end

    print("[Labirinto] Labirinto criado com sucesso!")

    if labyrinthSpeedEnabled then
        task.wait(1)
        aplicarVelocidadeLabirinto()
        iniciarAutoVelocidadeLabirinto()
    end

    monitorarSaidaLabirinto()

    creatingLabyrinth = false
end

local function iniciarLabirintoInfinito()
    if labyrinthSessionActive then 
        print("[Labirinto] Sessão já ativa")
        return 
    end

    if IsInsideLabyrinth() then
        print("[Labirinto] Já está dentro! Ativando sistemas...")
        labyrinthSessionActive = true

        if labyrinthSpeedEnabled then
            aplicarVelocidadeLabirinto()
            iniciarAutoVelocidadeLabirinto()
        end

        monitorarSaidaLabirinto()
        return
    end

    RecreateLabyrinth()
end

local function GenerateFloorList()
    local floors = {}
    for i = 1, 360, 30 do
        table.insert(floors, tostring(i))
    end
    return floors
end

SectionEventMain.CreateDropdown({
    Title = "Selecionar Andar",
    List = GenerateFloorList(),
    Default = Settings.LabyrinthFloor
}, function(v)
    selectedLabyrinthFloor = v
    Settings.LabyrinthFloor = v
    SaveSettings()
end)

SectionEventMain.CreateDropdown({
    Title = "Selecionar Speed",
    List = {"1", "3", "6"},
    Default = Settings.LabyrinthSpeed
}, function(v)
    selectedLabyrinthSpeed = v
    Settings.LabyrinthSpeed = v
    SaveSettings()

    if labyrinthSpeedEnabled then
        SafeFire({
            Speed = tonumber(selectedLabyrinthSpeed),
            Event = "InfiniteLabyrinthAction",
            Action = "SpeedUp"
        })
    end
end)

SectionEventMain.CreateToggle({
    Title = "Ativar Speed do Labirinto",
    Default = Settings.LabyrinthSpeedEnabled
}, function(v)
    labyrinthSpeedEnabled = v
    Settings.LabyrinthSpeedEnabled = v
    SaveSettings()

    if v then
        if IsInsideLabyrinth() then
            aplicarVelocidadeLabirinto()
            iniciarAutoVelocidadeLabirinto()

            Library.CreateNoti({
                Title = "Speed Labirinto",
                Desc = "Velocidade x" .. selectedLabyrinthSpeed .. " ativada com auto-reaplica!",
                ShowTime = 3
            })
        else
            Library.CreateNoti({
                Title = "Speed Labirinto",
                Desc = "Entre no labirinto para ativar a speed!",
                ShowTime = 3
            })
        end
    else
        pararAutoVelocidadeLabirinto()
    end
end)

SectionEventMain.CreateToggle({
    Title = "Auto Criar e Iniciar",
    Desc = "Cria e recria automaticamente quando portal for destruído",
    Default = Settings.AutoLabyrinth
}, function(v)
    autoLabyrinthEnabled = v
    Settings.AutoLabyrinth = v
    SaveSettings()

    if v then
        iniciarLabirintoInfinito()
        Library.CreateNoti({
            Title = "Auto Labirinto",
            Desc = "Sistema automático ativado!\nRecriar ao destruir portal: SIM",
            ShowTime = 4
        })
    else
        resetarEstadoLabirinto()
        Library.CreateNoti({
            Title = "Auto Labirinto",
            Desc = "Sistema automático desativado!",
            ShowTime = 3
        })
    end
end)

-- =====================================================
-- SHOP UI
-- =====================================================
SectionShopMain.CreateLabel({
    Title = "Compra automática a cada 10 minutos"
})

SectionShopMain.CreateToggle({
    Title = "Auto Buy Skip2Level",
    Desc = "Compra Skip2Level na shop a cada 10 minutos automaticamente",
    Default = Settings.AutoBuySkip2Level
}, function(v)
    Settings.AutoBuySkip2Level = v
    SaveSettings()

    if v then
        Library.CreateNoti({
            Title = "Shop Auto",
            Desc = "Auto Buy Skip2Level ATIVADO!\nPróxima compra em 10 minutos.",
            ShowTime = 4
        })
    else
        Library.CreateNoti({
            Title = "Shop Auto",
            Desc = "Auto Buy Skip2Level DESATIVADO!",
            ShowTime = 3
        })
    end
end)

SectionShopMain.CreateButton({
    Title = "Comprar Skip2Level Agora",
    Desc = "Compra imediatamente sem esperar o timer"
}, function()
    local args = {
        {
            {
                Name = "Skip2Level",
                Type = "Product",
                SubType = "Products",
                Event = "TicketShop"
            },
            "\017"
        }
    }
    local ok, err = pcall(function()
        ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
    end)
    if ok then
        print("[Shop] Skip2Level comprado manualmente!")
        Library.CreateNoti({
            Title = "Shop",
            Desc = "Skip2Level comprado com sucesso!",
            ShowTime = 3
        })
    else
        warn("[Shop] Erro:", err)
        Library.CreateNoti({
            Title = "Shop",
            Desc = "Erro ao comprar. Veja o console.",
            ShowTime = 3
        })
    end
end)

-- =====================================================
-- SETTINGS UI
-- =====================================================
local SectionSettings = PageSettings.CreateSection("Config")

SectionSettings.CreateLabel({
    Title = "Sistema de Salvamento\nSuas configurações são salvas automaticamente!"
})

SectionSettings.CreateButton({
    Title = "Salvar Configurações"
}, function()
    SaveSettings()
    Library.CreateNoti({
        Title = "Salvamento",
        Desc = "Configurações salvas com sucesso!",
        ShowTime = 3
    })
end)

SectionSettings.CreateButton({
    Title = "Recarregar Configurações"
}, function()
    LoadSettings()
    Library.CreateNoti({
        Title = "Salvamento",
        Desc = "Configurações recarregadas!",
        ShowTime = 3
    })
end)

SectionSettings.CreateButton({
    Title = "Resetar Todas Configurações"
}, function()
    if delfile and isfile(SETTINGS_FILE) then
        delfile(SETTINGS_FILE)
    end

    for key in pairs(Settings) do
        if key:find("RuneSlot") then
            Settings[key] = "Nenhuma"
        elseif type(Settings[key]) == "boolean" then
            Settings[key] = false
        elseif key == "MoveMode" then
            Settings[key] = "Tween"
        elseif key == "CastleSpeed" then
            Settings[key] = "1"
        elseif key == "EntryFloor" then
            Settings[key] = 1
        elseif key == "ResetFloor" then
            Settings[key] = 100
        elseif key == "LabyrinthFloor" then
            Settings[key] = "180"
        elseif key == "LabyrinthSpeed" then
            Settings[key] = "3"
        end
    end

    SaveSettings()

    Library.CreateNoti({
        Title = "Resetado",
        Desc = "Configurações resetadas com sucesso!",
        ShowTime = 3
    })
end)

SectionSettings.CreateButton({
    Title = "Reconectar Servidor"
}, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

Library.CreateNoti({
    Title = "Allan Hub V2",
    Desc = "Script carregado com sucesso!\nSistema de salvamento ativo\nRunas detectadas: " .. #AvailableRunes,
    ShowTime = 6
})

print("ALLAN HUB V2 CARREGADO")
print("Sistema de salvamento: ATIVO")
print("Runas detectadas: " .. #AvailableRunes)
print("Detecção automática de ID da dungeon: ATIVO")
print("ADD Status: ATIVO (toggle na aba Dungeon)")
print("Auto Buy Skip2Level: ATIVO (aba Shop)")
print("Todas as configurações serão salvas automaticamente!")
