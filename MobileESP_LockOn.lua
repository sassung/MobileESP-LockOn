--==================================================
-- MOBILE ESP + FOV LOCK-ON
-- FOR YOUR OWN ROBLOX GAME
--
-- LocalScript:
-- StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local FOV_RADIUS = 180
local MIN_FOV = 60
local MAX_FOV = 400

local LOCK_SMOOTHNESS = 0.15

-- ESP refresh interval: 5 minutes
local ESP_REFRESH_INTERVAL = 300

local ESP_ENABLED = true
local LOCK_ENABLED = false

local LockedTarget = nil
local Minimized = false

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "MobileESP_LockOn"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- FOV CIRCLE
--==================================================

local FOV = Instance.new("Frame")
FOV.Name = "FOVCircle"
FOV.AnchorPoint = Vector2.new(0.5, 0.5)

FOV.Position = UDim2.fromScale(0.5, 0.5)

FOV.Size = UDim2.fromOffset(
	FOV_RADIUS * 2,
	FOV_RADIUS * 2
)

FOV.BackgroundTransparency = 1
FOV.Parent = GUI

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOV

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOV

--==================================================
-- FOV DRAGGING
--==================================================

local draggingFOV = false
local dragStart
local startPosition

FOV.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		draggingFOV = true
		dragStart = input.Position
		startPosition = FOV.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not draggingFOV then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Touch
		and input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - dragStart

	FOV.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,

		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		draggingFOV = false
	end
end)

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(name, text, position)

	local button = Instance.new("TextButton")

	button.Name = name
	button.Text = text

	button.Size = UDim2.fromOffset(110, 55)
	button.Position = position

	button.BackgroundTransparency = 0.12

	button.TextSize = 18
	button.Font = Enum.Font.GothamBold

	button.AutoButtonColor = true
	button.Parent = GUI

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Parent = button

	return button
end

--==================================================
-- MAIN CONTROLS
--==================================================

local LockButton = createButton(
	"LockButton",
	"LOCK: OFF",
	UDim2.new(1, -125, 1, -135)
)

local ESPButton = createButton(
	"ESPButton",
	"ESP: ON",
	UDim2.new(1, -125, 1, -75)
)

local SmallerFOV = createButton(
	"FOVMinus",
	"FOV -",
	UDim2.new(0, 15, 1, -135)
)

local BiggerFOV = createButton(
	"FOVPlus",
	"FOV +",
	UDim2.new(0, 15, 1, -75)
)

--==================================================
-- MINIMIZE BUTTON
--==================================================

local MinimizeButton = Instance.new("TextButton")

MinimizeButton.Name = "MinimizeButton"

MinimizeButton.Size = UDim2.fromOffset(52, 52)

MinimizeButton.Position =
	UDim2.new(0, 15, 0.5, -26)

MinimizeButton.BackgroundTransparency = 0.1

MinimizeButton.Text = "≡"
MinimizeButton.TextSize = 28
MinimizeButton.Font = Enum.Font.GothamBold

MinimizeButton.Parent = GUI

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(1, 0)
MinimizeCorner.Parent = MinimizeButton

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Thickness = 2
MinimizeStroke.Transparency = 0.15
MinimizeStroke.Parent = MinimizeButton

--==================================================
-- ESP
--==================================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = GUI

local ESPObjects = {}

local function removeESP(model)

	if not model then
		return
	end

	if ESPObjects[model] then
		ESPObjects[model]:Destroy()
		ESPObjects[model] = nil
	end
end

local function createESP(model, displayName, isPlayer)

	if not model or not model:IsA("Model") then
		return
	end

	local head =
		model:FindFirstChild("Head")
		or model:FindFirstChild("HumanoidRootPart")

	if not head then
		return
	end

	-- Reuse existing ESP
	if ESPObjects[model] then

		local label =
			ESPObjects[model]:FindFirstChildOfClass("TextLabel")

		if label then
			label.Text = displayName
		end

		return
	end

	local billboard = Instance.new("BillboardGui")

	billboard.Name = "ESP_" .. model.Name
	billboard.Adornee = head

	billboard.Size =
		UDim2.fromOffset(200, 40)

	billboard.StudsOffset =
		Vector3.new(0, 2.5, 0)

	billboard.AlwaysOnTop = true
	billboard.Parent = ESPFolder

	local label = Instance.new("TextLabel")

	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)

	label.Text = displayName
	label.TextSize = 14

	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.25

	if isPlayer then
		label.TextColor3 =
			Color3.fromRGB(80, 255, 120)
	else
		label.TextColor3 =
			Color3.fromRGB(255, 180, 60)
	end

	label.Parent = billboard

	ESPObjects[model] = billboard
end

--==================================================
-- DETECTION
--==================================================

local function isNPC(model)

	if not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(model) then
		return false
	end

	return model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function isAlive(model)

	if not model then
		return false
	end

	local humanoid =
		model:FindFirstChildOfClass("Humanoid")

	return humanoid
		and humanoid.Health > 0
end

local function getRoot(model)

	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("Head")
end

--==================================================
-- ESP REFRESH
--==================================================

