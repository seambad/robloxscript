-- Position Save & Teleport GUI

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Сохраненная позиция
local savedPosition = nil
local flyEnabled = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PositionTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 260)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
title.BorderSizePixel = 0
title.Text = "Position Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Индикатор сохраненной позиции
local positionLabel = Instance.new("TextLabel")
positionLabel.Size = UDim2.new(1, -40, 0, 30)
positionLabel.Position = UDim2.new(0, 20, 0, 65)
positionLabel.BackgroundTransparency = 1
positionLabel.Text = "Позиция не сохранена"
positionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
positionLabel.TextSize = 14
positionLabel.Font = Enum.Font.Gotham
positionLabel.Parent = mainFrame

-- Кнопка Save Position
local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveButton"
saveBtn.Size = UDim2.new(0, 260, 0, 45)
saveBtn.Position = UDim2.new(0, 20, 0, 105)
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
saveBtn.Text = "Save Position"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.TextSize = 16
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = mainFrame

local saveBtnCorner = Instance.new("UICorner")
saveBtnCorner.CornerRadius = UDim.new(0, 8)
saveBtnCorner.Parent = saveBtn

-- Кнопка Teleport
local teleportBtn = Instance.new("TextButton")
teleportBtn.Name = "TeleportButton"
teleportBtn.Size = UDim2.new(0, 260, 0, 45)
teleportBtn.Position = UDim2.new(0, 20, 0, 160)
teleportBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
teleportBtn.Text = "Teleport"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.TextSize = 16
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.Parent = mainFrame

local teleportBtnCorner = Instance.new("UICorner")
teleportBtnCorner.CornerRadius = UDim.new(0, 8)
teleportBtnCorner.Parent = teleportBtn

-- Кнопка Fly
local flyBtn = Instance.new("TextButton")
flyBtn.Name = "FlyButton"
flyBtn.Size = UDim2.new(0, 260, 0, 45)
flyBtn.Position = UDim2.new(0, 20, 0, 215)
flyBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
flyBtn.Text = "Fly [OFF]"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 16
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Parent = mainFrame

local flyBtnCorner = Instance.new("UICorner")
flyBtnCorner.CornerRadius = UDim.new(0, 8)
flyBtnCorner.Parent = flyBtn

-- Функция сохранения позиции
saveBtn.MouseButton1Click:Connect(function()
    if character and humanoidRootPart then
        savedPosition = humanoidRootPart.CFrame
        local pos = savedPosition.Position
        positionLabel.Text = string.format("Сохранено: X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z)
        positionLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Эффект нажатия кнопки
        saveBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 235)
        wait(0.1)
        saveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        
        print("Позиция сохранена: " .. tostring(savedPosition.Position))
    end
end)

-- Функция телепортации
teleportBtn.MouseButton1Click:Connect(function()
    if savedPosition then
        if character then
            -- Телепортируем на высоту над сохраненной позицией
            local highPosition = savedPosition + Vector3.new(0, 500, 0)
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CFrame = CFrame.new(highPosition.Position)
                    -- Обнуляем скорость перед падением
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
            
            -- Небольшая задержка перед применением скорости
            wait(0.1)
            
            -- Кидаем вниз с огромной скоростью
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, -500, 0)
                end
            end
            
            -- Эффект нажатия кнопки
            teleportBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            wait(0.1)
            teleportBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            
            print("Телепортировано и сброшено вниз!")
        end
    else
        -- Если позиция не сохранена
        positionLabel.Text = "Сначала сохраните позицию!"
        positionLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(1.5)
        positionLabel.Text = "Позиция не сохранена"
        positionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Поддержка при респавне
player.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    flyEnabled = false
    flyBtn.Text = "Fly [OFF]"
    flyBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
end)

-- Функция Fly
local function enableFly()
    if not humanoidRootPart then return end
    
    -- Создаем BodyVelocity и BodyGyro
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = humanoidRootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
    
    -- Управление полетом
    local userInputService = game:GetService("UserInputService")
    
    game:GetService("RunService").Heartbeat:Connect(function()
        if not flyEnabled or not humanoidRootPart or not bodyVelocity then return end
        
        local camera = workspace.CurrentCamera
        local direction = Vector3.new(0, 0, 0)
        
        -- Получаем нажатые клавиши
        if userInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + (camera.CFrame.LookVector * flySpeed)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - (camera.CFrame.LookVector * flySpeed)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - (camera.CFrame.RightVector * flySpeed)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + (camera.CFrame.RightVector * flySpeed)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, flySpeed, 0)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, flySpeed, 0)
        end
        
        bodyVelocity.Velocity = direction
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function disableFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Кнопка Fly
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        flyBtn.Text = "Fly [ON]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
        enableFly()
    else
        flyBtn.Text = "Fly [OFF]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
        disableFly()
    end
end)

print("Position Teleport GUI загружен!")
print("Нажмите 'Save Position' чтобы сохранить текущую позицию")
print("Нажмите 'Teleport' чтобы телепортироваться на сохраненную позицию")
