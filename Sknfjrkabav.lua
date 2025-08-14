local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Sync Hub | Mini City RP",
    SubTitle = "by: Keef",
    LoadText = "Carregando Sync Hub",
    Flags = "ChaosHub_Broookhaven"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://128126421568053", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(35, 1) },
})

-- Aba Info
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://77991697673856" })

InfoTab:AddSection({ "Informações do Script" })
InfoTab:AddParagraph({ "Owner / Developer:", "Keef and BN" })
InfoTab:AddParagraph({ "Colaborações:", "BN" })
InfoTab:AddParagraph({ "Você está usando:", "Sync Hub Mini City RP" })
InfoTab:AddParagraph({ "Your executor:", executor or "Desconhecido" })

-- Função de Rejoin
InfoTab:AddSection({ "Rejoin" })
InfoTab:AddButton({
    Name = "Rejoin",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

-- Aba Helper
local HelperTab = Window:MakeTab({ Title = "Helper", Icon = "rbxassetid://112065172702553" })

-- Noclip com bypass avançado
local noclipConnection
local noclipParts = {}

local function enableNoclip()
    task.spawn(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    noclipParts[part] = part.CanCollide
                    part.CanCollide = false
                    
                    -- Método adicional para alguns anti-cheats
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = math.min(part.Transparency + 0.1, 0.9)
                    end
                end
            end
        end
    end)
end

local function disableNoclip()
    task.spawn(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            for part, originalState in pairs(noclipParts) do
                if part and part.Parent then
                    part.CanCollide = originalState
                    -- Restaurar transparência
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = math.max(part.Transparency - 0.1, 0)
                    end
                end
            end
            noclipParts = {}
        end
    end)
end

HelperTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        if state then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                enableNoclip()
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            disableNoclip()
        end
    end
})

-- Velocidade Configurável com bypass
local normalWalkSpeed = 16
local speedToggleState = false
local speedSliderValue = 16
local speedConnection

