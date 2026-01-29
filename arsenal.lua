-- Roblox Advanced Executor GUI v2 - ИСПРАВЛЕННАЯ ВЕРСИЯ
-- Серая цветовая схема

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Воспроизведение звука при запуске
local Sound = Instance.new("Sound")
Sound.SoundId = "rbxassetid://4590662766"
Sound.Volume = 0.5
Sound.Parent = game:GetService("SoundService")
Sound:Play()
game:GetService("Debris"):AddItem(Sound, 5)

-- Конфигурация (в памяти)
local Config = {
    Aim = {
        Enabled = false,
        Bind = Enum.KeyCode.Unknown,
        BindMode = "Toggle",
        ActivateOnRMB = true,
        FOV = 100,
        Speed = 5,
        Smoothness = 0.5,
        Prediction = 0.12,
        TeamCheck = true,
        VisibleCheck = true,
        AliveCheck = true,
        TargetMode = "Nearest to Crosshair",
        StickToTarget = true,
        TriggerBot = false,
        TriggerBotBind = Enum.KeyCode.Unknown,
        TriggerBotBindMode = "Toggle",
        TriggerDelay = 100,
        SpeedEnabled = false,
        SpeedValue = 16,
        FlyEnabled = false,
        FlySpeed = 50,
        HighJumpEnabled = false,
        JumpPower = 50,
        NoclipEnabled = false
    },
    ESP = {
        ["3D"] = false,
        ["3DBind"] = Enum.KeyCode.Unknown,
        ["3DBindMode"] = "Toggle",
        Box = false,
        BoxBind = Enum.KeyCode.Unknown,
        BoxBindMode = "Toggle",
        Skeleton = false,
        SkeletonBind = Enum.KeyCode.Unknown,
        SkeletonBindMode = "Toggle",
        Sound = false,
        SoundBind = Enum.KeyCode.Unknown,
        SoundBindMode = "Toggle",
        ESPColor = Color3.fromRGB(150, 150, 150),
        TeamCheck = true
    },
    Visuals = {
        FOVCircle = true,
        FOVCircleBind = Enum.KeyCode.Unknown,
        FOVCircleBindMode = "Toggle",
        FOVColor = Color3.fromRGB(150, 150, 150)
    },
    Settings = {
        ToggleKey = Enum.KeyCode.RightShift,
        UIColor = Color3.fromRGB(150, 150, 150)
    }
}

-- Сохранённые конфиги
local SavedConfigs = {}

-- Создание главного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Защита от удаления
if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 520)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Закругленные углы
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Граница
local BorderGlow = Instance.new("UIStroke")
BorderGlow.Color = Color3.fromRGB(80, 80, 90)
BorderGlow.Thickness = 1
BorderGlow.Parent = MainFrame

-- Шапка
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 12)
HeaderFix.Position = UDim2.new(0, 0, 1, -12)
HeaderFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "OFW CLIENT"
Title.TextColor3 = Color3.fromRGB(180, 180, 190)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Панель навигации (вкладки)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 120, 1, -70)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

-- Функция создания кнопки вкладки
local currentTab = nil
local function createTab(name, icon, yPos)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 42)
    tabButton.Position = UDim2.new(0, 5, 0, yPos)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tabButton.BorderSizePixel = 0
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Text = icon .. " " .. name
    tabButton.TextColor3 = Color3.fromRGB(120, 120, 130)
    tabButton.TextSize = 12
    tabButton.Parent = TabBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabButton
    
    return tabButton
end

local AimTab = createTab("Aim", "🎯", 5)
local ESPTab = createTab("ESP", "👁", 52)
local VisualsTab = createTab("Visuals", "✨", 99)
local MiscTab = createTab("Misc", "⚙", 146)
local SettingsTab = createTab("Settings", "⚡", 193)

-- ===================== AIM ВКЛАДКА =====================
local AimContainer = Instance.new("ScrollingFrame")
AimContainer.Name = "AimContainer"
AimContainer.Size = UDim2.new(1, -150, 1, -70)
AimContainer.Position = UDim2.new(0, 130, 0, 55)
AimContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
AimContainer.BorderSizePixel = 0
AimContainer.Visible = false
AimContainer.ScrollBarThickness = 4
AimContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
AimContainer.CanvasSize = UDim2.new(0, 0, 0, 630)
AimContainer.Parent = MainFrame

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 10)
AimCorner.Parent = AimContainer

-- Переменная для отслеживания биндов
local waitingForBind = nil

-- Функция создания секции
local function createSection(parent, title, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 28)
    section.Position = UDim2.new(0, 10, 0, yPos)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = title
    label.TextColor3 = Color3.fromRGB(160, 160, 170)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -3)
    line.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    line.BorderSizePixel = 0
    line.Parent = section
    
    return section
end

-- Функция создания чекбокса с биндом
local function createCheckbox(parent, text, yPos, configTable, configPath, bindPath, bindModePath)
    local checkbox = Instance.new("Frame")
    checkbox.Size = UDim2.new(1, -20, 0, 32)
    checkbox.Position = UDim2.new(0, 10, 0, yPos)
    checkbox.BackgroundTransparency = 1
    checkbox.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 22, 0, 22)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = checkbox
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(160, 160, 170)
    checkmark.TextSize = 16
    checkmark.Visible = configTable[configPath] or false
    checkmark.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 190)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkbox
    
    button.MouseButton1Click:Connect(function()
        configTable[configPath] = not configTable[configPath]
        checkmark.Visible = configTable[configPath]
    end)
    
    -- Кнопка бинда
    if bindPath and bindModePath then
        local bindButton = Instance.new("TextButton")
        bindButton.Size = UDim2.new(0, 80, 0, 22)
        bindButton.Position = UDim2.new(1, -85, 0, 5)
        bindButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        bindButton.BorderSizePixel = 0
        bindButton.Font = Enum.Font.Gotham
        
        local function updateBindText()
            local keyText = configTable[bindPath] == Enum.KeyCode.Unknown and "None" or configTable[bindPath].Name
            local mode = configTable[bindModePath]
            local modeShort = mode == "Always" and "[A]" or mode == "Hold" and "[H]" or mode == "Toggle" and "[T]" or "[X]"
            bindButton.Text = modeShort .. " " .. keyText
        end
        updateBindText()
        
        bindButton.TextColor3 = Color3.fromRGB(150, 150, 160)
        bindButton.TextSize = 10
        bindButton.Parent = checkbox
        
        local bindCorner = Instance.new("UICorner")
        bindCorner.CornerRadius = UDim.new(0, 5)
        bindCorner.Parent = bindButton
        
        bindButton.MouseButton1Click:Connect(function()
            waitingForBind = {configTable = configTable, configPath = bindPath, button = bindButton, updateFunc = updateBindText}
            bindButton.Text = "..."
        end)
        
        bindButton.MouseButton2Click:Connect(function()
            local contextMenu = Instance.new("Frame")
            contextMenu.Size = UDim2.new(0, 100, 0, 120)
            contextMenu.Position = UDim2.new(0, bindButton.AbsolutePosition.X - checkbox.AbsolutePosition.X, 0, 30)
            contextMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            contextMenu.BorderSizePixel = 0
            contextMenu.ZIndex = 100
            contextMenu.Parent = checkbox
            
            local contextCorner = Instance.new("UICorner")
            contextCorner.CornerRadius = UDim.new(0, 5)
            contextCorner.Parent = contextMenu
            
            local modes = {"Always", "Off", "Hold", "Toggle"}
            for i, mode in ipairs(modes) do
                local modeButton = Instance.new("TextButton")
                modeButton.Size = UDim2.new(1, -4, 0, 28)
                modeButton.Position = UDim2.new(0, 2, 0, (i - 1) * 30 + 2)
                modeButton.BackgroundColor3 = configTable[bindModePath] == mode and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(35, 35, 40)
                modeButton.BorderSizePixel = 0
                modeButton.Font = Enum.Font.Gotham
                modeButton.Text = mode
                modeButton.TextColor3 = Color3.fromRGB(180, 180, 190)
                modeButton.TextSize = 11
                modeButton.ZIndex = 101
                modeButton.Parent = contextMenu
                
                local modeCorner = Instance.new("UICorner")
                modeCorner.CornerRadius = UDim.new(0, 4)
                modeCorner.Parent = modeButton
                
                modeButton.MouseButton1Click:Connect(function()
                    configTable[bindModePath] = mode
                    
                    if mode == "Always" then
                        configTable[configPath] = true
                        checkmark.Visible = true
                    elseif mode == "Off" then
                        configTable[configPath] = false
                        checkmark.Visible = false
                    end
                    
                    updateBindText()
                    contextMenu:Destroy()
                end)
            end
            
            task.delay(0.1, function()
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if contextMenu.Parent then
                            contextMenu:Destroy()
                        end
                        connection:Disconnect()
                    end
                end)
            end)
        end)
    end
    
    return checkbox