local function updateESP()

	if not ESP_ENABLED then
		return
	end

	-- Players
	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local character = player.Character

			if character and isAlive(character) then

				createESP(
					character,
					player.Name,
					true
				)
			end
		end
	end

	-- NPCs
	for _, object in ipairs(workspace:GetDescendants()) do

		if isNPC(object) and isAlive(object) then

			createESP(
				object,
				object.Name,
				false
			)
		end
	end
end

--==================================================
-- TARGETS
--==================================================

local function getTargets()

	local targets = {}

	-- Players
	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer
			and player.Character
			and isAlive(player.Character) then

			table.insert(
				targets,
				player.Character
			)
		end
	end

	-- NPCs
	for _, object in ipairs(workspace:GetDescendants()) do

		if isNPC(object)
			and isAlive(object) then

			table.insert(
				targets,
				object
			)
		end
	end

	return targets
end

--==================================================
-- FIND CLOSEST TARGET
--==================================================

local function getClosestTarget()

	local center =
		Vector2.new(
			FOV.AbsolutePosition.X
				+ FOV.AbsoluteSize.X / 2,

			FOV.AbsolutePosition.Y
				+ FOV.AbsoluteSize.Y / 2
		)

	local radius =
		FOV.AbsoluteSize.X / 2

	local closestTarget = nil
	local closestDistance = radius

	for _, target in ipairs(getTargets()) do

		local root = getRoot(target)

		if root then

			local screenPosition, visible =
				Camera:WorldToViewportPoint(
					root.Position
				)

			if visible
				and screenPosition.Z > 0 then

				local point =
					Vector2.new(
						screenPosition.X,
						screenPosition.Y
					)

				local distance =
					(point - center).Magnitude

				if distance <= closestDistance then

					closestDistance = distance
					closestTarget = target
				end
			end
		end
	end

	return closestTarget
end

--==================================================
-- CAMERA LOCK
--==================================================

local function lockCamera(target)

	if not target then
		return
	end

	local root = getRoot(target)

	if not root then
		return
	end

	local cameraPosition =
		Camera.CFrame.Position

	local targetCFrame =
		CFrame.lookAt(
			cameraPosition,
			root.Position
		)

	Camera.CFrame =
		Camera.CFrame:Lerp(
			targetCFrame,
			LOCK_SMOOTHNESS
		)
end

--==================================================
-- LOCK BUTTON
--==================================================

LockButton.Activated:Connect(function()

	LOCK_ENABLED = not LOCK_ENABLED

	if LOCK_ENABLED then

		LockedTarget =
			getClosestTarget()

		if LockedTarget then

			LockButton.Text =
				"LOCK: ON"

		else

			LOCK_ENABLED = false

			LockButton.Text =
				"LOCK: OFF"
		end

	else

		LockedTarget = nil

		LockButton.Text =
			"LOCK: OFF"
	end
end)

--==================================================
-- ESP BUTTON
--==================================================

ESPButton.Activated:Connect(function()

	ESP_ENABLED = not ESP_ENABLED

	ESPFolder.Enabled =
		ESP_ENABLED

	if ESP_ENABLED then

		ESPButton.Text =
			"ESP: ON"

		updateESP()

	else

		ESPButton.Text =
			"ESP: OFF"
	end
end)

--==================================================
-- FOV SIZE
--==================================================

local function updateFOV()

	FOV.Size =
		UDim2.fromOffset(
			FOV_RADIUS * 2,
			FOV_RADIUS * 2
		)
end

SmallerFOV.Activated:Connect(function()

	FOV_RADIUS =
		math.max(
			MIN_FOV,
			FOV_RADIUS - 20
		)

	updateFOV()
end)

BiggerFOV.Activated:Connect(function()

	FOV_RADIUS =
		math.min(
			MAX_FOV,
			FOV_RADIUS + 20
		)

	updateFOV()
end)

--==================================================
-- MINIMIZE / EXPAND
--==================================================

local function setMinimized(state)

	Minimized = state

	LockButton.Visible = not state
	ESPButton.Visible = not state
	SmallerFOV.Visible = not state
	BiggerFOV.Visible = not state

	FOV.Visible = not state

	if state then
		MinimizeButton.Text = "＋"
	else
		MinimizeButton.Text = "≡"
	end
end

MinimizeButton.Activated:Connect(function()

	setMinimized(not Minimized)
end)

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		task.wait(0.5)

		if ESP_ENABLED then

			createESP(
				character,
				player.Name,
				true
			)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)

	if player.Character then
		removeESP(player.Character)
	end
end)

--==================================================
-- MAIN LOOP
--==================================================

local espTimer = 0

RunService.RenderStepped:Connect(function(dt)

	espTimer += dt

	-- Refresh ESP every 5 minutes
	if espTimer >= ESP_REFRESH_INTERVAL then

		espTimer = 0

		if ESP_ENABLED then
			updateESP()
		end
	end

	-- Lock-on continuously
	if LOCK_ENABLED then

		if not LockedTarget
			or not LockedTarget.Parent
			or not isAlive(LockedTarget) then

			LockedTarget =
				getClosestTarget()
		end

		if LockedTarget then
			lockCamera(LockedTarget)
		end
	end
end)

--==================================================
-- INITIALIZE
--==================================================

updateFOV()
updateESP()

print("Mobile ESP + FOV Lock-On loaded.")