local function setSpeed(speed)
    task.spawn(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed
                -- Método alternativo para alguns anti-cheats
                if char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end

HelperTab:AddToggle({
    Name = "Speed",
    Default = false,
    Callback = function(state)
        speedToggleState = state
        if state then
            speedConnection = game:GetService("RunService").Heartbeat:Connect(function()
                setSpeed(speedSliderValue)
            end)
        else
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
            setSpeed(normalWalkSpeed)
        end
    end
})

HelperTab:AddSlider({
    Name = "Speed Amount",
    Min = 16,
    Max = 100,
    Default = 16,
    Float = 1,
    Callback = function(value)
        speedSliderValue = value
        if speedToggleState then
            local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

-- Pulo Configurável com bypass
local normalJumpPower = 50
local jumpToggleState = false
local jumpSliderValue = 50
local jumpConnection

local function setJump(power)
    task.spawn(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = power
                humanoid.JumpHeight = power / 2.5 -- Para alguns jogos que usam JumpHeight
            end
        end
    end)
end

HelperTab:AddToggle({
    Name = "Jump",
    Default = false,
    Callback = function(state)
        jumpToggleState = state
        if state then
            jumpConnection = game:GetService("RunService").Heartbeat:Connect(function()
                setJump(jumpSliderValue)
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
            setJump(normalJumpPower)
        end
    end
})

HelperTab:AddSlider({
    Name = "Jump Amount",
    Min = 50,
    Max = 200,
    Default = 50,
    Float = 1,
    Callback = function(value)
        jumpSliderValue = value
        if jumpToggleState then
            local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

-- Aba ESP
local ESPTab = Window:MakeTab({ Title = "Esp", Icon = "rbxassetid://87627563993834" })

-- Função ESP Player
local espPlayerEnabled = false
local espPlayerConnections = {}

local function createESPForPlayer(player)
    if player == game.Players.LocalPlayer then return end
    if not player.Character then return end
    if player.Character:FindFirstChild("SyncHubESP") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "SyncHubESP"
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.Adornee = player.Character
    highlight.Parent = player.Character

    local billboard = Instance.new("BillboardGui", player.Character)
    billboard.Name = "NameTagESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.new(0, 1, 0)
    label.TextScaled = true
end

local function removeESPFromPlayer(player)
    if player.Character then
        if player.Character:FindFirstChild("SyncHubESP") then
            player.Character:FindFirstChild("SyncHubESP"):Destroy()
        end
        if player.Character:FindFirstChild("NameTagESP") then
            player.Character:FindFirstChild("NameTagESP"):Destroy()
        end
    end
end

ESPTab:AddToggle({
    Name = "ESP Player",
    Default = false,
    Callback = function(state)
        espPlayerEnabled = state
        if state then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr.Character then
                    createESPForPlayer(plr)
                end
                plr.CharacterAdded:Connect(function()
                    if espPlayerEnabled then
                        wait(0.5) -- Aguardar character carregar
                        createESPForPlayer(plr)
                    end
                end)
            end
            
            table.insert(espPlayerConnections, game.Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function()
                    if espPlayerEnabled then
                        wait(0.5)
                        createESPForPlayer(plr)
                    end
                end)
            end))
        else
            for _, plr in ipairs(game.Players:GetPlayers()) do
                removeESPFromPlayer(plr)
            end
            for _, conn in ipairs(espPlayerConnections) do
                if conn then
                    conn:Disconnect()
                end
            end
            espPlayerConnections = {}
        end
    end
})

-- ESP Admin
local ESPAdminEnabled = false
local AdminBillboards = {}

local function isPlayerAdmin(player)
    return player:GetRankInGroup(0) >= 100 -- Você pode ajustar este critério
end

local function UpdateAdminBillboard(player)
    if player == game.Players.LocalPlayer then return end
    if not isPlayerAdmin(player) then return end
    if not player.Character then return end

    if not AdminBillboards[player] then
        local billboard = Instance.new("BillboardGui", player.Character)
        billboard.Name = "SyncHubAdminESP"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel", billboard)
        label.Name = "AdminLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold

        -- Highlight para admins
        local highlight = Instance.new("Highlight")
        highlight.Name = "AdminHighlight"
        highlight.FillTransparency = 0.7
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character

        AdminBillboards[player] = { Billboard = billboard, Label = label, Highlight = highlight }
    end

    local label = AdminBillboards[player].Label
    label.Text = "⚠️ ADMIN: " .. player.Name .. " ⚠️"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESPAdminEnabled then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            UpdateAdminBillboard(player)
        end
    end
end)

ESPTab:AddToggle({
    Name = "ESP Admin",
    Default = false,
    Callback = function(state)
        ESPAdminEnabled = state

        if not state then
            for player, data in pairs(AdminBillboards) do
                if data.Billboard then 
                    data.Billboard:Destroy() 
                end
                if data.Highlight and data.Highlight.Parent then
                    data.Highlight:Destroy()
                end
            end
            AdminBillboards = {}
        end
    end
})

-- Aba Farm
local FarmTab = Window:MakeTab({ Title = "Farm", Icon = "rbxassetid://81812366414231" })

-- Variáveis para Farm Lixeiro
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local humanoid, hrp
local coletando = false
local originalSpeed = 16

-- Função para pegar o lixo mais próximo que esteja disponível
local function getLixoMaisProximo()
    local pastaLixos = workspace:FindFirstChild("MapaGeral")
        and workspace.MapaGeral:FindFirstChild("Gari")
        and workspace.MapaGeral.Gari:FindFirstChild("Lixos")
    
    if not pastaLixos then return nil end
    
    local maisProximo, menorDist = nil, math.huge
    for _, lixo in ipairs(pastaLixos:GetChildren()) do
        if lixo:IsA("BasePart") and string.find(string.upper(lixo.Name), "LEXOS") then
            local prompt = lixo:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and prompt.Enabled then
                local dist = (lixo.Position - hrp.Position).Magnitude
                if dist < menorDist then
                    menorDist = dist
                    maisProximo = lixo
                end
            end
        end
    end
    return maisProximo
end

-- Caminhar até o lixo com movimento natural
local function andarAte(lixo)
    if not humanoid or not hrp or not lixo or not lixo.Parent then return false end
    
    local caminho = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = math.random(4, 8) -- Espaçamento variável
    })
    
    local success, error = pcall(function()
        caminho:ComputeAsync(hrp.Position, lixo.Position)
    end)
    
    if not success or caminho.Status ~= Enum.PathStatus.Success then
        return false
    end
    
    local waypoints = caminho:GetWaypoints()
    for i, waypoint in ipairs(waypoints) do
        if not coletando or not lixo.Parent then return false end
        
        local prompt = lixo:FindFirstChildWhichIsA("ProximityPrompt")
        if not prompt or not prompt.Enabled then
            return false
        end
        
        humanoid:MoveTo(waypoint.Position)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            -- Delay natural antes do pulo
            task.wait(math.random(10, 25) / 100)
            humanoid.Jump = true
        end
        
        local timeoutConnection
        local moveFinished = false
        
        local connection = humanoid.MoveToFinished:Connect(function()
            moveFinished = true
        end)
        
        -- Timeout variável
        timeoutConnection = task.delay(math.random(80, 150) / 100, function()
            moveFinished = true
        end)
        
        repeat 
            task.wait(math.random(3, 8) / 100) 
        until moveFinished
        
        connection:Disconnect()
        if timeoutConnection then
            task.cancel(timeoutConnection)
        end
        
        -- Pequena pausa entre waypoints
        if i < #waypoints then
            task.wait(math.random(1, 5) / 100)
        end
    end
    return true
end

-- Loop principal do farm com bypass
local function iniciarColeta()
    coletando = true
    -- Salvar velocidade original e aumentar gradualmente
    humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        originalSpeed = humanoid.WalkSpeed
        -- Aumentar velocidade gradualmente para evitar detecção
        task.spawn(function()
            for i = originalSpeed, 35, 2 do
                if not coletando then break end
                humanoid.WalkSpeed = i
                task.wait(0.1)
            end
        end)
    end
    
    while coletando do
        if not player.Character then
            task.wait(math.random(80, 120) / 100) -- Delay aleatório
            continue
        end
        
        humanoid = player.Character:FindFirstChild("Humanoid")
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not hrp then
            task.wait(math.random(40, 80) / 100)
            continue
        end
        
        local lixo = getLixoMaisProximo()
        if lixo then
            local sucesso = andarAte(lixo)
            if sucesso and lixo.Parent and coletando then
                local prompt = lixo:FindFirstChildWhichIsA("ProximityPrompt")
                local distancia = (lixo.Position - hrp.Position).Magnitude
                if prompt and prompt.Enabled and distancia <= prompt.MaxActivationDistance then
                    -- Delay aleatório antes de coletar
                    task.wait(math.random(5, 15) / 100)
                    
                    -- Método alternativo de ativação
                    task.spawn(function()
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                    end)
                    
                    task.wait(math.random(8, 20) / 100)
                end
            end
        else
            task.wait(math.random(15, 35) / 100)
        end
        task.wait(math.random(3, 12) / 100) -- Delay variável entre ações
    end
end

local function pararColeta()
    coletando = false
    -- Restaurar velocidade gradualmente
    task.spawn(function()
        humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local currentSpeed = humanoid.WalkSpeed
            for i = currentSpeed, originalSpeed, -2 do
                humanoid.WalkSpeed = math.max(i, originalSpeed)
                task.wait(0.1)
                if i <= originalSpeed then break end
            end
            humanoid.WalkSpeed = originalSpeed
        end
    end)
end

FarmTab:AddToggle({
    Name = "Farm Lixeiro",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(iniciarColeta)
        else
            pararColeta()
        end
    end
})
