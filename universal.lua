-- ============================
-- OFW CLIENT BY 2b3f - ENHANCED
-- ============================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- ============================
-- EXPLOIT FUNCTION CHECKS
-- ============================
local hasMouseMove = mousemoverel ~= nil or mousemoveabs ~= nil
local hasMouseClick = mouse1press ~= nil and mouse1release ~= nil
local hasDrawing = Drawing ~= nil
local hasGetHui = gethui ~= nil
local hasSynProtect = syn ~= nil and syn.protect_gui ~= nil

if not hasMouseMove then
    warn("⚠️ WARNING: Mouse movement functions not available in your executor!")
end

if not hasMouseClick then
    warn("⚠️ WARNING: Mouse click functions not available in your executor!")
end

-- Settings
local Settings = {
    Aim = {
        AimAssist = false,
        AimAutoSpeed = true,
        AimSmoothness = 0.25,
        AimFOV = 80,
        StickyAim = true,
        TargetPart = "Head",
        MaxDistance = 500,
        Wallshot = false,
        Prediction = 0,
        TeamCheck = true,
        Triggerbot = false,
        TriggerbotDelay = 0,
        VisibleCheck = true,
        AliveCheck = true,
        TargetMode = "Distance",
        TpAura = false,
        TpAuraDistance = 0,
        TpAuraAutoShoot = true,
    },
    Visuals = {
        ThreeDBox = false,
        HealthESP = false,
        DistanceESP = false,
        SkeletonESP = false,
        ShowFOVCircle = true,
        ESPColor = Color3.fromRGB(255, 0, 0),
    },
    Misc = {
        Speed = false,
        SpeedValue = 16,
        Fly = false,
        FlySpeed = 50,
        InfiniteJump = false,
        TeleportBehind = false,
        TeleportDistance = 5,
        TeleportTeamCheck = true,
        Noclip = false,
        NoclipSpeed = 16,
    },
    Colors = {
        MapColor = Color3.fromRGB(255, 255, 255),
        UseMapColor = false,
        SkyColor = Color3.fromRGB(135, 206, 235),
        UseSkyColor = false,
    },
    Theme = {
        AccentColor = Color3.fromRGB(88, 101, 242),
        BackgroundColor = Color3.fromRGB(20, 20, 25),
        SecondaryBackground = Color3.fromRGB(25, 25, 30),
        TextColor = Color3.fromRGB(220, 220, 220),
    },
    Config = {
        MenuToggleKey = "RightShift",
        Watermark = true,
        ShowKeybinds = true,
        ShowAllKeybinds = false,
        Notifications = true,
    }
}

-- Variables
local ESPObjects = {}
local aimActive = false
local currentAimTarget = nil
local fovCircle = nil
local bindingKey = nil
local allBindData = {}
local menuToggleKey = Enum.KeyCode.RightShift
local originalMapColors = {}
local originalSkyColor = nil
local flyConnection = nil
local speedConnection = nil
local infiniteJumpConnection = nil
local currentConfig = "Default"
local savedConfigs = {"Default", "Legit", "Rage"}
local WatermarkGui = nil
local KeybindsGui = nil
local NotificationGui = nil
local NotificationQueue = {}
local wallshotStoredParts = {}
local wallshotActive = false
local tpAuraConnection = nil
local noclipConnection = nil
local rainbowHue = 0
local keybindsOriginalPosition = nil

-- FOV Circle
if hasDrawing then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 50
        fovCircle.Radius = Settings.Aim.AimFOV * 2.5
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Transparency = 0.7
        fovCircle.Filled = false
        fovCircle.Visible = true
    end)
else
    warn("⚠️ Drawing API not available - FOV Circle disabled")
end

-- ============================
-- DRAGGABLE FUNCTION
-- ============================
local function MakeDraggable(frame, dragFrame)
    local dragging = false
    local dragInput, mousePos, framePos

    dragFrame = dragFrame or frame

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- ============================
-- NOTIFICATION SYSTEM
-- ============================
local function CreateNotification(title, message, duration)
    if not Settings.Config.Notifications then return end
    
    duration = duration or 3
    
    pcall(function()
        if not NotificationGui then
            NotificationGui = Instance.new("ScreenGui")
            NotificationGui.Name = "RivalsNotification"
            NotificationGui.ResetOnSpawn = false
            NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            if hasGetHui then
                NotificationGui.Parent = gethui()
            elseif hasSynProtect then
                syn.protect_gui(NotificationGui)
                NotificationGui.Parent = game:GetService("CoreGui")
            else
                NotificationGui.Parent = game:GetService("CoreGui")
            end
        end
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(0, 250, 0, 60)
        NotifFrame.Position = UDim2.new(1, -260, 0, 20 + (#NotificationQueue * 70))
        NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Parent = NotificationGui
        
        table.insert(NotificationQueue, NotifFrame)
        
        Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)
        
        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 3, 1, 0)
        AccentBar.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = NotifFrame
        
        Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 8)
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -15, 0, 20)
        TitleLabel.Position = UDim2.new(0, 12, 0, 5)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 12
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = NotifFrame
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Size = UDim2.new(1, -15, 0, 30)
        MessageLabel.Position = UDim2.new(0, 12, 0, 25)
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.Text = message
        MessageLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        MessageLabel.TextSize = 10
        MessageLabel.TextWrapped = true
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        MessageLabel.Parent = NotifFrame
        
        NotifFrame.Position = UDim2.new(1, 20, 0, 20 + (#NotificationQueue * 70))
        TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, -260, 0, 20 + ((#NotificationQueue - 1) * 70))
        }):Play()
        
        task.delay(duration, function()
            TweenService:Create(NotifFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 20, 0, NotifFrame.Position.Y.Offset)
            }):Play()
            
            task.wait(0.3)
            
            for i, notif in ipairs(NotificationQueue) do
                if notif == NotifFrame then
                    table.remove(NotificationQueue, i)
                    break
                end
            end
            
            NotifFrame:Destroy()
            
            for i, notif in ipairs(NotificationQueue) do
                TweenService:Create(notif, TweenInfo.new(0.3), {
                    Position = UDim2.new(1, -260, 0, 20 + ((i - 1) * 70))
                }):Play()
            end
        end)
    end)
end

-- ============================
-- WATERMARK
-- ============================
local function CreateWatermark()
    pcall(function()
        if WatermarkGui then WatermarkGui:Destroy() end
        
        WatermarkGui = Instance.new("ScreenGui")
        WatermarkGui.Name = "RivalsWatermark"
        WatermarkGui.ResetOnSpawn = false
        WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        if hasGetHui then
            WatermarkGui.Parent = gethui()
        elseif hasSynProtect then
            syn.protect_gui(WatermarkGui)
            WatermarkGui.Parent = game:GetService("CoreGui")
        else
            WatermarkGui.Parent = game:GetService("CoreGui")
        end
        
        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Size = UDim2.new(0, 280, 0, 35)
        WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
        WatermarkFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        WatermarkFrame.BorderSizePixel = 0
        WatermarkFrame.Parent = WatermarkGui
        
        Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 8)
        
        local AccentLine = Instance.new("Frame")
        AccentLine.Size = UDim2.new(1, 0, 0, 2)
        AccentLine.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        AccentLine.BorderSizePixel = 0
        AccentLine.Parent = WatermarkFrame
        
        local WatermarkLabel = Instance.new("TextLabel")
        WatermarkLabel.Size = UDim2.new(1, -10, 1, -5)
        WatermarkLabel.Position = UDim2.new(0, 10, 0, 5)
        WatermarkLabel.BackgroundTransparency = 1
        WatermarkLabel.Font = Enum.Font.GothamBold
        WatermarkLabel.Text = "OFW CLIENT | " .. LocalPlayer.Name
        WatermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        WatermarkLabel.TextSize = 13
        WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
        WatermarkLabel.Parent = WatermarkFrame
        
        MakeDraggable(WatermarkFrame)
        
        task.spawn(function()
            while WatermarkGui and WatermarkGui.Parent do
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                local time = os.date("%H:%M:%S")
                WatermarkLabel.Text = string.format("OFW CLIENT | %s | %d FPS | %s", LocalPlayer.Name, fps, time)
                task.wait(1)
            end
        end)
    end)
