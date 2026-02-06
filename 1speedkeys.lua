-- Autofarm GUI для Roblox

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Координаты для телепортации
local farmPosition = Vector3.new(2035.0, 542.5, -1627.0)
local autofarmEnabled = false
local autofarmLoop = nil
local farmCount = 0

-- ===============================
-- АНТИ-AFK СИСТЕМА
-- ===============================
local VirtualUser = game:GetService("VirtualUser")

-- Отключаем стандартный AFK кик
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Дополнительная защита от AFK
spawn(function()
    while wait(300) do -- Каждые 5 минут
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

print("✅ Анти-AFK активирован!")
-- ===============================

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutofarmGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 240)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
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
title.Text = "Autofarm GUI"
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
    autofarmEnabled = false
    screenGui:Destroy()
end)

-- Индикатор статуса
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 65)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Автофарм выключен"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Счетчик фарма
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -40, 0, 25)
countLabel.Position = UDim2.new(0, 20, 0, 95)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Телепортаций: 0 | Получено: 0"
countLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
countLabel.TextSize = 12
countLabel.Font = Enum.Font.Gotham
countLabel.Parent = mainFrame

-- Отображение координат
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, -40, 0, 25)
coordsLabel.Position = UDim2.new(0, 20, 0, 120)
coordsLabel.BackgroundTransparency = 1
coordsLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z)
coordsLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
coordsLabel.TextSize = 11
coordsLabel.Font = Enum.Font.GothamMedium
coordsLabel.Parent = mainFrame

-- Кнопка Autofarm
local autofarmBtn = Instance.new("TextButton")
autofarmBtn.Name = "AutofarmButton"
autofarmBtn.Size = UDim2.new(0, 260, 0, 50)
autofarmBtn.Position = UDim2.new(0, 20, 0, 155)
autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
autofarmBtn.Text = "Autofarm [OFF]"
autofarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autofarmBtn.TextSize = 16
autofarmBtn.Font = Enum.Font.GothamBold
autofarmBtn.Parent = mainFrame

local autofarmBtnCorner = Instance.new("UICorner")
autofarmBtnCorner.CornerRadius = UDim.new(0, 8)
autofarmBtnCorner.Parent = autofarmBtn

-- Кнопка сброса счетчика
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetButton"
resetBtn.Size = UDim2.new(0, 60, 0, 25)
resetBtn.Position = UDim2.new(1, -80, 0, 215)
resetBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
resetBtn.Text = "Сброс"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Parent = mainFrame

local resetBtnCorner = Instance.new("UICorner")
resetBtnCorner.CornerRadius = UDim.new(0, 6)
resetBtnCorner.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    farmCount = 0
    countLabel.Text = "Телепортаций: 0 | Получено: 0"
end)

-- Функция телепортации
local function teleportToFarm()
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(farmPosition)
        
        -- Обнуляем скорость
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- Функция автофарма
local function startAutofarm()
    spawn(function()
        while autofarmEnabled do
            wait(2.3) -- Задержка 0.5 секунды
            
            if autofarmEnabled then
                teleportToFarm()
                farmCount = farmCount + 1
                countLabel.Text = string.format("Телепортаций: %d | Получено: %d", farmCount, farmCount * 3000)
            end
        end
    end)
end

-- Кнопка Autofarm
autofarmBtn.MouseButton1Click:Connect(function()
    autofarmEnabled = not autofarmEnabled
    
    if autofarmEnabled then
        autofarmBtn.Text = "Autofarm [ON]"
        autofarmBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        statusLabel.Text = "⚡ Автофарм активен!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        startAutofarm()
        print("Автофарм включен!")
    else
        autofarmBtn.Text = "Autofarm [OFF]"
        autofarmBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        statusLabel.Text = "Автофарм выключен"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        print("Автофарм выключен!")
    end
end)

-- Поддержка при респавне
player.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    -- Автоматически возобновляем автофарм если он был включен
    if autofarmEnabled then
        wait(1)
        startAutofarm()
    end
end)
