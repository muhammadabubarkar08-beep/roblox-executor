--========================================================
-- DARK AIM ASSIST V11 | COMPLETE HUB
-- Put this LocalScript in StarterPlayerScripts
-- For use in your own Roblox experience.
--
-- Compatible weapon setup:
-- Tool
--   ShootEvent (RemoteEvent)
--   ServerDamage (server Script that validates shots)
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

--========================================================
-- CONFIGURATION
--========================================================

local ACCESS_KEY = "V7q!N4x#P9mL2@kR"

local Settings = {
	AutoTarget = true,
	AutoFire = true,
	ShowFOV = true,
	FOV = 180,
	MaxDistance = 250,
	Smoothness = 10,
	FireInterval = 0.22,
	ScanInterval = 0.20,
}

local PURPLE = Color3.fromRGB(157, 91, 255)
local PURPLE_DARK = Color3.fromRGB(91, 48, 158)
local BG = Color3.fromRGB(12, 11, 18)
local PANEL = Color3.fromRGB(22, 20, 31)
local PANEL_LIGHT = Color3.fromRGB(31, 28, 44)
local WHITE = Color3.fromRGB(245, 242, 255)
local MUTED = Color3.fromRGB(155, 148, 174)
local GREEN = Color3.fromRGB(91, 220, 151)
local RED = Color3.fromRGB(255, 105, 115)

local currentTarget
local lastScan = 0
local lastShot = 0
local unlocked = false

--========================================================
-- GUI CREATION
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DarkAimV11"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = 0.15
	s.Parent = obj
	return s
end

local function tween(obj, duration, properties)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		properties
	)
	t:Play()
	return t
end

