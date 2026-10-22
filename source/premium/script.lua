-- NameHub · Premium Hub
print("[NameHub Premium] Boot", os.date("!%Y-%m-%dT%H:%M:%SZ"))

--[[
	NameHub Premium — paid tier hub
	Press Insert for menu · dark top-tab menu + ESP
]]

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
	ESPMaxDistance = 800,
	ESPBoxes = true,
	ESPFillBoxes = false,
	ESPNames = true,
	ESPDistance = true,
	ESPTracers = false,
	ESPHealthBar = true,
	ESPEnemyColor = Color3.fromRGB(230, 55, 85),
	ESPFillColor = Color3.fromRGB(230, 55, 85),
	ESPTracerColor = Color3.fromRGB(230, 55, 85),
	ESPNameColor = Color3.fromRGB(235, 235, 240),
	ESPWatermark = true,
}

local THEME = {
	Window = Color3.fromRGB(16, 16, 18),
	Top = Color3.fromRGB(12, 12, 14),
	Panel = Color3.fromRGB(22, 22, 25),
	Field = Color3.fromRGB(30, 30, 34),
	Border = Color3.fromRGB(48, 48, 54),
	Accent = Color3.fromRGB(230, 55, 85),
	Text = Color3.fromRGB(232, 232, 236),
	Muted = Color3.fromRGB(118, 116, 130),
	Dim = Color3.fromRGB(72, 72, 80),
}

local KNOWN_GAMES = {
	[286090429] = "Arsenal",
	[6035872082] = "Rivals",
	[98839997] = "Dino Sim",
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function gameLabel()
	return KNOWN_GAMES[game.GameId] or KNOWN_GAMES[game.PlaceId] or game.Name
end

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubPremiumUnload) == "function" then
		g.NameHubPremiumUnload()
	end
end)

local scriptAlive = true
local menuOpen = true
local loading = true

local function notify(title, detail)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = detail or title,
			Duration = 8,
		})
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NameHubPremiumUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2_000_000
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = true

local function resolveHudParent()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
	return playerGui
end

screenGui.Parent = resolveHudParent()

local loader = Instance.new("Frame")
loader.Name = "Loader"
loader.AnchorPoint = Vector2.new(0.5, 0.5)
loader.Position = UDim2.fromScale(0.5, 0.5)
loader.Size = UDim2.fromOffset(460, 124)
loader.BackgroundColor3 = THEME.Window
loader.BorderSizePixel = 0
loader.Parent = screenGui

local loaderStroke = Instance.new("UIStroke")
loaderStroke.Color = THEME.Border
loaderStroke.Thickness = 1
loaderStroke.Parent = loader

local loaderLogo = Instance.new("TextLabel")
loaderLogo.BackgroundTransparency = 1
loaderLogo.Position = UDim2.fromOffset(18, 16)
loaderLogo.Size = UDim2.fromOffset(200, 22)
loaderLogo.Font = Enum.Font.GothamBold
loaderLogo.TextSize = 18
loaderLogo.TextXAlignment = Enum.TextXAlignment.Left
loaderLogo.TextColor3 = THEME.Accent
loaderLogo.Text = "NAMEHUB"
loaderLogo.Parent = loader

local loaderPercent = Instance.new("TextLabel")
loaderPercent.BackgroundTransparency = 1
loaderPercent.AnchorPoint = Vector2.new(1, 0)
loaderPercent.Position = UDim2.new(1, -18, 0, 16)
loaderPercent.Size = UDim2.fromOffset(80, 22)
loaderPercent.Font = Enum.Font.GothamBold
loaderPercent.TextSize = 18
loaderPercent.TextXAlignment = Enum.TextXAlignment.Right
loaderPercent.TextColor3 = THEME.Text
loaderPercent.Text = "1%"
loaderPercent.Parent = loader

local loaderStatus = Instance.new("TextLabel")
loaderStatus.BackgroundTransparency = 1
loaderStatus.Position = UDim2.fromOffset(18, 44)
loaderStatus.Size = UDim2.new(1, -36, 0, 16)
loaderStatus.Font = Enum.Font.Gotham
loaderStatus.TextSize = 12
loaderStatus.TextXAlignment = Enum.TextXAlignment.Left
loaderStatus.TextColor3 = THEME.Muted
loaderStatus.Text = "loading"
loaderStatus.Parent = loader

local loaderTrack = Instance.new("Frame")
loaderTrack.Position = UDim2.fromOffset(18, 78)
loaderTrack.Size = UDim2.new(1, -36, 0, 8)
loaderTrack.BackgroundColor3 = THEME.Field
loaderTrack.BorderSizePixel = 0
loaderTrack.Parent = loader

