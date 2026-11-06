
-- DARK AIM ASSIST PRO V3
-- For Roblox games you own and control.
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Settings = {
    Enabled = true,
    Smoothness = 8,
    FOV = 120,
    MaxDistance = 250,
    TargetPart = "Head",
    ShowFOV = true,
    HoldToAim = true,
    AutoFire = false
}

local lockedTarget = nil
local rightMouseDown = false
local lastShot = 0
local FIRE_RATE = 0.2
local LOCK_KEY = Enum.KeyCode.Q
local RENDER_NAME = "DarkAimAssistProV3"

-- Remove an older copy if one is running.
pcall(function()
    RunService:UnbindFromRenderStep(RENDER_NAME)
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DarkAimAssistProV3"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(430, 360)
main.Position = UDim2.new(0.5, -215, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 70, 160)
stroke.Thickness = 1.5
stroke.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = Color3.fromRGB(30, 26, 43)
top.BorderSizePixel = 0
top.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = top

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, -90, 1, 0)
heading.Position = UDim2.fromOffset(14, 0)
heading.BackgroundTransparency = 1
heading.Text = "DARK AIM ASSIST PRO V3"
heading.TextColor3 = Color3.fromRGB(210, 190, 255)
heading.TextSize = 16
heading.Font = Enum.Font.GothamBold
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 28)
close.Position = UDim2.new(1, -40, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(130, 45, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = top

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

-- Draggable window
local dragging = false
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
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

UIS.InputEnded:Connect(function(input)
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
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabs

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(12, 96)
content.Size = UDim2.new(1, -24, 1, -108)
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
    layout.Padding = UDim.new(0, 8)
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

local function createTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(125, 32)
    button.BackgroundColor3 = Color3.fromRGB(48, 40, 65)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = tabs

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        showPage(name)
    end)
end

createTab("AIM")
createTab("VISUALS")
createTab("SETTINGS")
showPage("AIM")

-- UI control helpers
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(42, 38, 55)
    button.TextColor3 = Color3.fromRGB(235, 230, 255)
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

local function refresh()
    -- Update the labels of the controls.
end

createButton(aimPage, "Aim Assist: ON", function(button)
    Settings.Enabled = not Settings.Enabled
end).Text = "Toggle Aim Assist"

createButton(aimPage, "Smoothness: 8  (- / +)", function()
    Settings.Smoothness = Settings.Smoothness + 1
    if Settings.Smoothness > 20 then
        Settings.Smoothness = 1
    end
end)

createButton(aimPage, "FOV: 120  (- / +)", function()
    Settings.FOV = Settings.FOV + 20
    if Settings.FOV > 300 then
        Settings.FOV = 40
    end
end)

createButton(aimPage, "Max Distance: 250  (- / +)", function()
    Settings.MaxDistance = Settings.MaxDistance + 50
    if Settings.MaxDistance > 500 then
        Settings.MaxDistance = 50
    end
end)

createButton(aimPage, "Target Part: Head / HRP", function()
    Settings.TargetPart =
        Settings.TargetPart == "Head" and "HumanoidRootPart" or "Head"
end)

createButton(visualPage, "Toggle FOV Circle", function()
    Settings.ShowFOV = not Settings.ShowFOV
end)

createButton(settingsPage, "Hold RMB to Aim: Toggle", function()
    Settings.HoldToAim = not Settings.HoldToAim
end)

createButton(settingsPage, "Auto Fire: Toggle", function()
    Settings.AutoFire = not Settings.AutoFire
end)

createButton(settingsPage, "Unlock Current Target", function()
    lockedTarget = nil
end)

-- FOV circle
local circle = Instance.new("Frame")
circle.Name = "FOVCircle"
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 0
circle.Parent = gui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(175, 125, 255)
circleStroke.Thickness = 1.5
circleStroke.Parent = circle

-- Target helpers
local function getTargetPart(model)
    if not model then return nil end

    local part = model:FindFirstChild(Settings.TargetPart)
    if part and part:IsA("BasePart") then
        return part
    end

    return model:FindFirstChild("HumanoidRootPart")
end

local function isValidTarget(model)
    if not model or not model:IsA("Model") then return false end
    if player.Character and model == player.Character then return false end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local part = getTargetPart(model)

    if not humanoid or humanoid.Health <= 0 or not part then
        return false
    end

    local character = player.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end

    if (part.Position - myRoot.Position).Magnitude > Settings.MaxDistance then
        return false
    end

    return true
end

local function findClosestTarget()
    camera = workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local bestTarget = nil
    local bestDistance = Settings.FOV

    local checked = {}

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Humanoid") then
            local model = object.Parent

            if model and not checked[model] then
                checked[model] = true

                if isValidTarget(model) then
                    local part = getTargetPart(model)
                    local screenPosition, visible =
                        camera:WorldToViewportPoint(part.Position)

                    if visible and screenPosition.Z > 0 then
                        local distance = (
                            Vector2.new(screenPosition.X, screenPosition.Y)
                            - center
                        ).Magnitude

                        if distance < bestDistance then
                            bestDistance = distance
                            bestTarget = model
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- Lock target with Q; hold RMB to aim if enabled.
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == LOCK_KEY then
        if lockedTarget then
            lockedTarget = nil
        else
            lockedTarget = findClosestTarget()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
    end
end)

-- Find equipped gun RemoteEvent.
local function getEquippedShootEvent()
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

-- Main update
RunService:BindToRenderStep(
    RENDER_NAME,
    Enum.RenderPriority.Camera.Value + 1,
    function(dt)
        camera = workspace.CurrentCamera
        if not camera then return end

        local center = camera.ViewportSize / 2
        circle.Position = UDim2.fromOffset(center.X, center.Y)
        circle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
        circle.Visible = Settings.ShowFOV

        if not Settings.Enabled then return end
        if not isValidTarget(lockedTarget) then
            lockedTarget = nil
            return
        end

        local aiming = Settings.HoldToAim and rightMouseDown
            or (not Settings.HoldToAim and lockedTarget ~= nil)

        if not aiming then return end

        local targetPart = getTargetPart(lockedTarget)
        if not targetPart then return end

        local origin = camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit
        local goal = CFrame.lookAt(origin, targetPart.Position)

        local alpha = 1 - math.exp(-Settings.Smoothness * dt)
        camera.CFrame = camera.CFrame:Lerp(goal, math.clamp(alpha, 0, 1))

        if Settings.AutoFire and os.clock() - lastShot >= FIRE_RATE then
            local shootEvent = getEquippedShootEvent()

            if shootEvent then
                local character = player.Character
                local head = character and character:FindFirstChild("Head")

                if head then
                    local shotDirection =
                        (targetPart.Position - head.Position).Unit

                    shootEvent:FireServer(shotDirection)
                    lastShot = os.clock()
                end
            end
        end
    end
)

-- Close and clean up
close.MouseButton1Click:Connect(function()
    RunService:UnbindFromRenderStep(RENDER_NAME)
    gui:Destroy()
end)

print("Dark Aim Assist Pro V3 loaded")

