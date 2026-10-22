-- NameHub · Rivals build 2026-08-23T20:24:40.343Z
print("[NameHub] Boot rivals 2026-08-23T20:24:40.343Z")
--[[
	NameHub · Rivals (Beta)
	ESP-only build — same menu style as NameHub Arsenal/Da Hood
]]

local RIVALS_GAME_ID = 6035872082
local RIVALS_PLACE_IDS= {
	[17625359962] = true,
	[17720162456] = true,
}

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	ESPMaxDistance = 600,
	ESPBoxes = true,
	ESPFillBoxes = false,
	ESPTracers = false,
	ESPSkeleton = false,
	ESPChams = true,
	ESPEnemyColor = Color3.fromRGB(255, 75, 75),
	ESPFillColor = Color3.fromRGB(255, 75, 75),
	ESPTracerColor = Color3.fromRGB(255, 120, 120),
	ESPSkeletonColor = Color3.fromRGB(255, 180, 80),
	ESPChamsColor = Color3.fromRGB(255, 75, 75),
	ESPTracerThickness = 1,
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
}

local THEME = {
	Background = Color3.fromRGB(25, 27, 29),
	Topbar = Color3.fromRGB(32, 34, 37),
	Element = Color3.fromRGB(35, 37, 40),
	Accent = Color3.fromRGB(239, 68, 68),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(160, 160, 165),
	Muted = Color3.fromRGB(130, 132, 140),
	Border = Color3.fromRGB(55, 55, 60),
	ToggleOff = Color3.fromRGB(55, 58, 64),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

print("[NameHub Rivals] Booting… PlaceId", game.PlaceId, "GameId", game.GameId)

local function isSupportedGame()
	if game.GameId == RIVALS_GAME_ID then
		return true
	end
	return RIVALS_PLACE_IDS[game.PlaceId] == true
end

if not isSupportedGame() then
	warn(
		string.format(
			"[NameHub Rivals] Expected Rivals (GameId %s) — got PlaceId %s GameId %s (%s). Continuing anyway.",
			tostring(RIVALS_GAME_ID),
			tostring(game.PlaceId),
			tostring(game.GameId),
			game.Name
		)
	)
end

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubRivalsUnload) == "function" then
		g.NameHubRivalsUnload()
	end
end)

local scriptAlive = true
local menuOpen = true

local function notify(title, detail)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = detail or title,
			Duration = 6,
		})
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NameHubRivalsUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1_000_000
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = true

local function resolveHudParent()
	local parents= {}
	pcall(function()
		local hui = gethui()
		if typeof(hui) == "Instance" then
			table.insert(parents, hui)
		end
	end)
	pcall(function()
		table.insert(parents, game:GetService("CoreGui"))
	end)
	table.insert(parents, playerGui)
	for _, parent in parents do
		local ok = pcall(function()
			screenGui.Parent = parent
		end)
		if ok and screenGui.Parent == parent then
			return parent
		end
	end
	screenGui.Parent = playerGui
	return playerGui
end

resolveHudParent()

pcall(function()
	local g = getgenv()
	local protect = g.protect_gui or (typeof(g.syn) == "table" and g.syn.protect_gui) or g.protectgui
	if typeof(protect) == "function" then
		protect(screenGui)
	end
end)

local espHost = Instance.new("Frame")
espHost.Name = "ESP"
espHost.BackgroundTransparency = 1
espHost.Size = UDim2.fromScale(1, 1)
espHost.ZIndex = 30
espHost.Parent = screenGui

local menuFrame = Instance.new("Frame")
menuFrame.Name = "NameHubMenu"
menuFrame.AnchorPoint = Vector2.new(0, 0.5)
menuFrame.Position = UDim2.new(0, 24, 0.5, 0)
menuFrame.Size = UDim2.fromOffset(420, 360)
menuFrame.BackgroundColor3 = THEME.Background
menuFrame.BorderSizePixel = 0
menuFrame.ZIndex = 50
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = THEME.Border
menuStroke.Transparency = 0.4
menuStroke.Parent = menuFrame

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 44)
topbar.BackgroundColor3 = THEME.Topbar
topbar.BorderSizePixel = 0
topbar.ZIndex = 51
topbar.Parent = menuFrame
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topbar

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(14, 0)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "NameHub · Rivals"
titleLabel.TextColor3 = THEME.Text
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 52
titleLabel.Parent = topbar