end

-- Функция создания слайдера
local function createSlider(parent, text, yPos, configTable, configPath, min, max, default)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 48)
    slider.Position = UDim2.new(0, 10, 0, yPos)
    slider.BackgroundTransparency = 1
    slider.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text .. ": " .. (configTable[configPath] or default)
    label.TextColor3 = Color3.fromRGB(180, 180, 190)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((configTable[configPath] or default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new((configTable[configPath] or default - min) / (max - min), -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local dragging = false
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local trackPos = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            
            -- Для Prediction используем больше точности
            local value
            if configPath == "Prediction" then
                value = min + (max - min) * percent
                value = math.floor(value * 100) / 100 -- 2 знака после запятой
            else
                value = math.floor(min + (max - min) * percent)
            end
            
            configTable[configPath] = value
            label.Text = text .. ": " .. value
            fill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, -7, 0.5, -7)
        end
    end)
    
    return slider
end

-- Функция создания дропдауна
local function createDropdown(parent, text, yPos, configTable, configPath, options)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -20, 0, 32)
    dropdown.Position = UDim2.new(0, 10, 0, yPos)
    dropdown.BackgroundTransparency = 1
    dropdown.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 190)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdown
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.63, 0, 0, 28)
    button.Position = UDim2.new(0.37, 0, 0, 2)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.Text = configTable[configPath]
    button.TextColor3 = Color3.fromRGB(180, 180, 190)
    button.TextSize = 11
    button.Parent = dropdown
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 28)
    dropdownList.Position = UDim2.new(0, 0, 1, 3)
    dropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = button
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 5)
    listCorner.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 28)
        optionButton.Position = UDim2.new(0, 0, 0, (i - 1) * 28)
        optionButton.BackgroundTransparency = 1
        optionButton.Font = Enum.Font.Gotham
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(180, 180, 190)
        optionButton.TextSize = 11
        optionButton.ZIndex = 11
        optionButton.Parent = dropdownList
        
        optionButton.MouseButton1Click:Connect(function()
            configTable[configPath] = option
            button.Text = option
            dropdownList.Visible = false
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
    
    return dropdown
end

-- Функция создания Color Picker
local function createColorPicker(parent, text, yPos, configTable, configPath)
    local colorPicker = Instance.new("Frame")
    colorPicker.Size = UDim2.new(1, -20, 0, 32)
    colorPicker.Position = UDim2.new(0, 10, 0, yPos)
    colorPicker.BackgroundTransparency = 1
    colorPicker.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 190)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorPicker
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 80, 0, 26)
    colorButton.Position = UDim2.new(1, -85, 0, 3)
    colorButton.BackgroundColor3 = configTable[configPath]
    colorButton.BorderSizePixel = 0
    colorButton.Text = ""
    colorButton.Parent = colorPicker
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 5)
    colorCorner.Parent = colorButton
    
    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = Color3.fromRGB(60, 60, 70)
    colorStroke.Thickness = 1
    colorStroke.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        -- Проверяем, есть ли уже открытый picker
        local existingPicker = MainFrame:FindFirstChild("ColorPickerFrame_" .. configPath)
        if existingPicker then
            existingPicker:Destroy()
            return
        end
        
        -- Создаем Color Picker окно
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Name = "ColorPickerFrame_" .. configPath
        pickerFrame.Size = UDim2.new(0, 220, 0, 260)
        
        -- Вычисляем позицию относительно MainFrame
        local buttonPosX = colorButton.AbsolutePosition.X - MainFrame.AbsolutePosition.X
        local buttonPosY = colorButton.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y
        
        pickerFrame.Position = UDim2.new(0, buttonPosX - 230, 0, buttonPosY)
        pickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        pickerFrame.BorderSizePixel = 0
        pickerFrame.ZIndex = 300
        pickerFrame.Parent = MainFrame
        
        local pickerCorner = Instance.new("UICorner")
        pickerCorner.CornerRadius = UDim.new(0, 8)
        pickerCorner.Parent = pickerFrame
        
        local pickerStroke = Instance.new("UIStroke")
        pickerStroke.Color = Color3.fromRGB(60, 60, 70)
        pickerStroke.Thickness = 1
        pickerStroke.Parent = pickerFrame
        
        -- Заголовок
        local pickerTitle = Instance.new("TextLabel")
        pickerTitle.Size = UDim2.new(1, 0, 0, 30)
        pickerTitle.BackgroundTransparency = 1
        pickerTitle.Font = Enum.Font.GothamBold
        pickerTitle.Text = "Color Picker"
        pickerTitle.TextColor3 = Color3.fromRGB(180, 180, 190)
        pickerTitle.TextSize = 13
        pickerTitle.ZIndex = 301
        pickerTitle.Parent = pickerFrame
        
        -- Градиент HSV
        local hsvCanvas = Instance.new("Frame")
        hsvCanvas.Size = UDim2.new(1, -20, 0, 150)
        hsvCanvas.Position = UDim2.new(0, 10, 0, 40)
        hsvCanvas.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        hsvCanvas.BorderSizePixel = 0
        hsvCanvas.ZIndex = 301
        hsvCanvas.Parent = pickerFrame
        
        local hsvCorner = Instance.new("UICorner")
        hsvCorner.CornerRadius = UDim.new(0, 5)
        hsvCorner.Parent = hsvCanvas
        
        -- Белый градиент (saturation)
        local whiteGradient = Instance.new("Frame")
        whiteGradient.Size = UDim2.new(1, 0, 1, 0)
        whiteGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        whiteGradient.BackgroundTransparency = 0
        whiteGradient.BorderSizePixel = 0
        whiteGradient.ZIndex = 302
        whiteGradient.Parent = hsvCanvas
        
        local whiteCorner = Instance.new("UICorner")
        whiteCorner.CornerRadius = UDim.new(0, 5)
        whiteCorner.Parent = whiteGradient
        
        local whiteGrad = Instance.new("UIGradient")
        whiteGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        whiteGrad.Rotation = 0
        whiteGrad.Parent = whiteGradient
        
        -- Черный градиент (value)
        local blackGradient = Instance.new("Frame")
        blackGradient.Size = UDim2.new(1, 0, 1, 0)
        blackGradient.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackGradient.BackgroundTransparency = 0
        blackGradient.BorderSizePixel = 0
        blackGradient.ZIndex = 303
        blackGradient.Parent = hsvCanvas
        
        local blackCorner = Instance.new("UICorner")
        blackCorner.CornerRadius = UDim.new(0, 5)
        blackCorner.Parent = blackGradient
        
        local blackGrad = Instance.new("UIGradient")
        blackGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        blackGrad.Rotation = 90
        blackGrad.Parent = blackGradient
        
        -- Курсор выбора цвета
        local cursor = Instance.new("Frame")
        cursor.Size = UDim2.new(0, 10, 0, 10)
        cursor.Position = UDim2.new(0.5, -5, 0.5, -5)
        cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        cursor.BorderSizePixel = 0
        cursor.ZIndex = 304
        cursor.Parent = hsvCanvas
        
        local cursorCorner = Instance.new("UICorner")
        cursorCorner.CornerRadius = UDim.new(1, 0)
        cursorCorner.Parent = cursor
        
        local cursorStroke = Instance.new("UIStroke")
        cursorStroke.Color = Color3.fromRGB(0, 0, 0)
        cursorStroke.Thickness = 2
        cursorStroke.Parent = cursor
        
        -- Hue Slider
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(1, -20, 0, 15)
        hueSlider.Position = UDim2.new(0, 10, 0, 200)
        hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSlider.BorderSizePixel = 0
        hueSlider.ZIndex = 301
        hueSlider.Parent = pickerFrame
        
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(0, 5)
        hueCorner.Parent = hueSlider
        
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        hueGradient.Rotation = 0
        hueGradient.Parent = hueSlider
        
        local hueThumb = Instance.new("Frame")
        hueThumb.Size = UDim2.new(0, 4, 1, 4)
        hueThumb.Position = UDim2.new(0, -2, 0, -2)
        hueThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueThumb.BorderSizePixel = 0
        hueThumb.ZIndex = 302
        hueThumb.Parent = hueSlider
        
        local hueThumbCorner = Instance.new("UICorner")
        hueThumbCorner.CornerRadius = UDim.new(0, 2)
        hueThumbCorner.Parent = hueThumb
        
        local hueThumbStroke = Instance.new("UIStroke")
        hueThumbStroke.Color = Color3.fromRGB(0, 0, 0)
        hueThumbStroke.Thickness = 1
        hueThumbStroke.Parent = hueThumb
        
        -- Кнопки
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, -20, 0, 30)
        buttonFrame.Position = UDim2.new(0, 10, 0, 223)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.ZIndex = 301
        buttonFrame.Parent = pickerFrame
        
        local confirmButton = Instance.new("TextButton")
        confirmButton.Size = UDim2.new(0.48, 0, 1, 0)
        confirmButton.Position = UDim2.new(0, 0, 0, 0)
        confirmButton.BackgroundColor3 = Color3.fromRGB(40, 120, 80)
        confirmButton.BorderSizePixel = 0
        confirmButton.Font = Enum.Font.GothamBold
        confirmButton.Text = "✓ Apply"
        confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmButton.TextSize = 12
        confirmButton.ZIndex = 302
        confirmButton.Parent = buttonFrame
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 5)
        confirmCorner.Parent = confirmButton
        
        local cancelButton = Instance.new("TextButton")
        cancelButton.Size = UDim2.new(0.48, 0, 1, 0)
        cancelButton.Position = UDim2.new(0.52, 0, 0, 0)
        cancelButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        cancelButton.BorderSizePixel = 0
        cancelButton.Font = Enum.Font.GothamBold
        cancelButton.Text = "✗ Cancel"
        cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        cancelButton.TextSize = 12
        cancelButton.ZIndex = 302
        cancelButton.Parent = buttonFrame
        
        local cancelCorner = Instance.new("UICorner")
        cancelCorner.CornerRadius = UDim.new(0, 5)
        cancelCorner.Parent = cancelButton
        
        -- HSV переменные
        local currentHue = 0
        local currentSat = 1
        local currentVal = 1
        
        -- Функция конвертации HSV в RGB
        local function HSVtoRGB(h, s, v)
            local r, g, b
            
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)
            
            i = i % 6
            
            if i == 0 then r, g, b = v, t, p
            elseif i == 1 then r, g, b = q, v, p
            elseif i == 2 then r, g, b = p, v, t
            elseif i == 3 then r, g, b = p, q, v
            elseif i == 4 then r, g, b = t, p, v
            elseif i == 5 then r, g, b = v, p, q
            end
            
            return Color3.fromRGB(r * 255, g * 255, b * 255)
        end
        
        -- Обновление цвета
        local function updateColor()
            local color = HSVtoRGB(currentHue, currentSat, currentVal)
            colorButton.BackgroundColor3 = color
            
            local hueColor = HSVtoRGB(currentHue, 1, 1)
            hsvCanvas.BackgroundColor3 = hueColor
        end
        
        -- HSV Canvas dragging
        local hsvDragging = false
        
        hsvCanvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hsvDragging = true
                
                local mousePos = UserInputService:GetMouseLocation()
                local canvasPos = hsvCanvas.AbsolutePosition
                local canvasSize = hsvCanvas.AbsoluteSize
                
                local relX = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
                local relY = math.clamp((mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
                
                currentSat = relX
                currentVal = 1 - relY
                
                cursor.Position = UDim2.new(relX, -5, relY, -5)
                updateColor()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if hsvDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local canvasPos = hsvCanvas.AbsolutePosition
                local canvasSize = hsvCanvas.AbsoluteSize
                
                local relX = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
                local relY = math.clamp((mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
                
                currentSat = relX
                currentVal = 1 - relY
                
                cursor.Position = UDim2.new(relX, -5, relY, -5)
                updateColor()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hsvDragging = false
            end
        end)
        
        -- Hue Slider dragging
        local hueDragging = false
        
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = true
                
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = hueSlider.AbsolutePosition
                local sliderSize = hueSlider.AbsoluteSize
                
                local relX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                
                currentHue = relX
                hueThumb.Position = UDim2.new(relX, -2, 0, -2)
                updateColor()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = hueSlider.AbsolutePosition
                local sliderSize = hueSlider.AbsoluteSize
                
                local relX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                
                currentHue = relX
                hueThumb.Position = UDim2.new(relX, -2, 0, -2)
                updateColor()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = false
            end
        end)
        
        -- Кнопки
        confirmButton.MouseButton1Click:Connect(function()
            configTable[configPath] = HSVtoRGB(currentHue, currentSat, currentVal)
            pickerFrame:Destroy()
        end)
        
        cancelButton.MouseButton1Click:Connect(function()
            pickerFrame:Destroy()
        end)
        
        -- Закрытие при клике вне области
        task.delay(0.1, function()
            local closeConnection
            closeConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = UserInputService:GetMouseLocation()
                    local framePos = pickerFrame.AbsolutePosition
                    local frameSize = pickerFrame.AbsoluteSize
                    
                    if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                       mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                        if pickerFrame.Parent then
                            pickerFrame:Destroy()
                        end
                        closeConnection:Disconnect()
                    end
                end
            end)
        end)
        
        updateColor()
    end)
    
    return colorPicker
