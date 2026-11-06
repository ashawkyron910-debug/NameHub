-- NameHub · Blox Strike
warn("[NameHub] Boot Blox Strike")
--[[
	NameHub · Blox Strike
	Aim + ESP · Insert for menu
]]

local PLACE_ID = 114234929420007
local UNIVERSE_ID = 7633926880

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	TeamCheck = true,
	AimEnabled = false,
	AimHold = true,
	AimKey = Enum.UserInputType.MouseButton2,
	AimFov = 120,
	AimSmooth = 0.22,
	AimPart = "Head",
	ShowFov = true,
	ESPEnabled = true,
	ESPMaxDistance = 800,
	ESPBoxes = true,
	ESPNames = true,
	ESPDistance = true,
	ESPTracers = false,
	ESPTeamCheck = true,
	ESPEnemyColor = Color3.fromRGB(230, 55, 85),
	ESPNameColor = Color3.fromRGB(235, 235, 240),
	ESPTracerColor = Color3.fromRGB(230, 55, 85),
}

local THEME = {
	Background = Color3.fromRGB(16, 16, 18),
	Topbar = Color3.fromRGB(12, 12, 14),
	Element = Color3.fromRGB(22, 22, 25),
	Accent = Color3.fromRGB(230, 55, 85),
	Text = Color3.fromRGB(232, 232, 236),
	SubText = Color3.fromRGB(118, 116, 130),
	Stroke = Color3.fromRGB(48, 48, 54),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubBloxStrikeUnload) == "function" then
		g.NameHubBloxStrikeUnload()
	end
end)

local scriptAlive = true
local menuOpen = false
local uiLoading = true
local aimHolding = false
local currentPage = "Aim"

local screenGui
local menuFrame
local toggleButton
local pageButtons = {}
local pageFrames = {}
local espFolder
local fovRing

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text or title,
			Duration = 4,
		})
	end)
end

local function resolveHudParent(gui)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		gui.Parent = playerGui
	end
	if gui.Parent then
		return
	end
	pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end)
	if gui.Parent then
		return
	end
	pcall(function()
		local hui = gethui()
		if typeof(hui) == "Instance" then
			gui.Parent = hui
		end
	end)
end

local function protectGui(gui)
	pcall(function()
		local g = getgenv()
		local protect = g.protect_gui or (typeof(g.syn) == "table" and g.syn.protect_gui) or g.protectgui
		if typeof(protect) == "function" then
			protect(gui)
		end
	end)
end

local function sameTeam(player)
	if not player or player == localPlayer then
		return true
	end
	if localPlayer.Team and player.Team and localPlayer.Team == player.Team then
		return true
	end
	if localPlayer.TeamColor and player.TeamColor and localPlayer.TeamColor == player.TeamColor then
		return true
	end
	return false
end

local function getRoot(model)
	return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
end

local function getAimPart(char)
	if CONFIG.AimPart == "Head" then
		return char:FindFirstChild("Head") or getRoot(char)
	end
	return getRoot(char)
end

local function worldToScreen(point)
	local v, onScreen = camera:WorldToViewportPoint(point)
	if not onScreen or v.Z <= 0 then
		return nil
	end
	return Vector2.new(v.X, v.Y)
end

local function isValidTarget(player, useTeamCheck)
	if not player or player == localPlayer then
		return false
	end
	if useTeamCheck and sameTeam(player) then
		return false
	end
	local char = player.Character
	if not char or not char:IsDescendantOf(workspace) then
		return false
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = getRoot(char)
	if not hum or hum.Health <= 0 or not root then
		return false
	end
	return true
end

local function findClosestInFov()
	camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local center = camera.ViewportSize / 2
	local bestPlayer = nil
	local bestDist = CONFIG.AimFov
	for _, player in ipairs(Players:GetPlayers()) do
		if isValidTarget(player, CONFIG.TeamCheck) then
			local part = getAimPart(player.Character)
			if part then
				local screen = worldToScreen(part.Position)
				if screen then
					local dist = (screen - center).Magnitude
					if dist < bestDist then
						bestDist = dist
						bestPlayer = player
					end
				end
			end
		end
	end
	return bestPlayer
