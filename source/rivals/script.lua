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
	Background = Color3.fromRGB(16, 16, 18),
	Topbar = Color3.fromRGB(12, 12, 14),
	Element = Color3.fromRGB(22, 22, 25),
	Accent = Color3.fromRGB(230, 55, 85),
	Text = Color3.fromRGB(232, 232, 236),
	SubText = Color3.fromRGB(118, 116, 130),
	Muted = Color3.fromRGB(118, 116, 130),
	Border = Color3.fromRGB(48, 48, 54),
	ToggleOff = Color3.fromRGB(60, 60, 65),
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
local menuOpen = false
local uiLoading = true

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
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.Position = UDim2.fromScale(0.5, 0.5)
menuFrame.Size = UDim2.fromOffset(732, 340)
menuFrame.BackgroundColor3 = THEME.Background
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 50
menuFrame.Parent = screenGui
local menuStroke = Instance.new("UIStroke")
menuStroke.Color = THEME.Border
menuStroke.Parent = menuFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "NameHubToggle"
toggleButton.Size = UDim2.fromOffset(36, 36)
toggleButton.Position = UDim2.new(0, 12, 0.5, -18)
toggleButton.BackgroundColor3 = THEME.Background
toggleButton.TextColor3 = THEME.Accent
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Text = "NH"
toggleButton.ZIndex = 1000
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = THEME.Border
toggleStroke.Parent = toggleButton

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 46)
topbar.BackgroundColor3 = THEME.Topbar
topbar.BorderSizePixel = 0
topbar.ZIndex = 51
topbar.Parent = menuFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(16, 0)
titleLabel.Size = UDim2.fromOffset(140, 46)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "NAMEHUB"
titleLabel.TextColor3 = THEME.Accent
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 52
titleLabel.Parent = topbar

local espTab = Instance.new("TextLabel")
espTab.BackgroundTransparency = 1
espTab.Position = UDim2.fromOffset(150, 0)
espTab.Size = UDim2.fromOffset(50, 46)
espTab.Font = Enum.Font.GothamBold
espTab.Text = "ESP"
espTab.TextColor3 = THEME.Text
espTab.TextSize = 12
espTab.ZIndex = 52
espTab.Parent = topbar
local espLine = Instance.new("Frame")
espLine.AnchorPoint = Vector2.new(0.5, 1)
espLine.Position = UDim2.new(0.5, 0, 1, 0)
espLine.Size = UDim2.new(1, -16, 0, 2)
espLine.BackgroundColor3 = THEME.Accent
espLine.BorderSizePixel = 0
espLine.ZIndex = 53
espLine.Parent = espTab

local tag = Instance.new("TextLabel")
tag.BackgroundTransparency = 1
tag.AnchorPoint = Vector2.new(1, 0.5)
tag.Position = UDim2.new(1, -16, 0.5, 0)
tag.Size = UDim2.fromOffset(80, 20)
tag.Font = Enum.Font.Gotham
tag.Text = "rivals"
tag.TextColor3 = THEME.SubText
tag.TextSize = 12
tag.TextXAlignment = Enum.TextXAlignment.Right
tag.ZIndex = 52
tag.Parent = topbar

local closeButton = Instance.new("TextButton")
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -96, 0.5, 0)
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = THEME.SubText
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.ZIndex = 52
closeButton.Parent = topbar

local function makeColumn(x, title)
	local col = Instance.new("Frame")
	col.BackgroundColor3 = THEME.Element
	col.BorderSizePixel = 0
	col.Position = UDim2.fromOffset(x, 58)
	col.Size = UDim2.new(0, 228, 1, -70)
	col.ZIndex = 51
	col.Parent = menuFrame
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Border
	stroke.Parent = col
	local head = Instance.new("TextLabel")
	head.BackgroundTransparency = 1
	head.Position = UDim2.fromOffset(12, 10)
	head.Size = UDim2.new(1, -24, 0, 18)
	head.Font = Enum.Font.GothamBold
	head.Text = string.upper(title)
	head.TextColor3 = THEME.SubText
	head.TextSize = 11
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.ZIndex = 52
	head.Parent = col
	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(12, 36)
	body.Size = UDim2.new(1, -24, 1, -46)
	body.ZIndex = 52
	body.Parent = col
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = body
	return body