end

-- Создание элементов Aim вкладки
createSection(AimContainer, "🎯 AIM ASSIST", 10)
createCheckbox(AimContainer, "Enable Aim Assist", 45, Config.Aim, "Enabled", "Bind", "BindMode")
createCheckbox(AimContainer, "Activate on RMB (Right Click)", 85, Config.Aim, "ActivateOnRMB", nil, nil)
createSlider(AimContainer, "FOV Size", 125, Config.Aim, "FOV", 50, 500, 100)
createSlider(AimContainer, "Speed", 180, Config.Aim, "Speed", 1, 20, 5)
createSlider(AimContainer, "Prediction", 235, Config.Aim, "Prediction", 0, 0.3, 0.12)

createSection(AimContainer, "🔍 TARGETING", 295)
createCheckbox(AimContainer, "Team Check", 330, Config.Aim, "TeamCheck", nil, nil)
createCheckbox(AimContainer, "Visible Check (Wall Check)", 370, Config.Aim, "VisibleCheck", nil, nil)
createCheckbox(AimContainer, "Alive Check", 410, Config.Aim, "AliveCheck", nil, nil)
createCheckbox(AimContainer, "Stick to Target", 450, Config.Aim, "StickToTarget", nil, nil)
createDropdown(AimContainer, "Target Mode", 490, Config.Aim, "TargetMode", {"Nearest to Crosshair", "Distance", "HP"})