end

local function setMenuVisible(visible)
	if uiLoading then
		visible = false
	end
	menuOpen = visible
	if menuFrame then
		menuFrame.Visible = visible
	end
	if toggleButton then
		toggleButton.TextColor3 = if visible then THEME.Accent else THEME.SubText
	end
end

local function createToggle(parent, label, getter, setter)
	local row = Instance.new("TextButton")
	row.AutoButtonColor = false
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Text = ""
	row.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -28, 1, 0)
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 13
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = THEME.Text
	textLabel.Text = label
	textLabel.Parent = row
	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, 0, 0.5, 0)
	box.Size = UDim2.fromOffset(14, 14)
	box.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	box.BorderSizePixel = 0
	box.Parent = row
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Stroke
	stroke.Parent = box
	local mark = Instance.new("Frame")
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	mark.Size = UDim2.fromOffset(8, 8)
	mark.BackgroundColor3 = THEME.Accent
	mark.BorderSizePixel = 0
	mark.Parent = box
	local function paint()
		local on = getter()
		mark.Visible = on
		stroke.Color = if on then THEME.Accent else THEME.Stroke
	end
	row.MouseButton1Click:Connect(function()
		setter(not getter())
		paint()
	end)
	paint()
end

local function createSlider(parent, label, minV, maxV, getter, setter)
	local wrap = Instance.new("Frame")
	wrap.BackgroundTransparency = 1
	wrap.Size = UDim2.new(1, 0, 0, 42)
	wrap.Parent = parent
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 16)
	title.Font = Enum.Font.Gotham
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Text
	title.Parent = wrap
	local track = Instance.new("Frame")
	track.Position = UDim2.fromOffset(0, 24)
	track.Size = UDim2.new(1, 0, 0, 6)
	track.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	track.BorderSizePixel = 0
	track.Parent = wrap
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	local dragging = false
	local function paint()
		local value = getter()
		local alpha = math.clamp((value - minV) / (maxV - minV), 0, 1)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		title.Text = string.format("%s  %s", label, tostring(math.floor(value + 0.5)))
	end
	local function setFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		setter(minV + (maxV - minV) * rel)
		paint()
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	paint()
end

local function showPage(name)
	currentPage = name
	for pageName, frame in pairs(pageFrames) do
		frame.Visible = pageName == name
	end
	for pageName, button in pairs(pageButtons) do
		button.TextColor3 = if pageName == name then THEME.Accent else THEME.SubText
	end
end

