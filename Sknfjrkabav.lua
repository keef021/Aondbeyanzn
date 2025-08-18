-- High Menu - Mini City RP (Lightweight Version)
-- Versão otimizada para performance

-- Anti-Detecção Simples
local function simpleAntiDetection()
    spawn(function()
        while wait(5) do -- Reduzido para 5 segundos
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                local checkAnti = rs:FindFirstChild("CheckAnti")
                if checkAnti then
                    checkAnti:Destroy()
                end
            end)
        end
    end)
end

simpleAntiDetection()

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
workspace.FallenPartsDestroyHeight = -math.huge

-- Estado Global Simplificado
local State = {
    player = Players.LocalPlayer,
    character = nil,
    humanoid = nil,
    rootPart = nil,
    farmActive = false,
    stats = {
        collected = 0,
        startTime = tick()
    },
    settings = {
        flySpeed = 50,
        walkSpeed = 16,
        collectionRange = 100
    }
}

-- Função de atualização simples
local function updateCharacter()
    State.character = State.player.Character
    if State.character then
        State.humanoid = State.character:FindFirstChild("Humanoid")
        State.rootPart = State.character:FindFirstChild("HumanoidRootPart")
    end
end

-- Setup inicial
State.player.CharacterAdded:Connect(function()
    wait(1)
    updateCharacter()
end)
updateCharacter()

-- Criar janela principal
local Window = Library:MakeWindow({
    Title = "High Menu | Mini City RP",
    SubTitle = "by: Keef (Lightweight)",
    LoadText = "Carregando...",
    Flags = "HighMenu_Light"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://92698440248050", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(0, 35) },
})

-- =================
-- ABA INFO
-- =================
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://77991697673856" })

InfoTab:AddSection({ "Informações" })
InfoTab:AddParagraph({ "Versão:", "High Menu Lightweight" })
InfoTab:AddParagraph({ "Jogo:", "Mini City RP" })

InfoTab:AddButton({
    Name = "Reconectar",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, State.player)
    end
})

InfoTab:AddButton({
    Name = "Novo Servidor",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, State.player)
    end
})

-- Stats simples
local statsLabel = InfoTab:AddParagraph({ "Stats:", "Coletados: 0 | Tempo: 0s" })

spawn(function()
    while wait(2) do -- Reduzido para 2 segundos
        local elapsed = tick() - State.stats.startTime
        statsLabel:Set("Stats:", string.format("Coletados: %d | Tempo: %ds", 
            State.stats.collected, math.floor(elapsed)))
    end
end)

-- =================
-- ABA MOVIMENTO
-- =================
local MovementTab = Window:MakeTab({ Title = "Movement", Icon = "rbxassetid://112065172702553" })

-- Noclip simples
local noclipActive = false
MovementTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(enabled)
        noclipActive = enabled
        
        if enabled then
            spawn(function()
                while noclipActive do
                    updateCharacter()
                    if State.character then
                        for _, part in pairs(State.character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                    wait(0.5) -- Menos frequente
                end
            end)
        else
            updateCharacter()
            if State.character then
                for _, part in pairs(State.character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Fly simples
local flyActive = false
local bodyVelocity
MovementTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(enabled)
        flyActive = enabled
        
        if enabled then
            updateCharacter()
            if State.rootPart then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = State.rootPart
                
                if State.humanoid then
                    State.humanoid.PlatformStand = true
                end
                
                spawn(function()
                    while flyActive and bodyVelocity do
                        local camera = workspace.CurrentCamera
                        local moveVector = Vector3.new(0, 0, 0)
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            moveVector = moveVector + camera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            moveVector = moveVector - camera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            moveVector = moveVector - camera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            moveVector = moveVector + camera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveVector = moveVector + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveVector = moveVector - Vector3.new(0, 1, 0)
                        end
                        
                        bodyVelocity.Velocity = moveVector * State.settings.flySpeed
                        wait(0.1) -- Menos frequente
                    end
                end)
            end
        else
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            
            updateCharacter()
            if State.humanoid then
                State.humanoid.PlatformStand = false
            end
        end
    end
})

MovementTab:AddSlider({
    Name = "Velocidade Fly",
    Min = 10,
    Max = 150,
    Default = 50,
    Callback = function(value)
        State.settings.flySpeed = value
    end
})

-- Velocidade simples
MovementTab:AddSlider({
    Name = "Velocidade Caminhada",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(value)
        State.settings.walkSpeed = value
        updateCharacter()
        if State.humanoid then
            State.humanoid.WalkSpeed = value
        end
    end
})