end

local function createToggle(parent, name, initial, onChange)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.Text = ""
	row.AutoButtonColor = false
	row.ZIndex = 53
	row.Parent = parent
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, -24, 1, 0)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 54
	nameLabel.Parent = row
	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, 0, 0.5, 0)
	box.Size = UDim2.fromOffset(14, 14)
	box.BackgroundColor3 = if initial then THEME.Accent else Color3.fromRGB(18, 18, 20)
	box.BorderSizePixel = 0
	box.ZIndex = 54
	box.Parent = row
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = if initial then THEME.Accent else THEME.Border
	boxStroke.Parent = box
	local mark = Instance.new("Frame")
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	mark.Size = UDim2.fromOffset(8, 8)
	mark.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	mark.BorderSizePixel = 0
	mark.Visible = initial
	mark.ZIndex = 55
	mark.Parent = box
	local enabled = initial
	local function setValue(value)
		enabled = value
		box.BackgroundColor3 = if value then THEME.Accent else Color3.fromRGB(18, 18, 20)
		boxStroke.Color = if value then THEME.Accent else THEME.Border
		mark.Visible = value
	end
	row.MouseButton1Click:Connect(function()
		setValue(not enabled)
		onChange(enabled)
	end)
	return { Set = setValue }
end

local function setMenuVisible(visible)
	if uiLoading then
		visible = false
	end
	menuOpen = visible
	menuFrame.Visible = visible
	toggleButton.Text = "NH"
	toggleButton.TextColor3 = if visible then THEME.Accent else THEME.SubText
end

closeButton.MouseButton1Click:Connect(function()
	if uiLoading then
		return
	end
	setMenuVisible(false)
end)

toggleButton.MouseButton1Click:Connect(function()
	if uiLoading then
		return
	end
	setMenuVisible(not menuOpen)
end)

do
	local dragging = false
	local dragStart = nil
	local startPos = nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = menuFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not dragStart or not startPos then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local boxesCol = makeColumn(12, "Boxes")
local linesCol = makeColumn(252, "Lines")
local highlightCol = makeColumn(492, "Highlight")

createToggle(boxesCol, "Box ESP", CONFIG.ESPBoxes, function(v)
	CONFIG.ESPBoxes = v
end)
createToggle(boxesCol, "Fill Box ESP", CONFIG.ESPFillBoxes, function(v)
	CONFIG.ESPFillBoxes = v
end)
createToggle(linesCol, "Tracer ESP", CONFIG.ESPTracers, function(v)
	CONFIG.ESPTracers = v
end)
createToggle(linesCol, "Skeleton ESP", CONFIG.ESPSkeleton, function(v)
	CONFIG.ESPSkeleton = v
end)
createToggle(highlightCol, "Chams ESP", CONFIG.ESPChams, function(v)
	CONFIG.ESPChams = v
end)

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 16, 1, -8)
footer.Size = UDim2.new(1, -32, 0, 16)
footer.Font = Enum.Font.Gotham
footer.TextSize = 11
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.TextColor3 = THEME.SubText
footer.Text = "Insert · rivals"
footer.ZIndex = 52
footer.Parent = menuFrame

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
		if uiLoading then
			return
		end
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

