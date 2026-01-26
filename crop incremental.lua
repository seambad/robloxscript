
-- FIELD TELEPORT GUI WITH AUTOFARM & AUTO SELL
-- executor | client sided
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== ЖДЁМ FIELDS =====
local Fields = workspace:WaitForChild("Fields", 10)
if not Fields then
    warn("❌ Fields not found")
    return
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "FieldTeleportGUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3, 0.6)
frame.Position = UDim2.fromScale(0.05, 0.25)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🐝 Field Teleport"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- ===== CONTROL PANEL =====
local controlPanel = Instance.new("Frame", frame)
controlPanel.Size = UDim2.new(1, 0, 0, 175)
controlPanel.Position = UDim2.new(0, 0, 0, 45)
controlPanel.BackgroundColor3 = Color3.fromRGB(20,20,20)
controlPanel.BorderSizePixel = 0

-- Teleport Button
local btnTeleport = Instance.new("TextButton", controlPanel)
btnTeleport.Size = UDim2.new(0.65, -6, 0, 35)
btnTeleport.Position = UDim2.new(0, 8, 0, 8)
btnTeleport.Text = "📍 Teleport to Selected"
btnTeleport.BackgroundColor3 = Color3.fromRGB(50,100,200)
btnTeleport.TextColor3 = Color3.new(1,1,1)
btnTeleport.Font = Enum.Font.GothamBold
btnTeleport.TextSize = 14
Instance.new("UICorner", btnTeleport).CornerRadius = UDim.new(0, 8)

-- Player Info Button
local btnPlayerInfo = Instance.new("TextButton", controlPanel)
btnPlayerInfo.Size = UDim2.new(0.35, -6, 0, 35)
btnPlayerInfo.Position = UDim2.new(0.65, 2, 0, 8)
btnPlayerInfo.Text = "👤 Player Info"
btnPlayerInfo.BackgroundColor3 = Color3.fromRGB(200,100,50)
btnPlayerInfo.TextColor3 = Color3.new(1,1,1)
btnPlayerInfo.Font = Enum.Font.GothamBold
btnPlayerInfo.TextSize = 13
Instance.new("UICorner", btnPlayerInfo).CornerRadius = UDim.new(0, 8)

-- AutoFarm Toggle
local autoFarmEnabled = false
local btnAutoFarm = Instance.new("TextButton", controlPanel)
btnAutoFarm.Size = UDim2.new(1, -16, 0, 35)
btnAutoFarm.Position = UDim2.new(0, 8, 0, 50)
btnAutoFarm.Text = "⛏️ Auto Farm: OFF"
btnAutoFarm.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnAutoFarm.TextColor3 = Color3.new(1,1,1)
btnAutoFarm.Font = Enum.Font.GothamBold
btnAutoFarm.TextSize = 14
Instance.new("UICorner", btnAutoFarm).CornerRadius = UDim.new(0, 8)

-- Auto Collect Toggle
local autoCollectEnabled = false
local btnAutoCollect = Instance.new("TextButton", controlPanel)
btnAutoCollect.Size = UDim2.new(0.48, -8, 0, 35)
btnAutoCollect.Position = UDim2.new(0, 8, 0, 92)
btnAutoCollect.Text = "🌟 Collect: OFF"
btnAutoCollect.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnAutoCollect.TextColor3 = Color3.new(1,1,1)
btnAutoCollect.Font = Enum.Font.GothamBold
btnAutoCollect.TextSize = 13
Instance.new("UICorner", btnAutoCollect).CornerRadius = UDim.new(0, 8)

-- Auto Sell Toggle
local autoSellEnabled = false
local btnAutoSell = Instance.new("TextButton", controlPanel)
btnAutoSell.Size = UDim2.new(0.48, -8, 0, 35)
btnAutoSell.Position = UDim2.new(0.52, 0, 0, 92)
btnAutoSell.Text = "💰 Auto Sell: OFF"
btnAutoSell.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnAutoSell.TextColor3 = Color3.new(1,1,1)
btnAutoSell.Font = Enum.Font.GothamBold
btnAutoSell.TextSize = 13
Instance.new("UICorner", btnAutoSell).CornerRadius = UDim.new(0, 8)