end

-- ============================
-- KEYBINDS DISPLAY (FIXED POSITION)
-- ============================
local function UpdateKeybindsDisplay()
    if not Settings.Config.ShowKeybinds then
        if KeybindsGui then
            KeybindsGui:Destroy()
            KeybindsGui = nil
        end
        keybindsOriginalPosition = nil
        return
    end
    
    pcall(function()
        if KeybindsGui then KeybindsGui:Destroy() end
        
        KeybindsGui = Instance.new("ScreenGui")
        KeybindsGui.Name = "RivalsKeybinds"
        KeybindsGui.ResetOnSpawn = false
        KeybindsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        if hasGetHui then
            KeybindsGui.Parent = gethui()
        elseif hasSynProtect then
            syn.protect_gui(KeybindsGui)
            KeybindsGui.Parent = game:GetService("CoreGui")
        else
            KeybindsGui.Parent = game:GetService("CoreGui")
        end
        
        local KeybindsFrame = Instance.new("Frame")
        KeybindsFrame.Size = UDim2.new(0, 200, 0, 30)
        
        -- Используем сохраненную позицию или дефолтную
        if keybindsOriginalPosition then
            KeybindsFrame.Position = keybindsOriginalPosition
        else
            KeybindsFrame.Position = UDim2.new(1, -210, 0, 60)
            keybindsOriginalPosition = KeybindsFrame.Position
        end
        
        KeybindsFrame.BackgroundColor3 = Settings.Theme.BackgroundColor
        KeybindsFrame.BorderSizePixel = 0
        KeybindsFrame.Parent = KeybindsGui
        
        Instance.new("UICorner", KeybindsFrame).CornerRadius = UDim.new(0, 8)
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 25)
        Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Title.BorderSizePixel = 0
        Title.Font = Enum.Font.GothamBold
        Title.Text = "KEYBINDS"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 12
        Title.Parent = KeybindsFrame
        
        Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)
        
        local AccentLine = Instance.new("Frame")
        AccentLine.Size = UDim2.new(1, 0, 0, 2)
        AccentLine.Position = UDim2.new(0, 0, 1, 0)
        AccentLine.BackgroundColor3 = Settings.Theme.AccentColor
        AccentLine.BorderSizePixel = 0
        AccentLine.Parent = Title
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 2)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = KeybindsFrame
        
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            KeybindsFrame.Size = UDim2.new(0, 200, 0, ListLayout.AbsoluteContentSize.Y + 5)
        end)
        
        Title.LayoutOrder = 0
        
        -- Сохраняем позицию при перетаскивании
        local dragFrame = Title
        local dragging = false
        local dragInput, mousePos, framePos

        dragFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = KeybindsFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        keybindsOriginalPosition = KeybindsFrame.Position
                    end
                end)
            end
        end)

        dragFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
                KeybindsFrame.Position = newPos
            end
        end)
        
        task.spawn(function()
            while KeybindsGui and KeybindsGui.Parent do
                for _, child in pairs(KeybindsFrame:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                
                local index = 1
                for _, bindData in ipairs(allBindData) do
                    if bindData.key ~= "" and bindData.featureName then
                        local shouldShow = Settings.Config.ShowAllKeybinds or bindData.enabled
                        
                        if shouldShow then
                            local BindFrame = Instance.new("Frame")
                            BindFrame.Size = UDim2.new(1, -10, 0, 22)
                            BindFrame.BackgroundColor3 = Settings.Theme.SecondaryBackground
                            BindFrame.BorderSizePixel = 0
                            BindFrame.LayoutOrder = index + 1
                            BindFrame.Parent = KeybindsFrame
                            
                            Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 5)
                            
                            local FeatureName = Instance.new("TextLabel")
                            FeatureName.Size = UDim2.new(0.6, 0, 1, 0)
                            FeatureName.Position = UDim2.new(0, 8, 0, 0)
                            FeatureName.BackgroundTransparency = 1
                            FeatureName.Font = Enum.Font.Gotham
                            FeatureName.Text = bindData.featureName
                            FeatureName.TextColor3 = bindData.enabled and Settings.Theme.AccentColor or Color3.fromRGB(150, 150, 150)
                            FeatureName.TextSize = 11
                            FeatureName.TextXAlignment = Enum.TextXAlignment.Left
                            FeatureName.Parent = BindFrame
                            
                            local KeyName = Instance.new("TextLabel")
                            KeyName.Size = UDim2.new(0.35, 0, 1, 0)
                            KeyName.Position = UDim2.new(0.65, 0, 0, 0)
                            KeyName.BackgroundTransparency = 1
                            KeyName.Font = Enum.Font.GothamBold
                            KeyName.Text = "[" .. bindData.key .. "]"
                            KeyName.TextColor3 = Color3.fromRGB(200, 200, 200)
                            KeyName.TextSize = 10
                            KeyName.TextXAlignment = Enum.TextXAlignment.Right
                            KeyName.Parent = BindFrame
                            
                            local StatusDot = Instance.new("Frame")
                            StatusDot.Size = UDim2.new(0, 6, 0, 6)
                            StatusDot.Position = UDim2.new(1, -8, 0.5, -3)
                            StatusDot.BackgroundColor3 = bindData.enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                            StatusDot.BorderSizePixel = 0
                            StatusDot.Parent = BindFrame
                            
                            Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)
                            
                            index = index + 1
                        end
                    end
                end
                
                task.wait(0.1)
            end
        end)
    end)
end

-- ============================
-- IMPROVED PREDICTION SYSTEM
-- ============================
local function calculateAdvancedPrediction(target)
    if Settings.Aim.Prediction <= 0 then return target.Position end
    
    local myChar = LocalPlayer.Character
    if not myChar then return target.Position end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return target.Position end
    
    local targetParent = target.Parent
    if not targetParent then return target.Position end
    
    local targetHrp = targetParent:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return target.Position end
    
    -- Получаем velocity обоих игроков
    local myVelocity = myHrp.AssemblyLinearVelocity
    local targetVelocity = targetHrp.AssemblyLinearVelocity
    
    -- Относительная скорость цели
    local relativeVelocity = targetVelocity - myVelocity
    
    -- Дистанция до цели
    local distance = (targetHrp.Position - myHrp.Position).Magnitude
    
    -- Время полета пули (предполагаем скорость пули ~1000 studs/sec)
    local bulletSpeed = 1000
    local timeToHit = distance / bulletSpeed
    
    -- Применяем множитель prediction
    local predictionTime = timeToHit * Settings.Aim.Prediction
    
    -- Вычисляем предсказанную позицию
    local predictedPosition = target.Position + (relativeVelocity * predictionTime)
    
    return predictedPosition
end

-- ============================
-- NOCLIP
-- ============================
local function enableNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        if not Settings.Misc.Noclip then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Misc.NoclipSpeed
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