local closeButton = Instance.new("TextButton")
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.BackgroundColor3 = THEME.Element
closeButton.Text = "✕"
closeButton.TextColor3 = THEME.Text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.ZIndex = 52
closeButton.Parent = topbar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "NameHubToggle"
toggleButton.Size = UDim2.fromOffset(52, 52)
toggleButton.Position = UDim2.new(0, 12, 0.5, -26)
toggleButton.BackgroundColor3 = THEME.Accent
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Text = "NH ✕"
toggleButton.ZIndex = 1000
toggleButton.AutoButtonColor = true
toggleButton.Parent = screenGui
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.fromOffset(12, 52)
tabBar.Size = UDim2.new(1, -24, 0, 28)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 51
tabBar.Parent = menuFrame

local pagesHost = Instance.new("Frame")
pagesHost.Position = UDim2.fromOffset(0, 88)
pagesHost.Size = UDim2.new(1, 0, 1, -96)
pagesHost.BackgroundTransparency = 1
pagesHost.ZIndex = 50
pagesHost.Parent = menuFrame

local pages= {}
local tabButtons= {}
local layoutOrder = 0

local function nextOrder()
	layoutOrder += 1
	return layoutOrder
end

local function createPage(id)
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. id
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 6
	page.ScrollBarImageColor3 = THEME.Accent
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.Visible = false
	page.ZIndex = 50
	page.Parent = pagesHost
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = page
	pages[id] = page
	return page
end

local selectedTab = "ESP"

local function selectTab(id)
	selectedTab = id
	for name, page in pages do
		page.Visible = name == id
		if name == id then
			page.CanvasPosition = Vector2.zero
		end
	end
	for name, btn in tabButtons do
		local active = name == id
		btn.BackgroundColor3 = if active then THEME.Accent else THEME.ToggleOff
		btn.TextColor3 = if active then Color3.new(1, 1, 1) else THEME.SubText
	end
end

local function createTab(id, label)
	createPage(id)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = THEME.ToggleOff
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.Text = label
	btn.TextColor3 = THEME.SubText
	btn.TextSize = 11
	btn.AutoButtonColor = false
	btn.ZIndex = 52
	btn.Parent = tabBar
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
	tabButtons[id] = btn
	btn.MouseButton1Click:Connect(function()
		selectTab(id)
	end)
end

local function createSection(title)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 24)
	shell.BackgroundTransparency = 1
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = pages[selectedTab]
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = string.upper(title)
	label.TextColor3 = THEME.Muted
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 53
	label.Parent = shell
end

local function createToggle(name, desc, initial, onChange)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 52)
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = pages[selectedTab]
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -70, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 26)
	descLabel.Size = UDim2.new(1, -70, 0, 18)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = THEME.Muted
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 53
	descLabel.Parent = shell
	local toggleBg = Instance.new("Frame")
	toggleBg.AnchorPoint = Vector2.new(1, 0.5)
	toggleBg.Position = UDim2.new(1, -12, 0.5, 0)
	toggleBg.Size = UDim2.fromOffset(44, 24)
	toggleBg.BackgroundColor3 = if initial then THEME.Accent else THEME.ToggleOff
	toggleBg.BorderSizePixel = 0
	toggleBg.ZIndex = 53
	toggleBg.Parent = shell
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleBg
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = if initial then UDim2.new(1, -21, 0.5, -9) else UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 54
	knob.Parent = toggleBg
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	local enabled = initial
	local function setValue(value)
		enabled = value
		toggleBg.BackgroundColor3 = if value then THEME.Accent else THEME.ToggleOff
		knob.Position = if value then UDim2.new(1, -21, 0.5, -9) else UDim2.fromOffset(3, 3)
	end
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.ZIndex = 55
	hit.Parent = shell
	hit.MouseButton1Click:Connect(function()
		setValue(not enabled)
		onChange(enabled)
	end)
	return { Set = setValue }
end

local function setMenuVisible(visible)
	menuOpen = visible
	menuFrame.Visible = visible
	toggleButton.Text = if visible then "NH ✕" else "NH ▶"
	toggleButton.BackgroundColor3 = if visible then THEME.Accent else THEME.Topbar
end

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

toggleButton.MouseButton1Click:Connect(function()
	setMenuVisible(not menuOpen)
end)