-- Anti AFK Toggle
local antiAFKEnabled = false
local btnAntiAFK = Instance.new("TextButton", controlPanel)
btnAntiAFK.Size = UDim2.new(1, -16, 0, 35)
btnAntiAFK.Position = UDim2.new(0, 8, 0, 134)
btnAntiAFK.Text = "💤 Anti-AFK: OFF"
btnAntiAFK.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnAntiAFK.TextColor3 = Color3.new(1,1,1)
btnAntiAFK.Font = Enum.Font.GothamBold
btnAntiAFK.TextSize = 13
Instance.new("UICorner", btnAntiAFK).CornerRadius = UDim.new(0, 8)

local list = Instance.new("ScrollingFrame", frame)
list.Position = UDim2.new(0, 0, 0, 225)
list.Size = UDim2.new(1, 0, 1, -230)
list.BackgroundTransparency = 1
list.ScrollBarImageTransparency = 0.4
list.CanvasSize = UDim2.new()
list.ScrollingDirection = Enum.ScrollingDirection.Y

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 8)

-- ===== SELECTED FIELD =====
local selectedField = nil

-- ===== TELEPORT =====
local function teleportTo(part)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetCFrame = part.CFrame + Vector3.new(0, part.Size.Y/2 + 5, 0)
    hrp.CFrame = targetCFrame
    
    print("✅ Teleported to:", part.Name)
end

-- ===== BUTTON =====
local function createButton(part)
    local btn = Instance.new("TextButton", list)
    btn.Size = UDim2.new(1, -16, 0, 38)
    
    local displayName = part.Name:gsub(" Part$", "")
    btn.Text = "🌸 " .. displayName
    btn.Name = part.Name
    
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseEnter:Connect(function()
        if selectedField ~= part then
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        end
    end)
    btn.MouseLeave:Connect(function()
        if selectedField == part then
            btn.BackgroundColor3 = Color3.fromRGB(70,150,70)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        if selectedField then
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") and child.Name == selectedField.Name then
                    child.BackgroundColor3 = Color3.fromRGB(40,40,40)
                end
            end
        end
        
        selectedField = part
        btn.BackgroundColor3 = Color3.fromRGB(70,150,70)
        print("✅ Selected field:", displayName)
    end)
end

-- ===== LOAD FIELDS =====
for _, field in ipairs(Fields:GetChildren()) do
    if field:IsA("BasePart") then
        createButton(field)
    end
end

task.wait()
list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)

-- ===== AUTO FARM LOGIC =====
local autoFarmConnection = nil
local lastFarmClick = 0
local lastTeleportTime = 0
local teleportIndex = 1
local farmTeleportPositions = {}
local isMovingToToken = false
local toolRange = 10
local toolCooldown = 0.15

local function getToolInfo()
    local char = player.Character
    if not char then return nil end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    local info = {
        name = tool.Name,
        range = 10,
        cooldown = 0.15
    }
    
    local handle = tool:FindFirstChild("Handle")
    if handle then
        local size = handle.Size
        info.range = math.max(size.X, size.Y, size.Z) * 2
    end
    
    local toolName = tool.Name:lower()
    if toolName:find("scoop") then
        info.range = 8
        info.cooldown = 0.2
    elseif toolName:find("rake") then
        info.range = 12
        info.cooldown = 0.25
    elseif toolName:find("lollipop") or toolName:find("lolipop") then
        info.range = 6
        info.cooldown = 0.15
    elseif toolName:find("magnet") then
        info.range = 15
        info.cooldown = 0.3
    elseif toolName:find("spark") then
        info.range = 20
        info.cooldown = 0.4
    end
    
    print("🔧 Tool detected:", info.name)
    print("📏 Collection range:", info.range, "studs")
    print("⏱️ Cooldown:", info.cooldown, "seconds")
    
    return info
end

