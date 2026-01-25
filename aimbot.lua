-- Aimbot для Roblox (интеграция с меню)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Переменные состояния (связываются с меню)
local isEnabled = false
local targetPart = nil
local activationKey = Enum.UserInputType.MouseButton2

-- Функция получения части тела
local function getTargetPart(character, partName)
    if partName == "Head" then
        return character:FindFirstChild("Head")
    elseif partName == "Torso" then
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    elseif partName == "Legs" then
        return character:FindFirstChild("LeftFoot") or character:FindFirstChild("RightFoot")
    else
        return character:FindFirstChild("HumanoidRootPart")
    end
end

-- Активация по зажатию кнопки
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == activationKey then
        isEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == activationKey then
        isEnabled = false
        targetPart = nil
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Проверяем, включен ли аимбот через меню
    local aimEnabled = featureStates["rage_aimbot"]
    if not aimEnabled or not isEnabled or not LocalPlayer.Character then return end

    -- Получаем настройки из меню
    local fov = featureSettings["rage_aimbot_fov"] or 60
    local smoothness = (featureSettings["rage_aimbot_smoothness"] or 10) / 100 -- Конвертируем 1-100 в 0.01-1.0
    local targetBodyPart = featureSettings["rage_aimbot_target_part"] or "Head"
    local teamCheck = featureStates["rage_aimbot_teamcheck"] or false

    local bestTarget = nil
    local bestAngle = math.huge

    -- Поиск ближайшей цели в FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        
        -- Проверка команды
        if teamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetPartObj = getTargetPart(player.Character, targetBodyPart)
        if not targetPartObj then continue end

        -- Проверка видимости
        local direction = targetPartObj.Position - Camera.CFrame.Position
        local distance = direction.Magnitude
        local angle = math.deg(math.acos(Camera.CFrame.LookVector:Dot(direction.Unit)))

        if angle < fov and angle < bestAngle and distance < 500 then
            bestAngle = angle
            bestTarget = targetPartObj
        end
    end

    targetPart = bestTarget

    -- Наведение камеры
    if targetPart then
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
    end
end)
