local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Sync Hub | Steal a Driprot",
    SubTitle = "by: Keef",
    LoadText = "Carregando Sync Hub",
    Flags = "ChaosHub_Broookhaven"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://120052712529941", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(35, 1) },
})

-- Aba Info
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://15309138473" })

InfoTab:AddSection({ "Informações do Script" })
InfoTab:AddParagraph({ "Owner / Developer:", "Keef and BN" })
InfoTab:AddParagraph({ "Colaborações:", "BN" })
InfoTab:AddParagraph({ "Você está usando:", "Sync Hub Steal a Driprot" })
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

-- Noclip
local noclipConnection
HelperTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        if state then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
                
                -- Reativar colisão quando desligar noclip
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end
})

-- Velocidade Configurável
local normalWalkSpeed = 16
local speedToggleState = false
local speedSliderValue = 16

HelperTab:AddToggle({
    Name = "Speed",
    Default = false,
    Callback = function(state)
        speedToggleState = state
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if state then
                humanoid.WalkSpeed = speedSliderValue
            else
                humanoid.WalkSpeed = normalWalkSpeed
            end
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

-- Pulo Configurável
local normalJumpPower = 50
local jumpToggleState = false
local jumpSliderValue = 50

HelperTab:AddToggle({
    Name = "Jump",
    Default = false,
    Callback = function(state)
        jumpToggleState = state
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if state then
                humanoid.JumpPower = jumpSliderValue
            else
                humanoid.JumpPower = normalJumpPower
            end
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
local ESPTab = Window:MakeTab({ Title = "ESP", Icon = "rbxassetid://87627563993834" })

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

-- ESP Base
local ESPBaseEnabled = false
local BaseBillboards = {}

local function UpdateBaseBillboard(player)
    if player == game.Players.LocalPlayer then return end
    
    local base = workspace:FindFirstChild(player.Name .. "_Base") or workspace:FindFirstChild(player.Name .. "Base")
    if not base then return end

    if not BaseBillboards[player] then
        local billboard = Instance.new("BillboardGui", base)
        billboard.Name = "SyncHubBaseESP"
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel", billboard)
        label.Name = "BaseLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold

        BaseBillboards[player] = { Billboard = billboard, Label = label }
    end

    local label = BaseBillboards[player].Label
    label.Text = player.Name .. "'s Base"
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESPBaseEnabled then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            UpdateBaseBillboard(player)
        end
    end
end)

ESPTab:AddToggle({
    Name = "ESP Base",
    Default = false,
    Callback = function(state)
        ESPBaseEnabled = state

        if not state then
            for player, data in pairs(BaseBillboards) do
                if data.Billboard then 
                    data.Billboard:Destroy() 
                end
            end
            BaseBillboards = {}
        end
    end
})

-- Aba Steal
local StealTab = Window:MakeTab({ Title = "Steal", Icon = "rbxassetid://139284076376083" })

local savedBasePosition = nil
local isTweening = false
local tweenNoclipConnection = nil

StealTab:AddButton({
    Name = "Salvar Base",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedBasePosition = char.HumanoidRootPart.CFrame
            print("Base salva em:", savedBasePosition)
            -- Adicionar notificação visual
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sync Hub";
                Text = "Base salva com sucesso!";
                Duration = 3;
            })
        else
            warn("Personagem não encontrado!")
        end
    end
})

local tweenBaseToggleState = false
local tweenBaseButtonGui = nil

local function noclipEnable()
    if tweenNoclipConnection then return end
    tweenNoclipConnection = game:GetService("RunService").Stepped:Connect(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function noclipDisable()
    if tweenNoclipConnection then
        tweenNoclipConnection:Disconnect()
        tweenNoclipConnection = nil
    end
end

local function TweenToBase()
    if not savedBasePosition then
        warn("Nenhuma base salva! Use 'Salvar Base' primeiro.")
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sync Hub";
            Text = "Salve uma base primeiro!";
            Duration = 3;
        })
        return
    end
    if isTweening then 
        warn("Já está fazendo tween!")
        return 
    end
    
    isTweening = true

    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then
        isTweening = false
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        isTweening = false
        return
    end

    noclipEnable()
    local tweenService = game:GetService("TweenService")

    local basePos = savedBasePosition.Position
    local flyHeight = 50
    local currentPos = hrp.Position

    -- Tween para cima
    local upTweenTime = math.clamp((flyHeight + math.abs(currentPos.Y - basePos.Y)) / 50, 0.5, 5)
    local upTweenInfo = TweenInfo.new(upTweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local upTween = tweenService:Create(hrp, upTweenInfo, {CFrame = CFrame.new(currentPos.X, basePos.Y + flyHeight, currentPos.Z)})
    upTween:Play()
    upTween.Completed:Wait()

    -- Tween horizontal
    local horizDistance = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(basePos.X, 0, basePos.Z)).Magnitude
    local horizTweenTime = math.clamp(horizDistance / 60, 0.5, 8)
    local horizTweenInfo = TweenInfo.new(horizTweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local horizTween = tweenService:Create(hrp, horizTweenInfo, {CFrame = CFrame.new(basePos.X, basePos.Y + flyHeight, basePos.Z)})
    horizTween:Play()
    horizTween.Completed:Wait()

    -- Tween para baixo
    local downTweenTime = math.clamp(flyHeight / 40, 0.5, 3)
    local downTweenInfo = TweenInfo.new(downTweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local downTween = tweenService:Create(hrp, downTweenInfo, {CFrame = savedBasePosition})
    downTween:Play()
    downTween.Completed:Wait()

    wait(0.5)
    noclipDisable()
    isTweening = false
end

StealTab:AddToggle({
    Name = "Tween Base",
    Default = false,
    Callback = function(state)
        tweenBaseToggleState = state
        if state then
            if tweenBaseButtonGui == nil then
                -- Criar GUI do botão
                tweenBaseButtonGui = Instance.new("ScreenGui")
                tweenBaseButtonGui.Name = "SyncHubTweenBaseGui"
                tweenBaseButtonGui.ResetOnSpawn = false
                tweenBaseButtonGui.Parent = game.CoreGui

                -- Container principal do botão (aumentado para acomodar o botão Quit)
                local buttonContainer = Instance.new("Frame")
                buttonContainer.Size = UDim2.new(0, 180, 0, 100)
                buttonContainer.Position = UDim2.new(0.5, -90, 0.3, -50)
                buttonContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                buttonContainer.BorderSizePixel = 0
                buttonContainer.Parent = tweenBaseButtonGui
                buttonContainer.Active = true

                -- Bordas arredondadas para container
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = UDim.new(0, 15)
                containerCorner.Parent = buttonContainer

                -- Gradiente de fundo
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
                }
                gradient.Rotation = 45
                gradient.Parent = buttonContainer

                -- Borda do container
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stroke.Thickness = 1
                stroke.Transparency = 0.8
                stroke.Parent = buttonContainer

                -- Título
                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
                titleLabel.Position = UDim2.new(0, 0, 0, 0)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = "SYNC HUB"
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextScaled = true
                titleLabel.Parent = buttonContainer

                -- Botão principal (reajustado)
                local tweenButton = Instance.new("TextButton")
                tweenButton.Size = UDim2.new(0.9, 0, 0.35, 0)
                tweenButton.Position = UDim2.new(0.05, 0, 0.35, 0)
                tweenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                tweenButton.BorderSizePixel = 0
                tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                tweenButton.Font = Enum.Font.Gotham
                tweenButton.TextSize = 14
                tweenButton.Text = "TWEEN BASE"
                tweenButton.AutoButtonColor = false
                tweenButton.Parent = buttonContainer

                -- Bordas arredondadas do botão
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)
                buttonCorner.Parent = tweenButton

                -- Borda do botão
                local buttonStroke = Instance.new("UIStroke")
                buttonStroke.Color = Color3.fromRGB(255, 255, 255)
                buttonStroke.Thickness = 1
                buttonStroke.Transparency = 0.5
                buttonStroke.Parent = tweenButton

                -- Botão Quit
                local quitButton = Instance.new("TextButton")
                quitButton.Size = UDim2.new(0.9, 0, 0.25, 0)
                quitButton.Position = UDim2.new(0.05, 0, 0.72, 0)
                quitButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                quitButton.BorderSizePixel = 0
                quitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                quitButton.Font = Enum.Font.Gotham
                quitButton.TextSize = 12
                quitButton.Text = "QUIT"
                quitButton.AutoButtonColor = false
                quitButton.Parent = buttonContainer

                -- Bordas arredondadas do botão quit
                local quitCorner = Instance.new("UICorner")
                quitCorner.CornerRadius = UDim.new(0, 6)
                quitCorner.Parent = quitButton

                -- Borda do botão quit
                local quitStroke = Instance.new("UIStroke")
                quitStroke.Color = Color3.fromRGB(255, 100, 100)
                quitStroke.Thickness = 1
                quitStroke.Transparency = 0.7
                quitStroke.Parent = quitButton

                -- Efeitos de hover para botão Tween
                local tweenService = game:GetService("TweenService")
                local hoverInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                tweenButton.MouseEnter:Connect(function()
                    local hoverTween = tweenService:Create(tweenButton, hoverInfo, {
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        TextColor3 = Color3.fromRGB(200, 200, 200)
                    })
                    local strokeTween = tweenService:Create(buttonStroke, hoverInfo, {
                        Transparency = 0.2
                    })
                    hoverTween:Play()
                    strokeTween:Play()
                end)
                
                tweenButton.MouseLeave:Connect(function()
                    local unhoverTween = tweenService:Create(tweenButton, hoverInfo, {
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    })
                    local strokeTween = tweenService:Create(buttonStroke, hoverInfo, {
                        Transparency = 0.5
                    })
                    unhoverTween:Play()
                    strokeTween:Play()
                end)

                -- Efeitos de hover para botão Quit
                quitButton.MouseEnter:Connect(function()
                    local hoverTween = tweenService:Create(quitButton, hoverInfo, {
                        BackgroundColor3 = Color3.fromRGB(60, 20, 20),
                        TextColor3 = Color3.fromRGB(255, 150, 150)
                    })
                    local strokeTween = tweenService:Create(quitStroke, hoverInfo, {
                        Transparency = 0.3
                    })
                    hoverTween:Play()
                    strokeTween:Play()
                end)
                
                quitButton.MouseLeave:Connect(function()
                    local unhoverTween = tweenService:Create(quitButton, hoverInfo, {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    })
                    local strokeTween = tweenService:Create(quitStroke, hoverInfo, {
                        Transparency = 0.7
                    })
                    unhoverTween:Play()
                    strokeTween:Play()
                end)

                -- Sistema de arrastar corrigido (compatível com mobile)
                local UserInputService = game:GetService("UserInputService")
                local dragging = false
                local dragStart = nil
                local startPos = nil
                local dragConnection = nil

                -- Função para iniciar o drag
                local function startDragging(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = buttonContainer.Position
                        
                        if dragConnection then
                            dragConnection:Disconnect()
                        end
                        
                        dragConnection = UserInputService.InputChanged:Connect(function(input2)
                            if dragging and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
                                local delta = input2.Position - dragStart
                                local newX = math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - buttonContainer.AbsoluteSize.X)
                                local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - buttonContainer.AbsoluteSize.Y)
                                
                                buttonContainer.Position = UDim2.new(0, newX, 0, newY)
                            end
                        end)
                    end
                end

                -- Função para parar o drag
                local function stopDragging(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if dragConnection then
                            dragConnection:Disconnect()
                            dragConnection = nil
                        end
                    end
                end

                -- Fazer o título arrastável (compatível com mobile)
                titleLabel.InputBegan:Connect(startDragging)
                titleLabel.InputEnded:Connect(stopDragging)

                -- Adicionar cursor pointer no título para indicar que é arrastável
                titleLabel.MouseEnter:Connect(function()
                    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end)
                
                titleLabel.MouseLeave:Connect(function()
                    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end)

                -- Ação do botão Tween Base
                tweenButton.MouseButton1Click:Connect(function()
                    if not isTweening then
                        -- Efeito visual de clique
                        local clickTween = tweenService:Create(tweenButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        })
                        clickTween:Play()
                        clickTween.Completed:Wait()
                        
                        local unclickTween = tweenService:Create(tweenButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        })
                        unclickTween:Play()
                        
                        TweenToBase()
                    end
                end)

                -- Ação do botão Quit
                quitButton.MouseButton1Click:Connect(function()
                    -- Efeito visual de clique
                    local clickTween = tweenService:Create(quitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Color3.fromRGB(80, 40, 40)
                    })
                    clickTween:Play()
                    clickTween.Completed:Wait()
                    
                    -- Sair do jogo
                    game:Shutdown()
                end)
            end
        else
            if tweenBaseButtonGui then
                tweenBaseButtonGui:Destroy()
                tweenBaseButtonGui = nil
            end
        end
    end
})
