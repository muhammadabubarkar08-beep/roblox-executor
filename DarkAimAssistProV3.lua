
-- DARK AIM ASSIST PRO V7
-- For your own Roblox Studio game.
-- LocalScript: StarterPlayer > StarterPlayerScripts
--
-- Controls:
-- PC: Q = Lock/unlock; hold RMB = Aim
-- Mobile: LOCK, AIM, AUTO buttons
--
-- Supported Tool: contains RemoteEvent named ShootEvent.
-- Server must validate shots and apply damage.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SETTINGS = {
    Enabled = true,
    Smoothness = 10,
    FOV = 180,
    MaxDistance = 250,
    TargetPart = "Head",
    ShowFOV = true,
    HoldToAim = true,
    AutoFire = true,
    PredictMovement = true,
    PredictionStrength = 0.12,
}

local RENDER_NAME = "DarkAimAssistProV7"
local TUTORIAL_ATTRIBUTE = "DarkAimTutorialSeenV7"
local FIRE_RATE = 0.21

local lockedTarget = nil
local rightMouseDown = false
local mobileAim = false
local lastShot = 0
local closed = false
local connections = {}
local characterConnections = {}

pcall(function()
    RunService:UnbindFromRenderStep(RENDER_NAME)
end)

local oldGui = playerGui:FindFirstChild("DarkAimAssistProV7")
if oldGui then oldGui:Destroy() end

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function clearCharacterConnections()
    for _, c in ipairs(characterConnections) do
        c:Disconnect()
    end
    table.clear(characterConnections)
end

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
end

local function makeButton(parent, text, size, position)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(48, 38, 66)
    b.TextColor3 = Color3.fromRGB(240, 235, 255)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 8)
    return b
end

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DarkAimAssistProV7"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(410, 390)
main.Position = UDim2.new(0.5, -205, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(20, 19, 27)
main.BorderSizePixel = 0
main.Parent = gui
corner(main, 10)

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(140, 95, 215)
outline.Thickness = 1.5
outline.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 44)
top.BackgroundColor3 = Color3.fromRGB(39, 30, 54)
top.BorderSizePixel = 0
top.Parent = main
corner(top, 10)

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, -55, 1, 0)
heading.Position = UDim2.fromOffset(12, 0)
heading.BackgroundTransparency = 1
heading.Text = "DARK AIM ASSIST PRO V7"
heading.TextColor3 = Color3.fromRGB(225, 205, 255)
heading.Font = Enum.Font.GothamBold
heading.TextSize = 14
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.Parent = top

local closeButton = makeButton(
    top, "X", UDim2.fromOffset(32, 28),
    UDim2.new(1, -40, 0, 8)
)
closeButton.BackgroundColor3 = Color3.fromRGB(135, 45, 60)

-- Draggable window
local dragging = false
local dragStart
local startPosition