createSection(AimContainer, "🔫 TRIGGER BOT", 535)
createCheckbox(AimContainer, "Enable Trigger Bot", 570, Config.Aim, "TriggerBot", "TriggerBotBind", "TriggerBotBindMode")

-- ===================== ESP ВКЛАДКА =====================
local ESPContainer = Instance.new("ScrollingFrame")
ESPContainer.Name = "ESPContainer"
ESPContainer.Size = UDim2.new(1, -150, 1, -70)
ESPContainer.Position = UDim2.new(0, 130, 0, 55)
ESPContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ESPContainer.BorderSizePixel = 0
ESPContainer.Visible = false
ESPContainer.ScrollBarThickness = 4
ESPContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
ESPContainer.CanvasSize = UDim2.new(0, 0, 0, 360)
ESPContainer.Parent = MainFrame

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 10)
ESPCorner.Parent = ESPContainer

createSection(ESPContainer, "👁 ESP TYPES", 10)
createCheckbox(ESPContainer, "3D ESP (Name + Distance)", 45, Config.ESP, "3D", "3DBind", "3DBindMode")
createCheckbox(ESPContainer, "Box ESP", 85, Config.ESP, "Box", "BoxBind", "BoxBindMode")
createCheckbox(ESPContainer, "Skeleton ESP", 125, Config.ESP, "Skeleton", "SkeletonBind", "SkeletonBindMode")
createCheckbox(ESPContainer, "Sound ESP (Circle)", 165, Config.ESP, "Sound", "SoundBind", "SoundBindMode")

createSection(ESPContainer, "⚙ ESP SETTINGS", 210)
createCheckbox(ESPContainer, "Team Check", 245, Config.ESP, "TeamCheck", nil, nil)
createColorPicker(ESPContainer, "ESP Color", 285, Config.ESP, "ESPColor")

-- ===================== VISUALS ВКЛАДКА =====================
local VisualsContainer = Instance.new("ScrollingFrame")
VisualsContainer.Name = "VisualsContainer"
VisualsContainer.Size = UDim2.new(1, -150, 1, -70)
VisualsContainer.Position = UDim2.new(0, 130, 0, 55)
VisualsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
VisualsContainer.BorderSizePixel = 0
VisualsContainer.Visible = false
VisualsContainer.ScrollBarThickness = 4
VisualsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
VisualsContainer.CanvasSize = UDim2.new(0, 0, 0, 150)
VisualsContainer.Parent = MainFrame

local VisualsCorner = Instance.new("UICorner")
VisualsCorner.CornerRadius = UDim.new(0, 10)
VisualsCorner.Parent = VisualsContainer

createSection(VisualsContainer, "👁 VISUAL SETTINGS", 10)
createCheckbox(VisualsContainer, "Show FOV Circle", 45, Config.Visuals, "FOVCircle", "FOVCircleBind", "FOVCircleBindMode")
createColorPicker(VisualsContainer, "FOV Circle Color", 85, Config.Visuals, "FOVColor")

-- ===================== MISC ВКЛАДКА =====================
local MiscContainer = Instance.new("ScrollingFrame")
MiscContainer.Name = "MiscContainer"
MiscContainer.Size = UDim2.new(1, -150, 1, -70)
MiscContainer.Position = UDim2.new(0, 130, 0, 55)
MiscContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MiscContainer.BorderSizePixel = 0
MiscContainer.Visible = false
MiscContainer.ScrollBarThickness = 4
MiscContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
MiscContainer.CanvasSize = UDim2.new(0, 0, 0, 420)
MiscContainer.Parent = MainFrame

local MiscCorner = Instance.new("UICorner")
MiscCorner.CornerRadius = UDim.new(0, 10)
MiscCorner.Parent = MiscContainer

createSection(MiscContainer, "⚙ MISC FEATURES", 10)

-- Movement Settings
createSection(MiscContainer, "🏃 MOVEMENT", 45)
createCheckbox(MiscContainer, "Speed Hack", 80, Config.Aim, "SpeedEnabled", nil, nil)
createSlider(MiscContainer, "Speed Multiplier", 120, Config.Aim, "SpeedValue", 16, 100, 16)

createCheckbox(MiscContainer, "Fly", 175, Config.Aim, "FlyEnabled", nil, nil)
createSlider(MiscContainer, "Fly Speed", 215, Config.Aim, "FlySpeed", 10, 200, 50)

createCheckbox(MiscContainer, "High Jump", 270, Config.Aim, "HighJumpEnabled", nil, nil)
createSlider(MiscContainer, "Jump Power", 310, Config.Aim, "JumpPower", 50, 300, 50)

createCheckbox(MiscContainer, "Noclip", 365, Config.Aim, "NoclipEnabled", nil, nil)

-- Статус бар (создаём раньше для использования функции updateStatus)
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, 0, 0, 25)
StatusBar.Position = UDim2.new(0, 0, 1, -25)
StatusBar.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 12)
StatusCorner.Parent = StatusBar

local StatusFix = Instance.new("Frame")
StatusFix.Size = UDim2.new(1, 0, 0, 12)
StatusFix.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
StatusFix.BorderSizePixel = 0
StatusFix.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "✓ Готов к работе"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

