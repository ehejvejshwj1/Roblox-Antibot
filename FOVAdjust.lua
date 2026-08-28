--[[
    FOV 微调卡片 v1.0
    独立纯 GUI，不依赖任何 UI 库
    用法：
        local FOVAdjust = loadstring(game:HttpGet("你的GitHub链接"))()
        FOVAdjust:Create()
        FOVAdjust:SetVisible(true)
        FOVAdjust:SetOnChange(function(x, y) print("偏移:", x, y) end)
]]

local FOVAdjust = {
    Gui = nil,
    Container = nil,
    OffsetX = 0,
    OffsetY = 0,
    Step = 1,
    Visible = false,
    OnChange = nil,
    Title = "🎯 FOV 圈微调",
}

-- ==================== 创建 UI ====================
function FOVAdjust:Create()
    if self.Gui then return self end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVAdjustCard"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    self.Gui = screenGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 220, 0, 200)
    container.Position = UDim2.new(0.5, -110, 0.5, -100)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(60, 60, 80)
    stroke.Transparency = 0.5
    stroke.Parent = container

    self.Container = container

    -- 标题
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -12, 0, 28)
    title.Position = UDim2.new(0, 6, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = Color3.fromRGB(210, 210, 240)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.Parent = container

    -- 偏移显示
    local offsetLabel = Instance.new("TextLabel")
    offsetLabel.Name = "OffsetLabel"
    offsetLabel.Size = UDim2.new(1, -12, 0, 22)
    offsetLabel.Position = UDim2.new(0, 6, 0, 36)
    offsetLabel.BackgroundTransparency = 1
    offsetLabel.Text = "X: 0  Y: 0"
    offsetLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    offsetLabel.TextXAlignment = Enum.TextXAlignment.Center
    offsetLabel.Font = Enum.Font.Code
    offsetLabel.TextSize = 14
    offsetLabel.Parent = container

    -- 方向键区域
    local dirFrame = Instance.new("Frame")
    dirFrame.Size = UDim2.new(0, 140, 0, 100)
    dirFrame.Position = UDim2.new(0.5, -70, 0, 62)
    dirFrame.BackgroundTransparency = 1
    dirFrame.Parent = container

    local function createDirButton(text, posX, posY, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.Position = UDim2.new(posX, -20, posY, -20)
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 20
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = dirFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local selfRef = self

    createDirButton("↑", 0.5, 0.1, function()
        selfRef.OffsetY = selfRef.OffsetY - selfRef.Step
        selfRef:UpdateDisplay()
        if selfRef.OnChange then selfRef.OnChange(selfRef.OffsetX, selfRef.OffsetY) end
    end)

    createDirButton("↓", 0.5, 0.9, function()
        selfRef.OffsetY = selfRef.OffsetY + selfRef.Step
        selfRef:UpdateDisplay()
        if selfRef.OnChange then selfRef.OnChange(selfRef.OffsetX, selfRef.OffsetY) end
    end)

    createDirButton("←", 0.1, 0.5, function()
        selfRef.OffsetX = selfRef.OffsetX - selfRef.Step
        selfRef:UpdateDisplay()
        if selfRef.OnChange then selfRef.OnChange(selfRef.OffsetX, selfRef.OffsetY) end
    end)

    createDirButton("→", 0.9, 0.5, function()
        selfRef.OffsetX = selfRef.OffsetX + selfRef.Step
        selfRef:UpdateDisplay()
        if selfRef.OnChange then selfRef.OnChange(selfRef.OffsetX, selfRef.OffsetY) end
    end)

    -- 步长控制
    local stepFrame = Instance.new("Frame")
    stepFrame.Size = UDim2.new(1, -12, 0, 30)
    stepFrame.Position = UDim2.new(0, 6, 0, 166)
    stepFrame.BackgroundTransparency = 1
    stepFrame.Parent = container

    local stepLabel = Instance.new("TextLabel")
    stepLabel.Size = UDim2.new(0, 50, 1, 0)
    stepLabel.Position = UDim2.new(0, 0, 0, 0)
    stepLabel.BackgroundTransparency = 1
    stepLabel.Text = "步长"
    stepLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    stepLabel.TextXAlignment = Enum.TextXAlignment.Right
    stepLabel.Font = Enum.Font.Gotham
    stepLabel.TextSize = 13
    stepLabel.Parent = stepFrame

    local stepValue = Instance.new("TextLabel")
    stepValue.Name = "StepValue"
    stepValue.Size = UDim2.new(0, 30, 1, 0)
    stepValue.Position = UDim2.new(0, 55, 0, 0)
    stepValue.BackgroundTransparency = 1
    stepValue.Text = "1"
    stepValue.TextColor3 = Color3.fromRGB(255, 255, 100)
    stepValue.TextXAlignment = Enum.TextXAlignment.Center
    stepValue.Font = Enum.Font.Code
    stepValue.TextSize = 14
    stepValue.Parent = stepFrame

    local stepDec = Instance.new("TextButton")
    stepDec.Size = UDim2.new(0, 25, 1, 0)
    stepDec.Position = UDim2.new(0, 90, 0, 0)
    stepDec.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    stepDec.Text = "-"
    stepDec.TextColor3 = Color3.new(1, 1, 1)
    stepDec.TextSize = 18
    stepDec.Font = Enum.Font.GothamBold
    stepDec.BorderSizePixel = 0
    stepDec.Parent = stepFrame

    local stepInc = Instance.new("TextButton")
    stepInc.Size = UDim2.new(0, 25, 1, 0)
    stepInc.Position = UDim2.new(0, 120, 0, 0)
    stepInc.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    stepInc.Text = "+"
    stepInc.TextColor3 = Color3.new(1, 1, 1)
    stepInc.TextSize = 18
    stepInc.Font = Enum.Font.GothamBold
    stepInc.BorderSizePixel = 0
    stepInc.Parent = stepFrame

    stepDec.MouseButton1Click:Connect(function()
        if selfRef.Step > 1 then
            selfRef.Step = selfRef.Step - 1
            stepValue.Text = tostring(selfRef.Step)
        end
    end)

    stepInc.MouseButton1Click:Connect(function()
        if selfRef.Step < 10 then
            selfRef.Step = selfRef.Step + 1
            stepValue.Text = tostring(selfRef.Step)
        end
    end)

    -- 重置按钮
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 50, 0, 26)
    resetBtn.Position = UDim2.new(1, -56, 0, 4)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    resetBtn.Text = "重置"
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.TextSize = 12
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = container

    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 6)
    resetCorner.Parent = resetBtn

    resetBtn.MouseButton1Click:Connect(function()
        selfRef.OffsetX = 0
        selfRef.OffsetY = 0
        selfRef:UpdateDisplay()
        if selfRef.OnChange then selfRef.OnChange(selfRef.OffsetX, selfRef.OffsetY) end
    end)

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -24, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = container

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        self:SetVisible(false)
    end)

    self:UpdateDisplay()
    return self
