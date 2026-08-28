--[[
    Antibot + ESP v3.1 (完整整合版)
    功能：自瞄 + ESP2 + 夜视 + 热能透视 + 目标小窗
    FOV圈圈1 + FOV圈圈2
    FOV微调卡片（独立加载）
    作者：b站有点微醺啊
]]

-- ==================== 加载 FOV 微调卡片 ====================
local FOVAdjust = loadstring(game:HttpGet("https://raw.githubusercontent.com/ehejvejshwj1/Roblox-Antibot/main/FOVAdjust.lua"))()
FOVAdjust:Create()
FOVAdjust:SetTitle("🎯 FOV 圈微调")

-- ==================== 加载 LinoriaLib ====================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

-- ==================== 创建窗口 ====================
local Window = Library:CreateWindow({
    Title = "Antibot v3.1",
    Footer = "b站有点微醺啊 | FOV圈圈1+2",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- ==================== 配置表 ====================
local AimConfig = {
    fovsize = 50,
    fovlookAt = false,
    fovcolorFixed = Color3.fromRGB(0, 255, 0),
    fovcolorMode = "固定",
    textColorFixed = Color3.fromRGB(255, 255, 255),
    textColorMode = "固定",
    lineColorFixed = Color3.fromRGB(255, 0, 0),
    lineColorMode = "固定",
    espBoxColorFixed = Color3.fromRGB(255, 255, 255),
    espBoxColorMode = "固定",
    espTracerColorFixed = Color3.fromRGB(255, 0, 0),
    espTracerColorMode = "固定",
    espHeadCircleColorFixed = Color3.fromRGB(0, 255, 0),
    espHeadCircleColorMode = "固定",
    colorSpeed = 2.0,
    fovthickness = 2,
    distance = 200,
    Transparency = 5,
    teamCheck = false,
    wallCheck = false,
    aliveCheck = false,
    prejudgingselfsighting = false,
    prejudgingselfsightingdistance = 100,
    smoothness = 5,
    aimSpeed = 5,
    priorityMode = "Smart",
    aimMode = "AI",
    aimModeType = "普通",
    autoFire = false,
    fireRate = 10,
    dynamicFOV = false,
    dynamicFOVScale = 1.5,
    threatPriority = false,
    healthPriority = false,
    fovOffsetX = 0,
    fovOffsetY = 0,
    fovCalibrationMode = false,
    fovCircleVersion = 1,
}

local ESPConfig = {
    enabled = false,
    showBox = false,
    showHealth = false,
    showName = false,
    showDistance = false,
    showTracer = false,
    showHeadCircle = false,
    teamCheck = false,
}

local ParticleConfig = {
    shape = "圆形",
    count = 8,
    size = 10,
    colorFixed = Color3.fromRGB(255, 200, 100),
    colorMode = "固定",
}

local PanelConfig = {
    enabled = true,
}

local NightVision = {
    enabled = false,
    originalSettings = nil,
    connection = nil,
}

local ThermalESP = {
    enabled = false,
    color = Color3.fromRGB(255, 0, 0),
    colorMode = "固定",
    highlights = {},
}

local ESP2_Settings = {
    Enabled = false,
    ShowBox = true,
    ShowName = true,
    ShowHealth = true,
    ShowChams = true,
    TeamCheck = true,
    MaxDistance = 5000,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxColorMode = "固定",
    NameColor = Color3.fromRGB(255, 255, 255),
    NameColorMode = "固定",
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthBarColorMode = "固定",
}

local ESP2 = {
    ScreenGui = nil,
    PlayerElements = {},
    Connections = {},
    RenderConnection = nil,
    FontSize = 11,
}

local TextSize = 16
local BodyPartDisplay = {"头部", "躯干", "左臂", "右臂", "左腿", "右腿"}
local currentBodyPart = "头部"

local ColorPresets = {"红色", "绿色", "蓝色", "黄色", "青色", "紫色", "橙色", "白色"}
local ColorValues = {
    ["红色"] = Color3.fromRGB(255, 0, 0),
    ["绿色"] = Color3.fromRGB(0, 255, 0),
    ["蓝色"] = Color3.fromRGB(0, 0, 255),
    ["黄色"] = Color3.fromRGB(255, 255, 0),
    ["青色"] = Color3.fromRGB(0, 255, 255),
    ["紫色"] = Color3.fromRGB(128, 0, 128),
    ["橙色"] = Color3.fromRGB(255, 165, 0),
    ["白色"] = Color3.fromRGB(255, 255, 255),
}
local DynamicModes = {"循环色相", "瀑布", "波浪"}
local ParticleShapes = {"圆形", "爱心", "🩸"}
local heartSymbols = {
    "❤", "🧡", "💛", "💚", "💙", "💜", "🤎", "🖤", "💔", "❣",
    "💕", "💞", "💓", "💗", "💖", "💝", "💘", "💟", "💥", "💦", "💫"
}

-- ==================== 工具函数 ====================
local function safeClamp(value, minVal, maxVal)
    if minVal > maxVal then minVal, maxVal = maxVal, minVal end
    return math.clamp(value, minVal, maxVal)
end

local function getDynamicColor(mode)
    local t = tick() * AimConfig.colorSpeed
    if mode == "循环色相" then
        local hue = (t % 2) / 2
        return Color3.fromHSV(hue, 1, 1)
    elseif mode == "瀑布" then
        local hue = (t % 2) / 2
        local brightness = (math.sin(t * 2) + 1) / 2
        return Color3.fromHSV(hue, 1, brightness)
    elseif mode == "波浪" then
        local r = (math.sin(t * 1.3) + 1) / 2
        local g = (math.sin(t * 1.7 + 2) + 1) / 2
        local b = (math.sin(t * 2.1 + 4) + 1) / 2
        return Color3.new(r, g, b)
    end
    return Color3.fromHSV(0, 1, 1)
end

local function getCurrentColor(mode, fixedColor)
    if mode == "固定" then return fixedColor end
    return getDynamicColor(mode)
end

local function getParticleColor()
    if ParticleConfig.colorMode == "固定" then
        return ParticleConfig.colorFixed
    else
        return getDynamicColor(ParticleConfig.colorMode)
    end
end

local function IsSameTeam(player)
    return player.Team == game.Players.LocalPlayer.Team
end

local function IsAlive(player)
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function getTargetPart(character)
    if not character then return nil end
    if currentBodyPart == "头部" then return character:FindFirstChild("Head") end
    if currentBodyPart == "躯干" then return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") end
    if currentBodyPart == "左臂" then return character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm") end
    if currentBodyPart == "右臂" then return character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm") end
    if currentBodyPart == "左腿" then return character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg") end
    if currentBodyPart == "右腿" then return character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg") end
    return nil
end

local function CheckWall(player, targetPart)
    if not AimConfig.wallCheck then return true end
    local localChar = game.Players.LocalPlayer.Character
    if not localChar or not targetPart then return false end
    local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, targetPart.Position - workspace.CurrentCamera.CFrame.Position)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {localChar})
    return hit and hit:IsDescendantOf(player.Character) or not hit
end

local function PredictPosition(part)
    return part.Position + part.AssemblyLinearVelocity * ((part.Position - workspace.CurrentCamera.CFrame.Position)).Magnitude / 1000
end

local function IsInFOV(position)
    local camera = workspace.CurrentCamera
    local vp = camera:WorldToViewportPoint(position)
    return (Vector2.new(vp.X, vp.Y) - camera.ViewportSize / 2).Magnitude <= AimConfig.fovsize
end