createTab("ESP", "ESP")
selectTab("ESP")
selectedTab = "ESP"

createSection("Player ESP")
createToggle("Box ESP", "Corner boxes around players", CONFIG.ESPBoxes, function(v)
	CONFIG.ESPBoxes = v
end)
createToggle("Fill Box ESP", "Filled box behind corners", CONFIG.ESPFillBoxes, function(v)
	CONFIG.ESPFillBoxes = v
end)
createToggle("Tracer ESP", "Lines from screen center to players", CONFIG.ESPTracers, function(v)
	CONFIG.ESPTracers = v
end)
createToggle("Skeleton ESP", "Bone lines on player rigs", CONFIG.ESPSkeleton, function(v)
	CONFIG.ESPSkeleton = v
end)
createToggle("Chams ESP", "Wall highlight on players", CONFIG.ESPChams, function(v)
	CONFIG.ESPChams = v
end)

local function getCharacterPart(character, partName)
	local part = character:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

local function isAlive(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return character:FindFirstChild("HumanoidRootPart") ~= nil
	end
	return humanoid.Health > 0
end

local function espActive()
	return CONFIG.ESPBoxes
		or CONFIG.ESPFillBoxes
		or CONFIG.ESPTracers
		or CONFIG.ESPSkeleton
		or CONFIG.ESPChams
end

local function layoutCornerBox(arms, x, y, w, h, color)
	local len = math.clamp(math.min(w, h) * 0.22, 5, 11)
	local t = 1
	local specs = {
		{ x, y, len, t },
		{ x, y, t, len },
		{ x + w - len, y, len, t },
		{ x + w - t, y, t, len },
		{ x, y + h - t, len, t },
		{ x, y + h - len, t, len },
		{ x + w - len, y + h - t, len, t },
		{ x + w - t, y + h - len, t, len },
	}
	for i, arm in arms do
		local s = specs[i]
		arm.Visible = true
		arm.BackgroundColor3 = color
		arm.Position = UDim2.fromOffset(s[1], s[2])
		arm.Size = UDim2.fromOffset(s[3], s[4])
	end
end

local function hideCornerBox(arms)
	for _, arm in arms do
		arm.Visible = false
	end
end

local function placeEspLine(frame, from, to, color, thickness)
	local delta = to - from
	local length = delta.Magnitude
	if length < 1 then
		frame.Visible = false
		return
	end
	frame.Visible = true
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.25
	frame.Size = UDim2.fromOffset(length, thickness)
	frame.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
	frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

local SKELETON_BONES= {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local espVisuals= {}

local function getEspScreenBox(character)
	camera = workspace.CurrentCamera
	if not camera then
		return nil, nil
	end
	local cf, size = character:GetBoundingBox()
	local hx, hy, hz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local any = false
	for _, offset in {
		Vector3.new(-hx, hy, -hz),
		Vector3.new(hx, hy, -hz),
		Vector3.new(-hx, -hy, -hz),
		Vector3.new(hx, -hy, -hz),
		Vector3.new(-hx, hy, hz),
		Vector3.new(hx, hy, hz),
		Vector3.new(-hx, -hy, hz),
		Vector3.new(hx, -hy, hz),
	} do
		local sp, onScreen = camera:WorldToViewportPoint(cf:PointToWorldSpace(offset))
		if onScreen and sp.Z > 0 then
			any = true
			minX = math.min(minX, sp.X)
			minY = math.min(minY, sp.Y)
			maxX = math.max(maxX, sp.X)
			maxY = math.max(maxY, sp.Y)
		end
	end
	if not any then
		local root = getCharacterPart(character, "HumanoidRootPart")
		if not root then
			return nil, nil
		end
		local sp = camera:WorldToViewportPoint(root.Position)
		if sp.Z <= 0 then
			return nil, nil
		end
		return Vector2.new(sp.X - 14, sp.Y - 25), Vector2.new(28, 50)
	end
	return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local function createSkeletonLine(parent, name)
	local line = Instance.new("Frame")
	line.Name = name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = CONFIG.ESPSkeletonColor
	line.BorderSizePixel = 0
	line.BackgroundTransparency = 0.05
	line.Visible = false
	line.ZIndex = 31
	line.Parent = parent
	return line
end

local function createEspFeature(player)
	local root = Instance.new("Frame")
	root.Name = player.Name
	root.BackgroundTransparency = 1
	root.Visible = false
	root.ZIndex = 31
	root.Parent = espHost

	local boxFill = Instance.new("Frame")
	boxFill.Name = "Fill"
	boxFill.BackgroundColor3 = CONFIG.ESPFillColor
	boxFill.BackgroundTransparency = 0.75
	boxFill.BorderSizePixel = 0
	boxFill.Visible = false
	boxFill.ZIndex = 30
	boxFill.Parent = espHost

	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Size = UDim2.fromScale(1, 1)
	box.Parent = root
	local boxArms= {}
	for _ = 1, 8 do
		local arm = Instance.new("Frame")
		arm.BorderSizePixel = 0
		arm.BackgroundColor3 = CONFIG.ESPEnemyColor
		arm.Visible = false
		arm.ZIndex = 32
		arm.Parent = box
		table.insert(boxArms, arm)
	end

	local tracer = Instance.new("Frame")
	tracer.Name = "Tracer_" .. player.Name
	tracer.BackgroundColor3 = CONFIG.ESPTracerColor
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.ZIndex = 29
	tracer.Parent = espHost

	local skeletonLines= {}
	for i = 1, #SKELETON_BONES do
		table.insert(skeletonLines, createSkeletonLine(espHost, "Skel_" .. player.Name .. "_" .. i))
	end

	return {
		root = root,
		boxFill = boxFill,
		boxArms = boxArms,
		tracer = tracer,
		skeletonLines = skeletonLines,
		highlight = nil,
	}
end

local function clearEspForPlayer(player)
	local visuals = espVisuals[player]
	if visuals then
		visuals.root:Destroy()
		if visuals.boxFill then
			visuals.boxFill:Destroy()
		end
		if visuals.tracer then
			visuals.tracer:Destroy()
		end
		for _, line in visuals.skeletonLines do
			line:Destroy()
		end
		if visuals.highlight then
			visuals.highlight:Destroy()
		end
		espVisuals[player] = nil
	end
end

local function updateSkeletonEsp(visuals, character)
	if not CONFIG.ESPSkeleton then
		for _, line in visuals.skeletonLines do
			line.Visible = false
		end
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local lineIndex = 0
	for _, bone in SKELETON_BONES do
		local a = getCharacterPart(character, bone[1])
		local b = getCharacterPart(character, bone[2])
		if a and b then
			local sa, onA = camera:WorldToViewportPoint(a.Position)
			local sb, onB = camera:WorldToViewportPoint(b.Position)
			if onA and onB and sa.Z > 0 and sb.Z > 0 then
				lineIndex += 1
				local line = visuals.skeletonLines[lineIndex]
				if line then
					placeEspLine(
						line,
						Vector2.new(sa.X, sa.Y),
						Vector2.new(sb.X, sb.Y),
						CONFIG.ESPSkeletonColor,
						1
					)
				end
			end
		end
	end
	for i = lineIndex + 1, #visuals.skeletonLines do
		visuals.skeletonLines[i].Visible = false
	end
end

local function updateEsp()
	if not espActive() then
		for player in espVisuals do
			clearEspForPlayer(player)
		end
		return
	end

	camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local camPos = camera.CFrame.Position
	local tracerOrigin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y - 2)
	local seen= {}

	for _, other in Players:GetPlayers() do
		if other == localPlayer then
			continue
		end

		local character = other.Character
		if not character or not isAlive(character) then
			clearEspForPlayer(other)
			continue
		end

		local root = getCharacterPart(character, "HumanoidRootPart")
		if not root then
			clearEspForPlayer(other)
			continue
		end

		local dist = (root.Position - camPos).Magnitude
		if dist > CONFIG.ESPMaxDistance then
			clearEspForPlayer(other)
			continue
		end

		seen[other] = true
		local visuals = espVisuals[other] or createEspFeature(other)
		espVisuals[other] = visuals

		local topLeft, boxSize = getEspScreenBox(character)
		if not topLeft or not boxSize then
			visuals.root.Visible = false
			visuals.boxFill.Visible = false
			continue
		end

		local x, y = topLeft.X, topLeft.Y
		local width, height = boxSize.X, boxSize.Y
		visuals.root.Visible = true
		visuals.root.Position = UDim2.fromOffset(x, y)
		visuals.root.Size = UDim2.fromOffset(width, height)

		if CONFIG.ESPFillBoxes then
			visuals.boxFill.Visible = true
			visuals.boxFill.Position = UDim2.fromOffset(x, y)
			visuals.boxFill.Size = UDim2.fromOffset(width, height)
			visuals.boxFill.BackgroundColor3 = CONFIG.ESPFillColor
		else
			visuals.boxFill.Visible = false
		end

		if CONFIG.ESPBoxes then
			layoutCornerBox(visuals.boxArms, 0, 0, width, height, CONFIG.ESPEnemyColor)
		else
			hideCornerBox(visuals.boxArms)
		end

		if CONFIG.ESPChams then
			if not visuals.highlight or not visuals.highlight.Parent then
				if visuals.highlight then
					visuals.highlight:Destroy()
				end
				local highlight = Instance.new("Highlight")
				highlight.Name = "NameHubRivalsChams"
				highlight.FillColor = CONFIG.ESPChamsColor
				highlight.OutlineColor = CONFIG.ESPChamsColor
				highlight.FillTransparency = 0.82
				highlight.OutlineTransparency = 0.15
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Adornee = character
				highlight.Parent = character
				visuals.highlight = highlight
			end
			visuals.highlight.Enabled = true
			visuals.highlight.Adornee = character
		elseif visuals.highlight then
			visuals.highlight.Enabled = false
		end

		if CONFIG.ESPTracers then
			local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen and screenPos.Z > 0 then
				placeEspLine(
					visuals.tracer,
					tracerOrigin,
					Vector2.new(screenPos.X, screenPos.Y),
					CONFIG.ESPTracerColor,
					math.max(1, CONFIG.ESPTracerThickness)
				)
			else
				visuals.tracer.Visible = false
			end
		else
			visuals.tracer.Visible = false
		end

		updateSkeletonEsp(visuals, character)
	end

	for player in espVisuals do
		if not seen[player] then
			clearEspForPlayer(player)
		end
	end
end

local perfEsp = 0
RunService.Heartbeat:Connect(function()
	if not scriptAlive then
		return
	end
	local now = os.clock()
	if now - perfEsp >= 0.04 then
		perfEsp = now
		pcall(updateEsp)
	end
end)

UserInputService.InputBegan:Connect(function(input, _gameProcessed)
	if not scriptAlive then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.MenuKey then
		setMenuVisible(not menuOpen)
	end
end)

local function unload()
	scriptAlive = false
	for player in espVisuals do
		clearEspForPlayer(player)
	end
	if screenGui then
		screenGui:Destroy()
	end
end

pcall(function()
	getgenv().NameHubRivalsUnload = unload
end)

setMenuVisible(true)
notify("NameHub Rivals", "Loaded — Insert or NH button for menu")
print("[NameHub Rivals] Loaded — ESP tab ready · Insert = menu")

local HttpService = game:GetService("HttpService")

local function reportLoadToDiscord(gameLabel)
	task.defer(function()
		pcall(function()
			local g = getgenv()
			local url = g.NameHubLoadReportUrl
			if typeof(url) ~= "string" or url == "" then
				return
			end
			local licenseKey = g.NameHubKey
			if typeof(licenseKey) ~= "string" or licenseKey == "" then
				return
			end
			local executorName = "Unknown"
			pcall(function()
				if typeof(identifyexecutor) == "function" then
					executorName = identifyexecutor() or executorName
				elseif typeof(getexecutorname) == "function" then
					executorName = getexecutorname() or executorName
				end
			end)
			local payload = HttpService:JSONEncode({
				key = licenseKey,
				executor = executorName,
				robloxUser = localPlayer.Name,
				robloxUserId = localPlayer.UserId,
				placeId = game.PlaceId,
				gameName = game.Name,
				gameLabel = gameLabel,
			})
			local headers= { ["Content-Type"] = "application/json" }
			local secret = g.NameHubLoadReportSecret
			if typeof(secret) == "string" and secret ~= "" then
				headers["Authorization"] = "Bearer " .. secret
			end
			local req = g.request or g.http_request
			if typeof(g.syn) == "table" and typeof(g.syn.request) == "function" then
				req = g.syn.request
			end
			if typeof(req) == "function" then
				req({
					Url = url,
					Method = "POST",
					Headers = headers,
					Body = payload,
				})
			end
		end)
	end)
end

reportLoadToDiscord("Rivals")