local loaderFill = Instance.new("Frame")
loaderFill.Size = UDim2.fromScale(0.01, 1)
loaderFill.BackgroundColor3 = THEME.Accent
loaderFill.BorderSizePixel = 0
loaderFill.Parent = loaderTrack

local loaderHint = Instance.new("TextLabel")
loaderHint.BackgroundTransparency = 1
loaderHint.Position = UDim2.fromOffset(18, 96)
loaderHint.Size = UDim2.new(1, -36, 0, 16)
loaderHint.Font = Enum.Font.Gotham
loaderHint.TextSize = 11
loaderHint.TextXAlignment = Enum.TextXAlignment.Left
loaderHint.TextColor3 = THEME.Dim
loaderHint.Text = "premium"
loaderHint.Parent = loader

local watermark = Instance.new("TextLabel")
watermark.Name = "PremiumWatermark"
watermark.BackgroundTransparency = 1
watermark.Size = UDim2.new(0, 160, 0, 18)
watermark.Position = UDim2.new(1, -172, 0, 8)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 13
watermark.TextColor3 = THEME.Accent
watermark.TextXAlignment = Enum.TextXAlignment.Right
watermark.Text = "NAMEHUB"
watermark.Visible = false
watermark.Parent = screenGui

local espFolder = Instance.new("Folder")
espFolder.Name = "NameHubPremiumESP"
espFolder.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(740, 430)
mainFrame.BackgroundColor3 = THEME.Window
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.Border
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 46)
topbar.BackgroundColor3 = THEME.Top
topbar.BorderSizePixel = 0
topbar.Parent = mainFrame

local logo = Instance.new("TextLabel")
logo.BackgroundTransparency = 1
logo.Size = UDim2.fromOffset(110, 46)
logo.Position = UDim2.fromOffset(14, 0)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 16
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.TextColor3 = THEME.Accent
logo.Text = "NAMEHUB"
logo.Parent = topbar

local tabNames = { "VISUALS", "PLAYER", "MISC" }
local tabButtons = {}
local pages = {}
local activeTab = "VISUALS"

local function selectTab(name)
	activeTab = name
	for tabName, button in pairs(tabButtons) do
		local on = tabName == name
		button.Label.TextColor3 = on and THEME.Text or THEME.Muted
		button.Underline.Visible = on
	end
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end
end

local tabX = 124
for _, name in ipairs(tabNames) do
	local hit = Instance.new("TextButton")
	hit.Name = name
	hit.BackgroundTransparency = 1
	hit.AutoButtonColor = false
	hit.Text = ""
	hit.Size = UDim2.fromOffset(88, 46)
	hit.Position = UDim2.fromOffset(tabX, 0)
	hit.Parent = topbar

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, -2)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = THEME.Muted
	label.Text = name
	label.Parent = hit

	local underline = Instance.new("Frame")
	underline.Name = "Underline"
	underline.AnchorPoint = Vector2.new(0.5, 1)
	underline.Position = UDim2.new(0.5, 0, 1, 0)
	underline.Size = UDim2.fromOffset(52, 2)
	underline.BackgroundColor3 = THEME.Accent
	underline.BorderSizePixel = 0
	underline.Visible = false
	underline.Parent = hit

	tabButtons[name] = { Label = label, Underline = underline }
	hit.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
	tabX += 90
end

local buildTag = Instance.new("TextLabel")
buildTag.BackgroundTransparency = 1
buildTag.AnchorPoint = Vector2.new(1, 0.5)
buildTag.Position = UDim2.new(1, -16, 0.5, 0)
buildTag.Size = UDim2.fromOffset(180, 18)
buildTag.Font = Enum.Font.Gotham
buildTag.TextSize = 12
buildTag.TextXAlignment = Enum.TextXAlignment.Right
buildTag.TextColor3 = THEME.Muted
buildTag.Text = "premium"
buildTag.Parent = topbar

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.fromOffset(0, 46)
body.Size = UDim2.new(1, 0, 1, -74)
body.BackgroundTransparency = 1
body.Parent = mainFrame