-- ============================
-- TP AURA (IMPROVED)
-- ============================
local function getClosestEnemyForAura()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.Aim.TeamCheck then
                if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    continue
                end
            end
            
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local myChar = LocalPlayer.Character
                if myChar then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local distance = (myHrp.Position - hrp.Position).Magnitude
                        if distance < shortestDistance and distance <= Settings.Aim.MaxDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function enableTpAura()
    tpAuraConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Aim.TpAura then return end
        
        local targetPlayer = getClosestEnemyForAura()
        if not targetPlayer or not targetPlayer.Character then return end
        
        local targetChar = targetPlayer.Character
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHead = targetChar:FindFirstChild("Head")
        
        if not targetHrp or not targetHead then return end
        
        local myChar = LocalPlayer.Character
        if not myChar then return end
        
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        
        -- Телепорт: 0 = внутрь игрока, >0 = позади
        if Settings.Aim.TpAuraDistance == 0 then
            myHrp.CFrame = targetHrp.CFrame
        else
            local behindPosition = targetHrp.CFrame * CFrame.new(0, 0, Settings.Aim.TpAuraDistance)
            myHrp.CFrame = behindPosition
        end
        
        -- Наведение на голову
        if Camera then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
        
        -- Автострельба
        if Settings.Aim.TpAuraAutoShoot and hasMouseClick then
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
        
        -- Проверка на смерть цели для автосмены
        task.wait(0.1)
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            -- Цель мертва, ищем новую на следующем кадре
            return
        end
    end)
end

local function disableTpAura()
    if tpAuraConnection then
        tpAuraConnection:Disconnect()
        tpAuraConnection = nil
    end
end

-- ============================
-- WALLSHOT
-- ============================
local function enableWallshot()
    wallshotActive = true
    
    local mapModel = Workspace:FindFirstChild("MAP")
    if not mapModel then return end
    
    local function deletePart(target)
        if target and target:IsA("BasePart") and target:IsDescendantOf(mapModel) then
            if not wallshotStoredParts[target] then
                wallshotStoredParts[target] = true
                target.CanCollide = false
                target.Transparency = 0.8
            end
        end
    end
    
    RunService.Heartbeat:Connect(function()
        if wallshotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target:IsDescendantOf(mapModel) then
                deletePart(mouse.Target)
            end
        elseif not wallshotActive or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            for original in pairs(wallshotStoredParts) do
                if original and original.Parent then
                    original.CanCollide = true
                    original.Transparency = 0
                end
            end
            wallshotStoredParts = {}
        end
    end)
end

local function disableWallshot()
    wallshotActive = false
    for original in pairs(wallshotStoredParts) do
        if original and original.Parent then
            original.CanCollide = true
            original.Transparency = 0
        end
    end
    wallshotStoredParts = {}
end