local function generateOptimalTeleportGrid(centerCFrame, size, collectionRange)
    local positions = {}
    local centerPos = centerCFrame.Position
    local height = size.Y / 2 + 5
    
    -- Вычисляем оптимальное покрытие на основе радиуса сбора
    local effectiveRange = collectionRange * 0.9 -- Небольшое перекрытие для надёжности
    
    -- Определяем сколько точек нужно по X и Z
    local numPointsX = math.ceil(size.X / (effectiveRange * 2))
    local numPointsZ = math.ceil(size.Z / (effectiveRange * 2))
    
    -- Минимум 2x2, максимум 8x8 для производительности
    numPointsX = math.max(2, math.min(8, numPointsX))
    numPointsZ = math.max(2, math.min(8, numPointsZ))
    
    print("📊 Teleport Grid Calculation:")
    print("  • Field size:", math.floor(size.X), "x", math.floor(size.Z))
    print("  • Tool range:", math.floor(collectionRange), "studs")
    print("  • Grid size:", numPointsX, "x", numPointsZ, "=", numPointsX * numPointsZ, "positions")
    
    local stepX = size.X / (numPointsX + 1)
    local stepZ = size.Z / (numPointsZ + 1)
    
    -- Генерируем сетку телепортов
    for ix = 1, numPointsX do
        for iz = 1, numPointsZ do
            local offsetX = -size.X/2 + ix * stepX
            local offsetZ = -size.Z/2 + iz * stepZ
            
            local worldPos = centerCFrame * CFrame.new(offsetX, height, offsetZ)
            local finalPos = worldPos.Position
            
            -- Поворачиваем к центру поля
            local lookAtCenter = CFrame.new(finalPos, centerPos + Vector3.new(0, height, 0))
            table.insert(positions, lookAtCenter)
        end
    end
    
    print("  • Total teleport points:", #positions)
    print("  • Coverage efficiency: ~" .. math.floor((#positions * math.pi * collectionRange^2) / (size.X * size.Z) * 100) .. "%")
    print("  • Teleport interval:", math.floor(toolCooldown * 3 * 10) / 10, "seconds")
    
    return positions
end

local function startAutoFarm()
    if autoFarmConnection then return end
    
    local toolInfo = getToolInfo()
    if toolInfo then
        toolRange = toolInfo.range
        toolCooldown = toolInfo.cooldown
    else
        print("⚠️ No tool equipped, using default range:", toolRange)
        toolCooldown = 0.15
    end
    
    if selectedField then
        farmTeleportPositions = generateOptimalTeleportGrid(
            selectedField.CFrame, 
            selectedField.Size, 
            toolRange
        )
        print("✅ Auto Farm started - Optimized teleport grid")
        print("⏱️ Teleporting every", math.floor(toolCooldown * 3 * 10) / 10, "seconds based on tool cooldown")
    end
    
    teleportIndex = 1
    lastTeleportTime = 0
    
    autoFarmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled or not selectedField then return end
        
        local currentTime = tick()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if not hrp then return end
        
        local hasNearbyToken = false
        if autoCollectEnabled then
            local Tokens = workspace:FindFirstChild("Tokens")
            if Tokens then
                for _, token in ipairs(Tokens:GetChildren()) do
                    if token:IsA("BasePart") or (token:IsA("Model") and token.PrimaryPart) then
                        local tokenPos = token:IsA("BasePart") and token.Position or token.PrimaryPart.Position
                        local dist = (hrp.Position - tokenPos).Magnitude
                        
                        if dist < 70 then
                            hasNearbyToken = true
                            break
                        end
                    end
                end
            end
        end
        
        -- Телепорт по кулдауну инструмента (вместо фиксированных 1.5 сек)
        if not hasNearbyToken and not isMovingToToken and currentTime - lastTeleportTime >= toolCooldown * 3 then
            lastTeleportTime = currentTime
            
            if #farmTeleportPositions > 0 then
                hrp.CFrame = farmTeleportPositions[teleportIndex]
                
                teleportIndex = teleportIndex + 1
                if teleportIndex > #farmTeleportPositions then
                    teleportIndex = 1
                    print("🔄 Completed field cycle, restarting...")
                end
            end
        end
        
        -- Активация инструмента
        if currentTime - lastFarmClick >= toolCooldown then
            lastFarmClick = currentTime
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end)
end

local function stopAutoFarm()
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
    print("❌ Auto Farm stopped")
end

-- ===== BUTTON ACTIONS =====
btnTeleport.MouseButton1Click:Connect(function()
    if selectedField then
        teleportTo(selectedField)
    else
        warn("⚠️ No field selected!")
    end
end)

btnPlayerInfo.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then
        warn("⚠️ Character not found!")
        return
    end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    
    print("========== PLAYER INFO ==========")
    print("👤 Username:", player.Name)
    print("🎮 Display Name:", player.DisplayName)
    print("🆔 UserId:", player.UserId)
    
    if humanoid then
        print("❤️ Health:", math.floor(humanoid.Health), "/", math.floor(humanoid.MaxHealth))
        print("🏃 WalkSpeed:", humanoid.WalkSpeed)
        print("⚡ JumpPower:", humanoid.JumpPower)
    end
    
    if hrp then
        local pos = hrp.Position
        print("📍 Position: X:", math.floor(pos.X), "Y:", math.floor(pos.Y), "Z:", math.floor(pos.Z))
    end
    
    if tool then
        print("🔧 Current Tool:", tool.Name)
        local toolInfo = getToolInfo()
        if toolInfo then
            print("📏 Tool Stats: Range:", toolInfo.range, "Cooldown:", toolInfo.cooldown)
        end
    else
        print("🔧 Current Tool: None")
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tools = backpack:GetChildren()
        if #tools > 0 then
            print("🎒 Tools in Backpack:")
            for _, t in ipairs(tools) do
                if t:IsA("Tool") then
                    print("  • " .. t.Name)
                end
            end
        end
    end
    
    print("=================================")
    
    btnPlayerInfo.BackgroundColor3 = Color3.fromRGB(250,150,100)
    task.wait(0.2)
    btnPlayerInfo.BackgroundColor3 = Color3.fromRGB(200,100,50)
end)

btnAutoFarm.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    
    if autoFarmEnabled then
        if not selectedField then
            autoFarmEnabled = false
            warn("⚠️ Select a field first!")
            return
        end
        
        btnAutoFarm.Text = "⛏️ Auto Farm: ON"
        btnAutoFarm.BackgroundColor3 = Color3.fromRGB(70,170,70)
        
        task.spawn(function()
            teleportTo(selectedField)
            task.wait(0.3)
            startAutoFarm()
        end)
    else
        btnAutoFarm.Text = "⛏️ Auto Farm: OFF"
        btnAutoFarm.BackgroundColor3 = Color3.fromRGB(60,60,60)
        stopAutoFarm()
    end
end)

-- ===== AUTO SELL =====
local autoSellConnection = nil
local lastSellTime = 0

local function clickSellButton()
    local playerGui = player:WaitForChild("PlayerGui")
    local sellFrame = playerGui:FindFirstChild("Sell")
    
    if not sellFrame then
        warn("❌ Sell Frame not found")
        return false
    end
    
    local sellButton = sellFrame:FindFirstChild("Sell", true)
    if sellButton then
        sellButton = sellButton:FindFirstChild("Sell-Local")
    end
    
    if not sellButton then
        sellButton = sellFrame:FindFirstChild("Sell-Local", true)
    end
    
    if sellButton and sellButton:IsA("TextButton") then
        local success = pcall(function()
            firesignal(sellButton.MouseButton1Click)
        end)
        
        if not success then
            local vim = game:GetService("VirtualInputManager")
            local pos = sellButton.AbsolutePosition
            local size = sellButton.AbsoluteSize
            vim:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
            task.wait(0.05)
            vim:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
        end
        
        print("💰 Sold items!")
        return true
    else
        warn("❌ Sell-Local button not found")
        return false
    end
end

local function startAutoSell()
    if autoSellConnection then return end
    
    autoSellConnection = RunService.Heartbeat:Connect(function()
        if not autoSellEnabled then return end
        
        local currentTime = tick()
        if currentTime - lastSellTime >= 5 then
            lastSellTime = currentTime
            clickSellButton()
        end
    end)
    
    print("✅ Auto Sell started")
end

local function stopAutoSell()
    if autoSellConnection then
        autoSellConnection:Disconnect()
        autoSellConnection = nil
    end
    print("❌ Auto Sell stopped")
end

btnAutoSell.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    
    if autoSellEnabled then
        btnAutoSell.Text = "💰 Auto Sell: ON"
        btnAutoSell.BackgroundColor3 = Color3.fromRGB(70,170,70)
        startAutoSell()
    else
        btnAutoSell.Text = "💰 Auto Sell: OFF"
        btnAutoSell.BackgroundColor3 = Color3.fromRGB(60,60,60)
        stopAutoSell()
    end
end)