local function makePage(name)
	local page = Instance.new("Frame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = body
	pages[name] = page
	return page
end

local function makeGroup(parent, title, x, width)
	local panel = Instance.new("Frame")
	panel.Position = UDim2.fromOffset(x, 12)
	panel.Size = UDim2.new(0, width, 1, -24)
	panel.BackgroundColor3 = THEME.Panel
	panel.BorderSizePixel = 0
	panel.Parent = parent

	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Border
	stroke.Thickness = 1
	stroke.Parent = panel

	local header = Instance.new("TextLabel")
	header.BackgroundTransparency = 1
	header.Position = UDim2.fromOffset(12, 8)
	header.Size = UDim2.new(1, -24, 0, 16)
	header.Font = Enum.Font.Gotham
	header.TextSize = 11
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextColor3 = THEME.Muted
	header.Text = string.upper(title)
	header.Parent = panel

	local rule = Instance.new("Frame")
	rule.Position = UDim2.fromOffset(12, 28)
	rule.Size = UDim2.new(1, -24, 0, 1)
	rule.BackgroundColor3 = THEME.Border
	rule.BorderSizePixel = 0
	rule.Parent = panel

	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.fromOffset(12, 38)
	holder.Size = UDim2.new(1, -24, 1, -50)
	holder.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = holder
	return holder
end

local function checkbox(parent, text, getValue, setValue)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 22)
	row.BackgroundTransparency = 1
	row.AutoButtonColor = false
	row.Text = ""
	row.Parent = parent

	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, 0, 0.5, 0)
	box.Size = UDim2.fromOffset(14, 14)
	box.BackgroundColor3 = THEME.Field
	box.BorderSizePixel = 0
	box.Parent = row

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = THEME.Dim
	boxStroke.Thickness = 1
	boxStroke.Parent = box

	local mark = Instance.new("Frame")
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	mark.Size = UDim2.fromOffset(8, 8)
	mark.BackgroundColor3 = THEME.Accent
	mark.BorderSizePixel = 0
	mark.Parent = box

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -24, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = THEME.Text
	label.Text = text
	label.Parent = row

	local function paint()
		local on = getValue()
		mark.Visible = on
		boxStroke.Color = on and THEME.Accent or THEME.Dim
	end

	row.MouseButton1Click:Connect(function()
		setValue(not getValue())
		paint()
	end)
	paint()
end

local function slider(parent, text, minValue, maxValue, getValue, setValue)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1, 0, 0, 36)
	wrap.BackgroundTransparency = 1
	wrap.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -52, 0, 16)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = THEME.Text
	label.Text = text
	label.Parent = wrap

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, 0, 0, 0)
	valueLabel.Size = UDim2.fromOffset(52, 16)
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = THEME.Muted
	valueLabel.Parent = wrap

	local track = Instance.new("TextButton")
	track.Position = UDim2.fromOffset(0, 22)
	track.Size = UDim2.new(1, 0, 0, 8)
	track.BackgroundColor3 = THEME.Field
	track.AutoButtonColor = false
	track.Text = ""
	track.Parent = wrap

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track

	local function paint(value)
		local alpha = (value - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
		valueLabel.Text = tostring(math.floor(value))
	end

	local function setFromX(x)
		local relative = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local value = minValue + (maxValue - minValue) * relative
		setValue(value)
		paint(value)
	end

	local draggingSlider = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			setFromX(input.Position.X)
		end
	end)
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)
	paint(getValue())
end

local visuals = makePage("VISUALS")
local overlay = makeGroup(visuals, "Overlay", 14, 222)
local info = makeGroup(visuals, "Info", 248, 222)
local range = makeGroup(visuals, "Range", 482, 244)

checkbox(overlay, "Boxes", function()
	return CONFIG.ESPBoxes
end, function(v)
	CONFIG.ESPBoxes = v
end)
checkbox(overlay, "Names", function()
	return CONFIG.ESPNames
end, function(v)
	CONFIG.ESPNames = v
end)
checkbox(overlay, "Distance", function()
	return CONFIG.ESPDistance
end, function(v)
	CONFIG.ESPDistance = v
end)

checkbox(info, "Tracers", function()
	return CONFIG.ESPTracers
end, function(v)
	CONFIG.ESPTracers = v
end)
checkbox(info, "Watermark", function()
	return CONFIG.ESPWatermark
end, function(v)
	CONFIG.ESPWatermark = v
	watermark.Visible = v
end)

slider(range, "Max distance", 100, 2000, function()
	return CONFIG.ESPMaxDistance
end, function(v)
	CONFIG.ESPMaxDistance = v
end)

local playerPage = makePage("PLAYER")
local who = makeGroup(playerPage, "Session", 14, 340)

local function staticRow(parent, text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = THEME.Text
	label.Text = text
	label.Parent = parent
end

staticRow(who, "Game   " .. gameLabel())
staticRow(who, "User   " .. localPlayer.DisplayName)
staticRow(who, "Place  " .. tostring(game.PlaceId))

local misc = makePage("MISC")
local actions = makeGroup(misc, "General", 14, 340)

local function actionButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 28)
	button.BackgroundColor3 = THEME.Field
	button.AutoButtonColor = false
	button.Font = Enum.Font.Gotham
	button.TextSize = 13
	button.TextColor3 = THEME.Text
	button.Text = text
	button.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Border
	stroke.Parent = button
	button.MouseButton1Click:Connect(callback)
end

actionButton(actions, "Copy Discord invite", function()
	local copied = false
	pcall(function()
		if setclipboard then
			setclipboard(CONFIG.DiscordInviteUrl)
			copied = true
		end
	end)
	notify("NameHub", copied and "Discord invite copied." or CONFIG.DiscordInviteUrl)
end)