local function GetBestTarget()
    local bestScore = -math.huge
    local bestTarget = nil
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            local skip = false
            if AimConfig.aliveCheck and not IsAlive(player) then skip = true end
            if not skip and AimConfig.teamCheck and IsSameTeam(player) then skip = true end
            if not skip then
                local targetPart = getTargetPart(player.Character)
                if targetPart then
                    local dist = (targetPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                    if dist <= AimConfig.distance then
                        local speed = targetPart.AssemblyLinearVelocity.Magnitude
                        local camera = workspace.CurrentCamera
                        local screenPoint, isVisible = camera:WorldToViewportPoint(targetPart.Position)
                        local crossDist = math.huge
                        if isVisible and screenPoint then
                            crossDist = (Vector2.new(screenPoint.X, screenPoint.Y) - camera.ViewportSize / 2).Magnitude
                        end
                        local priority = 0
                        if AimConfig.priorityMode == "Distance" then
                            priority = -dist
                        elseif AimConfig.priorityMode == "Crosshair" then
                            priority = -crossDist
                        elseif AimConfig.priorityMode == "Speed" then
                            priority = speed
                        elseif AimConfig.priorityMode == "Smart" then
                            priority = -dist*0.5 + speed*0.3 - crossDist*0.2
                        end
                        if AimConfig.threatPriority then
                            priority = priority * (player:GetAttribute("ThreatLevel") or 1)
                        end
                        if AimConfig.healthPriority then
                            priority = priority * (1 / player.Character.Humanoid.Health)
                        end
                        if bestScore < priority and (not AimConfig.wallCheck or CheckWall(player, targetPart)) then
                            bestScore = priority
                            bestTarget = player
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- ==================== FOV圈圈1（原版纯 GUI） ====================
local FOVCircle1 = {
    Gui = nil,
    Frame = nil,
    Stroke = nil,
    Visible = false,
    Radius = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Thickness = 2,
    Transparency = 0.5,
    Dot = nil,
    DotVisible = false,
}

local function CreateFOVCircle1()
    if FOVCircle1.Gui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle1"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    FOVCircle1.Gui = screenGui

    local camera = workspace.CurrentCamera
    local vs = camera and camera.ViewportSize or Vector2.new(1080, 1920)
    local radius = FOVCircle1.Radius
    local offsetX = AimConfig.fovOffsetX or 0
    local offsetY = AimConfig.fovOffsetY or 0

    local frame = Instance.new("Frame")
    frame.Name = "CircleFrame"
    frame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    frame.Position = UDim2.new(0, vs.X/2 - radius + offsetX, 0, vs.Y/2 - radius + offsetY)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    FOVCircle1.Frame = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = FOVCircle1.Thickness
    stroke.Color = FOVCircle1.Color
    stroke.Transparency = FOVCircle1.Transparency
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    FOVCircle1.Stroke = stroke

    local dot = Instance.new("Frame")
    dot.Name = "CalibrationDot"
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, vs.X/2 + offsetX - 3, 0, vs.Y/2 + offsetY - 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.BorderSizePixel = 0
    dot.Visible = false
    dot.Parent = screenGui

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Thickness = 1
    dotStroke.Color = Color3.fromRGB(255, 255, 255)
    dotStroke.Transparency = 0.5
    dotStroke.Parent = dot

    FOVCircle1.Dot = dot
end

local function UpdateFOVCircle1()
    if not FOVCircle1.Frame then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local vs = camera.ViewportSize
    local radius = FOVCircle1.Radius
    local offsetX = AimConfig.fovOffsetX or 0
    local offsetY = AimConfig.fovOffsetY or 0
    FOVCircle1.Frame.Position = UDim2.new(0, vs.X/2 - radius + offsetX, 0, vs.Y/2 - radius + offsetY)
    FOVCircle1.Frame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    if FOVCircle1.Dot then
        FOVCircle1.Dot.Position = UDim2.new(0, vs.X/2 + offsetX - 3, 0, vs.Y/2 + offsetY - 3)
    end
end

local function SetFOVCircle1Visible(visible)
    FOVCircle1.Visible = visible
    if FOVCircle1.Frame then
        FOVCircle1.Frame.Visible = visible
    end
    if FOVCircle1.Dot then
        FOVCircle1.Dot.Visible = FOVCircle1.DotVisible and visible
    end
end

local function UpdateFOVCircle1Color()
    if FOVCircle1.Stroke then
        local color = getCurrentColor(AimConfig.fovcolorMode, AimConfig.fovcolorFixed)
        FOVCircle1.Stroke.Color = color
    end
end

local function SetCalibrationDot1Visible(visible)
    FOVCircle1.DotVisible = visible
    if FOVCircle1.Dot then
        FOVCircle1.Dot.Visible = visible and FOVCircle1.Visible
    end
end

local function InitAimFOV1(radius, color, thickness, transparency)
    FOVCircle1.Radius = radius or 50
    FOVCircle1.Color = color or Color3.fromRGB(0, 255, 0)
    FOVCircle1.Thickness = thickness or 2
    FOVCircle1.Transparency = transparency or 0.5
    CreateFOVCircle1()
    UpdateFOVCircle1()
    UpdateFOVCircle1Color()
    SetFOVCircle1Visible(showFOVCircleFlag)
end

-- ==================== FOV圈圈2（借鉴 V3.0phone.lua，带红线和十字准星） ====================
local FOVCircle2 = {
    Gui = nil,
    Frame = nil,
    Stroke = nil,
    Visible = false,
    Radius = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Thickness = 2,
    Transparency = 0.5,
    Dot = nil,
    DotVisible = false,
    RedLine = nil,
    RedLineVisible = false,
    RedLineColor = Color3.fromRGB(255, 0, 0),
    CrosshairLines = {},
    CrosshairVisible = true,
}

local function CreateFOVCircle2()
    if FOVCircle2.Gui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle2"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    FOVCircle2.Gui = screenGui

    local camera = workspace.CurrentCamera
    local vs = camera and camera.ViewportSize or Vector2.new(1080, 1920)
    local radius = FOVCircle2.Radius
    local offsetX = AimConfig.fovOffsetX or 0
    local offsetY = AimConfig.fovOffsetY or 0

    local frame = Instance.new("Frame")
    frame.Name = "CircleFrame"
    frame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    frame.Position = UDim2.new(0, vs.X/2 - radius + offsetX, 0, vs.Y/2 - radius + offsetY)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    FOVCircle2.Frame = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = FOVCircle2.Thickness
    stroke.Color = FOVCircle2.Color
    stroke.Transparency = FOVCircle2.Transparency
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    FOVCircle2.Stroke = stroke

    local dot = Instance.new("Frame")
    dot.Name = "CalibrationDot"
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, vs.X/2 + offsetX - 3, 0, vs.Y/2 + offsetY - 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.BorderSizePixel = 0
    dot.Visible = false
    dot.Parent = screenGui

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Thickness = 1
    dotStroke.Color = Color3.fromRGB(255, 255, 255)
    dotStroke.Transparency = 0.5
    dotStroke.Parent = dot

    FOVCircle2.Dot = dot

    -- 红线（自瞄锁定线）
    local redLine = Instance.new("Frame")
    redLine.Name = "RedLine"
    redLine.Size = UDim2.new(0, 0, 0, 2)
    redLine.Position = UDim2.new(0, vs.X/2, 0, vs.Y/2)
    redLine.BackgroundColor3 = FOVCircle2.RedLineColor
    redLine.BackgroundTransparency = 0.5
    redLine.Visible = false
    redLine.Parent = screenGui
    FOVCircle2.RedLine = redLine

    -- 十字准星辅助线
    local function createCrosshairLine(posX, posY, sizeX, sizeY, parent)
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, sizeX, 0, sizeY)
        line.Position = UDim2.new(0, posX, 0, posY)
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.BackgroundTransparency = 0.3
        line.Visible = false
        line.Parent = parent
        return line
    end

    local crossSize = 10
    local thickness = 2
    local centerX = vs.X/2 + offsetX
    local centerY = vs.Y/2 + offsetY

    local hLine1 = createCrosshairLine(centerX - crossSize, centerY - thickness/2, crossSize, thickness, screenGui)
    local hLine2 = createCrosshairLine(centerX, centerY - thickness/2, crossSize, thickness, screenGui)
    local vLine1 = createCrosshairLine(centerX - thickness/2, centerY - crossSize, thickness, crossSize, screenGui)
    local vLine2 = createCrosshairLine(centerX - thickness/2, centerY, thickness, crossSize, screenGui)

    FOVCircle2.CrosshairLines = {hLine1, hLine2, vLine1, vLine2}
end