local function makePage(parent, name)
	local frame = Instance.new("ScrollingFrame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.CanvasSize = UDim2.new()
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.ScrollBarThickness = 3
	frame.ScrollBarImageColor3 = THEME.Accent
	frame.Visible = false
	frame.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = frame
	pageFrames[name] = frame
	return frame
end

local loaderFrame
local loadPercent
local loadFill
local loadStatus

local function buildMenu()
	if screenGui then
		screenGui:Destroy()
	end
	pageButtons = {}
	pageFrames = {}

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NameHubBloxStrikeUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1_000_000
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	resolveHudParent(screenGui)
	protectGui(screenGui)

	espFolder = Instance.new("Folder")
	espFolder.Name = "NameHubBloxStrikeESP"
	espFolder.Parent = screenGui

	fovRing = Instance.new("Frame")
	fovRing.Name = "Fov"
	fovRing.AnchorPoint = Vector2.new(0.5, 0.5)
	fovRing.BackgroundTransparency = 1
	fovRing.BorderSizePixel = 0
	fovRing.Visible = false
	fovRing.Parent = screenGui
	local fovStroke = Instance.new("UIStroke")
	fovStroke.Color = THEME.Accent
	fovStroke.Thickness = 1
	fovStroke.Transparency = 0.35
	fovStroke.Parent = fovRing
	local fovCorner = Instance.new("UICorner")
	fovCorner.CornerRadius = UDim.new(1, 0)
	fovCorner.Parent = fovRing

	toggleButton = Instance.new("TextButton")
	toggleButton.Name = "NameHubToggle"
	toggleButton.AnchorPoint = Vector2.new(1, 0)
	toggleButton.Position = UDim2.new(1, -16, 0, 72)
	toggleButton.Size = UDim2.fromOffset(36, 36)
	toggleButton.BackgroundColor3 = THEME.Element
	toggleButton.BorderSizePixel = 0
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 12
	toggleButton.Text = "NH"
	toggleButton.TextColor3 = THEME.SubText
	toggleButton.AutoButtonColor = false
	toggleButton.Parent = screenGui
	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = THEME.Stroke
	toggleStroke.Parent = toggleButton
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleButton
	toggleButton.MouseButton1Click:Connect(function()
		setMenuVisible(not menuOpen)
	end)

	menuFrame = Instance.new("Frame")
	menuFrame.Name = "Menu"
	menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	menuFrame.Position = UDim2.fromScale(0.5, 0.5)
	menuFrame.Size = UDim2.fromOffset(460, 360)
	menuFrame.BackgroundColor3 = THEME.Background
	menuFrame.BorderSizePixel = 0
	menuFrame.Visible = false
	menuFrame.Parent = screenGui
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = THEME.Stroke
	menuStroke.Parent = menuFrame
	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 10)
	menuCorner.Parent = menuFrame

	local top = Instance.new("Frame")
	top.BackgroundColor3 = THEME.Topbar
	top.BorderSizePixel = 0
	top.Size = UDim2.new(1, 0, 0, 44)
	top.Parent = menuFrame
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = top
	local topMask = Instance.new("Frame")
	topMask.BackgroundColor3 = THEME.Topbar
	topMask.BorderSizePixel = 0
	topMask.Position = UDim2.new(0, 0, 1, -10)
	topMask.Size = UDim2.new(1, 0, 0, 10)
	topMask.Parent = top

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(16, 0)
	title.Size = UDim2.new(0.5, 0, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Text
	title.Text = "NameHub · Blox Strike"
	title.Parent = top

	local tabs = Instance.new("Frame")
	tabs.BackgroundTransparency = 1
	tabs.AnchorPoint = Vector2.new(1, 0.5)
	tabs.Position = UDim2.new(1, -12, 0.5, 0)
	tabs.Size = UDim2.fromOffset(180, 28)
	tabs.Parent = top
	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	tabsLayout.Padding = UDim.new(0, 8)
	tabsLayout.Parent = tabs

	local body = Instance.new("Frame")
	body.BackgroundColor3 = THEME.Element
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(16, 56)
	body.Size = UDim2.new(1, -32, 1, -72)
	body.Parent = menuFrame
	local bodyStroke = Instance.new("UIStroke")
	bodyStroke.Color = THEME.Stroke
	bodyStroke.Parent = body
	local bodyCorner = Instance.new("UICorner")
	bodyCorner.CornerRadius = UDim.new(0, 8)
	bodyCorner.Parent = body

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(14, 12)
	content.Size = UDim2.new(1, -28, 1, -24)
	content.Parent = body

	for _, name in ipairs({ "Aim", "Visuals" }) do
		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.fromOffset(56, 28)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.Text = name
		btn.TextColor3 = THEME.SubText
		btn.AutoButtonColor = false
		btn.Parent = tabs
		pageButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			showPage(name)
		end)
		makePage(content, name)
	end

	local aimPage = pageFrames.Aim
	createToggle(aimPage, "Aimbot", function()
		return CONFIG.AimEnabled
	end, function(v)
		CONFIG.AimEnabled = v
	end)
	createToggle(aimPage, "Hold RMB", function()
		return CONFIG.AimHold
	end, function(v)
		CONFIG.AimHold = v
	end)
	createToggle(aimPage, "Team Check", function()
		return CONFIG.TeamCheck
	end, function(v)
		CONFIG.TeamCheck = v
	end)
	createToggle(aimPage, "Show FOV", function()
		return CONFIG.ShowFov
	end, function(v)
		CONFIG.ShowFov = v
	end)
	createSlider(aimPage, "FOV", 40, 400, function()
		return CONFIG.AimFov
	end, function(v)
		CONFIG.AimFov = v
	end)
	createSlider(aimPage, "Smooth", 1, 40, function()
		return math.floor(CONFIG.AimSmooth * 100 + 0.5)
	end, function(v)
		CONFIG.AimSmooth = math.clamp(v / 100, 0.01, 1)
	end)

	local visualsPage = pageFrames.Visuals
	createToggle(visualsPage, "ESP", function()
		return CONFIG.ESPEnabled
	end, function(v)
		CONFIG.ESPEnabled = v
	end)
	createToggle(visualsPage, "Boxes", function()
		return CONFIG.ESPBoxes
	end, function(v)
		CONFIG.ESPBoxes = v
	end)
	createToggle(visualsPage, "Names", function()
		return CONFIG.ESPNames
	end, function(v)
		CONFIG.ESPNames = v
	end)
	createToggle(visualsPage, "Distance", function()
		return CONFIG.ESPDistance
	end, function(v)
		CONFIG.ESPDistance = v
	end)
	createToggle(visualsPage, "Tracers", function()
		return CONFIG.ESPTracers
	end, function(v)
		CONFIG.ESPTracers = v
	end)
	createToggle(visualsPage, "ESP Team Check", function()
		return CONFIG.ESPTeamCheck
	end, function(v)
		CONFIG.ESPTeamCheck = v
	end)
	createSlider(visualsPage, "Max Distance", 100, 2000, function()
		return CONFIG.ESPMaxDistance
	end, function(v)
		CONFIG.ESPMaxDistance = v
	end)

	showPage("Aim")

	loaderFrame = Instance.new("Frame")
	loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	loaderFrame.Position = UDim2.fromScale(0.5, 0.5)
	loaderFrame.Size = UDim2.fromOffset(260, 84)
	loaderFrame.BackgroundColor3 = THEME.Background
	loaderFrame.BorderSizePixel = 0
	loaderFrame.Parent = screenGui
	local loaderStroke = Instance.new("UIStroke")
	loaderStroke.Color = THEME.Stroke
	loaderStroke.Parent = loaderFrame
	local loaderCorner = Instance.new("UICorner")
	loaderCorner.CornerRadius = UDim.new(0, 10)
	loaderCorner.Parent = loaderFrame

	local loaderTitle = Instance.new("TextLabel")
	loaderTitle.BackgroundTransparency = 1
	loaderTitle.Position = UDim2.fromOffset(16, 12)
	loaderTitle.Size = UDim2.new(1, -32, 0, 18)
	loaderTitle.Font = Enum.Font.GothamBold
	loaderTitle.TextSize = 13
	loaderTitle.TextXAlignment = Enum.TextXAlignment.Left
	loaderTitle.TextColor3 = THEME.Text
	loaderTitle.Text = "NameHub · Blox Strike"
	loaderTitle.Parent = loaderFrame

	loadStatus = Instance.new("TextLabel")
	loadStatus.BackgroundTransparency = 1
	loadStatus.Position = UDim2.fromOffset(16, 34)
	loadStatus.Size = UDim2.new(1, -80, 0, 16)
	loadStatus.Font = Enum.Font.Gotham
	loadStatus.TextSize = 11
	loadStatus.TextXAlignment = Enum.TextXAlignment.Left
	loadStatus.TextColor3 = THEME.SubText
	loadStatus.Text = "loading"
	loadStatus.Parent = loaderFrame

	loadPercent = Instance.new("TextLabel")
	loadPercent.BackgroundTransparency = 1
	loadPercent.AnchorPoint = Vector2.new(1, 0)
	loadPercent.Position = UDim2.new(1, -16, 0, 34)
	loadPercent.Size = UDim2.fromOffset(48, 16)
	loadPercent.Font = Enum.Font.GothamBold
	loadPercent.TextSize = 11
	loadPercent.TextXAlignment = Enum.TextXAlignment.Right
	loadPercent.TextColor3 = THEME.Accent
	loadPercent.Text = "0%"
	loadPercent.Parent = loaderFrame

	local barBg = Instance.new("Frame")
	barBg.Position = UDim2.fromOffset(16, 58)
	barBg.Size = UDim2.new(1, -32, 0, 8)
	barBg.BackgroundColor3 = THEME.Element
	barBg.BorderSizePixel = 0
	barBg.Parent = loaderFrame
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = barBg
	loadFill = Instance.new("Frame")
	loadFill.Size = UDim2.new(0, 0, 1, 0)
	loadFill.BackgroundColor3 = THEME.Accent
	loadFill.BorderSizePixel = 0
	loadFill.Parent = barBg
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = loadFill
end