actionButton(actions, "Unload", function()
	if typeof(getgenv().NameHubPremiumUnload) == "function" then
		getgenv().NameHubPremiumUnload()
	end
end)

local footer = Instance.new("Frame")
footer.Position = UDim2.new(0, 0, 1, -28)
footer.Size = UDim2.new(1, 0, 0, 28)
footer.BackgroundTransparency = 1
footer.Parent = mainFrame

local footerText = Instance.new("TextLabel")
footerText.BackgroundTransparency = 1
footerText.Position = UDim2.fromOffset(14, 0)
footerText.Size = UDim2.new(1, -28, 1, 0)
footerText.Font = Enum.Font.Gotham
footerText.TextSize = 12
footerText.TextXAlignment = Enum.TextXAlignment.Left
footerText.TextColor3 = THEME.Dim
footerText.Text = "Insert  ·  " .. gameLabel()
footerText.Parent = footer

selectTab("VISUALS")

local dragging = false
local dragStart = Vector2.zero
local frameStart = Vector2.zero
topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = Vector2.new(input.Position.X, input.Position.Y)
		frameStart = Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
	end
end)
topbar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
		mainFrame.AnchorPoint = Vector2.zero
		mainFrame.Position = UDim2.fromOffset(frameStart.X + delta.X, frameStart.Y + delta.Y)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if loading then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.MenuKey then
		menuOpen = not menuOpen
		mainFrame.Visible = menuOpen
	end
end)

type EspEntry = {
	highlight: Highlight?,
	box: Frame?,
	name: TextLabel?,
	dist: TextLabel?,
	tracer: Frame?,
	health: Frame?,
}

local espCache: { [Model]: EspEntry } = {}

local function cleanupEsp(model: Model)
	local entry = espCache[model]
	if not entry then
		return
	end
	if entry.highlight then
		entry.highlight:Destroy()
	end
	if entry.box then
		entry.box:Destroy()
	end
	if entry.name then
		entry.name:Destroy()
	end
	if entry.dist then
		entry.dist:Destroy()
	end
	if entry.tracer then
		entry.tracer:Destroy()
	end
	if entry.health then
		entry.health:Destroy()
	end
	espCache[model] = nil
end

local function getRoot(model: Model): BasePart?
	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Head")
		or model.PrimaryPart
end

local function worldToScreen(point: Vector3): Vector2?
	local v, onScreen = camera:WorldToViewportPoint(point)
	if not onScreen or v.Z <= 0 then
		return nil
	end
	return Vector2.new(v.X, v.Y)
end

local function updateEsp()
	if not scriptAlive then
		return
	end
	camera = workspace.CurrentCamera
	local seen: { [Model]: boolean } = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player == localPlayer then
			continue
		end
		local char = player.Character
		if not char or not char:IsDescendantOf(workspace) then
			continue
		end
		local root = getRoot(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then
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
		local foot = root.Position - Vector3.new(0, 3, 0)
		local top = head.Position + Vector3.new(0, 0.8, 0)
		local sTop = worldToScreen(top)
		local sFoot = worldToScreen(foot)
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

	for model, _ in pairs(espCache) do
		if not seen[model] then
			cleanupEsp(model)
		end
	end
end

RunService:BindToRenderStep("NameHubPremiumESP", Enum.RenderPriority.Camera.Value + 1, updateEsp)

local function unload()
	scriptAlive = false
	pcall(function()
		RunService:UnbindFromRenderStep("NameHubPremiumESP")
	end)
	for model in pairs(espCache) do
		cleanupEsp(model)
	end
	if screenGui then
		screenGui:Destroy()
	end
end

getgenv().NameHubPremiumUnload = unload

task.spawn(function()
	for percent = 1, 100 do
		if not scriptAlive or not loader.Parent then
			return
		end
		loaderPercent.Text = percent .. "%"
		loaderFill.Size = UDim2.fromScale(percent / 100, 1)
		if percent < 35 then
			loaderStatus.Text = "loading"
		elseif percent < 70 then
			loaderStatus.Text = "preparing visuals"
		elseif percent < 100 then
			loaderStatus.Text = "starting"
		else
			loaderStatus.Text = "ready"
		end
		task.wait(0.018)
	end
	if not scriptAlive then
		return
	end
	loading = false
	loader:Destroy()
	watermark.Visible = CONFIG.ESPWatermark
	mainFrame.Visible = menuOpen
	notify("NameHub Premium", "Loaded · " .. gameLabel() .. " · Insert for menu")
end)

Players.PlayerRemoving:Connect(function(player)
	local char = player.Character
	if char then
		cleanupEsp(char)
	end
end)

print("[NameHub Premium] Ready · PlaceId", game.PlaceId, "GameId", game.GameId)