-- ============================
-- TELEPORT BEHIND
-- ============================
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.Misc.TeleportTeamCheck then
                if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    continue
                end
            end
            
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local myChar = LocalPlayer.Character
                if myChar then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local distance = (myHrp.Position - hrp.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local teleportEnabled = false
local function toggleTeleportBehind(state)
    teleportEnabled = state
    
    if state then
        task.spawn(function()
            local targetPlayer = getClosestEnemy()
            if not targetPlayer then 
                CreateNotification("Teleport", "No valid target found", 2)
                return 
            end
            
            local targetChar = targetPlayer.Character
            if not targetChar then return end
            
            local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHrp then return end
            
            local myChar = LocalPlayer.Character
            if not myChar then return end
            
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            
            local behindPosition = targetHrp.CFrame * CFrame.new(0, 0, Settings.Misc.TeleportDistance)
            myHrp.CFrame = behindPosition
            
            CreateNotification("Teleport", "Teleported behind " .. targetPlayer.Name, 2)
        end)
    end
end

-- ============================
-- SPEED
-- ============================
local function enableSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "SpeedBoost"
    bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    speedConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Misc.Speed then
            if bodyVelocity then bodyVelocity:Destroy() end
            if speedConnection then speedConnection:Disconnect() end
            return
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local moveDirection = humanoid.MoveDirection
            bodyVelocity.Velocity = moveDirection * Settings.Misc.SpeedValue
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function disableSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bodyVel = hrp:FindFirstChild("SpeedBoost")
            if bodyVel then
                bodyVel:Destroy()
            end
        end
    end
end

-- ============================
-- FLY
-- ============================
local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.P = 10000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Misc.Fly then
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if flyConnection then flyConnection:Disconnect() end
            return
        end
        
        local cam = Camera
        local speed = Settings.Misc.FlySpeed
        local velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + (cam.CFrame.LookVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - (cam.CFrame.LookVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - (cam.CFrame.RightVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + (cam.CFrame.RightVector * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, speed, 0)
        end
        
        bodyVelocity.Velocity = velocity
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in pairs(hrp:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                    obj:Destroy()
                end
            end
        end
    end
end

-- ============================
-- INFINITE JUMP
-- ============================
local function enableInfiniteJump()
    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if Settings.Misc.InfiniteJump then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

local function disableInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end

-- ============================
-- MAP & SKY COLOR
-- ============================
local function applyMapColor()
    pcall(function()
        if Settings.Colors.UseMapColor then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or workspace) then
                    if not originalMapColors[obj] then
                        originalMapColors[obj] = obj.Color
                    end
                    obj.Color = Settings.Colors.MapColor
                end
            end
        else
            for obj, originalColor in pairs(originalMapColors) do
                if obj and obj.Parent then
                    obj.Color = originalColor
                end
            end
            originalMapColors = {}
        end
    end)
end

local function applySkyColor()
    pcall(function()
        if Settings.Colors.UseSkyColor then
            if not originalSkyColor then
                originalSkyColor = Lighting.Ambient
            end
            Lighting.Ambient = Settings.Colors.SkyColor
            Lighting.OutdoorAmbient = Settings.Colors.SkyColor
        else
            if originalSkyColor then
                Lighting.Ambient = originalSkyColor
                Lighting.OutdoorAmbient = originalSkyColor
            end
        end
    end)
end

-- ============================
-- CONFIG SYSTEM
-- ============================
local function saveConfig(configName)
    local success, err = pcall(function()
        if writefile then
            writefile("rivals_config_" .. configName .. ".json", game:GetService("HttpService"):JSONEncode(Settings))
            CreateNotification("Config", "Saved: " .. configName, 2)
        else
            CreateNotification("Error", "writefile not available", 2)
        end
    end)
    
    if not success then
        CreateNotification("Error", "Failed to save config", 2)
    end
end

local function loadConfig(configName)
    local success, err = pcall(function()
        if readfile then
            local data = readfile("rivals_config_" .. configName .. ".json")
            Settings = game:GetService("HttpService"):JSONDecode(data)
            
            for _, bindData in ipairs(allBindData) do
                if bindData.updateSwitch then
                    bindData.updateSwitch(false)
                end
            end
            CreateNotification("Config", "Loaded: " .. configName, 2)
        else
            CreateNotification("Error", "readfile not available", 2)
        end
    end)
    
    if not success then
        CreateNotification("Error", "Failed to load config", 2)
    end
end

-- ============================
-- 3D BOX ESP
-- ============================
local function create3DBox(player)
    if not hasDrawing then return end
    
    local esp = {}
    
    esp.Lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Settings.Visuals.ESPColor
        line.Thickness = 2
        line.Transparency = 1
        table.insert(esp.Lines, line)
    end
    
    esp.Health = Drawing.new("Text")
    esp.Health.Visible = false
    esp.Health.Size = 13
    esp.Health.Center = true
    esp.Health.Outline = true
    
    esp.Distance = Drawing.new("Text")
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    esp.Skeleton = {}
    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 2
        table.insert(esp.Skeleton, line)
    end
    
    ESPObjects[player] = esp
end

local function update3DBox()
    if not hasDrawing then return end
    
    for player, esp in pairs(ESPObjects) do
        pcall(function()
            if not player or not player.Parent or not player.Character then
                for _, v in pairs(esp) do
                    if typeof(v) == "table" then
                        for _, obj in pairs(v) do
                            obj.Visible = false
                        end
                    else
                        v.Visible = false
                    end
                end
                return
            end
            
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not humanoid or humanoid.Health <= 0 then 
                for _, v in pairs(esp) do
                    if typeof(v) == "table" then
                        for _, obj in pairs(v) do
                            obj.Visible = false
                        end
                    else
                        v.Visible = false
                    end
                end
                return 
            end
            
            local corners = {}
            local size = Vector3.new(2.5, 5.5, 1.5)
            local cf = hrp.CFrame
            
            corners[1] = cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)
            corners[2] = cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)
            corners[3] = cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)
            corners[4] = cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)
            corners[5] = cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)
            corners[6] = cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)
            corners[7] = cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)
            corners[8] = cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)
            
            local screenCorners = {}
            local allOnScreen = true
            
            for i, corner in pairs(corners) do
                local pos, onScreen = Camera:WorldToViewportPoint(corner.Position)
                screenCorners[i] = Vector2.new(pos.X, pos.Y)
                if not onScreen then
                    allOnScreen = false
                end
            end
            
            if Settings.Visuals.ThreeDBox and allOnScreen then
                esp.Lines[1].From = screenCorners[1]
                esp.Lines[1].To = screenCorners[2]
                esp.Lines[2].From = screenCorners[2]
                esp.Lines[2].To = screenCorners[4]
                esp.Lines[3].From = screenCorners[4]
                esp.Lines[3].To = screenCorners[3]
                esp.Lines[4].From = screenCorners[3]
                esp.Lines[4].To = screenCorners[1]
                
                esp.Lines[5].From = screenCorners[5]
                esp.Lines[5].To = screenCorners[6]
                esp.Lines[6].From = screenCorners[6]
                esp.Lines[6].To = screenCorners[8]
                esp.Lines[7].From = screenCorners[8]
                esp.Lines[7].To = screenCorners[7]
                esp.Lines[8].From = screenCorners[7]
                esp.Lines[8].To = screenCorners[5]
                
                esp.Lines[9].From = screenCorners[1]
                esp.Lines[9].To = screenCorners[5]
                esp.Lines[10].From = screenCorners[2]
                esp.Lines[10].To = screenCorners[6]
                esp.Lines[11].From = screenCorners[3]
                esp.Lines[11].To = screenCorners[7]
                esp.Lines[12].From = screenCorners[4]
                esp.Lines[12].To = screenCorners[8]
                
                for _, line in pairs(esp.Lines) do
                    line.Visible = true
                    line.Color = Settings.Visuals.ESPColor
                end
            else
                for _, line in pairs(esp.Lines) do
                    line.Visible = false
                end
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            esp.Health.Visible = Settings.Visuals.HealthESP and onScreen
            if Settings.Visuals.HealthESP and onScreen then
                local health = math.floor(humanoid.Health)
                esp.Health.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
                esp.Health.Text = tostring(health) .. " HP"
                esp.Health.Color = Color3.fromRGB(255 * (1 - humanoid.Health/humanoid.MaxHealth), 255 * humanoid.Health/humanoid.MaxHealth, 0)
            end
            
            esp.Distance.Visible = Settings.Visuals.DistanceESP and onScreen
            if Settings.Visuals.DistanceESP and onScreen then
                local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - 55)
                esp.Distance.Text = "[" .. distance .. "m]"
            end
            
            if Settings.Visuals.SkeletonESP and onScreen then
                local function getPos(partName)
                    local part = char:FindFirstChild(partName)
                    if part then
                        local pos, vis = Camera:WorldToViewportPoint(part.Position)
                        return Vector2.new(pos.X, pos.Y), vis
                    end
                    return nil, false
                end
                
                local head, headVis = getPos("Head")
                local upperTorso, upperVis = getPos("UpperTorso") or getPos("Torso")
                local lowerTorso, lowerVis = getPos("LowerTorso") or getPos("Torso")
                local leftArm, leftArmVis = getPos("LeftUpperArm") or getPos("Left Arm")
                local rightArm, rightArmVis = getPos("RightUpperArm") or getPos("Right Arm")
                local leftLeg, leftLegVis = getPos("LeftUpperLeg") or getPos("Left Leg")
                local rightLeg, rightLegVis = getPos("RightUpperLeg") or getPos("Right Leg")
                
                local connections = {
                    {head, upperTorso},
                    {upperTorso, lowerTorso},
                    {upperTorso, leftArm},
                    {upperTorso, rightArm},
                    {lowerTorso, leftLeg},
                    {lowerTorso, rightLeg},
                }
                
                for i, connection in ipairs(connections) do
                    local line = esp.Skeleton[i]
                    if connection[1] and connection[2] then
                        line.Visible = true
                        line.From = connection[1]
                        line.To = connection[2]
                        line.Color = Settings.Visuals.ESPColor
                    else
                        line.Visible = false
                    end
                end
            else
                for _, line in pairs(esp.Skeleton) do
                    line.Visible = false
                end
            end
        end)
    end
end

-- ============================
-- AIM FUNCTIONS
-- ============================
local function isSameTeam(player)
    if not Settings.Aim.TeamCheck then return false end
    return player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

local function isVisible(targetPos)
    if not Settings.Aim.VisibleCheck then return true end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local origin = Camera.CFrame.Position
    local direction = targetPos - origin
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(origin, direction, rayParams)
    
    if result then
        return Players:GetPlayerFromCharacter(result.Instance.Parent) ~= nil
    end
    
    return true
end

local function worldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

local function findBestAimTarget()
    local bestTarget = nil
    local bestValue = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if isSameTeam(player) then continue end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then continue end
        
        if Settings.Aim.AliveCheck and humanoid.Health <= 0 then continue end
        
        local targetPart = player.Character:FindFirstChild(Settings.Aim.TargetPart) or player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        local screenPos, onScreen = worldToScreen(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.Aim.MaxDistance then continue end
        
        if not isVisible(targetPart.Position) then continue end
        
        local viewport = Camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local angle = (screenPos - center).Magnitude
        
        if angle < Settings.Aim.AimFOV * 2.5 then
            local value
            if Settings.Aim.TargetMode == "Distance" then
                value = distance
            elseif Settings.Aim.TargetMode == "HP" then
                value = humanoid.Health
            end
            
            if value < bestValue then
                bestValue = value
                bestTarget = targetPart
            end
        end
    end
    
    return bestTarget
end

-- ============================
-- TRIGGERBOT
-- ============================
local function checkTriggerbotTarget()
    if not Settings.Aim.Triggerbot then return false end
    if not hasMouseClick then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    
    if not target then return false end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player or player == LocalPlayer then return false end
    
    if isSameTeam(player) then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    if Settings.Aim.AliveCheck and humanoid.Health <= 0 then return false end
    
    return true
end

-- ============================
-- GUI CREATION
-- ============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsCheatMenu"
ScreenGui.ResetOnSpawn = false

if hasGetHui then
    ScreenGui.Parent = gethui()
elseif hasSynProtect then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 620, 0, 480)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -240)
MainFrame.BackgroundColor3 = Settings.Theme.BackgroundColor
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Resize Handle
local ResizeHandle = Instance.new("Frame")
ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
ResizeHandle.BackgroundColor3 = Settings.Theme.AccentColor
ResizeHandle.BorderSizePixel = 0
ResizeHandle.Parent = MainFrame

Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 4)