local loaderFrame = Instance.new("Frame")
loaderFrame.Name = "Loader"
loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
loaderFrame.Position = UDim2.fromScale(0.5, 0.5)
loaderFrame.Size = UDim2.fromOffset(460, 124)
loaderFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
loaderFrame.BorderSizePixel = 0
loaderFrame.ZIndex = 80
loaderFrame.Parent = screenGui
local loaderStroke = Instance.new("UIStroke")
loaderStroke.Color = Color3.fromRGB(48, 48, 54)
loaderStroke.Parent = loaderFrame
local loaderLogo = Instance.new("TextLabel")
loaderLogo.BackgroundTransparency = 1
loaderLogo.Position = UDim2.fromOffset(18, 16)
loaderLogo.Size = UDim2.new(1, -120, 0, 24)
loaderLogo.Font = Enum.Font.GothamBold
loaderLogo.TextSize = 18
loaderLogo.TextXAlignment = Enum.TextXAlignment.Left
loaderLogo.TextColor3 = Color3.fromRGB(230, 55, 85)
loaderLogo.Text = "NAMEHUB"
loaderLogo.ZIndex = 81
loaderLogo.Parent = loaderFrame
local loaderPercent = Instance.new("TextLabel")
loaderPercent.BackgroundTransparency = 1
loaderPercent.AnchorPoint = Vector2.new(1, 0)
loaderPercent.Position = UDim2.new(1, -18, 0, 16)
loaderPercent.Size = UDim2.fromOffset(80, 24)
loaderPercent.Font = Enum.Font.GothamBold
loaderPercent.TextSize = 18
loaderPercent.TextXAlignment = Enum.TextXAlignment.Right
loaderPercent.TextColor3 = Color3.fromRGB(232, 232, 236)
loaderPercent.Text = "1%"
loaderPercent.ZIndex = 81
loaderPercent.Parent = loaderFrame
local loaderStatus = Instance.new("TextLabel")
loaderStatus.BackgroundTransparency = 1
loaderStatus.Position = UDim2.fromOffset(18, 44)
loaderStatus.Size = UDim2.new(1, -36, 0, 18)
loaderStatus.Font = Enum.Font.Gotham
loaderStatus.TextSize = 13
loaderStatus.TextXAlignment = Enum.TextXAlignment.Left
loaderStatus.TextColor3 = Color3.fromRGB(118, 116, 130)
loaderStatus.Text = "loading"
loaderStatus.ZIndex = 81
loaderStatus.Parent = loaderFrame
local loaderTrack = Instance.new("Frame")
loaderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
loaderTrack.BorderSizePixel = 0
loaderTrack.Position = UDim2.fromOffset(18, 78)
loaderTrack.Size = UDim2.new(1, -36, 0, 8)
loaderTrack.ZIndex = 81
loaderTrack.Parent = loaderFrame
local loaderFill = Instance.new("Frame")
loaderFill.BackgroundColor3 = Color3.fromRGB(230, 55, 85)
loaderFill.BorderSizePixel = 0
loaderFill.Size = UDim2.new(0.01, 0, 1, 0)
loaderFill.ZIndex = 82
loaderFill.Parent = loaderTrack
local loaderHint = Instance.new("TextLabel")
loaderHint.BackgroundTransparency = 1
loaderHint.Position = UDim2.fromOffset(18, 94)
loaderHint.Size = UDim2.new(1, -36, 0, 16)
loaderHint.Font = Enum.Font.Gotham
loaderHint.TextSize = 11
loaderHint.TextXAlignment = Enum.TextXAlignment.Left
loaderHint.TextColor3 = Color3.fromRGB(118, 116, 130)
loaderHint.Text = "rivals"
loaderHint.ZIndex = 81
loaderHint.Parent = loaderFrame

setMenuVisible(false)
print("[NameHub Rivals] Loading")
task.spawn(function()
	for step = 1, 100 do
		if not scriptAlive then
			return
		end
		loaderPercent.Text = tostring(step) .. "%"
		loaderFill.Size = UDim2.new(step / 100, 0, 1, 0)
		if step < 35 then
			loaderStatus.Text = "loading"
		elseif step < 70 then
			loaderStatus.Text = "preparing visuals"
		elseif step < 100 then
			loaderStatus.Text = "starting"
		else
			loaderStatus.Text = "ready"
		end
		task.wait(0.018)
	end
	uiLoading = false
	if loaderFrame then
		loaderFrame:Destroy()
	end
	setMenuVisible(true)
	notify("NameHub Rivals", "Insert opens the menu")
end)

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