-- ===================== SETTINGS ВКЛАДКА =====================
local SettingsContainer = Instance.new("ScrollingFrame")
SettingsContainer.Name = "SettingsContainer"
SettingsContainer.Size = UDim2.new(1, -150, 1, -70)
SettingsContainer.Position = UDim2.new(0, 130, 0, 55)
SettingsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SettingsContainer.BorderSizePixel = 0
SettingsContainer.Visible = false
SettingsContainer.ScrollBarThickness = 4
SettingsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, 450)
SettingsContainer.Parent = MainFrame

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 10)
SettingsCorner.Parent = SettingsContainer

createSection(SettingsContainer, "⚡ UI SETTINGS", 10)

-- Кнопка выбора клавиши открытия GUI
local toggleKeyFrame = Instance.new("Frame")
toggleKeyFrame.Size = UDim2.new(1, -20, 0, 48)
toggleKeyFrame.Position = UDim2.new(0, 10, 0, 45)
toggleKeyFrame.BackgroundTransparency = 1
toggleKeyFrame.Parent = SettingsContainer

local toggleKeyLabel = Instance.new("TextLabel")
toggleKeyLabel.Size = UDim2.new(1, 0, 0, 18)
toggleKeyLabel.BackgroundTransparency = 1
toggleKeyLabel.Font = Enum.Font.Gotham
toggleKeyLabel.Text = "Toggle GUI Key:"
toggleKeyLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
toggleKeyLabel.TextSize = 12
toggleKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleKeyLabel.Parent = toggleKeyFrame

local toggleKeyButton = Instance.new("TextButton")
toggleKeyButton.Size = UDim2.new(1, 0, 0, 28)
toggleKeyButton.Position = UDim2.new(0, 0, 0, 20)
toggleKeyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
toggleKeyButton.BorderSizePixel = 0
toggleKeyButton.Font = Enum.Font.Gotham
toggleKeyButton.Text = Config.Settings.ToggleKey.Name
toggleKeyButton.TextColor3 = Color3.fromRGB(150, 150, 160)
toggleKeyButton.TextSize = 11
toggleKeyButton.Parent = toggleKeyFrame

local toggleKeyCorner = Instance.new("UICorner")
toggleKeyCorner.CornerRadius = UDim.new(0, 5)
toggleKeyCorner.Parent = toggleKeyButton

local waitingForToggleKey = false

toggleKeyButton.MouseButton1Click:Connect(function()
    waitingForToggleKey = true
    toggleKeyButton.Text = "Press any key..."
end)

local toggleKeyConnection
toggleKeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if waitingForToggleKey and input.KeyCode ~= Enum.KeyCode.Unknown then
        Config.Settings.ToggleKey = input.KeyCode
        toggleKeyButton.Text = input.KeyCode.Name
        waitingForToggleKey = false
    end
end)

-- CONFIG SYSTEM в Settings
createSection(SettingsContainer, "💾 CONFIG SYSTEM", 110)

local configYPos = 145
local configName = Instance.new("Frame")
configName.Size = UDim2.new(1, -20, 0, 48)
configName.Position = UDim2.new(0, 10, 0, configYPos)
configName.BackgroundTransparency = 1
configName.Parent = SettingsContainer

local configLabel = Instance.new("TextLabel")
configLabel.Size = UDim2.new(1, 0, 0, 18)
configLabel.BackgroundTransparency = 1
configLabel.Font = Enum.Font.Gotham
configLabel.Text = "Config Name:"
configLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
configLabel.TextSize = 12
configLabel.TextXAlignment = Enum.TextXAlignment.Left
configLabel.Parent = configName

local configInput = Instance.new("TextBox")
configInput.Size = UDim2.new(1, 0, 0, 28)
configInput.Position = UDim2.new(0, 0, 0, 20)
configInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
configInput.BorderSizePixel = 0
configInput.Font = Enum.Font.Gotham
configInput.PlaceholderText = "Enter config name..."
configInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
configInput.Text = ""
configInput.TextColor3 = Color3.fromRGB(180, 180, 190)
configInput.TextSize = 11
configInput.Parent = configName

local configInputCorner = Instance.new("UICorner")
configInputCorner.CornerRadius = UDim.new(0, 5)
configInputCorner.Parent = configInput

-- Функция обновления статуса
local function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color
    task.wait(3)
    StatusLabel.Text = "✓ Готов к работе"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
end

-- Функция создания кнопки конфига
local function createConfigButton(text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 32)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(180, 180, 190)
    button.TextSize = 12
    button.Parent = SettingsContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local saveConfigBtn = createConfigButton("💾 Save Config", 203, function()
    local name = configInput.Text
    if name ~= "" then
        SavedConfigs[name] = {
            Aim = {},
            ESP = {},
            Visuals = {},
            Settings = {}
        }
        for k, v in pairs(Config.Aim) do
            SavedConfigs[name].Aim[k] = v
        end
        for k, v in pairs(Config.ESP) do
            SavedConfigs[name].ESP[k] = v
        end
        for k, v in pairs(Config.Visuals) do
            SavedConfigs[name].Visuals[k] = v
        end
        for k, v in pairs(Config.Settings) do
            SavedConfigs[name].Settings[k] = v
        end
        updateStatus("💾 Config '" .. name .. "' saved!", Color3.fromRGB(150, 150, 160))
    end
end)

local loadConfigBtn = createConfigButton("📂 Load Config", 243, function()
    local name = configInput.Text
    if SavedConfigs[name] then
        for k, v in pairs(SavedConfigs[name].Aim) do
            Config.Aim[k] = v
        end
        for k, v in pairs(SavedConfigs[name].ESP) do
            Config.ESP[k] = v
        end
        for k, v in pairs(SavedConfigs[name].Visuals) do
            Config.Visuals[k] = v
        end
        for k, v in pairs(SavedConfigs[name].Settings) do
            Config.Settings[k] = v
        end
        updateStatus("📂 Config '" .. name .. "' loaded!", Color3.fromRGB(150, 150, 160))
    else
        updateStatus("⚠ Config not found!", Color3.fromRGB(180, 150, 100))
    end
end)

local deleteConfigBtn = createConfigButton("🗑 Delete Config", 283, function()
    local name = configInput.Text
    if SavedConfigs[name] then
        SavedConfigs[name] = nil
        updateStatus("🗑 Config '" .. name .. "' deleted!", Color3.fromRGB(180, 120, 100))
    end
end)

local resetConfigBtn = createConfigButton("🔄 Reset to Default", 323, function()
    Config.Aim = {
        Enabled = false,
        Bind = Enum.KeyCode.Unknown,
        BindMode = "Toggle",
        ActivateOnRMB = true,
        FOV = 100,
        Speed = 5,
        Smoothness = 0.5,
        Prediction = 0.12,
        TeamCheck = true,
        VisibleCheck = true,
        AliveCheck = true,
        TargetMode = "Nearest to Crosshair",
        StickToTarget = true,
        TriggerBot = false,
        TriggerBotBind = Enum.KeyCode.Unknown,
        TriggerBotBindMode = "Toggle",
        TriggerDelay = 100
    }
    updateStatus("🔄 Settings reset to default!", Color3.fromRGB(120, 120, 180))
end)

