-- Базовый Client-Sided скрипт для Roblox
-- Этот скрипт выполняется только на стороне клиента

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Функция для уведомлений
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 5;
    })
end

-- Приветствие
notify("Скрипт загружен", "Добро пожаловать, " .. LocalPlayer.Name, 3)

-- Пример 1: Изменение скорости ходьбы
local function setWalkSpeed(speed)
    if Humanoid then
        Humanoid.WalkSpeed = speed
        notify("Скорость изменена", "Новая скорость: " .. speed, 3)
    end
end

-- Пример 2: Изменение высоты прыжка
local function setJumpPower(power)
    if Humanoid then
        Humanoid.JumpPower = power
        notify("Прыжок изменен", "Новая сила прыжка: " .. power, 3)
    end
end

-- Пример 3: Телепортация к позиции
local function teleportTo(x, y, z)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        notify("Телепортация", "Перемещено на позицию", 3)
    end
end

-- Пример 4: Полёт (простая версия)
local flying = false
local flySpeed = 50

local function toggleFly()
    flying = not flying
    
    if flying then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = Character.HumanoidRootPart
        bodyVelocity.Name = "FlyVelocity"
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.Parent = Character.HumanoidRootPart
        bodyGyro.Name = "FlyGyro"
        
        notify("Полёт", "Полёт активирован", 3)
        
        -- Управление полётом
        local UserInputService = game:GetService("UserInputService")
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not flying then
                connection:Disconnect()
                return
            end
            
            local camera = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = direction * flySpeed
            bodyGyro.CFrame = camera.CFrame
        end)
    else
        if Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
            Character.HumanoidRootPart.FlyVelocity:Destroy()
        end
        if Character.HumanoidRootPart:FindFirstChild("FlyGyro") then
            Character.HumanoidRootPart.FlyGyro:Destroy()
        end
        notify("Полёт", "Полёт деактивирован", 3)
    end
end

-- Пример 5: ESP (подсветка игроков)
local function toggleESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if highlight then
                highlight:Destroy()
            else
                local newHighlight = Instance.new("Highlight")
                newHighlight.Name = "ESPHighlight"
                newHighlight.Adornee = player.Character
                newHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                newHighlight.FillTransparency = 0.5
                newHighlight.Parent = player.Character
            end
        end
    end
end

-- Биндинг клавиш (примеры)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F - переключить полёт
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
    
    -- E - переключить ESP
    if input.KeyCode == Enum.KeyCode.E then
        toggleESP()
    end
    
    -- R - сброс персонажа
    if input.KeyCode == Enum.KeyCode.R then
        LocalPlayer.Character:BreakJoints()
    end
    
    -- T - телепорт на заданные координаты
    if input.KeyCode == Enum.KeyCode.T then
        quickTeleport()
    end
end)

-- Телепортация на указанные координаты
local targetX = -2032.1
local targetY = 541.2
local targetZ = -1626.6

-- Функция быстрой телепортации на клавишу
local function quickTeleport()
    teleportTo(targetX, targetY, targetZ)
end

-- Примеры использования функций:
-- setWalkSpeed(100) -- Установить скорость ходьбы на 100
-- setJumpPower(100) -- Установить силу прыжка на 100
-- teleportTo(0, 50, 0) -- Телепортироваться на координаты (0, 50, 0)

print("Client-sided скрипт успешно загружен!")
print("Клавиши управления:")
print("F - Переключить полёт")
print("E - Переключить ESP")
print("R - Сброс персонажа")
print("T - Телепорт на координаты (-2032.1, 541.2, -1626.6)")