local resizing = false
local resizeStart, sizeStart

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStart = input.Position
        sizeStart = MainFrame.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - resizeStart
        local newWidth = math.max(500, sizeStart.X.Offset + delta.X)
        local newHeight = math.max(400, sizeStart.Y.Offset + delta.Y)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.Text = "OFW CLIENT ENHANCED"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Parent = MainFrame

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, 0)
AccentLine.BackgroundColor3 = Settings.Theme.AccentColor
AccentLine.BorderSizePixel = 0
AccentLine.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Title

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

MakeDraggable(MainFrame, Title)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 160, 1, -70)
TabContainer.Position = UDim2.new(0, 15, 0, 65)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -200, 1, -80)
ContentContainer.Position = UDim2.new(0, 190, 0, 65)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- ============================
-- UI CREATION FUNCTIONS
-- ============================
local function CreateTab(name, icon, position)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 45)
    TabButton.Position = UDim2.new(0, 0, 0, position)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabButton.BorderSizePixel = 0
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.Text = "  " .. icon .. "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.TextSize = 14
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabContainer
    
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
    
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "Content"
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Visible = false
    Content.Parent = ContentContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = Content
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(ContentContainer:GetChildren()) do
            child.Visible = false
        end
        for _, tab in pairs(TabContainer:GetChildren()) do
            if tab:IsA("TextButton") then
                tab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                tab.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        
        Content.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    return Content
end

local function hexToRgb(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber("0x" .. hex:sub(1, 2))
        local g = tonumber("0x" .. hex:sub(3, 4))
        local b = tonumber("0x" .. hex:sub(5, 6))
        return Color3.fromRGB(r, g, b)
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateToggle(parent, text, callback, featureName)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -10, 0, 40)
    Toggle.BackgroundColor3 = Settings.Theme.SecondaryBackground
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent
    
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -140, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local BindBox = Instance.new("TextButton")
    BindBox.Size = UDim2.new(0, 60, 0, 26)
    BindBox.Position = UDim2.new(1, -105, 0.5, -13)
    BindBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    BindBox.BorderSizePixel = 1
    BindBox.BorderColor3 = Color3.fromRGB(50, 50, 55)
    BindBox.Text = "None"
    BindBox.Font = Enum.Font.GothamBold
    BindBox.TextSize = 10
    BindBox.TextColor3 = Color3.fromRGB(180, 180, 180)
    BindBox.Parent = Toggle
    
    Instance.new("UICorner", BindBox).CornerRadius = UDim.new(0, 5)
    
    local bindData = {
        key = "",
        keyCode = nil,
        mode = "Toggle",
        isBinding = false,
        enabled = false,
        updateSwitch = nil,
        featureName = featureName or text
    }
    
    local ContextMenu = Instance.new("Frame")
    ContextMenu.Size = UDim2.new(0, 100, 0, 90)
    ContextMenu.Position = UDim2.new(0, 0, 1, 2)
    ContextMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ContextMenu.BorderSizePixel = 1
    ContextMenu.BorderColor3 = Color3.fromRGB(88, 101, 242)
    ContextMenu.Visible = false
    ContextMenu.ZIndex = 100
    ContextMenu.Parent = BindBox
    
    Instance.new("UICorner", ContextMenu).CornerRadius = UDim.new(0, 6)
    
    local modes = {"Toggle", "Hold", "Always On"}
    for i, mode in ipairs(modes) do
        local ModeButton = Instance.new("TextButton")
        ModeButton.Size = UDim2.new(1, -8, 0, 26)
        ModeButton.Position = UDim2.new(0, 4, 0, (i-1) * 28 + 4)
        ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        ModeButton.Text = mode
        ModeButton.Font = Enum.Font.Gotham
        ModeButton.TextSize = 10
        ModeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModeButton.BorderSizePixel = 0
        ModeButton.ZIndex = 101
        ModeButton.Parent = ContextMenu
        
        Instance.new("UICorner", ModeButton).CornerRadius = UDim.new(0, 4)
        
        ModeButton.MouseButton1Click:Connect(function()
            bindData.mode = mode
            ContextMenu.Visible = false
            
            if mode == "Always On" then
                bindData.enabled = true
                if bindData.updateSwitch then
                    bindData.updateSwitch(true)
                end
            end
        end)
        
        ModeButton.MouseEnter:Connect(function()
            ModeButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)
        
        ModeButton.MouseLeave:Connect(function()
            ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end)
    end
    
    BindBox.MouseButton1Click:Connect(function()
        if bindData.isBinding then return end
        
        BindBox.Text = "..."
        BindBox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        bindData.isBinding = true
        bindingKey = text
        
        local connection
        
        connection = UserInputService.InputBegan:Connect(function(input)
            if bindData.isBinding then
                local keyName = ""
                local keyCodeValue = nil
                
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        bindData.key = ""
                        bindData.keyCode = nil
                        BindBox.Text = "None"
                        BindBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                        bindData.isBinding = false
                        bindingKey = nil
                        connection:Disconnect()
                        return
                    end
                    keyName = input.KeyCode.Name
                    keyCodeValue = input.KeyCode
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    keyName = "Mouse1"
                    keyCodeValue = Enum.UserInputType.MouseButton1
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    keyName = "Mouse2"
                    keyCodeValue = Enum.UserInputType.MouseButton2
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    keyName = "Mouse3"
                    keyCodeValue = Enum.UserInputType.MouseButton3
                end
                
                if keyName ~= "" then
                    bindData.key = keyName
                    bindData.keyCode = keyCodeValue
                    BindBox.Text = keyName
                    BindBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    bindData.isBinding = false
                    bindingKey = nil
                    connection:Disconnect()
                    UpdateKeybindsDisplay()
                end
            end
        end)
    end)
    
    BindBox.MouseButton2Click:Connect(function()
        ContextMenu.Visible = not ContextMenu.Visible
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if ContextMenu.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local guiPos = ContextMenu.AbsolutePosition
                local guiSize = ContextMenu.AbsoluteSize
                
                if mousePos.X < guiPos.X or mousePos.X > guiPos.X + guiSize.X or
                   mousePos.Y < guiPos.Y or mousePos.Y > guiPos.Y + guiSize.Y then
                    ContextMenu.Visible = false
                end
            end
        end
    end)
    
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 40, 0, 22)
    Switch.Position = UDim2.new(1, -45, 0.5, -11)
    Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Switch.BorderSizePixel = 0
    Switch.Parent = Toggle
    
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.BorderSizePixel = 0
    Circle.Parent = Switch
    
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 40, 1, 0)
    Button.Position = UDim2.new(1, -45, 0, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Toggle
    
    local function updateSwitch(state)
        bindData.enabled = state
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        
        if state then
            TweenService:Create(Circle, tweenInfo, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            TweenService:Create(Switch, tweenInfo, {BackgroundColor3 = Settings.Theme.AccentColor}):Play()
            TweenService:Create(Circle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(Circle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            TweenService:Create(Switch, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
            TweenService:Create(Circle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        
        callback(state)
        UpdateKeybindsDisplay()
        CreateNotification(featureName or text, state and "Enabled" or "Disabled", 1.5)
    end
    
    bindData.updateSwitch = updateSwitch
    table.insert(allBindData, bindData)
    
    Button.MouseButton1Click:Connect(function()
        if bindData.mode == "Always On" then return end
        updateSwitch(not bindData.enabled)
    end)
    
    return Toggle, bindData
end

local function CreateSlider(parent, text, min, max, default, callback, hideCondition)
    local Slider = Instance.new("Frame")
    Slider.Name = "Slider_" .. text
    Slider.Size = UDim2.new(1, -10, 0, 55)
    Slider.BackgroundColor3 = Settings.Theme.SecondaryBackground
    Slider.BorderSizePixel = 0
    Slider.Parent = parent
    
    Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Settings.Theme.AccentColor
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Slider
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 1, -15)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Slider
    
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Settings.Theme.AccentColor
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar
    
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Dragging = false
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            local relative = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relative)
            
            Fill.Size = UDim2.new(relative, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    if hideCondition then
        task.spawn(function()
            while Slider and Slider.Parent do
                Slider.Visible = not hideCondition()
                task.wait(0.1)
            end
        end)
    end
    
    return Slider
end

local function CreateDropdown(parent, text, options, default, callback)
    local Dropdown = Instance.new("Frame")
    Dropdown.Size = UDim2.new(1, -10, 0, 40)
    Dropdown.BackgroundColor3 = Settings.Theme.SecondaryBackground
    Dropdown.BorderSizePixel = 0
    Dropdown.Parent = parent
    
    Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Dropdown
    
    local DropButton = Instance.new("TextButton")
    DropButton.Size = UDim2.new(0.45, 0, 0, 28)
    DropButton.Position = UDim2.new(0.55, 0, 0.5, -14)
    DropButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    DropButton.BorderSizePixel = 0
    DropButton.Font = Enum.Font.GothamBold
    DropButton.Text = default .. " ▼"
    DropButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropButton.TextSize = 11
    DropButton.Parent = Dropdown
    
    Instance.new("UICorner", DropButton).CornerRadius = UDim.new(0, 6)
    
    local DropList = Instance.new("Frame")
    DropList.Size = UDim2.new(0.45, 0, 0, #options * 32)
    DropList.Position = UDim2.new(0.55, 0, 1, 5)
    DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    DropList.BorderSizePixel = 1
    DropList.BorderColor3 = Color3.fromRGB(88, 101, 242)
    DropList.Visible = false
    DropList.ZIndex = 10
    DropList.Parent = Dropdown
    
    Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = DropList
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, -8, 0, 28)
        OptionButton.Position = UDim2.new(0, 4, 0, 0)
        OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        OptionButton.BorderSizePixel = 0
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptionButton.TextSize = 11
        OptionButton.ZIndex = 11
        OptionButton.Parent = DropList
        
        Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 5)
        
        OptionButton.MouseButton1Click:Connect(function()
            DropButton.Text = option .. " ▼"
            DropList.Visible = false
            callback(option)
        end)
        
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end)
    end
    
    DropButton.MouseButton1Click:Connect(function()
        DropList.Visible = not DropList.Visible
    end)
    
    return Dropdown
end

local function CreateColorPicker(parent, text, defaultColor, callback)
    local ColorPicker = Instance.new("Frame")
    ColorPicker.Size = UDim2.new(1, -10, 0, 70)
    ColorPicker.BackgroundColor3 = Settings.Theme.SecondaryBackground
    ColorPicker.BorderSizePixel = 0
    ColorPicker.Parent = parent
    
    Instance.new("UICorner", ColorPicker).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ColorPicker
    
    local ColorBox = Instance.new("Frame")
    ColorBox.Size = UDim2.new(0, 30, 0, 28)
    ColorBox.Position = UDim2.new(1, -35, 0, 3)
    ColorBox.BackgroundColor3 = defaultColor
    ColorBox.BorderSizePixel = 0
    ColorBox.Parent = ColorPicker
    
    Instance.new("UICorner", ColorBox).CornerRadius = UDim.new(0, 6)
    
    local HexInput = Instance.new("TextBox")
    HexInput.Size = UDim2.new(1, -20, 0, 30)
    HexInput.Position = UDim2.new(0, 10, 0, 35)
    HexInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    HexInput.BorderSizePixel = 0
    HexInput.Font = Enum.Font.GothamBold
    HexInput.PlaceholderText = "Hex code (e.g., #FF0000)"
    HexInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    HexInput.Text = ""
    HexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    HexInput.TextSize = 12
    HexInput.ClearTextOnFocus = false
    HexInput.Parent = ColorPicker
    
    Instance.new("UICorner", HexInput).CornerRadius = UDim.new(0, 6)
    
    HexInput.FocusLost:Connect(function(enter)
        if enter and HexInput.Text ~= "" then
            local newColor = hexToRgb(HexInput.Text)
            ColorBox.BackgroundColor3 = newColor
            callback(newColor)
        end
    end)
    
    return ColorPicker
end

local function CreateButton(parent, text, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -10, 0, 45)
    ButtonFrame.BackgroundColor3 = Settings.Theme.SecondaryBackground
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = parent
    
    Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 8)
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 1, -10)
    Btn.Position = UDim2.new(0, 10, 0, 5)
    Btn.BackgroundColor3 = Settings.Theme.AccentColor
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BorderSizePixel = 0
    Btn.Parent = ButtonFrame
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        callback()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 80, 200)}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    end)
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 115, 255)}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    end)
    
    return ButtonFrame