local function UpdateFOVCircle2()
    if not FOVCircle2.Frame then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local vs = camera.ViewportSize
    local radius = FOVCircle2.Radius
    local offsetX = AimConfig.fovOffsetX or 0
    local offsetY = AimConfig.fovOffsetY or 0

    FOVCircle2.Frame.Position = UDim2.new(0, vs.X/2 - radius + offsetX, 0, vs.Y/2 - radius + offsetY)
    FOVCircle2.Frame.Size = UDim2.new(0, radius * 2, 0, radius * 2)

    if FOVCircle2.Dot then
        FOVCircle2.Dot.Position = UDim2.new(0, vs.X/2 + offsetX - 3, 0, vs.Y/2 + offsetY - 3)
    end

    local centerX = vs.X/2 + offsetX
    local centerY = vs.Y/2 + offsetY
    local crossSize = 10
    local thickness = 2

    local lines = FOVCircle2.CrosshairLines
    if #lines >= 4 then
        lines[1].Position = UDim2.new(0, centerX - crossSize, 0, centerY - thickness/2)
        lines[1].Size = UDim2.new(0, crossSize, 0, thickness)
        lines[2].Position = UDim2.new(0, centerX, 0, centerY - thickness/2)
        lines[2].Size = UDim2.new(0, crossSize, 0, thickness)
        lines[3].Position = UDim2.new(0, centerX - thickness/2, 0, centerY - crossSize)
        lines[3].Size = UDim2.new(0, thickness, 0, crossSize)
        lines[4].Position = UDim2.new(0, centerX - thickness/2, 0, centerY)
        lines[4].Size = UDim2.new(0, thickness, 0, crossSize)
    end

    if FOVCircle2.RedLine then
        FOVCircle2.RedLine.Position = UDim2.new(0, centerX, 0, centerY)
    end
end

local function SetFOVCircle2Visible(visible)
    FOVCircle2.Visible = visible
    if FOVCircle2.Frame then
        FOVCircle2.Frame.Visible = visible
    end
    if FOVCircle2.Dot then
        FOVCircle2.Dot.Visible = FOVCircle2.DotVisible and visible
    end
    for _, line in ipairs(FOVCircle2.CrosshairLines) do
        line.Visible = visible and FOVCircle2.CrosshairVisible
    end
    if FOVCircle2.RedLine then
        FOVCircle2.RedLine.Visible = visible and FOVCircle2.RedLineVisible
    end
end

local function UpdateFOVCircle2Color()
    if FOVCircle2.Stroke then
        local color = getCurrentColor(AimConfig.fovcolorMode, AimConfig.fovcolorFixed)
        FOVCircle2.Stroke.Color = color
    end
end

local function SetCalibrationDot2Visible(visible)
    FOVCircle2.DotVisible = visible
    if FOVCircle2.Dot then
        FOVCircle2.Dot.Visible = visible and FOVCircle2.Visible
    end
end

local function UpdateAimLockLine2()
    if not FOVCircle2.RedLine or not FOVCircle2.Visible then
        if FOVCircle2.RedLine then FOVCircle2.RedLine.Visible = false end
        return
    end

    local target = GetBestTarget()
    if target and target.Character then
        local part = getTargetPart(target.Character)
        if part then
            local camera = workspace.CurrentCamera
            local sp, on = camera:WorldToViewportPoint(part.Position)
            if on then
                local center = camera.ViewportSize / 2
                local offsetX = AimConfig.fovOffsetX or 0
                local offsetY = AimConfig.fovOffsetY or 0

                local dx = sp.X - (center.X + offsetX)
                local dy = sp.Y - (center.Y + offsetY)
                local dist = math.sqrt(dx * dx + dy * dy)

                if dist > 0 then
                    local angle = math.atan2(dy, dx)
                    FOVCircle2.RedLine.Size = UDim2.new(0, dist, 0, 2)
                    FOVCircle2.RedLine.Position = UDim2.new(0, center.X + offsetX, 0, center.Y + offsetY)
                    FOVCircle2.RedLine.Rotation = math.deg(angle)
                    FOVCircle2.RedLine.BackgroundColor3 = getCurrentColor(AimConfig.lineColorMode, AimConfig.lineColorFixed)
                    FOVCircle2.RedLine.Visible = true
                    FOVCircle2.RedLine.BackgroundTransparency = 0.5
                    return
                end
            end
        end
    end
    FOVCircle2.RedLine.Visible = false
end

local function InitAimFOV2(radius, color, thickness, transparency)
    FOVCircle2.Radius = radius or 50
    FOVCircle2.Color = color or Color3.fromRGB(0, 255, 0)
    FOVCircle2.Thickness = thickness or 2
    FOVCircle2.Transparency = transparency or 0.5
    CreateFOVCircle2()
    UpdateFOVCircle2()
    UpdateFOVCircle2Color()
    SetFOVCircle2Visible(showFOVCircleFlag)
end

-- ==================== FOV圈统一管理 ====================
local showFOVCircleFlag = false

local function UpdateFOVCircle()
    if AimConfig.fovCircleVersion == 1 then
        UpdateFOVCircle1()
    else
        UpdateFOVCircle2()
    end
end

local function SetFOVCircleVisible(visible)
    showFOVCircleFlag = visible
    if AimConfig.fovCircleVersion == 1 then
        SetFOVCircle1Visible(visible)
    else
        SetFOVCircle2Visible(visible)
    end
end

local function UpdateFOVCircleColor()
    if AimConfig.fovCircleVersion == 1 then
        UpdateFOVCircle1Color()
    else
        UpdateFOVCircle2Color()
    end
end

local function SetCalibrationDotVisible(visible)
    if AimConfig.fovCircleVersion == 1 then
        SetCalibrationDot1Visible(visible)
    else
        SetCalibrationDot2Visible(visible)
    end
end

local function InitAimFOV(radius, color, thickness, transparency)
    InitAimFOV1(radius, color, thickness, transparency)
    InitAimFOV2(radius, color, thickness, transparency)
    if AimConfig.fovCircleVersion == 1 then
        SetFOVCircle1Visible(showFOVCircleFlag)
        SetFOVCircle2Visible(false)
    else
        SetFOVCircle1Visible(false)
        SetFOVCircle2Visible(showFOVCircleFlag)
    end
end

-- FOV 微调卡片回调
FOVAdjust:SetOnChange(function(x, y)
    AimConfig.fovOffsetX = x
    AimConfig.fovOffsetY = y
    UpdateFOVCircle()
end)

-- ==================== 目标文字标签 ====================
local TargetTextLabels = {}
local TargetTextGui = nil

local function CreateTargetTextGui()
    if TargetTextGui then return end
    TargetTextGui = Instance.new("ScreenGui")
    TargetTextGui.Name = "TargetTextLabels"
    TargetTextGui.ResetOnSpawn = false
    TargetTextGui.Parent = game:GetService("CoreGui")
end

local function ClearTargetTextLabels()
    for _, label in pairs(TargetTextLabels) do
        if label then label:Destroy() end
    end
    TargetTextLabels = {}
end