-- Pulo infinito simples
local infiniteJump = false
MovementTab:AddToggle({
    Name = "Pulo Infinito",
    Default = false,
    Callback = function(enabled)
        infiniteJump = enabled
        
        if enabled then
            UserInputService.JumpRequest:Connect(function()
                if infiniteJump then
                    updateCharacter()
                    if State.humanoid then
                        State.humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end
})

-- =================
-- ABA FARM LIXEIRO
-- =================
local FarmTab = Window:MakeTab({ Title = "Farm", Icon = "rbxassetid://81812366414231" })

-- TweenService para movimento suave
local TweenService = game:GetService("TweenService")

-- Função para encontrar lixos
local function findAllTrash()
    local trashList = {}
    local trashFolder = workspace:FindFirstChild("MapaGeral")
    
    if trashFolder then
        trashFolder = trashFolder:FindFirstChild("Gari")
        if trashFolder then
            trashFolder = trashFolder:FindFirstChild("Lixos")
        end
    end
    
    if not trashFolder then return trashList end
    
    for _, trash in pairs(trashFolder:GetChildren()) do
        if trash:IsA("BasePart") and string.find(string.upper(trash.Name), "LEXOS") then
            local prompt = trash:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and prompt.Enabled then
                table.insert(trashList, trash)
            end
        end
    end
    
    return trashList
end

-- Função para tween até o lixo
local function tweenToTrash(targetTrash)
    updateCharacter()
    if not State.rootPart or not targetTrash then return false end
    
    local targetPosition = targetTrash.Position + Vector3.new(0, 3, 0) -- Voar um pouco acima
    local distance = (State.rootPart.Position - targetPosition).Magnitude
    
    if distance < 5 then return true end -- Já está perto
    
    -- Configurar TweenInfo baseado na distância
    local speed = 50 -- studs por segundo
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(
        duration, -- Duração baseada na distância
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        0, -- Não repetir
        false, -- Não reverter
        0 -- Sem delay
    )
    
    -- Criar tween
    local goal = {Position = targetPosition}
    local tween = TweenService:Create(State.rootPart, tweenInfo, goal)
    
    -- Iniciar tween
    tween:Play()
    
    -- Esperar completar ou ser cancelado
    local startTime = tick()
    local completed = false
    
    tween.Completed:Connect(function()
        completed = true
    end)
    
    -- Aguardar com timeout
    while not completed and State.farmActive and tick() - startTime < duration + 2 do
        wait(0.1)
    end
    
    return completed or (State.rootPart.Position - targetPosition).Magnitude < 10
end

-- Farm Lixeiro com TweenFly
local farmLixeiroActive = false
FarmTab:AddToggle({
    Name = "Farm Lixeiro (Risco)",
    Default = false,
    Callback = function(enabled)
        farmLixeiroActive = enabled
        State.farmActive = enabled
        
        if enabled then
            -- Avisar sobre o risco
            print("⚠️ ATENÇÃO: Farm Lixeiro ativo - pode ser detectado!")
            
            spawn(function()
                while farmLixeiroActive do
                    updateCharacter()
                    
                    if State.humanoid and State.rootPart then
                        -- Ativar fly para movimento
                        if State.humanoid then
                            State.humanoid.PlatformStand = true
                        end
                        
                        -- Buscar todos os lixos disponíveis
                        local trashList = findAllTrash()
                        
                        if #trashList > 0 then
                            -- Pegar o primeiro lixo da lista
                            local targetTrash = trashList[1]
                            
                            -- Ir até o lixo usando tween
                            local success = tweenToTrash(targetTrash)
                            
                            if success and targetTrash.Parent and farmLixeiroActive then
                                -- Coletar o lixo
                                local prompt = targetTrash:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt and prompt.Enabled and fireproximityprompt then
                                    fireproximityprompt(prompt)
                                    State.stats.collected = State.stats.collected + 1
                                    print("Coletado! Total: " .. State.stats.collected)
                                end
                                
                                wait(0.5) -- Pequena pausa após coletar
                            end
                        else
                            print("Nenhum lixo encontrado, aguardando...")
                            wait(3) -- Esperar mais tempo se não houver lixo
                        end
                    end
                    
                    wait(0.2) -- Pequeno delay entre iterações
                end
                
                -- Desativar fly ao parar
                updateCharacter()
                if State.humanoid then
                    State.humanoid.PlatformStand = false
                end
                
                print("Farm Lixeiro desativado.")
            end)
        else
            print("Parando Farm Lixeiro...")
        end
    end
})

FarmTab:AddButton({
    Name = "Reset Stats",
    Callback = function()
        State.stats.collected = 0
        State.stats.startTime = tick()
    end
})

-- =================
-- ESP SIMPLES
-- =================
local ESPTab = Window:MakeTab({ Title = "ESP", Icon = "rbxassetid://87627563993834" })

local espActive = false
ESPTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(enabled)
        espActive = enabled
        
        if enabled then
            -- Adicionar ESP aos jogadores existentes
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= State.player and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "SimpleESP"
                    highlight.FillTransparency = 0.8
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = player.Character
                    highlight.Parent = player.Character
                end
            end
            
            -- Monitorar novos jogadores
            spawn(function()
                while espActive do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= State.player and player.Character and not player.Character:FindFirstChild("SimpleESP") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "SimpleESP"
                            highlight.FillTransparency = 0.8
                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineTransparency = 0
                            highlight.Adornee = player.Character
                            highlight.Parent = player.Character
                        end
                    end
                    wait(2)
                end
            end)
        else
            -- Remover ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("SimpleESP")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
})

-- Função de limpeza simples
local function cleanup()
    State.farmActive = false
    farmLixeiroActive = false
    noclipActive = false
    flyActive = false
    espActive = false
    infiniteJump = false
    
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
    
    updateCharacter()
    if State.humanoid then
        State.humanoid.WalkSpeed = 16
        State.humanoid.PlatformStand = false
    end
    
    -- Remover ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("SimpleESP")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Cleanup ao sair
Players.PlayerRemoving:Connect(function(player)
    if player == State.player then
        cleanup()
    end
end)

-- Mensagem final
print("High Menu Lightweight carregado!")
print("Versão otimizada para melhor performance.")