-- Система переключения вкладок
local function switchTab(tab)
    AimContainer.Visible = false
    ESPContainer.Visible = false
    VisualsContainer.Visible = false
    MiscContainer.Visible = false
    SettingsContainer.Visible = false
    
    AimTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    AimTab.TextColor3 = Color3.fromRGB(120, 120, 130)
    ESPTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ESPTab.TextColor3 = Color3.fromRGB(120, 120, 130)
    VisualsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    VisualsTab.TextColor3 = Color3.fromRGB(120, 120, 130)
    MiscTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MiscTab.TextColor3 = Color3.fromRGB(120, 120, 130)
    SettingsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SettingsTab.TextColor3 = Color3.fromRGB(120, 120, 130)
    
    if tab == "Aim" then
        AimContainer.Visible = true
        AimTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        AimTab.TextColor3 = Color3.fromRGB(180, 180, 190)
    elseif tab == "ESP" then
        ESPContainer.Visible = true
        ESPTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        ESPTab.TextColor3 = Color3.fromRGB(180, 180, 190)
    elseif tab == "Visuals" then
        VisualsContainer.Visible = true
        VisualsTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        VisualsTab.TextColor3 = Color3.fromRGB(180, 180, 190)
    elseif tab == "Misc" then
        MiscContainer.Visible = true
        MiscTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        MiscTab.TextColor3 = Color3.fromRGB(180, 180, 190)
    elseif tab == "Settings" then
        SettingsContainer.Visible = true
        SettingsTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        SettingsTab.TextColor3 = Color3.fromRGB(180, 180, 190)
    end
end

AimTab.MouseButton1Click:Connect(function() switchTab("Aim") end)
ESPTab.MouseButton1Click:Connect(function() switchTab("ESP") end)
VisualsTab.MouseButton1Click:Connect(function() switchTab("Visuals") end)
MiscTab.MouseButton1Click:Connect(function() switchTab("Misc") end)
SettingsTab.MouseButton1Click:Connect(function() switchTab("Settings") end)

switchTab("Aim")

-- Система биндов
local heldKeys = {}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Config.Settings.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
            return
        end
        
        if waitingForBind and input.KeyCode ~= Enum.KeyCode.Unknown then
            waitingForBind.configTable[waitingForBind.configPath] = input.KeyCode
            if waitingForBind.updateFunc then
                waitingForBind.updateFunc()
            else
                waitingForBind.button.Text = input.KeyCode.Name
            end
            waitingForBind = nil
            return
        end
        
        local function handleBind(bindKey, bindMode, configTable, configPath)
            if input.KeyCode == bindKey and bindKey ~= Enum.KeyCode.Unknown then
                if bindMode == "Toggle" then
                    configTable[configPath] = not configTable[configPath]
                elseif bindMode == "Hold" then
                    heldKeys[bindKey] = true
                    configTable[configPath] = true
                elseif bindMode == "Always" then
                    configTable[configPath] = true
                end
            end
        end
        
        handleBind(Config.Aim.Bind, Config.Aim.BindMode, Config.Aim, "Enabled")
        handleBind(Config.Aim.TriggerBotBind, Config.Aim.TriggerBotBindMode, Config.Aim, "TriggerBot")
        handleBind(Config.ESP["3DBind"], Config.ESP["3DBindMode"], Config.ESP, "3D")
        handleBind(Config.ESP.BoxBind, Config.ESP.BoxBindMode, Config.ESP, "Box")
        handleBind(Config.ESP.SkeletonBind, Config.ESP.SkeletonBindMode, Config.ESP, "Skeleton")
        handleBind(Config.ESP.SoundBind, Config.ESP.SoundBindMode, Config.ESP, "Sound")
        handleBind(Config.Visuals.FOVCircleBind, Config.Visuals.FOVCircleBindMode, Config.Visuals, "FOVCircle")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if heldKeys[input.KeyCode] then
        heldKeys[input.KeyCode] = nil
        
        if input.KeyCode == Config.Aim.Bind and Config.Aim.BindMode == "Hold" then
            Config.Aim.Enabled = false
        elseif input.KeyCode == Config.Aim.TriggerBotBind and Config.Aim.TriggerBotBindMode == "Hold" then
            Config.Aim.TriggerBot = false
        elseif input.KeyCode == Config.ESP["3DBind"] and Config.ESP["3DBindMode"] == "Hold" then
            Config.ESP["3D"] = false
        elseif input.KeyCode == Config.ESP.BoxBind and Config.ESP.BoxBindMode == "Hold" then
            Config.ESP.Box = false
        elseif input.KeyCode == Config.ESP.SkeletonBind and Config.ESP.SkeletonBindMode == "Hold" then
            Config.ESP.Skeleton = false
        elseif input.KeyCode == Config.ESP.SoundBind and Config.ESP.SoundBindMode == "Hold" then
            Config.ESP.Sound = false
        elseif input.KeyCode == Config.Visuals.FOVCircleBind and Config.Visuals.FOVCircleBindMode == "Hold" then
            Config.Visuals.FOVCircle = false
        end
    end
end)

-- ===================== AIM ASSIST ЛОГИКА =====================

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 50
FOVCircle.Radius = Config.Aim.FOV
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Color = Config.Visuals.FOVColor
FOVCircle.Visible = false

-- ===================== ESP СИСТЕМЫ =====================

local ESPObjects = {}

local function clearESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj.Remove then
                obj:Remove()
            elseif obj.Destroy then
                obj:Destroy()
            end
        end
        ESPObjects[player] = nil
    end
end

local function create3DESP(player)
    if not ESPObjects[player] then
        ESPObjects[player] = {}
    end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "3DESP"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextColor3 = Config.ESP.ESPColor
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboardGui
    
    ESPObjects[player]["3D"] = {billboardGui, textLabel}
    
    return billboardGui, textLabel
end

local function createBoxESP()
    local box = {}
    
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Config.ESP.ESPColor
        line.Transparency = 1
        line.Visible = false
        box[i] = line
    end
    
    return box
end

local function createSkeletonESP()
    local skeleton = {}
    
    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }
    
    for i = 1, #connections do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Config.ESP.ESPColor
        line.Transparency = 1
        line.Visible = false
        skeleton[i] = {line = line, from = connections[i][1], to = connections[i][2]}
    end
    
    return skeleton
end

local soundCircles = {}

local function createSoundESP(position)
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.NumSides = 50
    circle.Radius = 0
    circle.Color = Config.ESP.ESPColor
    circle.Transparency = 1
    circle.Filled = false
    circle.Visible = true
    
    local startTime = tick()
    local startPos = position
    
    table.insert(soundCircles, {
        circle = circle,
        startTime = startTime,
        position = startPos
    })
    
    return circle
end

RunService.RenderStepped:Connect(function()
    for i = #soundCircles, 1, -1 do
        local data = soundCircles[i]
        local elapsed = tick() - data.startTime
        
        if elapsed >= 1.2 then
            data.circle:Remove()
            table.remove(soundCircles, i)
        else
            local progress = elapsed / 1.2
            local screenPos, onScreen = Camera:WorldToViewportPoint(data.position)
            
            if onScreen then
                data.circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                data.circle.Radius = 100 * progress
                data.circle.Transparency = 1 - progress
                data.circle.Visible = Config.ESP.Sound
            else
                data.circle.Visible = false
            end
        end
    end
end)

