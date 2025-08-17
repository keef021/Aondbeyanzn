local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Sync Hub | Mini City RP",
    SubTitle = "by: Keef",
    LoadText = "Carregando Sync Hub",
    Flags = "ChaosHub_Broookhaven"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://128161889268721", BackgroundTransparency = 0 },
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

-- Noclip com bypass
local noclipConnection
HelperTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        if state then
            noclipConnection = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
    end
})

-- Fly com bypass
local flyConnection
local flySpeed = 50
HelperTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local bg = Instance.new("BodyVelocity")
                    bg.MaxForce = Vector3.new(4000, 4000, 4000)
                    bg.Velocity = Vector3.new(0, 0, 0)
                    bg.Parent = hrp
                    
                    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        pcall(function()
                            local cam = workspace.CurrentCamera
                            local moveVector = Vector3.new(0, 0, 0)
                            
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                                moveVector = moveVector + cam.CFrame.LookVector
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                                moveVector = moveVector - cam.CFrame.LookVector
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                                moveVector = moveVector - cam.CFrame.RightVector
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                                moveVector = moveVector + cam.CFrame.RightVector
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                                moveVector = moveVector + Vector3.new(0, 1, 0)
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                                moveVector = moveVector - Vector3.new(0, 1, 0)
                            end
                            
                            bg.Velocity = moveVector * flySpeed
                        end)
                    end)
                end
            end)
        else
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, obj in pairs(char.HumanoidRootPart:GetChildren()) do
                        if obj:IsA("BodyVelocity") then
                            obj:Destroy()
                        end
                    end
                end
            end)
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

-- Função para pegar o lixo mais próximo ou longe
local function getLixoMaisProximo()
    local pastaLixos = workspace:FindFirstChild("MapaGeral")
        and workspace.MapaGeral:FindFirstChild("Gari")
        and workspace.MapaGeral.Gari:FindFirstChild("Lixos")
    
    if not pastaLixos then return nil end
    
    local lixosDisponiveis = {}
    for _, lixo in ipairs(pastaLixos:GetChildren()) do
        if lixo:IsA("BasePart") and string.find(string.upper(lixo.Name), "LEXOS") then
            local prompt = lixo:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and prompt.Enabled then
                local dist = (lixo.Position - hrp.Position).Magnitude
                table.insert(lixosDisponiveis, {lixo = lixo, distancia = dist})
            end
        end
    end
    
    if #lixosDisponiveis == 0 then return nil end
    
    -- Ordenar por distância
    table.sort(lixosDisponiveis, function(a, b) return a.distancia < b.distancia end)
    
    -- Pegar o mais próximo, ou se não tiver próximo (<50), pegar qualquer um
    local maisProximo = lixosDisponiveis[1]
    if maisProximo.distancia < 50 then
        return maisProximo.lixo
    else
        -- Retornar qualquer lixo disponível (mesmo longe)
        return lixosDisponiveis[math.random(1, #lixosDisponiveis)].lixo
    end
end

-- Caminhar até o lixo com bypass
local function andarAte(lixo)
    if not humanoid or not hrp or not lixo or not lixo.Parent then return false end
    
    local targetPosition = lixo.Position
    local maxDistance = (hrp.Position - targetPosition).Magnitude
    
    if maxDistance > 200 then return false end
    
    task.spawn(function()
        pcall(function()
            humanoid:MoveTo(targetPosition)
        end)
    end)
    
    local startTime = tick()
    while coletando and lixo.Parent do
        local currentDistance = (hrp.Position - targetPosition).Magnitude
        local timeElapsed = tick() - startTime
        
        if currentDistance < 8 or timeElapsed > 15 then break end
        
        local prompt = lixo:FindFirstChildWhichIsA("ProximityPrompt")
        if not prompt or not prompt.Enabled then break end
        
        task.wait(0.1)
    end
    
    return lixo.Parent ~= nil
end

-- Loop principal do farm com bypass
local function iniciarColeta()
    coletando = true
    task.spawn(function()
        pcall(function()
            humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                originalSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = 35
            end
        end)
    end)
    
    while coletando do
        if not player.Character then
            task.wait(1)
            continue
        end
        
        humanoid = player.Character:FindFirstChild("Humanoid")
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not hrp then
            task.wait(0.5)
            continue
        end
        
        local lixo = getLixoMaisProximo()
        if lixo then
            local sucesso = andarAte(lixo)
            if sucesso and lixo.Parent and coletando then
                local prompt = lixo:FindFirstChildWhichIsA("ProximityPrompt")
                local distancia = (lixo.Position - hrp.Position).Magnitude
                if prompt and prompt.Enabled and distancia <= prompt.MaxActivationDistance then
                    task.spawn(function()
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                    end)
                    task.wait(0.2)
                end
            end
        else
            task.wait(1) -- Esperar mais se não há lixo
        end
        task.wait(0.1)
    end
end

local function pararColeta()
    coletando = false
    task.spawn(function()
        pcall(function()
            humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalSpeed
            end
        end)
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