local function UpdateTargetTextLabels()
    if not AimConfig.fovlookAt then
        ClearTargetTextLabels()
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local center = camera.ViewportSize / 2
    local fovR = AimConfig.fovsize
    local lp = game.Players.LocalPlayer

    local targets = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= lp then
            local skip = false
            if AimConfig.aliveCheck and not IsAlive(p) then skip = true end
            if not skip and AimConfig.teamCheck and IsSameTeam(p) then skip = true end
            if not skip then
                local part = getTargetPart(p.Character)
                if part then
                    local sp, on = camera:WorldToViewportPoint(part.Position)
                    if on then
                        local distToCenter = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if distToCenter <= fovR and (not AimConfig.wallCheck or CheckWall(p, part)) then
                            table.insert(targets, {player = p, pos = Vector2.new(sp.X, sp.Y)})
                        end
                    end
                end
            end
        end
    end

    CreateTargetTextGui()
    local labelsToKeep = {}
    for _, info in ipairs(targets) do
        local label = TargetTextLabels[info.player]
        if not label then
            label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 150, 0, 20)
            label.BackgroundTransparency = 1
            label.TextColor3 = getCurrentColor(AimConfig.textColorMode, AimConfig.textColorFixed)
            label.Font = Enum.Font.GothamBold
            label.TextSize = TextSize
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Parent = TargetTextGui
            TargetTextLabels[info.player] = label
        end
        local hum = info.player.Character and info.player.Character:FindFirstChild("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        local name = info.player.DisplayName or info.player.Name
        label.Text = name .. "  [" .. hp .. " HP]"
        label.Position = UDim2.new(0, info.pos.X - 75, 0, info.pos.Y - 40)
        label.Visible = true
        labelsToKeep[info.player] = true
    end

    for player, label in pairs(TargetTextLabels) do
        if not labelsToKeep[player] then
            label.Visible = false
        end
    end
end

-- ==================== 自瞄逻辑 ====================
local function AimAI()
    local target = GetBestTarget()
    if target and target.Character then
        local part = getTargetPart(target.Character)
        if part then
            local pos = part.Position
            if IsInFOV(pos) then
                if AimConfig.prejudgingselfsighting then
                    local dist = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude
                    if dist <= AimConfig.prejudgingselfsightingdistance then
                        pos = PredictPosition(part)
                    end
                end
                if AimConfig.aimModeType == "强锁" then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
                else
                    local alpha = math.clamp((AimConfig.aimSpeed / 10) * (1 / AimConfig.smoothness), 0.02, 0.8)
                    local cur = workspace.CurrentCamera.CFrame
                    local targetCF = CFrame.new(cur.Position, pos)
                    workspace.CurrentCamera.CFrame = cur:Lerp(targetCF, alpha)
                end
                if AimConfig.autoFire then
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            local now = tick()
                            local lastFire = tool:GetAttribute("LastFireTime") or 0
                            if (now - lastFire) >= (1 / AimConfig.fireRate) then
                                local fired = false
                                local events = {"Fire", "Shoot", "Click", "Attack", "Activate", "RemoteEvent"}
                                for _, evName in ipairs(events) do
                                    local ev = tool:FindFirstChild(evName)
                                    if ev and ev:IsA("RemoteEvent") then
                                        ev:FireServer()
                                        fired = true
                                        break
                                    end
                                end
                                if not fired then pcall(function() tool:Activate() end) end                                tool:SetAttribute("LastFireTime", now)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function AimFunction()
    local target = GetBestTarget()
    if target and target.Character then
        local part = getTargetPart(target.Character)
        if part then
            local pos = part.Position
            if IsInFOV(pos) then
                local predicted = pos
                if AimConfig.prejudgingselfsighting then
                    local dist = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude
                    if dist <= AimConfig.prejudgingselfsightingdistance then
                        local time = (part.Position - workspace.CurrentCamera.CFrame.Position).Magnitude / 1000
                        predicted = pos + part.AssemblyLinearVelocity * time + 0.5 * Vector3.new(0, -workspace.Gravity, 0) * time^2
                    end
                end
                if AimConfig.aimModeType == "强锁" then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, predicted)
                else
                    local alpha = math.clamp((AimConfig.aimSpeed / 10) * (1 / AimConfig.smoothness), 0.02, 0.8)
                    local cur = workspace.CurrentCamera.CFrame
                    local targetCF = CFrame.new(cur.Position, predicted)
                    workspace.CurrentCamera.CFrame = cur:Lerp(targetCF, alpha)
                end
                if AimConfig.autoFire then
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            local now = tick()
                            local lastFire = tool:GetAttribute("LastFireTime") or 0
                            if (now - lastFire) >= (1 / AimConfig.fireRate) then
                                local fired = false
                                local events = {"Fire", "Shoot", "Click", "Attack", "Activate", "RemoteEvent"}
                                for _, evName in ipairs(events) do
                                    local ev = tool:FindFirstChild(evName)
                                    if ev and ev:IsA("RemoteEvent") then
                                        ev:FireServer()
                                        fired = true
                                        break
                                    end
                                end
                                if not fired then pcall(function() tool:Activate() end) end
                                tool:SetAttribute("LastFireTime", now)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ==================== 夜视功能 ====================
local Lighting = game:GetService("Lighting")
local function SaveOriginalLighting()
    if NightVision.originalSettings then return end
    NightVision.originalSettings = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogColor = Lighting.FogColor,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        ClockTime = Lighting.ClockTime,
    }
end

local function ApplyNightVision()
    Lighting.Brightness = 3
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.FogColor = Color3.new(0,0,0)
    Lighting.FogEnd = 1e9
    Lighting.GlobalShadows = false
    Lighting.ClockTime = 12
end

local function RestoreLighting()
    if NightVision.originalSettings then
        for k, v in pairs(NightVision.originalSettings) do
            Lighting[k] = v
        end
    end
end

local function StartNightVision()
    if NightVision.connection then NightVision.connection:Disconnect() end
    SaveOriginalLighting()
    ApplyNightVision()
    NightVision.connection = game:GetService("RunService").Heartbeat:Connect(function()
        if Lighting.Brightness ~= 3 or Lighting.Ambient ~= Color3.new(1,1,1) then
            ApplyNightVision()
        end
    end)
end

local function StopNightVision()
    if NightVision.connection then
        NightVision.connection:Disconnect()
        NightVision.connection = nil
    end
    RestoreLighting()
end

-- ==================== 热能透视 ====================
local function UpdateThermalESP()
    local lp = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= lp then
            local char = player.Character
            if char then
                local highlight = ThermalESP.highlights[player]
                if ThermalESP.enabled then
                    local shouldShow = (not ESPConfig.teamCheck or not IsSameTeam(player)) and (not AimConfig.aliveCheck or IsAlive(player))
                    if shouldShow then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "ThermalESP"
                            highlight.Parent = char
                            highlight.Adornee = char
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.OutlineColor = Color3.new(1,1,1)
                            ThermalESP.highlights[player] = highlight
                        end
                        local color = ThermalESP.colorMode == "固定" and ThermalESP.color or getDynamicColor(ThermalESP.colorMode)
                        highlight.FillColor = color
                        highlight.Enabled = true
                    else
                        if highlight then highlight.Enabled = false end
                    end
                else
                    if highlight then highlight:Destroy() end
                    ThermalESP.highlights[player] = nil
                end
            else
                if highlight then highlight:Destroy() end
                ThermalESP.highlights[player] = nil
            end
        end
    end
end

local function SetupThermalEvents()
    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function() task.wait(0.5); UpdateThermalESP() end)
        UpdateThermalESP()
    end)
    game.Players.PlayerRemoving:Connect(function(player)
        local h = ThermalESP.highlights[player]
        if h then h:Destroy() end
        ThermalESP.highlights[player] = nil
    end)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            player.CharacterAdded:Connect(function() task.wait(0.5); UpdateThermalESP() end)
        end
    end
end

-- ==================== ESP2 功能函数 ====================
local function ESP2_GetDynamicColor(mode, speed)
    speed = speed or AimConfig.colorSpeed
    local t = tick() * speed
    if mode == "循环色相" then
        local hue = (t % 2) / 2
        return Color3.fromHSV(hue, 1, 1)
    elseif mode == "瀑布" then
        local hue = (t % 2) / 2
        local brightness = (math.sin(t * 2) + 1) / 2
        return Color3.fromHSV(hue, 1, brightness)
    elseif mode == "波浪" then
        local r = (math.sin(t * 1.3) + 1) / 2
        local g = (math.sin(t * 1.7 + 2) + 1) / 2
        local b = (math.sin(t * 2.1 + 4) + 1) / 2
        return Color3.new(r, g, b)
    end
    return Color3.fromHSV(0, 1, 1)
end

local function ESP2_GetCurrentColor(mode, fixedColor)
    if mode == "固定" then return fixedColor end
    return ESP2_GetDynamicColor(mode)
end

local function ESP2_Create(Class, Properties)
    local inst = (type(Class) == "string") and Instance.new(Class) or Class
    for prop, val in pairs(Properties) do
        inst[prop] = val
    end
    return inst
end

local function ESP2_FadeOutOnDist(element, distance, maxDist)
    local maxD = maxDist or ESP2_Settings.MaxDistance
    local transparency = math.max(0.1, 1 - (distance / maxD))
    if element:IsA("TextLabel") then
        element.TextTransparency = 1 - transparency
    elseif element:IsA("ImageLabel") then
        element.ImageTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then
        element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    elseif element:IsA("Highlight") then
        element.FillTransparency = 1 - transparency
        element.OutlineTransparency = 1 - transparency
    end
end

local function CreateESP2ScreenGui()
    if ESP2.ScreenGui then return end
    ESP2.ScreenGui = ESP2_Create("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        Name = "ESP2Holder",
        Enabled = true,
    })
end