connect(top.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

connect(UIS.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

connect(UIS.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Tabs
local tabs = Instance.new("Frame")
tabs.Position = UDim2.fromOffset(10, 52)
tabs.Size = UDim2.new(1, -20, 0, 34)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabs

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(12, 94)
content.Size = UDim2.new(1, -24, 1, -127)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.Parent = page

    pages[name] = page
    return page
end

local aimPage = createPage("AIM")
local visualPage = createPage("VISUALS")
local settingsPage = createPage("SETTINGS")

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
end

for _, name in ipairs({"AIM", "VISUALS", "SETTINGS"}) do
    local tab = makeButton(
        tabs, name, UDim2.fromOffset(125, 32),
        UDim2.new()
    )

    connect(tab.MouseButton1Click, function()
        showPage(name)
    end)
end

showPage("AIM")

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 12, 1, -25)
status.Size = UDim2.new(1, -24, 0, 18)
status.BackgroundTransparency = 1
status.Text = "Q: Lock | Hold RMB: Aim"
status.TextColor3 = Color3.fromRGB(190, 170, 220)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = main

-- Settings buttons
local function addSetting(parent, name, callback)
    local b = makeButton(
        parent, name,
        UDim2.new(1, 0, 0, 35),
        UDim2.new()
    )
    connect(b.MouseButton1Click, callback)
    return b
end

local function updateSettings()
    for _, b in ipairs(aimPage:GetChildren()) do
        if b:IsA("TextButton") then
            if b.Name == "Enabled" then
                b.Text = "Aim Assist: " .. (SETTINGS.Enabled and "ON" or "OFF")
            elseif b.Name == "Smooth" then
                b.Text = "Smoothness: " .. SETTINGS.Smoothness
            elseif b.Name == "FOV" then
                b.Text = "FOV: " .. SETTINGS.FOV
            elseif b.Name == "Distance" then
                b.Text = "Max Distance: " .. SETTINGS.MaxDistance
            elseif b.Name == "Part" then
                b.Text = "Target Part: " .. SETTINGS.TargetPart
            end
        end
    end

    for _, b in ipairs(visualPage:GetChildren()) do
        if b:IsA("TextButton") then
            b.Text = "Show FOV: " .. (SETTINGS.ShowFOV and "ON" or "OFF")
        end
    end

    for _, b in ipairs(settingsPage:GetChildren()) do
        if b:IsA("TextButton") then
            if b.Name == "Hold" then
                b.Text = "Hold RMB to Aim: " .. (SETTINGS.HoldToAim and "ON" or "OFF")
            elseif b.Name == "Auto" then
                b.Text = "Auto Fire: " .. (SETTINGS.AutoFire and "ON" or "OFF")
            elseif b.Name == "Prediction" then
                b.Text = "Movement Prediction: " .. (SETTINGS.PredictMovement and "ON" or "OFF")
            end
        end
    end
end

local b = addSetting(aimPage, "", function()
    SETTINGS.Enabled = not SETTINGS.Enabled
    if not SETTINGS.Enabled then lockedTarget = nil end
    updateSettings()
end)
b.Name = "Enabled"

b = addSetting(aimPage, "", function()
    SETTINGS.Smoothness += 2
    if SETTINGS.Smoothness > 20 then SETTINGS.Smoothness = 2 end
    updateSettings()
end)
b.Name = "Smooth"

b = addSetting(aimPage, "", function()
    SETTINGS.FOV += 20
    if SETTINGS.FOV > 300 then SETTINGS.FOV = 60 end
    updateSettings()
end)
b.Name = "FOV"

b = addSetting(aimPage, "", function()
    SETTINGS.MaxDistance += 50
    if SETTINGS.MaxDistance > 500 then SETTINGS.MaxDistance = 100 end
    updateSettings()
end)
b.Name = "Distance"

b = addSetting(aimPage, "", function()
    SETTINGS.TargetPart =
        SETTINGS.TargetPart == "Head" and "HumanoidRootPart" or "Head"
    updateSettings()
end)
b.Name = "Part"

b = addSetting(visualPage, "", function()
    SETTINGS.ShowFOV = not SETTINGS.ShowFOV
    updateSettings()
end)
b.Name = "Visual"

b = addSetting(settingsPage, "", function()
    SETTINGS.HoldToAim = not SETTINGS.HoldToAim
    updateSettings()
end)
b.Name = "Hold"

b = addSetting(settingsPage, "", function()
    SETTINGS.AutoFire = not SETTINGS.AutoFire
    updateSettings()
end)
b.Name = "Auto"

b = addSetting(settingsPage, "", function()
    SETTINGS.PredictMovement = not SETTINGS.PredictMovement
    updateSettings()
end)
b.Name = "Prediction"

addSetting(settingsPage, "Unlock Target", function()
    lockedTarget = nil
    status.Text = "Target unlocked"
end)

updateSettings()

-- FOV circle
local circle = Instance.new("Frame")
circle.Name = "FOVCircle"
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Size = UDim2.fromOffset(SETTINGS.FOV * 2, SETTINGS.FOV * 2)
circle.BackgroundTransparency = 1
circle.Parent = gui
corner(circle, 300)

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(175, 125, 255)
circleStroke.Thickness = 1.5
circleStroke.Parent = circle

-- Mobile controls
local mobile = Instance.new("Frame")
mobile.Name = "MobileControls"
mobile.Size = UDim2.fromOffset(150, 130)
mobile.Position = UDim2.new(1, -165, 1, -155)
mobile.BackgroundTransparency = 1
mobile.Visible = UIS.TouchEnabled
mobile.Parent = gui

local mobileLock = makeButton(
    mobile, "LOCK", UDim2.fromOffset(70, 45),
    UDim2.fromOffset(0, 0)
)

local mobileAimButton = makeButton(
    mobile, "AIM: OFF", UDim2.fromOffset(70, 45),
    UDim2.fromOffset(78, 0)
)

local mobileAuto = makeButton(
    mobile, "AUTO: ON", UDim2.fromOffset(148, 40),
    UDim2.fromOffset(0, 55)
)

-- Target helpers
local function getHumanoid(model)
    if not model then return nil end
    return model:FindFirstChildOfClass("Humanoid")
end

local function getTargetPart(model)
    if not model then return nil end

    local part = model:FindFirstChild(SETTINGS.TargetPart, true)
    if part and part:IsA("BasePart") then
        return part
    end

    local root = model:FindFirstChild("HumanoidRootPart", true)
    if root and root:IsA("BasePart") then
        return root
    end

    return nil
end

local function validTarget(model)
    if not model or not model:IsA("Model") then return false end
    if model == player.Character then return false end

    local humanoid = getHumanoid(model)
    local part = getTargetPart(model)
    local character = player.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not part or not myRoot then
        return false
    end

    return (part.Position - myRoot.Position).Magnitude <= SETTINGS.MaxDistance
end

local function getCandidates()
    local candidates = {}
    local seen = {}

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local model = otherPlayer.Character
            if not seen[model] then
                seen[model] = true
                table.insert(candidates, model)
            end
        end
    end

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Humanoid") then
            local model = object:FindFirstAncestorOfClass("Model")
            if model and model ~= player.Character and not seen[model] then
                seen[model] = true
                table.insert(candidates, model)
            end
        end
    end

    return candidates
end

local function findClosestTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local bestDistance = SETTINGS.FOV
    local bestModel = nil

    for _, model in ipairs(getCandidates()) do
        if validTarget(model) then
            local part = getTargetPart(model)
            local screenPosition, onScreen =
                camera:WorldToViewportPoint(part.Position)

            if onScreen and screenPosition.Z > 0 then
                local screenDistance = (
                    Vector2.new(screenPosition.X, screenPosition.Y) - center
                ).Magnitude

                if screenDistance <= bestDistance then
                    bestDistance = screenDistance
                    bestModel = model
                end
            end
        end
    end

    return bestModel
end

local function toggleLock()
    if lockedTarget and validTarget(lockedTarget) then
        lockedTarget = nil
        status.Text = "Target unlocked"
    else
        lockedTarget = findClosestTarget()
        if lockedTarget then
            status.Text = "Locked: " .. lockedTarget.Name
        else
            status.Text = "No target in FOV"
        end
    end
end

connect(mobileLock.MouseButton1Click, toggleLock)

connect(mobileAimButton.MouseButton1Click, function()
    mobileAim = not mobileAim
    mobileAimButton.Text = mobileAim and "AIM: ON" or "AIM: OFF"
end)

connect(mobileAuto.MouseButton1Click, function()
    SETTINGS.AutoFire = not SETTINGS.AutoFire
    mobileAuto.Text = SETTINGS.AutoFire and "AUTO: ON" or "AUTO: OFF"
    updateSettings()
end)

-- One-time tutorial
local tutorial = Instance.new("Frame")
tutorial.Size = UDim2.fromOffset(320, 205)
tutorial.Position = UDim2.new(0.5, -160, 0.5, -102)
tutorial.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
tutorial.Visible = false
tutorial.Parent = gui
tutorial.ZIndex = 10
corner(tutorial, 10)

local tutorialStroke = Instance.new("UIStroke")
tutorialStroke.Color = Color3.fromRGB(150, 110, 220)
tutorialStroke.Thickness = 2
tutorialStroke.Parent = tutorial

local tutorialTitle = Instance.new("TextLabel")
tutorialTitle.Size = UDim2.new(1, -20, 0, 35)
tutorialTitle.Position = UDim2.fromOffset(10, 8)
tutorialTitle.BackgroundTransparency = 1
tutorialTitle.Text = "HOW TO USE THE HUB"
tutorialTitle.TextColor3 = Color3.fromRGB(220, 195, 255)
tutorialTitle.Font = Enum.Font.GothamBold
tutorialTitle.TextSize = 16
tutorialTitle.Parent = tutorial
tutorialTitle.ZIndex = 11

local tutorialText = Instance.new("TextLabel")
tutorialText.Size = UDim2.new(1, -24, 0, 105)
tutorialText.Position = UDim2.fromOffset(12, 45)
tutorialText.BackgroundTransparency = 1
tutorialText.TextColor3 = Color3.fromRGB(235, 230, 245)
tutorialText.Font = Enum.Font.Gotham
tutorialText.TextSize = 13
tutorialText.TextWrapped = true
tutorialText.TextYAlignment = Enum.TextYAlignment.Top
tutorialText.Text =
    "PC:\nQ = Lock / unlock target\nHold right mouse button = Aim\n\nMOBILE:\nLOCK = Lock / unlock target\nAIM = Toggle aiming\nAUTO = Toggle automatic shots"
tutorialText.Parent = tutorial
tutorialText.ZIndex = 11

local gotIt = makeButton(
    tutorial, "GOT IT",
    UDim2.new(1, -24, 0, 36),
    UDim2.fromOffset(12, 160)
)
gotIt.ZIndex = 11

connect(gotIt.MouseButton1Click, function()
    player:SetAttribute(TUTORIAL_ATTRIBUTE, true)
    tutorial.Visible = false
end)

local function showTutorialOnce()
    if not player:GetAttribute(TUTORIAL_ATTRIBUTE) then
        tutorial.Visible = true
    end
end

-- Gun RemoteEvent lookup
local function getShootEvent()
    local character = player.Character
    if not character then return nil end

    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            local event = item:FindFirstChild("ShootEvent")
            if event and event:IsA("RemoteEvent") then
                return event
            end
        end
    end

    return nil
end

local function checkTool(tool)
    if not tool:IsA("Tool") then return end

    local event = tool:FindFirstChild("ShootEvent")
    if event and event:IsA("RemoteEvent") then
        status.Text = "Gun equipped: " .. tool.Name
        showTutorialOnce()
    end
end

local function watchCharacter(character)
    clearCharacterConnections()
    lockedTarget = nil

    table.insert(characterConnections, character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.delay(0.15, function()
                if child.Parent == character then
                    checkTool(child)
                end
            end)
        end
    end))

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            task.delay(0.15, function()
                if child.Parent == character then
                    checkTool(child)
                end
            end)
        end
    end
end

if player.Character then
    watchCharacter(player.Character)
end

connect(player.CharacterAdded, watchCharacter)

-- PC inputs
connect(UIS.InputBegan, function(input, processed)
    if closed then return end

    if input.KeyCode == Enum.KeyCode.Q and not processed then
        toggleLock()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true

        if SETTINGS.Enabled and (not lockedTarget or not validTarget(lockedTarget)) then
            lockedTarget = findClosestTarget()
            if lockedTarget then
                status.Text = "Aiming at: " .. lockedTarget.Name
            else
                status.Text = "No target in FOV"
            end
        end
    end
end)

connect(UIS.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
    end
end)

-- Continuous tracking, prediction and automatic shot requests
RunService:BindToRenderStep(
    RENDER_NAME,
    Enum.RenderPriority.Camera.Value + 1,
    function(dt)
        if closed then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local center = camera.ViewportSize / 2
        circle.Position = UDim2.fromOffset(center.X, center.Y)
        circle.Size = UDim2.fromOffset(SETTINGS.FOV * 2, SETTINGS.FOV * 2)
        circle.Visible = SETTINGS.ShowFOV

        if not SETTINGS.Enabled then return end

        local aiming = SETTINGS.HoldToAim
            and (rightMouseDown or mobileAim)
            or (not SETTINGS.HoldToAim and lockedTarget ~= nil)

        if aiming and (not lockedTarget or not validTarget(lockedTarget)) then
            lockedTarget = findClosestTarget()
        end

        if not lockedTarget or not validTarget(lockedTarget) then
            if aiming then
                status.Text = "Searching for target..."
            end
            return
        end

        if not aiming then return end

        local part = getTargetPart(lockedTarget)
        local humanoid = getHumanoid(lockedTarget)

        if not part or not humanoid then return end

        -- Predict movement
        local predictedPosition = part.Position

        if SETTINGS.PredictMovement then
            predictedPosition +=
                part.AssemblyLinearVelocity * SETTINGS.PredictionStrength
        end

        -- Smooth camera tracking
        local origin = camera.CFrame.Position
        local goal = CFrame.lookAt(origin, predictedPosition)
        local alpha = 1 - math.exp(-SETTINGS.Smoothness * dt)

        camera.CFrame = camera.CFrame:Lerp(
            goal,
            math.clamp(alpha, 0, 1)
        )

        -- Automatic firing requests
        if SETTINGS.AutoFire and os.clock() - lastShot >= FIRE_RATE then
            local event = getShootEvent()
            local character = player.Character
            local head = character and character:FindFirstChild("Head")

            if event and head then
                local direction = predictedPosition - head.Position

                if direction.Magnitude > 0 then
                    event:FireServer(direction.Unit)
                    lastShot = os.clock()
                end
            end
        end
    end
)

-- Cleanup
local function cleanup()
    if closed then return end
    closed = true

    RunService:UnbindFromRenderStep(RENDER_NAME)
    clearCharacterConnections()

    for _, c in ipairs(connections) do
        c:Disconnect()
    end

    gui:Destroy()
end

connect(closeButton.MouseButton1Click, cleanup)

print("Dark Aim Assist Pro V7 loaded")