end

-- CREATE TABS
local AimTab = CreateTab("Aim", "🎯", 0)
local VisualsTab = CreateTab("Visuals", "👁️", 55)
local ColorsTab = CreateTab("Colors", "🎨", 110)
local MiscTab = CreateTab("Misc", "⚙️", 165)
local ConfigTab = CreateTab("Config", "💾", 220)

-- ============================
-- AIM TAB
-- ============================
CreateToggle(AimTab, "Aim Assist (RMB)", function(state)
    Settings.Aim.AimAssist = state
end, "Aim Assist")

CreateToggle(AimTab, "Auto Speed", function(state)
    Settings.Aim.AimAutoSpeed = state
end, "Auto Speed")

CreateSlider(AimTab, "Smoothness", 1, 10, 3, function(value)
    Settings.Aim.AimSmoothness = value / 40
end, function() return Settings.Aim.AimAutoSpeed end)

CreateSlider(AimTab, "Prediction", 0, 10, 0, function(value)
    Settings.Aim.Prediction = value / 10
end)

CreateSlider(AimTab, "FOV", 50, 300, 80, function(value)
    Settings.Aim.AimFOV = value
    if fovCircle then fovCircle.Radius = value * 2.5 end
end)

CreateSlider(AimTab, "Max Distance", 100, 1000, 500, function(value)
    Settings.Aim.MaxDistance = value
end)

CreateToggle(AimTab, "Sticky Aim", function(state)
    Settings.Aim.StickyAim = state
end, "Sticky Aim")

CreateToggle(AimTab, "Wallshot", function(state)
    Settings.Aim.Wallshot = state
    if state then
        enableWallshot()
    else
        disableWallshot()
    end
end, "Wallshot")

CreateToggle(AimTab, "Visible Check", function(state)
    Settings.Aim.VisibleCheck = state
end, "Visible Check")

CreateToggle(AimTab, "Alive Check", function(state)
    Settings.Aim.AliveCheck = state
end, "Alive Check")

CreateToggle(AimTab, "Team Check", function(state)
    Settings.Aim.TeamCheck = state
end, "Team Check")

CreateDropdown(AimTab, "Target Mode", {"Distance", "HP"}, "Distance", function(option)
    Settings.Aim.TargetMode = option
end)