local function updateBoxESP(player, box)
    local character = player.Character
    if not character then
        for _, line in pairs(box) do
            line.Visible = false
        end
        return
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        for _, line in pairs(box) do
            line.Visible = false
        end
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        for _, line in pairs(box) do
            line.Visible = false
        end
        return
    end
    
    local topPos = (hrp.CFrame * CFrame.new(0, 3, 0)).Position
    local bottomPos = (hrp.CFrame * CFrame.new(0, -3, 0)).Position
    
    local topLeft = Camera:WorldToViewportPoint(topPos + Vector3.new(-2, 0, 0))
    local topRight = Camera:WorldToViewportPoint(topPos + Vector3.new(2, 0, 0))
    local bottomLeft = Camera:WorldToViewportPoint(bottomPos + Vector3.new(-2, 0, 0))
    local bottomRight = Camera:WorldToViewportPoint(bottomPos + Vector3.new(2, 0, 0))
    
    if topLeft and topRight and bottomLeft and bottomRight then
        box[1].From = Vector2.new(topLeft.X, topLeft.Y)
        box[1].To = Vector2.new(topRight.X, topRight.Y)
        box[1].Visible = true
        
        box[2].From = Vector2.new(topRight.X, topRight.Y)
        box[2].To = Vector2.new(bottomRight.X, bottomRight.Y)
        box[2].Visible = true
        
        box[3].From = Vector2.new(bottomRight.X, bottomRight.Y)
        box[3].To = Vector2.new(bottomLeft.X, bottomLeft.Y)
        box[3].Visible = true
        
        box[4].From = Vector2.new(bottomLeft.X, bottomLeft.Y)
        box[4].To = Vector2.new(topLeft.X, topLeft.Y)
        box[4].Visible = true
    else
        for _, line in pairs(box) do
            line.Visible = false
        end
    end
end

local function updateSkeletonESP(player, skeleton)
    local character = player.Character
    if not character then
        for _, data in pairs(skeleton) do
            data.line.Visible = false
        end
        return
    end
    
    for _, data in pairs(skeleton) do
        local fromPart = character:FindFirstChild(data.from)
        local toPart = character:FindFirstChild(data.to)
        
        if fromPart and toPart then
            local fromPos, fromOnScreen = Camera:WorldToViewportPoint(fromPart.Position)
            local toPos, toOnScreen = Camera:WorldToViewportPoint(toPart.Position)
            
            if fromOnScreen and toOnScreen then
                data.line.From = Vector2.new(fromPos.X, fromPos.Y)
                data.line.To = Vector2.new(toPos.X, toPos.Y)
                data.line.Visible = true
            else
                data.line.Visible = false
            end
        else
            data.line.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            
            if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                clearESP(player)
                continue
            end
            
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and hrp then
                    if Config.ESP["3D"] then
                        if not ESPObjects[player] or not ESPObjects[player]["3D"] then
                            local gui, label = create3DESP(player)
                            gui.Adornee = hrp
                            gui.Parent = hrp
                        end
                        
                        if ESPObjects[player] and ESPObjects[player]["3D"] then
                            local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            ESPObjects[player]["3D"][2].Text = player.Name .. "\n[" .. distance .. "m]"
                            ESPObjects[player]["3D"][2].TextColor3 = Config.ESP.ESPColor
                        end
                    else
                        if ESPObjects[player] and ESPObjects[player]["3D"] then
                            ESPObjects[player]["3D"][1]:Destroy()
                            ESPObjects[player]["3D"] = nil
                        end
                    end
                    
                    if Config.ESP.Box then
                        if not ESPObjects[player] or not ESPObjects[player].Box then
                            if not ESPObjects[player] then
                                ESPObjects[player] = {}
                            end
                            ESPObjects[player].Box = createBoxESP()
                        end
                        updateBoxESP(player, ESPObjects[player].Box)
                    else
                        if ESPObjects[player] and ESPObjects[player].Box then
                            for _, line in pairs(ESPObjects[player].Box) do
                                line.Visible = false
                            end
                        end
                    end
                    
                    if Config.ESP.Skeleton then
                        if not ESPObjects[player] or not ESPObjects[player].Skeleton then
                            if not ESPObjects[player] then
                                ESPObjects[player] = {}
                            end
                            ESPObjects[player].Skeleton = createSkeletonESP()
                        end
                        updateSkeletonESP(player, ESPObjects[player].Skeleton)
                    else
                        if ESPObjects[player] and ESPObjects[player].Skeleton then
                            for _, data in pairs(ESPObjects[player].Skeleton) do
                                data.line.Visible = false
                            end
                        end
                    end
                else
                    clearESP(player)
                end
            else
                clearESP(player)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.ESP.Sound then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
                        if math.random() > 0.95 then
                            createSoundESP(hrp.Position)
                        end
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearESP(player)
end)