local function CreateESP2ForPlayer(plr)
    if ESP2.PlayerElements[plr] then return end
    local sg = ESP2.ScreenGui
    if not sg then return end

    local elements = {}
    elements.Name = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    elements.Distance = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    elements.Weapon = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    elements.Box = ESP2_Create("Frame", {Parent = sg, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0})
    elements.Outline = ESP2_Create("UIStroke", {Parent = elements.Box, Enabled = false, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
    elements.Healthbar = ESP2_Create("Frame", {Parent = sg, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0})
    elements.BehindHealthbar = ESP2_Create("Frame", {Parent = sg, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
    elements.HealthText = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
    elements.Chams = ESP2_Create("Highlight", {Parent = sg, FillTransparency = 1, OutlineTransparency = 0, OutlineColor = Color3.fromRGB(119, 120, 255), DepthMode = "AlwaysOnTop"})
    elements.WeaponIcon = ESP2_Create("ImageLabel", {Parent = sg, BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(0, 40, 0, 40)})
    elements.Gradient1 = ESP2_Create("UIGradient", {Parent = elements.Box, Enabled = false, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(119, 120, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))}})
    elements.Gradient2 = ESP2_Create("UIGradient", {Parent = elements.Outline, Enabled = false, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(119, 120, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))}})
    elements.Gradient3 = ESP2_Create("UIGradient", {Parent = elements.WeaponIcon, Rotation = -90, Enabled = false, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(119, 120, 255))}})
    for _, v in pairs(elements) do if v and v:IsA("GuiObject") then v.Visible = false end end
    if elements.Chams then elements.Chams.Enabled = false end
    ESP2.PlayerElements[plr] = elements
end

local function DestroyESP2ForPlayer(plr)
    local elements = ESP2.PlayerElements[plr]
    if elements then
        for _, v in pairs(elements) do if v then pcall(function() v:Destroy() end) end end
        ESP2.PlayerElements[plr] = nil
    end
end

local function UpdateESP2()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local lp = game.Players.LocalPlayer
    local maxDist = ESP2_Settings.MaxDistance

    local boxColor = ESP2_GetCurrentColor(ESP2_Settings.BoxColorMode, ESP2_Settings.BoxColor)
    local nameColor = ESP2_GetCurrentColor(ESP2_Settings.NameColorMode, ESP2_Settings.NameColor)
    local healthColor = ESP2_GetCurrentColor(ESP2_Settings.HealthBarColorMode, ESP2_Settings.HealthBarColor)

    for plr, elements in pairs(ESP2.PlayerElements) do
        local shouldHide = true
        if plr and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local sameTeam = (ESP2_Settings.TeamCheck and lp.Team == plr.Team and lp.Team ~= nil)
                if not sameTeam then
                    local pos, onScreen = camera:WorldToScreenPoint(hrp.Position)
                    local dist = (camera.CFrame.Position - hrp.Position).Magnitude
                    if onScreen and dist <= maxDist then
                        shouldHide = false
                        local size = hrp.Size.Y
                        local scaleFactor = (size * camera.ViewportSize.Y) / (pos.Z * 2)
                        local w = 3 * scaleFactor
                        local h = 4.5 * scaleFactor

                        ESP2_FadeOutOnDist(elements.Box, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Outline, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Name, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Healthbar, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.BehindHealthbar, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.HealthText, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Chams, dist, maxDist)

                        if ESP2_Settings.ShowBox then
                            elements.Box.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
                            elements.Box.Size = UDim2.new(0, w, 0, h)
                            elements.Box.Visible = true
                            elements.Box.BackgroundTransparency = 0.75
                            elements.Box.BorderSizePixel = 1
                            elements.Box.BackgroundColor3 = boxColor
                        else
                            elements.Box.Visible = false
                        end

                        if ESP2_Settings.ShowChams then
                            elements.Chams.Adornee = char
                            elements.Chams.Enabled = true
                            elements.Chams.FillColor = Color3.fromRGB(119, 120, 255)
                            elements.Chams.FillTransparency = 0.8
                            elements.Chams.OutlineColor = Color3.fromRGB(119, 120, 255)
                            elements.Chams.OutlineTransparency = 0.5
                            elements.Chams.DepthMode = "AlwaysOnTop"
                        else
                            elements.Chams.Enabled = false
                        end

                        if ESP2_Settings.ShowName then
                            elements.Name.Text = string.format("%s [%dm]", plr.Name, math.floor(dist))
                            elements.Name.Position = UDim2.new(0, pos.X, 0, pos.Y - h/2 - 9)
                            elements.Name.TextColor3 = nameColor
                            elements.Name.Visible = true
                        else
                            elements.Name.Visible = false
                        end

                        if ESP2_Settings.ShowHealth then
                            local health = hum.Health / hum.MaxHealth
                            health = math.clamp(health, 0, 1)
                            elements.Healthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1 - health))
                            elements.Healthbar.Size = UDim2.new(0, 2.5, 0, h * health)
                            elements.Healthbar.BackgroundColor3 = healthColor
                            elements.Healthbar.Visible = true
                            elements.BehindHealthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2)
                            elements.BehindHealthbar.Size = UDim2.new(0, 2.5, 0, h)
                            elements.BehindHealthbar.Visible = true
                            local healthPercent = math.floor(hum.Health / hum.MaxHealth * 100)
                            elements.HealthText.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1 - healthPercent/100) + 3)
                            elements.HealthText.Text = tostring(healthPercent)
                            elements.HealthText.Visible = (hum.Health < hum.MaxHealth)
                        else
                            elements.Healthbar.Visible = false
                            elements.BehindHealthbar.Visible = false
                            elements.HealthText.Visible = false
                        end

                        elements.Weapon.Visible = false
                        elements.WeaponIcon.Visible = false
                        elements.Distance.Visible = false
                    end
                end
            end
        end
        if shouldHide then
            for _, v in pairs(elements) do if v and v:IsA("GuiObject") then v.Visible = false end end
            if elements.Chams then elements.Chams.Enabled = false end
        end
    end

    for plr, _ in pairs(ESP2.PlayerElements) do
        if not game.Players:FindFirstChild(plr.Name) then DestroyESP2ForPlayer(plr) end
    end
end

local function StartESP2()
    if ESP2.RenderConnection then return end
    ESP2.RenderConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if ESP2_Settings.Enabled then
            UpdateESP2()
        else
            for plr, elements in pairs(ESP2.PlayerElements) do
                for _, v in pairs(elements) do if v and v:IsA("GuiObject") then v.Visible = false end end
                if elements.Chams then elements.Chams.Enabled = false end
            end
        end
    end)
end

local function InitESP2Events()
    if ESP2.Connections.PlayerAdded then return end
    ESP2.Connections.PlayerAdded = game.Players.PlayerAdded:Connect(function(plr)
        if plr == game.Players.LocalPlayer then return end
        CreateESP2ForPlayer(plr)
    end)
    ESP2.Connections.PlayerRemoving = game.Players.PlayerRemoving:Connect(function(plr)
        DestroyESP2ForPlayer(plr)
    end)
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then CreateESP2ForPlayer(plr) end
    end
end

local function SetESP2Enabled(enabled)
    ESP2_Settings.Enabled = enabled
    if enabled then
        CreateESP2ScreenGui()
        InitESP2Events()
        StartESP2()
    else
        for plr, elements in pairs(ESP2.PlayerElements) do
            for _, v in pairs(elements) do if v and v:IsA("GuiObject") then v.Visible = false end end
            if elements.Chams then elements.Chams.Enabled = false end
        end
    end
end

-- ==================== 目标信息面板（小窗，可开关） ====================
local TargetInfo = {
    Panel = nil, Avatar = nil, NameLabel = nil, HealthBarBg = nil, HealthBarFill = nil,
    HealthText = nil, DistanceText = nil, CurrentTarget = nil, IsVisible = false,
    TweenIn = nil, TweenOut = nil, UpdateConnection = nil, LastHealth = {},
}

local function ClearAllParticles()
    local parent = TargetInfo.Panel and TargetInfo.Panel.Parent
    if not parent then return end
    for _, child in ipairs(parent:GetChildren()) do if child.Name == "Particle" then child:Destroy() end end
end