CreateToggle(AimTab, "Triggerbot", function(state)
    Settings.Aim.Triggerbot = state
end, "Triggerbot")

CreateSlider(AimTab, "Triggerbot Delay (ms)", 0, 500, 0, function(value)
    Settings.Aim.TriggerbotDelay = value
end)

-- TP AURA
CreateToggle(AimTab, "TP Aura", function(state)
    Settings.Aim.TpAura = state
    if state then
        enableTpAura()
    else
        disableTpAura()
    end
end, "TP Aura")

CreateSlider(AimTab, "TP Aura Distance (0=Inside)", 0, 20, 0, function(value)
    Settings.Aim.TpAuraDistance = value
end)

CreateToggle(AimTab, "TP Aura Auto Shoot", function(state)
    Settings.Aim.TpAuraAutoShoot = state
end, "TP Aura Shoot")

-- ============================
-- VISUALS TAB
-- ============================
CreateToggle(VisualsTab, "Show FOV Circle", function(state)
    Settings.Visuals.ShowFOVCircle = state
    if fovCircle then fovCircle.Visible = state end
end, "FOV Circle")

CreateToggle(VisualsTab, "3D Box ESP", function(state)
    Settings.Visuals.ThreeDBox = state
end, "3D Box ESP")

CreateToggle(VisualsTab, "Health ESP", function(state)
    Settings.Visuals.HealthESP = state
end, "Health ESP")

CreateToggle(VisualsTab, "Distance ESP", function(state)
    Settings.Visuals.DistanceESP = state
end, "Distance ESP")

CreateToggle(VisualsTab, "Skeleton ESP", function(state)
    Settings.Visuals.SkeletonESP = state
end, "Skeleton ESP")

CreateColorPicker(VisualsTab, "ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    Settings.Visuals.ESPColor = color
end)

-- ============================
-- COLORS TAB
-- ============================
CreateToggle(ColorsTab, "Map Color", function(state)
    Settings.Colors.UseMapColor = state
    applyMapColor()
end, "Map Color")

CreateColorPicker(ColorsTab, "Map Color", Color3.fromRGB(255, 255, 255), function(color)
    Settings.Colors.MapColor = color
    if Settings.Colors.UseMapColor then
        applyMapColor()
    end
end)

CreateToggle(ColorsTab, "Sky Color", function(state)
    Settings.Colors.UseSkyColor = state
    applySkyColor()
end, "Sky Color")

CreateColorPicker(ColorsTab, "Sky Color", Color3.fromRGB(135, 206, 235), function(color)
    Settings.Colors.SkyColor = color
    if Settings.Colors.UseSkyColor then
        applySkyColor()
    end
end)

-- ============================
-- MISC TAB
-- ============================
CreateToggle(MiscTab, "Speed", function(state)
    Settings.Misc.Speed = state
    if state then
        enableSpeed()
    else
        disableSpeed()
    end
end, "Speed")

CreateSlider(MiscTab, "Speed Value", 16, 200, 16, function(value)
    Settings.Misc.SpeedValue = value
end)

CreateToggle(MiscTab, "Fly", function(state)
    Settings.Misc.Fly = state
    if state then
        enableFly()
    else
        disableFly()
    end
end, "Fly")

CreateSlider(MiscTab, "Fly Speed", 10, 200, 50, function(value)
    Settings.Misc.FlySpeed = value
end)

CreateToggle(MiscTab, "Infinite Jump", function(state)
    Settings.Misc.InfiniteJump = state
    if state then
        enableInfiniteJump()
    else
        disableInfiniteJump()
    end
end, "Infinite Jump")

CreateToggle(MiscTab, "Teleport Behind Enemy", function(state)
    toggleTeleportBehind(state)
end, "Teleport Behind")

CreateToggle(MiscTab, "Teleport Team Check", function(state)
    Settings.Misc.TeleportTeamCheck = state
end, "TP Team Check")

CreateSlider(MiscTab, "Teleport Distance", 3, 15, 5, function(value)
    Settings.Misc.TeleportDistance = value
end)

-- NOCLIP
CreateToggle(MiscTab, "Noclip", function(state)
    Settings.Misc.Noclip = state
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
end, "Noclip")

CreateSlider(MiscTab, "Noclip Speed", 16, 200, 16, function(value)
    Settings.Misc.NoclipSpeed = value
end)

-- ============================
-- CONFIG TAB
-- ============================
CreateToggle(ConfigTab, "Watermark", function(state)
    Settings.Config.Watermark = state
    if state then
        CreateWatermark()
    else
        if WatermarkGui then
            WatermarkGui:Destroy()
            WatermarkGui = nil
        end
    end
end, "Watermark")

CreateToggle(ConfigTab, "Show Keybinds", function(state)
    Settings.Config.ShowKeybinds = state
    UpdateKeybindsDisplay()
end, "Keybinds")

CreateToggle(ConfigTab, "Show All Keybinds", function(state)
    Settings.Config.ShowAllKeybinds = state
    UpdateKeybindsDisplay()
end, "All Keybinds")

CreateToggle(ConfigTab, "Notifications", function(state)
    Settings.Config.Notifications = state
end, "Notifications")

-- GUI THEME COLORS
CreateColorPicker(ConfigTab, "Accent Color", Color3.fromRGB(88, 101, 242), function(color)
    Settings.Theme.AccentColor = color
    CreateNotification("Theme", "Restart menu to apply colors", 3)
end)

CreateColorPicker(ConfigTab, "Background Color", Color3.fromRGB(20, 20, 25), function(color)
    Settings.Theme.BackgroundColor = color
    CreateNotification("Theme", "Restart menu to apply colors", 3)
end)

CreateColorPicker(ConfigTab, "Secondary Background", Color3.fromRGB(25, 25, 30), function(color)
    Settings.Theme.SecondaryBackground = color
    CreateNotification("Theme", "Restart menu to apply colors", 3)
end)

CreateColorPicker(ConfigTab, "Text Color", Color3.fromRGB(220, 220, 220), function(color)
    Settings.Theme.TextColor = color
    CreateNotification("Theme", "Restart menu to apply colors", 3)
end)

local ConfigList = Instance.new("Frame")
ConfigList.Size = UDim2.new(1, -10, 0, 150)
ConfigList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ConfigList.BorderSizePixel = 0
ConfigList.Parent = ConfigTab

Instance.new("UICorner", ConfigList).CornerRadius = UDim.new(0, 8)

local ConfigTitle = Instance.new("TextLabel")
ConfigTitle.Size = UDim2.new(1, -20, 0, 30)
ConfigTitle.Position = UDim2.new(0, 10, 0, 5)
ConfigTitle.BackgroundTransparency = 1
ConfigTitle.Font = Enum.Font.GothamBold
ConfigTitle.Text = "📋 Saved Configs"
ConfigTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
ConfigTitle.TextSize = 14
ConfigTitle.TextXAlignment = Enum.TextXAlignment.Left
ConfigTitle.Parent = ConfigList

local ConfigScroll = Instance.new("ScrollingFrame")
ConfigScroll.Size = UDim2.new(1, -20, 1, -40)
ConfigScroll.Position = UDim2.new(0, 10, 0, 35)
ConfigScroll.BackgroundTransparency = 1
ConfigScroll.BorderSizePixel = 0
ConfigScroll.ScrollBarThickness = 4
ConfigScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, #savedConfigs * 35)
ConfigScroll.Parent = ConfigList