local function label(parent, text, size, pos, fontSize, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = size
	l.Position = pos
	l.Text = text
	l.TextColor3 = color or WHITE
	l.TextSize = fontSize or 14
	l.Font = Enum.Font.Gotham
	l.TextWrapped = true
	l.Parent = parent
	return l
end

local function button(parent, text, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = PANEL_LIGHT
	b.Text = text
	b.TextColor3 = WHITE
	b.TextSize = 13
	b.Font = Enum.Font.GothamSemibold
	b.AutoButtonColor = false
	b.Parent = parent
	corner(b, 9)
	stroke(b, Color3.fromRGB(65, 57, 83), 1)

	b.MouseEnter:Connect(function()
		tween(b, 0.15, {BackgroundColor3 = Color3.fromRGB(55, 39, 77)})
	end)

	b.MouseLeave:Connect(function()
		tween(b, 0.15, {BackgroundColor3 = PANEL_LIGHT})
	end)

	return b
end

local function newFrame(parent, size, pos, color)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = color or PANEL
	f.BorderSizePixel = 0
	f.Parent = parent
	corner(f, 12)
	return f
end

--========================================================
-- ACCESS KEY SCREEN
--========================================================

local keyScreen = Instance.new("Frame")
keyScreen.Size = UDim2.fromScale(1, 1)
keyScreen.BackgroundColor3 = BG
keyScreen.Parent = gui

local keyCard = newFrame(
	keyScreen,
	UDim2.new(0, 370, 0, 330),
	UDim2.new(0.5, -185, 0.5, -165),
	PANEL
)
stroke(keyCard, PURPLE, 1.5)

local keyLogo = label(
	keyCard, "DARK AIM",
	UDim2.new(1, 0, 0, 55),
	UDim2.new(0, 0, 0, 28),
	29, PURPLE
)
keyLogo.Font = Enum.Font.GothamBlack

label(
	keyCard, "PRIVATE ACCESS",
	UDim2.new(1, 0, 0, 25),
	UDim2.new(0, 0, 0, 82),
	11, MUTED
)

label(
	keyCard, "Enter your access key to continue",
	UDim2.new(1, -30, 0, 30),
	UDim2.new(0, 15, 0, 125),
	13, WHITE
)

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -50, 0, 46)
keyBox.Position = UDim2.new(0, 25, 0, 165)
keyBox.BackgroundColor3 = BG
keyBox.TextColor3 = WHITE
keyBox.PlaceholderColor3 = MUTED
keyBox.PlaceholderText = "Enter access key..."
keyBox.Text = ""
keyBox.TextSize = 14
keyBox.Font = Enum.Font.Gotham
keyBox.ClearTextOnFocus = false
keyBox.Parent = keyCard
corner(keyBox, 9)
stroke(keyBox, PURPLE, 1)

local unlock = button(
	keyCard, "UNLOCK HUB",
	UDim2.new(1, -50, 0, 44),
	UDim2.new(0, 25, 0, 225)
)
unlock.BackgroundColor3 = PURPLE_DARK

local keyStatus = label(
	keyCard, "",
	UDim2.new(1, -30, 0, 25),
	UDim2.new(0, 15, 1, -32),
	11, RED
)

--========================================================
-- LOADING SCREEN
--========================================================

local loading = Instance.new("Frame")
loading.Size = UDim2.fromScale(1, 1)
loading.BackgroundColor3 = BG
loading.Visible = false
loading.Parent = gui

local loadingLogo = label(
	loading, "DARK AIM",
	UDim2.new(1, 0, 0, 60),
	UDim2.new(0, 0, 0.35, 0),
	34, PURPLE
)
loadingLogo.Font = Enum.Font.GothamBlack

local loadingSub = label(
	loading, "Preparing your hub...",
	UDim2.new(1, 0, 0, 30),
	UDim2.new(0, 0, 0.45, 0),
	13, MUTED
)

local progressBack = newFrame(
	loading,
	UDim2.new(0, 300, 0, 8),
	UDim2.new(0.5, -150, 0.55, 0),
	PANEL_LIGHT
)
corner(progressBack, 10)

local progress = Instance.new("Frame")
progress.Size = UDim2.new(0, 0, 1, 0)
progress.BackgroundColor3 = PURPLE
progress.BorderSizePixel = 0
progress.Parent = progressBack
corner(progress, 10)

local spinner = label(
	loading, "◌",
	UDim2.new(0, 50, 0, 50),
	UDim2.new(0.5, -25, 0.62, 0),
	34, PURPLE
)

local spinning = true
task.spawn(function()
	while spinning and spinner.Parent do
		spinner.Rotation += 8
		task.wait(0.02)
	end
end)

--========================================================
-- MAIN HUB
--========================================================

local main = newFrame(
	gui,
	UDim2.new(0, 650, 0, 430),
	UDim2.new(0.5, -325, 0.5, -215),
	BG
)
main.Visible = false
stroke(main, Color3.fromRGB(92, 67, 130), 1.5)

local top = newFrame(
	main,
	UDim2.new(1, 0, 0, 57),
	UDim2.new(0, 0, 0, 0),
	PANEL
)

local topTitle = label(
	top, "DARK AIM",
	UDim2.new(0, 180, 1, 0),
	UDim2.new(0, 20, 0, 0),
	19, PURPLE
)
topTitle.Font = Enum.Font.GothamBlack
topTitle.TextXAlignment = Enum.TextXAlignment.Left

label(
	top, "V11  •  CONTROL CENTER",
	UDim2.new(0, 220, 1, 0),
	UDim2.new(0, 155, 0, 0),
	10, MUTED
).TextXAlignment = Enum.TextXAlignment.Left

local minimize = button(
	top, "—",
	UDim2.new(0, 38, 0, 34),
	UDim2.new(1, -52, 0, 11)
)
minimize.TextSize = 19

-- Dragging the window from the top bar.
local dragging = false
local dragStart
local originalPosition

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		originalPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			originalPosition.X.Scale,
			originalPosition.X.Offset + delta.X,
			originalPosition.Y.Scale,
			originalPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local restore = button(
	gui, "DA",
	UDim2.new(0, 52, 0, 52),
	UDim2.new(0, 18, 0.5, -26)
)
restore.Visible = false
restore.TextColor3 = PURPLE
restore.TextSize = 17
stroke(restore, PURPLE, 1.5)

minimize.MouseButton1Click:Connect(function()
	main.Visible = false
	restore.Visible = true
end)

restore.MouseButton1Click:Connect(function()
	main.Visible = true
	restore.Visible = false
end)

--========================================================
-- SIDEBAR
--========================================================

local sidebar = newFrame(
	main,
	UDim2.new(0, 155, 1, -75),
	UDim2.new(0, 12, 0, 65),
	PANEL
)

label(
	sidebar, "NAVIGATION",
	UDim2.new(1, -20, 0, 30),
	UDim2.new(0, 12, 0, 12),
	10, MUTED
).TextXAlignment = Enum.TextXAlignment.Left

local content = newFrame(
	main,
	UDim2.new(1, -190, 1, -75),
	UDim2.new(0, 178, 0, 65),
	PANEL
)

local pages = {}
local navButtons = {}

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = content
	pages[name] = page
	return page
end

local function switchPage(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	for buttonName, nav in pairs(navButtons) do
		nav.BackgroundColor3 = buttonName == name
			and PURPLE_DARK or PANEL_LIGHT
	end
end

local function createNav(name, text, y)
	local nav = button(
		sidebar, text,
		UDim2.new(1, -20, 0, 42),
		UDim2.new(0, 10, 0, y)
	)
	navButtons[name] = nav
	nav.MouseButton1Click:Connect(function()
		switchPage(name)
	end)
end

createNav("Home", "⌂   Dashboard", 52)
createNav("Aim", "◎   Aim Settings", 102)
createNav("Visuals", "◉   Visuals", 152)
createNav("Settings", "⚙   Settings", 202)

label(
	sidebar, "DARK AIM V11",
	UDim2.new(1, -20, 0, 25),
	UDim2.new(0, 10, 1, -38),
	10, MUTED
)

local homePage = createPage("Home")
local aimPage = createPage("Aim")
local visualsPage = createPage("Visuals")
local settingsPage = createPage("Settings")

--========================================================
-- DASHBOARD PAGE
--========================================================

label(
	homePage, "Dashboard",
	UDim2.new(1, -30, 0, 35),
	UDim2.new(0, 15, 0, 15),
	22, WHITE
).Font = Enum.Font.GothamBold

label(
	homePage, "Welcome to your control center.",
	UDim2.new(1, -30, 0, 25),
	UDim2.new(0, 15, 0, 48),
	12, MUTED
)

local targetCard = newFrame(
	homePage,
	UDim2.new(1, -30, 0, 100),
	UDim2.new(0, 15, 0, 95),
	PANEL_LIGHT
)

label(
	targetCard, "CURRENT TARGET",
	UDim2.new(1, -20, 0, 25),
	UDim2.new(0, 12, 0, 12),
	10, MUTED
).TextXAlignment = Enum.TextXAlignment.Left

local targetStatus = label(
	targetCard, "Searching...",
	UDim2.new(1, -20, 0, 35),
	UDim2.new(0, 12, 0, 42),
	19, PURPLE
)
targetStatus.TextXAlignment = Enum.TextXAlignment.Left
targetStatus.Font = Enum.Font.GothamBold

local systemCard = newFrame(
	homePage,
	UDim2.new(1, -30, 0, 90),
	UDim2.new(0, 15, 0, 210),
	PANEL_LIGHT
)

label(
	systemCard, "SYSTEM STATUS",
	UDim2.new(1, -20, 0, 25),
	UDim2.new(0, 12, 0, 10),
	10, MUTED
).TextXAlignment = Enum.TextXAlignment.Left

local systemStatus = label(
	systemCard, "Hub ready",
	UDim2.new(1, -20, 0, 35),
	UDim2.new(0, 12, 0, 40),
	16, GREEN
)
systemStatus.TextXAlignment = Enum.TextXAlignment.Left

--========================================================
-- REUSABLE TOGGLE ROW
--========================================================

local function toggleRow(parent, titleText, description, settingName, y)
	local row = newFrame(
		parent,
		UDim2.new(1, -30, 0, 70),
		UDim2.new(0, 15, 0, y),
		PANEL_LIGHT
	)

	local title = label(
		row, titleText,
		UDim2.new(0, 220, 0, 25),
		UDim2.new(0, 12, 0, 9),
		13, WHITE
	)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamSemibold

	local desc = label(
		row, description,
		UDim2.new(0, 220, 0, 20),
		UDim2.new(0, 12, 0, 36),
		10, MUTED
	)
	desc.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = button(
		row, "",
		UDim2.new(0, 90, 0, 34),
		UDim2.new(1, -102, 0.5, -17)
	)

	local function refresh()
		toggle.Text = Settings[settingName] and "ON" or "OFF"
		toggle.BackgroundColor3 = Settings[settingName]
			and PURPLE_DARK or PANEL
	end

	toggle.MouseButton1Click:Connect(function()
		Settings[settingName] = not Settings[settingName]
		refresh()
	end)

	refresh()
	return refresh
end

--========================================================
-- AIM PAGE
--========================================================

label(
	aimPage, "Aim Controls",
	UDim2.new(1, -30, 0, 35),
	UDim2.new(0, 15, 0, 15),
	21, WHITE
).Font = Enum.Font.GothamBold

toggleRow(
	aimPage, "Automatic Target",
	"Find and track a valid target automatically.",
	"AutoTarget", 65
)

toggleRow(
	aimPage, "Automatic Fire",
	"Request shots through your equipped weapon.",
	"AutoFire", 145
)

local smoothLabel = label(
	aimPage, "Smoothness: " .. Settings.Smoothness,
	UDim2.new(1, -30, 0, 25),
	UDim2.new(0, 15, 0, 230),
	12, WHITE
)
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left

local smoothMinus = button(
	aimPage, "−",
	UDim2.new(0, 50, 0, 35),
	UDim2.new(0, 15, 0, 265)
)
local smoothPlus = button(
	aimPage, "+",
	UDim2.new(0, 50, 0, 35),
	UDim2.new(0, 75, 0, 265)
)

local function refreshSmooth()
	smoothLabel.Text = "Smoothness: " .. Settings.Smoothness
end

smoothMinus.MouseButton1Click:Connect(function()
	Settings.Smoothness = math.max(1, Settings.Smoothness - 1)
	refreshSmooth()
end)

smoothPlus.MouseButton1Click:Connect(function()
	Settings.Smoothness = math.min(30, Settings.Smoothness + 1)
	refreshSmooth()
end)

--========================================================
-- VISUALS PAGE
--========================================================

label(
	visualsPage, "Visual Controls",
	UDim2.new(1, -30, 0, 35),
	UDim2.new(0, 15, 0, 15),
	21, WHITE
).Font = Enum.Font.GothamBold

toggleRow(
	visualsPage, "FOV Circle",
	"Show the target selection radius.",
	"ShowFOV", 65
)

local fovLabel = label(
	visualsPage, "FOV Size: " .. Settings.FOV,
	UDim2.new(1, -30, 0, 25),
	UDim2.new(0, 15, 0, 155),
	12, WHITE
)
fovLabel.TextXAlignment = Enum.TextXAlignment.Left

local fovMinus = button(
	visualsPage, "−",
	UDim2.new(0, 50, 0, 35),
	UDim2.new(0, 15, 0, 190)
)

local fovPlus = button(
	visualsPage, "+",
	UDim2.new(0, 50, 0, 35),
	UDim2.new(0, 75, 0, 190)
)

local function refreshFOV()
	fovLabel.Text = "FOV Size: " .. Settings.FOV
end

fovMinus.MouseButton1Click:Connect(function()
	Settings.FOV = math.max(40, Settings.FOV - 10)
	refreshFOV()
end)

fovPlus.MouseButton1Click:Connect(function()
	Settings.FOV = math.min(400, Settings.FOV + 10)
	refreshFOV()
end)

--========================================================
-- SETTINGS PAGE
--========================================================

label(
	settingsPage, "Hub Settings",
	UDim2.new(1, -30, 0, 35),
	UDim2.new(0, 15, 0, 15),
	21, WHITE
).Font = Enum.Font.GothamBold

local resetButton = button(
	settingsPage, "RESET SETTINGS",
	UDim2.new(1, -30, 0, 42),
	UDim2.new(0, 15, 0, 70)
)

local resetStatus = label(
	settingsPage, "",
	UDim2.new(1, -30, 0, 30),
	UDim2.new(0, 15, 0, 120),
	11, GREEN
)

resetButton.MouseButton1Click:Connect(function()
	Settings.AutoTarget = true
	Settings.AutoFire = true
	Settings.ShowFOV = true
	Settings.FOV = 180
	Settings.Smoothness = 10

	refreshSmooth()
	refreshFOV()
	resetStatus.Text = "Settings restored."
end)

--========================================================
-- FOV CIRCLE
--========================================================

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui
corner(fovCircle, 500)
stroke(fovCircle, PURPLE, 1.5)

--========================================================
-- TARGET HELPERS
--========================================================

local function getCharacter()
	return player.Character
end

local function getTargetPart(model)
	if not model then return nil end
	return model:FindFirstChild("Head")
		or model:FindFirstChild("HumanoidRootPart")
end

local function validTarget(model)
	if not model or not model:IsDescendantOf(workspace) then
		return false
	end

	if model == getCharacter() then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local part = getTargetPart(model)
	local character = getCharacter()
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not part or not root then
		return false
	end

	if (part.Position - root.Position).Magnitude > Settings.MaxDistance then
		return false
	end

	local targetPlayer = Players:GetPlayerFromCharacter(model)
	if targetPlayer and player.Team and targetPlayer.Team == player.Team then
		return false
	end

	local screenPos, visible = camera:WorldToViewportPoint(part.Position)
	if not visible or screenPos.Z <= 0 then
		return false
	end

	local center = camera.ViewportSize / 2
	local distance = (
		Vector2.new(screenPos.X, screenPos.Y) - center
	).Magnitude

	return distance <= Settings.FOV
end

local function findTarget()
	local best
	local bestDistance = math.huge
	local center = camera.ViewportSize / 2
	local seen = {}

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Humanoid") then
			local model = object.Parent

			if model and model:IsA("Model") and not seen[model] then
				seen[model] = true

				if validTarget(model) then
					local part = getTargetPart(model)
					local screenPos = camera:WorldToViewportPoint(part.Position)
					local distance = (
						Vector2.new(screenPos.X, screenPos.Y) - center
					).Magnitude

					if distance < bestDistance then
						bestDistance = distance
						best = model
					end
				end
			end
		end
	end

	return best
end

--========================================================
-- WEAPON HELPERS
--========================================================

local function getEquippedWeapon()
	local character = getCharacter()
	if not character then return nil end

	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") then
			local event = item:FindFirstChild("ShootEvent")

			if event and event:IsA("RemoteEvent") then
				return item, event
			end
		end
	end

	return nil
end

local function fireAtTarget(target)
	local tool, event = getEquippedWeapon()
	if not tool or not event then
		return false
	end

	local character = getCharacter()
	local origin = character and (
		character:FindFirstChild("Head")
			or character:FindFirstChild("HumanoidRootPart")
	)
	local part = getTargetPart(target)

	if not origin or not part then
		return false
	end

	local direction = part.Position - origin.Position
	if direction.Magnitude <= 0 then
		return false
	end

	-- The server must validate the shot and calculate damage.
	event:FireServer(direction.Unit)
	return true
end

--========================================================
-- NAVIGATION INITIAL STATE
--========================================================

switchPage("Home")

--========================================================
-- ACCESS + LOADING FLOW
--========================================================

local function startHub()
	if unlocked then return end
	unlocked = true

	tween(keyCard, 0.25, {
		Position = UDim2.new(0.5, -185, 0.55, -165)
	})

	task.wait(0.25)
	keyScreen.Visible = false
	loading.Visible = true

	tween(progress, 1.8, {
		Size = UDim2.new(1, 0, 1, 0)
	})

	task.wait(1.85)
	spinning = false

	main.Visible = true
	main.Size = UDim2.new(0, 610, 0, 400)
	tween(main, 0.35, {
		Size = UDim2.new(0, 650, 0, 430)
	})

	tween(loading, 0.35, {
		BackgroundTransparency = 1
	})

	task.wait(0.4)
	loading:Destroy()
end

local function checkKey()
	if unlocked then return end

	if keyBox.Text == ACCESS_KEY then
		keyStatus.TextColor3 = GREEN
		keyStatus.Text = "Access granted!"
		unlock.Text = "ACCESS GRANTED"
		task.wait(0.3)
		startHub()
	else
		keyStatus.TextColor3 = RED
		keyStatus.Text = "Incorrect key. Try again."
		keyBox.Text = ""
		tween(keyCard, 0.06, {
			Position = UDim2.new(0.5, -178, 0.5, -165)
		})
		task.wait(0.07)
		tween(keyCard, 0.06, {
			Position = UDim2.new(0.5, -185, 0.5, -165)
		})
	end
end

unlock.MouseButton1Click:Connect(checkKey)

keyBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		checkKey()
	end
end)

--========================================================
-- AUTOMATIC TARGETING / FIRING LOOP
--========================================================

RunService:BindToRenderStep(
	"DarkAimV11",
	Enum.RenderPriority.Camera.Value + 1,
	function(deltaTime)
		camera = workspace.CurrentCamera
		if not camera or not unlocked then return end

		fovCircle.Position = UDim2.fromScale(0.5, 0.5)
		fovCircle.Size = UDim2.new(
			0, Settings.FOV * 2,
			0, Settings.FOV * 2
		)
		fovCircle.Visible = Settings.ShowFOV

		if not Settings.AutoTarget then
			currentTarget = nil
			targetStatus.Text = "Auto target disabled"
			return
		end

		if not validTarget(currentTarget)
			or os.clock() - lastScan >= Settings.ScanInterval then

			if not validTarget(currentTarget) then
				currentTarget = nil
			end

			if not currentTarget then
				currentTarget = findTarget()
			end

			lastScan = os.clock()
		end

		if not currentTarget then
			targetStatus.Text = "Searching for targets..."
			systemStatus.Text = "Waiting for a valid target"
			systemStatus.TextColor3 = MUTED
			return
		end

		local part = getTargetPart(currentTarget)
		if not part then
			currentTarget = nil
			return
		end

		targetStatus.Text = currentTarget.Name
		systemStatus.Text = "Target locked"
		systemStatus.TextColor3 = GREEN

		local desired = CFrame.lookAt(
			camera.CFrame.Position,
			part.Position
		)

		local alpha = math.clamp(
			deltaTime * Settings.Smoothness,
			0,
			1
		)

		camera.CFrame = camera.CFrame:Lerp(desired, alpha)

		if Settings.AutoFire
			and os.clock() - lastShot >= Settings.FireInterval then

			if getEquippedWeapon() then
				if fireAtTarget(currentTarget) then
					lastShot = os.clock()
				end
			end
		end
	end
)

script.Destroying:Connect(function()
	spinning = false
	RunService:UnbindFromRenderStep("DarkAimV11")
end)

print("Dark Aim Assist V11 ready.")