-- ===== ANTI AFK =====
local antiAFKConnection = nil
local lastAFKAction = 0

local function startAntiAFK()
    if antiAFKConnection then return end
    
    antiAFKConnection = RunService.Heartbeat:Connect(function()
        if not antiAFKEnabled then return end
        
        local currentTime = tick()
        
        if currentTime - lastAFKAction >= 30 then
            lastAFKAction = currentTime
            
            local char = player.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            
            if humanoid then
                humanoid.Jump = true
                print("💤 Anti-AFK: Jump")
            end
        end
    end)
    
    print("✅ Anti-AFK started")
end

local function stopAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    print("❌ Anti-AFK stopped")
end

btnAntiAFK.MouseButton1Click:Connect(function()
    antiAFKEnabled = not antiAFKEnabled
    
    if antiAFKEnabled then
        btnAntiAFK.Text = "💤 Anti-AFK: ON"
        btnAntiAFK.BackgroundColor3 = Color3.fromRGB(70,170,70)
        lastAFKAction = tick()
        startAntiAFK()
    else
        btnAntiAFK.Text = "💤 Anti-AFK: OFF"
        btnAntiAFK.BackgroundColor3 = Color3.fromRGB(60,60,60)
        stopAntiAFK()
    end
end)

-- ===== AUTO COLLECT TOKENS =====
local autoCollectConnection = nil
local Tokens = workspace:WaitForChild("Tokens", 10)
local lastTokenMoveTime = 0