end

function FOVAdjust:UpdateDisplay()
    if not self.Container then return end
    local offsetLabel = self.Container:FindFirstChild("OffsetLabel")
    if offsetLabel then
        offsetLabel.Text = string.format("X: %d  Y: %d", self.OffsetX, self.OffsetY)
    end
end

function FOVAdjust:SetVisible(visible)
    self.Visible = visible
    if self.Container then
        self.Container.Visible = visible
    end
    if visible then
        self.Container.Parent = self.Gui
        self:UpdateDisplay()
    end
end

function FOVAdjust:Toggle()
    self:SetVisible(not self.Visible)
end

function FOVAdjust:GetOffset()
    return self.OffsetX, self.OffsetY
end

function FOVAdjust:SetOffset(x, y)
    self.OffsetX = x or 0
    self.OffsetY = y or 0
    self:UpdateDisplay()
end

function FOVAdjust:SetStep(step)
    self.Step = step or 1
    local stepValue = self.Container and self.Container:FindFirstChild("StepValue")
    if stepValue then stepValue.Text = tostring(self.Step) end
end

function FOVAdjust:SetOnChange(callback)
    self.OnChange = callback
end

function FOVAdjust:SetTitle(title)
    self.Title = title or "🎯 FOV 圈微调"
    if self.Container then
        local titleLabel = self.Container:FindFirstChild("Title")
        if titleLabel then titleLabel.Text = self.Title end
    end
end

function FOVAdjust:Destroy()
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
        self.Container = nil
    end
end

-- 自动创建
FOVAdjust:Create()

-- 快捷指令：输入 /fov 切换显示
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "/fov" then
        FOVAdjust:Toggle()
    end
end)

return FOVAdjust