local espCache = {}

local function cleanupEsp(model)
	local entry = espCache[model]
	if not entry then
		return
	end
	for _, key in ipairs({ "box", "name", "dist", "tracer" }) do
		local obj = entry[key]
		if obj then
			obj:Destroy()
		end
	end
	espCache[model] = nil
end

local function updateEsp()
	if not scriptAlive or not espFolder then
		return
	end
	camera = workspace.CurrentCamera
	local seen = {}
	if not CONFIG.ESPEnabled then
		for model in pairs(espCache) do
			cleanupEsp(model)
		end
		return
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if not isValidTarget(player, CONFIG.ESPTeamCheck) then
			continue
		end
		local char = player.Character
		local root = getRoot(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then
			continue
		end
		local dist = (root.Position - camera.CFrame.Position).Magnitude
		if dist > CONFIG.ESPMaxDistance then
			continue
		end
		seen[char] = true
		local entry = espCache[char]
		if not entry then
			entry = {}
			espCache[char] = entry
		end
		local head = char:FindFirstChild("Head") or root
		local sTop = worldToScreen(head.Position + Vector3.new(0, 0.8, 0))
		local sFoot = worldToScreen(root.Position - Vector3.new(0, 3, 0))
		if not sTop or not sFoot then
			continue
		end
		local height = math.abs(sFoot.Y - sTop.Y)
		local width = height * 0.55

		if CONFIG.ESPBoxes then
			if not entry.box then
				local box = Instance.new("Frame")
				box.BackgroundTransparency = 1
				box.BorderSizePixel = 0
				box.Parent = espFolder
				local stroke = Instance.new("UIStroke")
				stroke.Color = CONFIG.ESPEnemyColor
				stroke.Thickness = 1.5
				stroke.Parent = box
				entry.box = box
			end
			entry.box.Size = UDim2.fromOffset(width, height)
			entry.box.Position = UDim2.fromOffset(sTop.X - width / 2, sTop.Y)
			entry.box.Visible = true
		elseif entry.box then
			entry.box.Visible = false
		end

		if CONFIG.ESPNames then
			if not entry.name then
				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 13
				lbl.TextColor3 = CONFIG.ESPNameColor
				lbl.Parent = espFolder
				entry.name = lbl
			end
			entry.name.Text = player.DisplayName
			entry.name.Size = UDim2.fromOffset(200, 16)
			entry.name.Position = UDim2.fromOffset(sTop.X - 100, sTop.Y - 18)
			entry.name.Visible = true
		elseif entry.name then
			entry.name.Visible = false
		end

		if CONFIG.ESPTracers then
			if not entry.tracer then
				local line = Instance.new("Frame")
				line.AnchorPoint = Vector2.new(0, 0.5)
				line.BorderSizePixel = 0
				line.BackgroundColor3 = CONFIG.ESPTracerColor
				line.Parent = espFolder
				entry.tracer = line
			end
			local origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
			local delta = Vector2.new(sFoot.X, sFoot.Y) - origin
			entry.tracer.Size = UDim2.fromOffset(delta.Magnitude, 1)
			entry.tracer.Position = UDim2.fromOffset(origin.X, origin.Y)
			entry.tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			entry.tracer.Visible = true
		elseif entry.tracer then
			entry.tracer.Visible = false
		end

		if CONFIG.ESPDistance then
			if not entry.dist then
				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = THEME.SubText
				lbl.Parent = espFolder
				entry.dist = lbl
			end
			entry.dist.Text = string.format("%dm", math.floor(dist))
			entry.dist.Size = UDim2.fromOffset(80, 14)
			entry.dist.Position = UDim2.fromOffset(sTop.X - 40, sFoot.Y + 2)
			entry.dist.Visible = true
		elseif entry.dist then
			entry.dist.Visible = false
		end
	end
	for model in pairs(espCache) do
		if not seen[model] then
			cleanupEsp(model)
		end
	end
end

local function updateAim()
	if not scriptAlive then
		return
	end
	camera = workspace.CurrentCamera
	if fovRing then
		local show = CONFIG.ShowFov and CONFIG.AimEnabled and not uiLoading
		fovRing.Visible = show
		if show and camera then
			local size = CONFIG.AimFov * 2
			fovRing.Size = UDim2.fromOffset(size, size)
			fovRing.Position = UDim2.fromOffset(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		end
	end
	if not CONFIG.AimEnabled or not camera then
		return
	end
	if CONFIG.AimHold and not aimHolding then
		return
	end
	local target = findClosestInFov()
	if not target or not target.Character then
		return
	end
	local part = getAimPart(target.Character)
	if not part then
		return
	end
	local goal = CFrame.new(camera.CFrame.Position, part.Position)
	local alpha = math.clamp(CONFIG.AimSmooth, 0.01, 1)
	camera.CFrame = camera.CFrame:Lerp(goal, alpha)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not scriptAlive then
		return
	end
	if input.UserInputType == CONFIG.AimKey then
		aimHolding = true
	end
	if gameProcessed then
		return
	end
	if input.KeyCode == CONFIG.MenuKey then
		setMenuVisible(not menuOpen)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == CONFIG.AimKey then
		aimHolding = false
	end
end)

buildMenu()
RunService:BindToRenderStep("NameHubBloxStrikeESP", Enum.RenderPriority.Camera.Value + 1, updateEsp)
RunService:BindToRenderStep("NameHubBloxStrikeAim", Enum.RenderPriority.Camera.Value + 2, updateAim)

task.spawn(function()
	for step = 1, 100 do
		if not scriptAlive then
			return
		end
		if loadPercent then
			loadPercent.Text = tostring(step) .. "%"
		end
		if loadFill then
			loadFill.Size = UDim2.new(step / 100, 0, 1, 0)
		end
		if loadStatus then
			if step < 35 then
				loadStatus.Text = "loading"
			elseif step < 70 then
				loadStatus.Text = "preparing aim"
			elseif step < 100 then
				loadStatus.Text = "starting"
			else
				loadStatus.Text = "ready"
			end
		end
		task.wait(0.014)
	end
	uiLoading = false
	if loaderFrame then
		loaderFrame:Destroy()
		loaderFrame = nil
	end
	setMenuVisible(true)
	notify("NameHub", "Insert opens the menu")
end)

pcall(function()
	getgenv().NameHubBloxStrikeUnload = function()
		scriptAlive = false
		pcall(function()
			RunService:UnbindFromRenderStep("NameHubBloxStrikeESP")
		end)
		pcall(function()
			RunService:UnbindFromRenderStep("NameHubBloxStrikeAim")
		end)
		for model in pairs(espCache) do
			cleanupEsp(model)
		end
		if screenGui then
			screenGui:Destroy()
		end
	end
end)

if game.PlaceId ~= PLACE_ID and game.GameId ~= UNIVERSE_ID then
	warn("[NameHub Blox Strike] This script is for Blox Strike. PlaceId", game.PlaceId)
end

print("[NameHub Blox Strike] Loaded PlaceId", game.PlaceId)