for i, configName in ipairs(savedConfigs) do
    local ConfigItem = Instance.new("TextButton")
    ConfigItem.Size = UDim2.new(1, -10, 0, 30)
    ConfigItem.Position = UDim2.new(0, 5, 0, (i-1) * 35)
    ConfigItem.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ConfigItem.Text = "  " .. configName
    ConfigItem.Font = Enum.Font.Gotham
    ConfigItem.TextSize = 12
    ConfigItem.TextColor3 = Color3.fromRGB(200, 200, 200)
    ConfigItem.TextXAlignment = Enum.TextXAlignment.Left
    ConfigItem.BorderSizePixel = 0
    ConfigItem.Parent = ConfigScroll
    
    Instance.new("UICorner", ConfigItem).CornerRadius = UDim.new(0, 5)
    
    ConfigItem.MouseButton1Click:Connect(function()
        currentConfig = configName
        for _, child in pairs(ConfigScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            end
        end
        ConfigItem.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)
end

CreateButton(ConfigTab, "💾 Save Config", function()
    saveConfig(currentConfig)
end)

CreateButton(ConfigTab, "📂 Load Config", function()
    loadConfig(currentConfig)
end)

-- ============================
-- MAIN LOOPS
-- ============================
RunService.RenderStepped:Connect(function()
    pcall(function()
        if fovCircle then
            local viewport = Camera.ViewportSize
            fovCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
            fovCircle.Color = aimActive and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
            fovCircle.Visible = Settings.Visuals.ShowFOVCircle
        end
    end)
end)

-- Triggerbot loop
if hasMouseClick then
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if checkTriggerbotTarget() then
                task.wait(Settings.Aim.TriggerbotDelay / 1000)
                if checkTriggerbotTarget() then
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end
            end
        end)
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.Aim.AimAssist then
        aimActive = true
    end
    
    if bindingKey or processed then return end
    
    if input.KeyCode == menuToggleKey then
        local menuOpen = MainFrame.Visible
        
        if not menuOpen then
            MainFrame.Visible = true
            MainFrame.Position = UDim2.new(0.5, -310, 0.5, -260)
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -310, 0.5, -240)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -310, 0.5, -260)}):Play()
            wait(0.3)
            MainFrame.Visible = false
        end
        return
    end
    
    for _, bindData in ipairs(allBindData) do
        if bindData.keyCode then
            local keyMatch = false
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyMatch = input.KeyCode == bindData.keyCode
            elseif bindData.keyCode == Enum.UserInputType.MouseButton1 then
                keyMatch = input.UserInputType == Enum.UserInputType.MouseButton1
            elseif bindData.keyCode == Enum.UserInputType.MouseButton2 then
                keyMatch = input.UserInputType == Enum.UserInputType.MouseButton2
            elseif bindData.keyCode == Enum.UserInputType.MouseButton3 then
                keyMatch = input.UserInputType == Enum.UserInputType.MouseButton3
            end
            
            if keyMatch then
                if bindData.mode == "Toggle" then
                    if bindData.updateSwitch then
                        bindData.updateSwitch(not bindData.enabled)
                    end
                elseif bindData.mode == "Hold" then
                    if bindData.updateSwitch then
                        bindData.updateSwitch(true)
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimActive = false
        currentAimTarget = nil
    end
    
    for _, bindData in ipairs(allBindData) do
        if bindData.mode == "Hold" and bindData.keyCode then
            local keyMatch = false
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyMatch = input.KeyCode == bindData.keyCode
            elseif bindData.keyCode == Enum.UserInputType.MouseButton1 then
                keyMatch = input.UserInputType == Enum.UserInputType.MouseButton1
            elseif bindData.keyCode == Enum.UserInputType.MouseButton2 then
                keyMatch = input.UserInputType == Enum.UserInputType.MouseButton2
            elseif bindData.keyCode == Enum.UserInputType.MouseButton3 then
                keyMatch = input.UserInputType == Enum.UserInputType.MouseButton3
            end
            
            if keyMatch then
                if bindData.updateSwitch then
                    bindData.updateSwitch(false)
                end
            end
        end
    end
end)

-- Improved Aimbot loop with FASTER Auto Speed
if hasMouseMove then
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if not aimActive or not Settings.Aim.AimAssist then return end
            
            local target = findBestAimTarget()
            
            if Settings.Aim.StickyAim and currentAimTarget and currentAimTarget.Parent then
                local humanoid = currentAimTarget.Parent:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    target = currentAimTarget
                else
                    currentAimTarget = nil
                    target = findBestAimTarget()
                end
            else
                currentAimTarget = target
            end
            
            if target then
                local targetPos = calculateAdvancedPrediction(target)
                
                local screenPos, onScreen = worldToScreen(targetPos)
                
                if onScreen then
                    local viewport = Camera.ViewportSize
                    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
                    
                    local smoothness = Settings.Aim.AimSmoothness
                    
                    -- IMPROVED Auto Speed: MUCH FASTER based on distance
                    if Settings.Aim.AimAutoSpeed then
                        local distance = (target.Position - Camera.CFrame.Position).Magnitude
                        local distanceRatio = math.clamp(distance / Settings.Aim.MaxDistance, 0.05, 1)
                        -- Lower values = faster aim, exponential curve for aggressive close-range
                        smoothness = math.pow(distanceRatio, 1.5) * 0.3
                    end
                    
                    local delta = (screenPos - center) * smoothness
                    
                    if mousemoverel then
                        mousemoverel(delta.X, delta.Y)
                    elseif mousemoveabs then
                        local mousePos = UserInputService:GetMouseLocation()
                        mousemoveabs(mousePos.X + delta.X, mousePos.Y + delta.Y)
                    end
                end
            end
        end)
    end)
else
    warn("⚠️ Mouse movement not available - Aim Assist disabled")
end

-- ESP loop
if hasDrawing then
    RunService.RenderStepped:Connect(function()
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESPObjects[player] then
                    create3DBox(player)
                end
            end
            update3DBox()
        end)
    end)
end

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        pcall(function()
            for _, v in pairs(ESPObjects[player]) do
                if typeof(v) == "table" then
                    for _, obj in pairs(v) do
                        obj:Remove()
                    end
                else
                    v:Remove()
                end
            end
        end)
        ESPObjects[player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Misc.Speed then
        enableSpeed()
    end
    if Settings.Misc.Fly then
        enableFly()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -310, 0.5, -260)}):Play()
    wait(0.3)
    MainFrame.Visible = false
end)

-- ============================
-- INITIALIZATION
-- ============================
task.spawn(function()
    wait(0.1)
    for _, child in pairs(TabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            for _, content in pairs(ContentContainer:GetChildren()) do
                content.Visible = false
            end
            
            local content = ContentContainer:FindFirstChild(child.Name:gsub("Tab", "Content"))
            if content then
                content.Visible = true
                child.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
                child.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
            break
        end
    end
    
    if Settings.Config.Watermark then
        CreateWatermark()
    end
    
    if Settings.Config.ShowKeybinds then
        UpdateKeybindsDisplay()
    end
    
    CreateNotification("OFW CLIENT", "Script loaded successfully!", 3)
end)

print("━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ OFW CLIENT ENHANCED LOADED")
print("━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔓 " .. Settings.Config.MenuToggleKey .. " - Open Menu")
print("   Mouse Movement: " .. (hasMouseMove and "✅" or "❌"))
print("   Mouse Click: " .. (hasMouseClick and "✅" or "❌"))
print("   Drawing API: " .. (hasDrawing and "✅" or "❌"))
print("   File System: " .. ((writefile and readfile) and "✅" or "❌"))
print("━━━━━━━━━━━━━━━━━━━━━━━━")