local function CreateTargetInfoPanel()
    local screenGui = game:GetService("CoreGui"):FindFirstChild("AimAssistPanel")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AimAssistPanel"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game:GetService("CoreGui")
    end
    local existing = screenGui:FindFirstChild("TargetInfoPanel")
    if existing then existing:Destroy() end
    local isMobileDevice = game:GetService("UserInputService").TouchEnabled
    local PANEL_WIDTH, PANEL_HEIGHT, AVATAR_SIZE, FONT_SIZE_NAME, FONT_SIZE_TEXT
    if isMobileDevice then
        PANEL_WIDTH = math.min(220, workspace.CurrentCamera.ViewportSize.X * 0.7)
        PANEL_HEIGHT = 90
        AVATAR_SIZE = 50
        FONT_SIZE_NAME = 12
        FONT_SIZE_TEXT = 10
    else
        PANEL_WIDTH = 280
        PANEL_HEIGHT = 110
        AVATAR_SIZE = 64
        FONT_SIZE_NAME = 14
        FONT_SIZE_TEXT = 12
    end
    local panel = Instance.new("Frame")
    panel.Name = "TargetInfoPanel"
    panel.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
    panel.Position = UDim2.new(1, 20, 0.5, -PANEL_HEIGHT/2)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.Visible = true
    panel.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE)
    avatar.Position = UDim2.new(0, 8, 0.5, -AVATAR_SIZE/2)
    avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    avatar.BackgroundTransparency = 0.2
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Parent = panel
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, AVATAR_SIZE/2)
    avatarCorner.Parent = avatar
    local name = Instance.new("TextLabel")
    name.Name = "NameLabel"
    name.Size = UDim2.new(1, - (AVATAR_SIZE + 16), 0, 24)
    name.Position = UDim2.new(0, AVATAR_SIZE + 12, 0, 6)
    name.BackgroundTransparency = 1
    name.Text = ""
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Font = Enum.Font.GothamBold
    name.TextSize = FONT_SIZE_NAME
    name.Parent = panel
    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.Size = UDim2.new(1, - (AVATAR_SIZE + 16), 0, 10)
    healthBg.Position = UDim2.new(0, AVATAR_SIZE + 12, 0, 32)
    healthBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = panel
    local healthBgCorner = Instance.new("UICorner")
    healthBgCorner.CornerRadius = UDim.new(0, 4)
    healthBgCorner.Parent = healthBg
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg
    local healthFillCorner = Instance.new("UICorner")
    healthFillCorner.CornerRadius = UDim.new(0, 4)
    healthFillCorner.Parent = healthFill
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, - (AVATAR_SIZE + 16), 0, 18)
    healthText.Position = UDim2.new(0, AVATAR_SIZE + 12, 0, 46)
    healthText.BackgroundTransparency = 1
    healthText.Text = ""
    healthText.TextColor3 = Color3.fromRGB(220, 220, 220)
    healthText.TextXAlignment = Enum.TextXAlignment.Left
    healthText.Font = Enum.Font.Gotham
    healthText.TextSize = FONT_SIZE_TEXT
    healthText.Parent = panel
    local distanceText = Instance.new("TextLabel")
    distanceText.Name = "DistanceText"
    distanceText.Size = UDim2.new(0, 70, 0, 18)
    distanceText.Position = UDim2.new(1, -78, 0, PANEL_HEIGHT - 24)
    distanceText.BackgroundTransparency = 1
    distanceText.Text = ""
    distanceText.TextColor3 = Color3.fromRGB(200, 200, 100)
    distanceText.TextXAlignment = Enum.TextXAlignment.Right
    distanceText.Font = Enum.Font.Gotham
    distanceText.TextSize = FONT_SIZE_TEXT
    distanceText.Parent = panel
    local appearTween = game:GetService("TweenService"):Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -PANEL_WIDTH - 20, 0.5, -PANEL_HEIGHT/2),
        BackgroundTransparency = 0.15
    })
    local disappearTween = game:GetService("TweenService"):Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 20, 0.5, -PANEL_HEIGHT/2),
        BackgroundTransparency = 1
    })
    TargetInfo.Panel = panel
    TargetInfo.Avatar = avatar
    TargetInfo.NameLabel = name
    TargetInfo.HealthBarBg = healthBg
    TargetInfo.HealthBarFill = healthFill
    TargetInfo.HealthText = healthText
    TargetInfo.DistanceText = distanceText
    TargetInfo.TweenIn = appearTween
    TargetInfo.TweenOut = disappearTween
end

local function SetPlayerAvatar(player)
    if not TargetInfo.Avatar then return end
    local userId = player.UserId
    local avatarUrl = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", userId)
    TargetInfo.Avatar.Image = avatarUrl
end

local function createParticle(centerX, centerY, ts)
    local shape = ParticleConfig.shape
    local size = ParticleConfig.size
    local particle
    if shape == "圆形" then
        particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, size, 0, size)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        particle.BackgroundColor3 = getParticleColor()
        particle.BackgroundTransparency = 0.3
        particle.BorderSizePixel = 0
    elseif shape == "爱心" then
        particle = Instance.new("TextLabel")
        local symbol = heartSymbols[math.random(1, #heartSymbols)]
        particle.Text = symbol
        particle.Font = Enum.Font.GothamBold
        particle.TextSize = size
        particle.TextColor3 = getParticleColor()
        particle.BackgroundTransparency = 1
        particle.Size = UDim2.new(0, size+6, 0, size+6)
    elseif shape == "🩸" then
        particle = Instance.new("TextLabel")
        particle.Text = "🩸"
        particle.Font = Enum.Font.GothamBold
        particle.TextSize = size
        particle.TextColor3 = getParticleColor()
        particle.BackgroundTransparency = 1
        particle.Size = UDim2.new(0, size+6, 0, size+6)
    end
    if not particle then return end
    particle.Name = "Particle"
    particle.Parent = TargetInfo.Panel.Parent
    local angle = math.random() * math.pi * 2
    local radius = math.random(20, 60)
    local offsetX = math.cos(angle) * radius
    local offsetY = math.sin(angle) * radius - 20
    particle.Position = UDim2.new(0, centerX + offsetX, 0, centerY + offsetY)
    local endPos = UDim2.new(0, centerX + offsetX * 1.8, 0, centerY + offsetY * 1.8 - 30)
    local tweenProps = (shape == "圆形") and {Position = endPos, BackgroundTransparency = 1} or {Position = endPos, TextTransparency = 1}
    local tween = ts:Create(particle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), tweenProps)
    tween:Play()
    tween.Completed:Connect(function() particle:Destroy() end)
end

local isShaking = false
local function PlayHitEffect()
    local tweenService = game:GetService("TweenService")
    if not TargetInfo.Avatar or not TargetInfo.Avatar.Parent or isShaking or not PanelConfig.enabled then
        return
    end
    isShaking = true
    ClearAllParticles()
    local originalPos = TargetInfo.Avatar.Position
    local offsetRight = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 6, originalPos.Y.Scale, originalPos.Y.Offset)
    local offsetLeft = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 6, originalPos.Y.Scale, originalPos.Y.Offset)
    local shakeRight = tweenService:Create(TargetInfo.Avatar, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {Position = offsetRight})
    local shakeLeft = tweenService:Create(TargetInfo.Avatar, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {Position = offsetLeft})
    local back = tweenService:Create(TargetInfo.Avatar, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {Position = originalPos})
    shakeRight:Play()
    shakeRight.Completed:Connect(function()
        shakeLeft:Play()
        shakeLeft.Completed:Connect(function()
            back:Play()
            back.Completed:Connect(function() isShaking = false end)
        end)
    end)
    local avatarAbsPos = TargetInfo.Avatar.AbsolutePosition
    local avatarSize = TargetInfo.Avatar.AbsoluteSize
    local center = avatarAbsPos + avatarSize/2
    for i = 1, ParticleConfig.count do createParticle(center.X, center.Y, tweenService) end
end

