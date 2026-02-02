-- Улучшенный Client-Sided скрипт для Roblox с GUI
-- Исправлена ошибка с nil значениями

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Безопасное ожидание персонажа
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Переменные
local autoFarmEnabled = false
local teleportCount = 0
local startTime = tick()

-- Координаты для телепортации
local farmCoords = Vector3.new(-2032.1, 541.2, -1626.6)

-- Функция уведомлений
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 3;
        })
    end)
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Защита от удаления
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = game.CoreGui
end

-- Статистика (верхняя панель)
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.new(0, 400, 0, 80)
StatsFrame.Position = UDim2.new(0.5, -200, 0, 10)
StatsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = ScreenGui

-- Скругление углов статистики
local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 12)
StatsCorner.Parent = StatsFrame

-- Градиент фона статистики
local StatsGradient = Instance.new("UIGradient")
StatsGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
}
StatsGradient.Rotation = 90
StatsGradient.Parent = StatsFrame

-- Обводка статистики
local StatsStroke = Instance.new("UIStroke")
StatsStroke.Color = Color3.fromRGB(100, 150, 255)
StatsStroke.Thickness = 2
StatsStroke.Transparency = 0.5
StatsStroke.Parent = StatsFrame

-- Заголовок статистики
local StatsTitle = Instance.new("TextLabel")
StatsTitle.Name = "Title"
StatsTitle.Size = UDim2.new(1, -20, 0, 25)
StatsTitle.Position = UDim2.new(0, 10, 0, 5)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Font = Enum.Font.GothamBold
StatsTitle.Text = "📊 СТАТИСТИКА"
StatsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsTitle.TextSize = 16
StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
StatsTitle.Parent = StatsFrame

-- Текст статистики
local StatsText = Instance.new("TextLabel")
StatsText.Name = "StatsText"
StatsText.Size = UDim2.new(1, -20, 0, 45)
StatsText.Position = UDim2.new(0, 10, 0, 30)
StatsText.BackgroundTransparency = 1
StatsText.Font = Enum.Font.Gotham
StatsText.Text = "Телепортов: 0 | Время работы: 0с | Статус: Ожидание"
StatsText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsText.TextSize = 13
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.TextYAlignment = Enum.TextYAlignment.Top
StatsText.TextWrapped = true
StatsText.Parent = StatsFrame

-- Основной фрейм GUI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление углов
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Градиент фона
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Обводка
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 150, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0.3
Stroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Информация о координатах
local CoordInfo = Instance.new("TextLabel")
CoordInfo.Name = "CoordInfo"
CoordInfo.Size = UDim2.new(1, -40, 0, 30)
CoordInfo.Position = UDim2.new(0, 20, 0, 55)
CoordInfo.BackgroundTransparency = 1
CoordInfo.Font = Enum.Font.Gotham
CoordInfo.Text = "📍 Координаты: " .. tostring(farmCoords)
CoordInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
CoordInfo.TextSize = 12
CoordInfo.TextXAlignment = Enum.TextXAlignment.Left
CoordInfo.TextWrapped = true
CoordInfo.Parent = MainFrame

-- Кнопка AutoFarm
local AutoFarmButton = Instance.new("TextButton")
AutoFarmButton.Name = "AutoFarmButton"
AutoFarmButton.Size = UDim2.new(1, -40, 0, 50)
AutoFarmButton.Position = UDim2.new(0, 20, 0, 95)
AutoFarmButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
AutoFarmButton.BorderSizePixel = 0
AutoFarmButton.Font = Enum.Font.GothamBold
AutoFarmButton.Text = "▶ ЗАПУСТИТЬ AUTO FARM"
AutoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmButton.TextSize = 16
AutoFarmButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = AutoFarmButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(70, 200, 70)
ButtonStroke.Thickness = 2
ButtonStroke.Transparency = 0.5
ButtonStroke.Parent = AutoFarmButton

-- Кнопка телепорта (один раз)
local TeleportButton = Instance.new("TextButton")
TeleportButton.Name = "TeleportButton"
TeleportButton.Size = UDim2.new(1, -40, 0, 40)
TeleportButton.Position = UDim2.new(0, 20, 0, 155)
TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
TeleportButton.BorderSizePixel = 0
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.Text = "📍 Телепорт (1 раз)"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextSize = 14
TeleportButton.Parent = MainFrame

local TeleportCorner = Instance.new("UICorner")
TeleportCorner.CornerRadius = UDim.new(0, 10)
TeleportCorner.Parent = TeleportButton

-- Функция безопасной телепортации
local function safeTeleport(position)
    local success = pcall(function()
        local rootPart = getRootPart()
        if rootPart then
            rootPart.CFrame = CFrame.new(position)
            teleportCount = teleportCount + 1
            return true
        end
    end)
    return success
end

-- Функция обновления статистики
local function updateStats()
    local elapsedTime = math.floor(tick() - startTime)
    local status = autoFarmEnabled and "🟢 Активен" or "⚪ Остановлен"
    StatsText.Text = string.format("Телепортов: %d | Время: %dс | Статус: %s", 
        teleportCount, elapsedTime, status)
end

-- Автофарм логика
local autoFarmConnection
local function startAutoFarm()
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
    end
    
    autoFarmConnection = RunService.Heartbeat:Connect(function()
        if autoFarmEnabled then
            wait(0.5) -- Задержка между телепортами
            safeTeleport(farmCoords)
        end
    end)
end

-- Обработчик кнопки AutoFarm
AutoFarmButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    
    if autoFarmEnabled then
        AutoFarmButton.Text = "⏸ ОСТАНОВИТЬ AUTO FARM"
        AutoFarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ButtonStroke.Color = Color3.fromRGB(255, 70, 70)
        notify("Auto Farm", "Автофарм запущен!", 3)
        startAutoFarm()
    else
        AutoFarmButton.Text = "▶ ЗАПУСТИТЬ AUTO FARM"
        AutoFarmButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        ButtonStroke.Color = Color3.fromRGB(70, 200, 70)
        notify("Auto Farm", "Автофарм остановлен!", 3)
    end
end)

-- Обработчик кнопки одиночного телепорта
TeleportButton.MouseButton1Click:Connect(function()
    if safeTeleport(farmCoords) then
        notify("Телепорт", "Успешно телепортирован!", 2)
    else
        notify("Ошибка", "Не удалось телепортироваться", 3)
    end
end)

-- Обработчик кнопки закрытия
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Анимация при наведении на кнопки
local function addHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

addHoverEffect(AutoFarmButton, Color3.fromRGB(50, 150, 50), Color3.fromRGB(60, 180, 60))
addHoverEffect(TeleportButton, Color3.fromRGB(100, 100, 255), Color3.fromRGB(120, 120, 255))
addHoverEffect(CloseButton, Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 80, 80))

-- Перетаскивание GUI
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Обновление статистики каждую секунду
RunService.Heartbeat:Connect(function()
    wait(1)
    updateStats()
end)

-- Защита при респавне персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    if autoFarmEnabled then
        startAutoFarm()
    end
end)

-- Клавиша для показа/скрытия GUI (Insert)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Приветственное сообщение
notify("Auto Farm GUI", "Загружено! Нажмите Insert для открытия меню", 5)

print("========================================")
print("Auto Farm GUI успешно загружен!")
print("Нажмите INSERT для открытия/закрытия меню")
print("Координаты телепорта:", farmCoords)
print("========================================")