local function moveToToken()
    if not Tokens then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    humanoid.WalkSpeed = 55
    
    local nearestToken = nil
    local nearestDist = 70
    
    for _, token in ipairs(Tokens:GetChildren()) do
        if token:IsA("BasePart") or (token:IsA("Model") and token.PrimaryPart) then
            local tokenPos = token:IsA("BasePart") and token.Position or token.PrimaryPart.Position
            local dist = (hrp.Position - tokenPos).Magnitude
            
            if dist < nearestDist and dist > 2 then
                nearestDist = dist
                nearestToken = token
            end
        end
    end
    
    if nearestToken then
        isMovingToToken = true
        lastTokenMoveTime = tick()
        local targetPos = nearestToken:IsA("BasePart") and nearestToken.Position or nearestToken.PrimaryPart.Position
        
        humanoid:MoveTo(targetPos)
        
        task.delay(0.5, function()
            isMovingToToken = false
        end)
    else
        if tick() - lastTokenMoveTime > 1 then
            isMovingToToken = false
        end
    end
end

local function startAutoCollect()
    if autoCollectConnection then return end
    lastTokenMoveTime = tick()
    
    autoCollectConnection = RunService.Heartbeat:Connect(function()
        if not autoCollectEnabled then return end
        
        task.wait(0.15)
        moveToToken()
    end)
    
    print("✅ Auto Collect started - Speed 55 mode")
end

local function stopAutoCollect()
    if autoCollectConnection then
        autoCollectConnection:Disconnect()
        autoCollectConnection = nil
    end
    print("❌ Auto Collect stopped")
end

btnAutoCollect.MouseButton1Click:Connect(function()
    autoCollectEnabled = not autoCollectEnabled
    
    if autoCollectEnabled then
        btnAutoCollect.Text = "🌟 Collect: ON"
        btnAutoCollect.BackgroundColor3 = Color3.fromRGB(70,170,70)
        print("💡 Auto Collect: Speed 55 walking mode")
        startAutoCollect()
    else
        btnAutoCollect.Text = "🌟 Collect: OFF"
        btnAutoCollect.BackgroundColor3 = Color3.fromRGB(60,60,60)
        stopAutoCollect()
    end
end)

-- ===== TOGGLE GUI =====
local visible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        visible = not visible
        frame.Visible = visible
    end
end)

print("✅ Fields loaded:", #Fields:GetChildren())
print("🎮 Press Right Shift to toggle GUI")