local function UpdateTargetPanel(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    if AimConfig.aliveCheck and not IsAlive(targetPlayer) then return false end
    if AimConfig.teamCheck and IsSameTeam(targetPlayer) then return false end
    local hum = targetPlayer.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    TargetInfo.NameLabel.Text = targetPlayer.DisplayName or targetPlayer.Name
    local currentHealth = hum.Health
    local maxHealth = hum.MaxHealth
    local healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)
    TargetInfo.HealthBarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
    if healthPercent > 0.6 then
        TargetInfo.HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    elseif healthPercent > 0.3 then
        TargetInfo.HealthBarFill.BackgroundColor3 = Color3.fromRGB(250, 180, 30)
    else
        TargetInfo.HealthBarFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
    TargetInfo.HealthText.Text = string.format("%.0f / %.0f", currentHealth, maxHealth)
    local localChar = game.Players.LocalPlayer.Character
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = 0
    if localChar and localChar:FindFirstChild("HumanoidRootPart") and targetRoot then
        distance = (localChar.HumanoidRootPart.Position - targetRoot.Position).Magnitude
    end
    TargetInfo.DistanceText.Text = string.format("%.1f m", distance)
    SetPlayerAvatar(targetPlayer)
    local last = TargetInfo.LastHealth[targetPlayer] or currentHealth
    if currentHealth < last then PlayHitEffect() end
    TargetInfo.LastHealth[targetPlayer] = currentHealth
    return true
end

local function GetBestTargetInFOV()
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local fovRadius = AimConfig.fovsize
    local center = camera.ViewportSize / 2
    local bestTarget = nil
    local bestScore = math.huge
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            local skip = false
            if AimConfig.aliveCheck and not IsAlive(player) then skip = true end
            if not skip and AimConfig.teamCheck and IsSameTeam(player) then skip = true end
            if not skip then
                local head = player.Character and player.Character:FindFirstChild("Head")
                if head then
                    local wallOk = true
                    if AimConfig.wallCheck then
                        local localChar = localPlayer.Character
                        local ray = Ray.new(camera.CFrame.Position, head.Position - camera.CFrame.Position)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {localChar})
                        if hit and not hit:IsDescendantOf(player.Character) then wallOk = false end
                    end
                    if wallOk then
                        local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local distToCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                            if distToCenter <= fovRadius and distToCenter < bestScore then
                                bestScore = distToCenter
                                bestTarget = player
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function ShowPanel()
    if not PanelConfig.enabled then return end
    if TargetInfo.TweenOut and TargetInfo.TweenOut.PlaybackState == Enum.PlaybackState.Playing then
        TargetInfo.TweenOut:Cancel()
        local PANEL_HEIGHT = TargetInfo.Panel.AbsoluteSize.Y
        TargetInfo.Panel.Position = UDim2.new(1, 20, 0.5, -PANEL_HEIGHT/2)
        TargetInfo.Panel.BackgroundTransparency = 1
    end
    TargetInfo.IsVisible = true
    TargetInfo.Panel.Visible = true
    if not (TargetInfo.TweenIn and TargetInfo.TweenIn.PlaybackState == Enum.PlaybackState.Playing) then
        TargetInfo.TweenIn:Play()
    end
end

local function HidePanel()
    if not TargetInfo.IsVisible then return end
    TargetInfo.IsVisible = false
    TargetInfo.TweenOut:Play()
    TargetInfo.TweenOut.Completed:Wait()
    TargetInfo.Panel.Visible = false
    ClearAllParticles()
end

local function RefreshTarget(target)
    if not PanelConfig.enabled then if TargetInfo.IsVisible then HidePanel() end; return end
    if not target then if TargetInfo.IsVisible then HidePanel() end; return end
    local success = UpdateTargetPanel(target)
    if not success then if TargetInfo.IsVisible then HidePanel() end; return end
    if TargetInfo.CurrentTarget ~= target then TargetInfo.CurrentTarget = target end
    if not TargetInfo.IsVisible or not TargetInfo.Panel.Visible then ShowPanel() end
end

local function OnRenderStep()
    if not TargetInfo.Panel then CreateTargetInfoPanel() end
    if not AimConfig.fovlookAt then if TargetInfo.IsVisible then HidePanel() end; return end
    local best = GetBestTargetInFOV()
    RefreshTarget(best)
end

if TargetInfo.UpdateConnection then TargetInfo.UpdateConnection:Disconnect() end
TargetInfo.UpdateConnection = game:GetService("RunService").RenderStepped:Connect(OnRenderStep)

game.Players.PlayerRemoving:Connect(function(player)
    TargetInfo.LastHealth[player] = nil
    if TargetInfo.CurrentTarget == player then TargetInfo.CurrentTarget = nil; if TargetInfo.IsVisible then HidePanel() end end
    local h = ThermalESP.highlights[player]; if h then h:Destroy() end; ThermalESP.highlights[player] = nil
end)

local function onPlayerCharacterAdded(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            local label = TargetTextLabels[player]
            if label then label:Destroy() end
            TargetTextLabels[player] = nil
        end)
    end
end

for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then onPlayerCharacterAdded(player) end
end
game.Players.PlayerAdded:Connect(onPlayerCharacterAdded)

-- ==================== LinoriaLib UI 构建 ====================
local Tabs = {
    Main = Window:AddTab("主控", "user"),
    Aim = Window:AddTab("自瞄", "crosshair"),
    Visual = Window:AddTab("透视", "eye"),
    FOV = Window:AddTab("FOV圈", "circle"),
    Settings = Window:AddTab("设置", "settings"),
}

-- 主控
local MainGroup = Tabs.Main:AddGroupbox({ Side = "Left", Name = "主控开关" })
MainGroup:AddToggle("AimToggle", { Text = "开启自瞄", Default = AimConfig.fovlookAt, Callback = function(v) AimConfig.fovlookAt = v end })
MainGroup:AddToggle("FOVToggle", { Text = "显示FOV圈圈", Default = showFOVCircleFlag, Callback = function(v)
    if v then
        InitAimFOV(AimConfig.fovsize, getCurrentColor(AimConfig.fovcolorMode, AimConfig.fovcolorFixed), AimConfig.fovthickness, AimConfig.Transparency/10)
        SetFOVCircleVisible(true)
        if AimConfig.fovCalibrationMode then
            FOVAdjust:SetVisible(true)
            SetCalibrationDotVisible(true)
        end
    else
        SetFOVCircleVisible(false)
        FOVAdjust:SetVisible(false)
        SetCalibrationDotVisible(false)
    end
end })

local MainGroup2 = Tabs.Main:AddGroupbox({ Side = "Right", Name = "功能选项" })
MainGroup2:AddToggle("TeamCheck", { Text = "队伍检测", Default = AimConfig.teamCheck, Callback = function(v) AimConfig.teamCheck = v; ESPConfig.teamCheck = v end })
MainGroup2:AddToggle("AliveCheck", { Text = "活体检测", Default = AimConfig.aliveCheck, Callback = function(v) AimConfig.aliveCheck = v end })
MainGroup2:AddToggle("WallCheck", { Text = "墙壁检测", Default = AimConfig.wallCheck, Callback = function(v) AimConfig.wallCheck = v end })
MainGroup2:AddToggle("Prejudge", { Text = "预判自瞄", Default = AimConfig.prejudgingselfsighting, Callback = function(v) AimConfig.prejudgingselfsighting = v end })
MainGroup2:AddToggle("AutoFire", { Text = "自动开火", Default = AimConfig.autoFire, Callback = function(v) AimConfig.autoFire = v end })

-- 自瞄
local AimGroup = Tabs.Aim:AddGroupbox({ Side = "Left", Name = "自瞄参数" })
AimGroup:AddDropdown("BodyPart", { Values = BodyPartDisplay, Default = "头部", Text = "瞄准部位", Callback = function(v) currentBodyPart = v end })
AimGroup:AddDropdown("PriorityMode", { Values = {"Distance","Crosshair","Speed","Smart"}, Default = "Smart", Text = "优先模式", Callback = function(v) AimConfig.priorityMode = v end })
AimGroup:AddDropdown("AimMode", { Values = {"AI","Function"}, Default = "AI", Text = "自瞄模式", Callback = function(v) AimConfig.aimMode = v end })
AimGroup:AddDropdown("AimType", { Values = {"普通", "强锁"}, Default = "普通", Text = "自瞄类型", Callback = function(v) AimConfig.aimModeType = v end })

