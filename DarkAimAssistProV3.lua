
local tool = script.Parent
local player = game.Players.LocalPlayer

local shootEvent = tool:WaitForChild("ShootEvent")

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LOCK_KEY = Enum.KeyCode.Q
local RANGE = 500
local FIRE_RATE = 0.2
local LOCK_RADIUS = 300

local equipped = false
local lockedTarget = nil
local fireTimer = 0

local function getTargetPart(model)
	return model:FindFirstChild("Head")
		or model:FindFirstChild("HumanoidRootPart")
end

local function findTarget()
	local character = player.Character
	local camera = workspace.CurrentCamera

	if not character or not camera then return nil end

	local center = camera.ViewportSize / 2
	local bestTarget = nil
	local bestDistance = LOCK_RADIUS

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Humanoid") and object.Health > 0 then
			local model = object.Parent

			if model and model:IsA("Model") and model ~= character then
				local part = getTargetPart(model)

				if part then
					local distance = (part.Position - camera.CFrame.Position).Magnitude

					if distance <= RANGE then
						local screenPos, visible =
							camera:WorldToViewportPoint(part.Position)

						if visible and screenPos.Z > 0 then
							local screenDistance = (
								Vector2.new(screenPos.X, screenPos.Y) - center
							).Magnitude

							if screenDistance < bestDistance then
								local direction = part.Position - camera.CFrame.Position

								local result = workspace:Raycast(
									camera.CFrame.Position,
									direction,
									params
								)

								if result and result.Instance:IsDescendantOf(model) then
									bestDistance = screenDistance
									bestTarget = part
								end
							end
						end
					end
				end
			end
		end
	end

	return bestTarget
end

UIS.InputBegan:Connect(function(input, processed)
	if processed or not equipped then return end

	if input.KeyCode == LOCK_KEY then
		if lockedTarget then
			lockedTarget = nil
			print("Aim lock OFF")
		else
			lockedTarget = findTarget()

			if lockedTarget then
				print("Aim locked:", lockedTarget.Parent.Name)
			else
				print("No visible target nearby")
			end
		end
	end
end)

tool.Equipped:Connect(function()
	equipped = true
end)

tool.Unequipped:Connect(function()
	equipped = false
	lockedTarget = nil
end)

RunService:BindToRenderStep(
	"GunHardLock",
	Enum.RenderPriority.Camera.Value + 1,
	function(dt)
		if not equipped or not lockedTarget then return end

		if not lockedTarget.Parent
			or not lockedTarget:IsDescendantOf(workspace) then
			lockedTarget = nil
			return
		end

		local character = player.Character
		local camera = workspace.CurrentCamera
		local head = character and character:FindFirstChild("Head")

		if not camera or not head then return end

		-- Turn the camera toward the locked target
		camera.CFrame = CFrame.lookAt(
			camera.CFrame.Position,
			lockedTarget.Position
		)

		-- Automatically shoot while locked
		fireTimer += dt

		if fireTimer >= FIRE_RATE then
			fireTimer = 0

			local direction =
				(lockedTarget.Position - head.Position).Unit

			shootEvent:FireServer(direction)
		end
	end
)