local function isVisible(targetPart)
    if not Config.Aim.VisibleCheck then
        return true
    end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        local hit = result.Instance
        if hit:IsDescendantOf(targetPart.Parent) then
            return true
        end
    end
    
    return false
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                if Config.Aim.AliveCheck then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        continue
                    end
                end
                
                if Config.Aim.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local targetPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance
                        
                        if Config.Aim.TargetMode == "Nearest to Crosshair" then
                            distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        elseif Config.Aim.TargetMode == "Distance" then
                            distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                        elseif Config.Aim.TargetMode == "HP" then
                            local humanoid = character:FindFirstChild("Humanoid")
                            distance = humanoid and humanoid.Health or 100
                        end
                        
                        if Config.Aim.TargetMode == "Nearest to Crosshair" then
                            if distance <= Config.Aim.FOV and distance < shortestDistance then
                                if isVisible(targetPart) then
                                    closestPlayer = targetPart
                                    shortestDistance = distance
                                end
                            end
                        else
                            if distance < shortestDistance then
                                if isVisible(targetPart) then
                                    closestPlayer = targetPart
                                    shortestDistance = distance
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local currentTarget = nil
local lastTargetPosition = nil
local lastTargetTime = nil

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Config.Aim.FOV
    FOVCircle.Color = Config.Visuals.FOVColor
    FOVCircle.Visible = Config.Visuals.FOVCircle
    
    local isAimActive = Config.Aim.Enabled
    
    if Config.Aim.ActivateOnRMB then
        local isRMBPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        isAimActive = isAimActive and isRMBPressed
    end
    
    if isAimActive then
        local target
        
        if Config.Aim.StickToTarget and currentTarget then
            local character = currentTarget.Parent
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local player = Players:GetPlayerFromCharacter(character)
                
                local isValid = true
                
                if Config.Aim.AliveCheck and (not humanoid or humanoid.Health <= 0) then
                    isValid = false
                end
                
                if player and Config.Aim.TeamCheck and player.Team == LocalPlayer.Team then
                    isValid = false
                end
                
                if Config.Aim.VisibleCheck and not isVisible(currentTarget) then
                    isValid = false
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance > Config.Aim.FOV * 1.5 then
                        isValid = false
                    end
                else
                    isValid = false
                end
                
                if isValid then
                    target = currentTarget
                else
                    currentTarget = nil
                    target = getClosestPlayer()
                    if target then
                        currentTarget = target
                    end
                end
            else
                currentTarget = nil
                target = getClosestPlayer()
                if target then
                    currentTarget = target
                end
            end
        else
            target = getClosestPlayer()
            if Config.Aim.StickToTarget and target then
                currentTarget = target
            end
        end
        
        if target then
            local targetCharacter = target.Parent
            local myCharacter = LocalPlayer.Character
            
            if targetCharacter and myCharacter then
                -- Получаем части тела
                local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
                local myHRP = myCharacter:FindFirstChild("HumanoidRootPart")
                
                if targetHRP and myHRP then
                    -- Вычисляем velocity врага
                    local targetVelocity = Vector3.new(0, 0, 0)
                    if targetHRP:IsA("BasePart") then
                        targetVelocity = targetHRP.AssemblyLinearVelocity or targetHRP.Velocity
                    end
                    
                    -- Вычисляем мою velocity
                    local myVelocity = Vector3.new(0, 0, 0)
                    if myHRP:IsA("BasePart") then
                        myVelocity = myHRP.AssemblyLinearVelocity or myHRP.Velocity
                    end
                    
                    -- Относительная velocity (враг относительно меня)
                    local relativeVelocity = targetVelocity - myVelocity
                    
                    -- Дистанция до цели
                    local distance = (targetHRP.Position - myHRP.Position).Magnitude
                    
                    -- Направление движения врага
                    local movingDirection = relativeVelocity.Unit
                    
                    -- Время, которое потребуется пуле/атаке достичь цели (примерная скорость пули 1000 studs/s)
                    local bulletSpeed = 1000
                    local timeToHit = distance / bulletSpeed
                    
                    -- Предсказываем позицию с учетом времени полета
                    local predictionMultiplier = Config.Aim.Prediction
                    local predictedOffset = relativeVelocity * timeToHit * predictionMultiplier
                    
                    -- Применяем предсказание к позиции головы
                    local predictedPosition = target.Position + predictedOffset
                    
                    -- Конвертируем в экранные координаты
                    local targetPos = Camera:WorldToViewportPoint(predictedPosition)
                    local currentMousePos = UserInputService:GetMouseLocation()
                    
                    local predictedPos = Vector2.new(targetPos.X, targetPos.Y)
                    
                    local deltaX = predictedPos.X - currentMousePos.X
                    local deltaY = predictedPos.Y - currentMousePos.Y
                    
                    local screenDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
                    local smoothFactor = Config.Aim.Speed
                    
                    -- Адаптивная плавность в зависимости от расстояния
                    if screenDistance > 50 then
                        smoothFactor = smoothFactor * 0.7
                    end
                    
                    local smoothedX = currentMousePos.X + (deltaX / smoothFactor)
                    local smoothedY = currentMousePos.Y + (deltaY / smoothFactor)
                    
                    mousemoverel((smoothedX - currentMousePos.X), (smoothedY - currentMousePos.Y))
                    
                    if Config.Aim.TriggerBot then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distanceToCenter = (predictedPos - screenCenter).Magnitude
                        
                        if distanceToCenter <= 20 then
                            task.wait(Config.Aim.TriggerDelay / 1000)
                            mouse1click()
                        end
                    end
                end
            end
        else
            currentTarget = nil
            lastTargetPosition = nil
            lastTargetTime = nil
        end
    else
        currentTarget = nil
        lastTargetPosition = nil
        lastTargetTime = nil
    end
end)

-- ===================== ПЕРЕТАСКИВАНИЕ ОКНА =====================
local dragging = false
local dragInput, mousePos, framePos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- ===================== ИЗМЕНЕНИЕ РАЗМЕРА GUI =====================
local resizing = false
local resizeStart
local resizeStartSize
local minSize = Vector2.new(600, 400)
local maxSize = Vector2.new(1200, 800)

-- Создаём уголок для изменения размера
local ResizeCorner = Instance.new("TextButton")
ResizeCorner.Name = "ResizeCorner"
ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
ResizeCorner.Position = UDim2.new(1, -20, 1, -20)
ResizeCorner.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
ResizeCorner.BorderSizePixel = 0
ResizeCorner.Text = "⋰"
ResizeCorner.TextColor3 = Color3.fromRGB(200, 200, 210)
ResizeCorner.TextSize = 14
ResizeCorner.Font = Enum.Font.GothamBold
ResizeCorner.ZIndex = 10
ResizeCorner.Parent = MainFrame

local ResizeCornerCorner = Instance.new("UICorner")
ResizeCornerCorner.CornerRadius = UDim.new(0, 5)
ResizeCornerCorner.Parent = ResizeCorner

ResizeCorner.MouseButton1Down:Connect(function()
    resizing = true
    resizeStart = UserInputService:GetMouseLocation()
    resizeStartSize = MainFrame.AbsoluteSize
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentMouse = UserInputService:GetMouseLocation()
        local delta = currentMouse - resizeStart
        
        local newWidth = math.clamp(resizeStartSize.X + delta.X, minSize.X, maxSize.X)
        local newHeight = math.clamp(resizeStartSize.Y + delta.Y, minSize.Y, maxSize.Y)
        
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        -- Обновляем позицию, чтобы GUI оставался центрированным
        MainFrame.Position = UDim2.new(0.5, -newWidth/2, 0.5, -newHeight/2)
    end
end)

-- ===================== АНИМАЦИЯ ОТКРЫТИЯ =====================
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Visible = true
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 750, 0, 520)
}):Play()

-- ===================== MISC ФУНКЦИИ =====================

-- Speed Hack
RunService.RenderStepped:Connect(function()
    if Config.Aim.SpeedEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.Aim.SpeedValue
        end
    end
end)

-- Fly System
local flying = false
local flyConnection

local function startFly()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = hrp
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 9e4
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp
        
        flying = true
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not Config.Aim.FlyEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                bodyVelocity:Destroy()
                bodyGyro:Destroy()
                flying = false
                if flyConnection then
                    flyConnection:Disconnect()
                end
                return
            end
            
            local speed = Config.Aim.FlySpeed or 50
            local velocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + Camera.CFrame.LookVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - Camera.CFrame.LookVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - Camera.CFrame.RightVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + Camera.CFrame.RightVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, speed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, speed, 0)
            end
            
            bodyVelocity.Velocity = velocity
            bodyGyro.CFrame = Camera.CFrame
        end)
    end
end

local function stopFly()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("BodyVelocity")
        local bg = hrp:FindFirstChild("BodyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

-- Проверка Fly включения/выключения
RunService.Heartbeat:Connect(function()
    if Config.Aim.FlyEnabled and not flying then
        startFly()
    elseif not Config.Aim.FlyEnabled and flying then
        stopFly()
    end
end)

-- High Jump
RunService.RenderStepped:Connect(function()
    if Config.Aim.HighJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = Config.Aim.JumpPower
        end
    end
end)

-- Noclip
local noclipConnection
RunService.Stepped:Connect(function()
    if Config.Aim.NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "⚡ OFW CLIENT";
    Text = "GUI успешно загружен!";
    Duration = 3;
})

print("=================================")
print("=================================")