local AimGroup2 = Tabs.Aim:AddGroupbox({ Side = "Right", Name = "数值调节" })
AimGroup2:AddSlider("FOVSize", { Text = "FOV大小", Default = AimConfig.fovsize, Min = 10, Max = 500, Rounding = 0, Callback = function(v) AimConfig.fovsize = v; FOVCircle1.Radius = v; FOVCircle2.Radius = v end })
AimGroup2:AddSlider("Distance", { Text = "自瞄距离", Default = AimConfig.distance, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) AimConfig.distance = v end })
AimGroup2:AddSlider("Smoothness", { Text = "平滑度", Default = AimConfig.smoothness, Min = 1, Max = 20, Rounding = 0, Callback = function(v) AimConfig.smoothness = v end })
AimGroup2:AddSlider("AimSpeed", { Text = "自瞄速度", Default = AimConfig.aimSpeed, Min = 1, Max = 20, Rounding = 0, Callback = function(v) AimConfig.aimSpeed = v end })
AimGroup2:AddSlider("TextSize", { Text = "文字大小", Default = TextSize, Min = 10, Max = 30, Rounding = 0, Callback = function(v) TextSize = v; for _, label in pairs(TargetTextLabels) do if label then label.TextSize = v end end end })
AimGroup2:AddSlider("ColorSpeed", { Text = "动态彩色速度", Default = AimConfig.colorSpeed, Min = 0.5, Max = 5, Rounding = 1, Callback = function(v) AimConfig.colorSpeed = v end })
AimGroup2:AddSlider("PrejudgeDist", { Text = "预判自瞄距离", Default = AimConfig.prejudgingselfsightingdistance, Min = 10, Max = 500, Rounding = 0, Callback = function(v) AimConfig.prejudgingselfsightingdistance = v end })

-- 透视
local VisGroup = Tabs.Visual:AddGroupbox({ Side = "Left", Name = "ESP2 (GIT风格)" })
VisGroup:AddToggle("ESP2Enabled", { Text = "ESP2 总开关", Default = ESP2_Settings.Enabled, Callback = function(v) SetESP2Enabled(v) end })
VisGroup:AddToggle("ESP2Box", { Text = "显示方框", Default = ESP2_Settings.ShowBox, Callback = function(v) ESP2_Settings.ShowBox = v end })
VisGroup:AddToggle("ESP2Name", { Text = "显示名字", Default = ESP2_Settings.ShowName, Callback = function(v) ESP2_Settings.ShowName = v end })
VisGroup:AddToggle("ESP2Health", { Text = "显示血量", Default = ESP2_Settings.ShowHealth, Callback = function(v) ESP2_Settings.ShowHealth = v end })
VisGroup:AddToggle("ESP2Chams", { Text = "上色 (Chams)", Default = ESP2_Settings.ShowChams, Callback = function(v) ESP2_Settings.ShowChams = v end })
VisGroup:AddToggle("ESP2Team", { Text = "队伍检测", Default = ESP2_Settings.TeamCheck, Callback = function(v) ESP2_Settings.TeamCheck = v end })
VisGroup:AddSlider("ESP2Dist", { Text = "最大距离", Default = ESP2_Settings.MaxDistance, Min = 50, Max = 5000, Rounding = 0, Callback = function(v) ESP2_Settings.MaxDistance = v end })

local VisGroup2 = Tabs.Visual:AddGroupbox({ Side = "Right", Name = "其他透视" })
VisGroup2:AddToggle("NightVision", { Text = "夜视", Default = NightVision.enabled, Callback = function(v) if v then StartNightVision() else StopNightVision() end end })
VisGroup2:AddToggle("ThermalESP", { Text = "热能透视", Default = ThermalESP.enabled, Callback = function(v)
    ThermalESP.enabled = v
    if v then SetupThermalEvents(); UpdateThermalESP() else for _, h in pairs(ThermalESP.highlights) do if h then h:Destroy() end end; ThermalESP.highlights = {} end
end })

-- FOV圈
local FOVGroup = Tabs.FOV:AddGroupbox({ Side = "Left", Name = "FOV圈选择" })
FOVGroup:AddDropdown("FOVVersion", { Values = {"FOV圈圈1 (原版)", "FOV圈圈2 (带红线)"}, Default = "FOV圈圈1 (原版)", Text = "选择FOV圈版本", Callback = function(v)
    if v == "FOV圈圈1 (原版)" then
        AimConfig.fovCircleVersion = 1
        SetFOVCircle1Visible(showFOVCircleFlag)
        SetFOVCircle2Visible(false)
    else
        AimConfig.fovCircleVersion = 2
        SetFOVCircle1Visible(false)
        SetFOVCircle2Visible(showFOVCircleFlag)
    end
end })

local FOVGroup2 = Tabs.FOV:AddGroupbox({ Side = "Right", Name = "FOV微调" })
FOVGroup2:AddToggle("CalibrationMode", { Text = "微调模式 (显示校准点)", Default = AimConfig.fovCalibrationMode, Callback = function(v)
    AimConfig.fovCalibrationMode = v
    if showFOVCircleFlag then
        FOVAdjust:SetVisible(v)
        SetCalibrationDotVisible(v)
    end
end })

FOVGroup2:AddButton({ Text = "打开微调卡片", Func = function()
    FOVAdjust:Toggle()
end })

-- 颜色设置
local ColorGroup = Tabs.FOV:AddGroupbox({ Side = "Left", Name = "颜色设置" })
ColorGroup:AddLabel("FOV圈颜色"):AddColorPicker("FOVColor", {
    Default = AimConfig.fovcolorFixed,
    Title = "FOV圈颜色",
    Callback = function(v)
        AimConfig.fovcolorFixed = v
        UpdateFOVCircleColor()
    end
})
ColorGroup:AddLabel("文字颜色"):AddColorPicker("TextColor", {
    Default = AimConfig.textColorFixed,
    Title = "文字颜色",
    Callback = function(v)
        AimConfig.textColorFixed = v
        for _, label in pairs(TargetTextLabels) do if label then label.TextColor3 = v end end
    end
})
ColorGroup:AddLabel("红线颜色"):AddColorPicker("LineColor", {
    Default = AimConfig.lineColorFixed,
    Title = "红线颜色",
    Callback = function(v)
        AimConfig.lineColorFixed = v
    end
})

-- 设置
local SettingsGroup = Tabs.Settings:AddGroupbox({ Side = "Left", Name = "面板调试" })
SettingsGroup:AddToggle("PanelEnabled", { Text = "启用小窗人物信息", Default = PanelConfig.enabled, Callback = function(v)
    PanelConfig.enabled = v
    if not v and TargetInfo.Panel then
        TargetInfo.IsVisible = false
        TargetInfo.Panel.Visible = false
        ClearAllParticles()
    end
end })

-- ==================== 主循环 ====================
local UpdateThrottle = {
    ESP2 = 0,
    Thermal = 0,
    TargetPanel = 0,
    Labels = 0,
    Interval = 1/30,
}

local function ThrottledUpdate(module, currentTime)
    if not UpdateThrottle[module] then return true end
    if currentTime - UpdateThrottle[module] >= UpdateThrottle.Interval then
        UpdateThrottle[module] = currentTime
        return true
    end
    return false
end

local function OptimizedMainLoop()
    local currentTime = tick()

    if AimConfig.fovlookAt then
        if AimConfig.aimMode == "AI" then AimAI() else AimFunction() end
        if AimConfig.fovCircleVersion == 2 then
            UpdateAimLockLine2()
        end
    end

    if ThrottledUpdate("ESP2", currentTime) then
        if ESP2_Settings.Enabled then
            UpdateESP2()
        end
        if ThermalESP.enabled then
            UpdateThermalESP()
        end
        if AimConfig.fovlookAt then
            UpdateTargetTextLabels()
        else
            ClearTargetTextLabels()
        end
    end

    if ThrottledUpdate("TargetPanel", currentTime) then
        if not TargetInfo.Panel then CreateTargetInfoPanel() end
        if AimConfig.fovlookAt then
            local best = GetBestTargetInFOV()
            RefreshTarget(best)
        else
            if TargetInfo.IsVisible then HidePanel() end
        end
    end

    if showFOVCircleFlag then
        UpdateFOVCircle()
        if AimConfig.fovcolorMode ~= "固定" then
            UpdateFOVCircleColor()
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(OptimizedMainLoop)

-- ==================== 保存管理 ====================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Antibot")
SaveManager:SetFolder("Antibot")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- ==================== 通知 ====================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Antibot v3.1 加载成功",
    Text = "FOV圈圈1+2 | 输入 /fov 切换微调卡片",
    Duration = 5
})
