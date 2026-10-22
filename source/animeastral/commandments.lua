-- NameHub · Anime Astral Simulator
warn("[NameHub] Boot auto farm")
--[[
	NameHub · Anime Astral Simulator
	Auto collect Commandment crystals in Lion Kingdom
]]

local PLACE_ID = 102072869879193
local UNIVERSE_ID = 10502841145

local COMMANDMENTS = {
	"Faith",
	"Love",
	"Pacifism",
	"Patience",
	"Piety",
	"Purity",
	"Repose",
	"Reticence",
	"Selflessness",
	"Truth",
}

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	AutoCollectEnabled = false,
	CollectInterval = 0.45,
}

local wanted = {}
for _, name in COMMANDMENTS do
	wanted[name] = true
end

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
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubAstralUnload) == "function" then
		g.NameHubAstralUnload()
	end
end)

local scriptAlive = true
local menuOpen = false
local uiLoading = true
local collectRunning = false
local sessionCollects = 0
local lastFound = "none"

local screenGui
local menuFrame
local toggleButton
local statusLabel
local statsLabel

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text or title,
			Duration = 5,
		})
	end)
end

local function getRoot()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function matchesCommandment(name)
	local lower = string.lower(name)
	local mentionsCommandment = string.find(lower, "commandment", 1, true) ~= nil
	for _, commandment in COMMANDMENTS do
		local token = string.lower(commandment)
		local exact = lower == token
		local named = mentionsCommandment and string.find(lower, token, 1, true) ~= nil
		if exact or named then
			return wanted[commandment] == true
		end
	end
	if mentionsCommandment then
		for _, commandment in COMMANDMENTS do
			if wanted[commandment] then
				return true
			end
		end
	end
	return false
end

local function collectPart(part)
	local root = getRoot()
	if not root or not part then
		return false
	end
	local ok = pcall(function()
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end)
	if not ok then
		return false
	end
	pcall(function()
		if typeof(firetouchinterest) == "function" then
			firetouchinterest(root, part, 0)
			task.wait(0.05)
			firetouchinterest(root, part, 1)
		end
	end)
	local prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt and part.Parent then
		prompt = part.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
	end
	if prompt then
		pcall(function()
			if typeof(fireproximityprompt) == "function" then
				fireproximityprompt(prompt)
			else
				prompt:InputHoldBegin()
				task.wait(prompt.HoldDuration)
				prompt:InputHoldEnd()
			end
		end)
	end
	return true
end

local function findCommandment()
	for _, inst in workspace:GetDescendants() do
		if not scriptAlive or not CONFIG.AutoCollectEnabled then
			return nil
		end
		if inst:IsA("BasePart") and matchesCommandment(inst.Name) then
			return inst
		end
		if inst:IsA("ProximityPrompt") and matchesCommandment(inst.Name) and inst.Parent and inst.Parent:IsA("BasePart") then
			return inst.Parent
		end
	end
	return nil
end

local function refreshStats()
	if statsLabel then
		statsLabel.Text = string.format("Collected this session: %d\nLast crystal: %s", sessionCollects, lastFound)
	end
end

local function startCollectLoop()
	if collectRunning then
		return
	end
	collectRunning = true
	task.spawn(function()
		while scriptAlive and CONFIG.AutoCollectEnabled do
			local part = findCommandment()
			if part then
				lastFound = part.Name
				if statusLabel then
					statusLabel.Text = "Collecting " .. part.Name
				end
				if collectPart(part) then
					sessionCollects += 1
					refreshStats()
				end
			elseif statusLabel then
				statusLabel.Text = "Waiting for a crystal in Lion Kingdom"
			end
			task.wait(CONFIG.CollectInterval)
		end
		collectRunning = false
		if statusLabel and scriptAlive then
			statusLabel.Text = "Auto collect paused"
		end
	end)
end

local function resolveHudParent(gui)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
	local ok = pcall(function()
		gui.Parent = playerGui
	end)
	if ok and gui.Parent == playerGui then
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

local function setMenuVisible(visible)
	if uiLoading then
		visible = false
	end
	menuOpen = visible
	if menuFrame then
		menuFrame.Visible = visible
	end
	if toggleButton then
		toggleButton.Text = "NH"
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

local function makeColumn(parent, x, title)
	local col = Instance.new("Frame")
	col.BackgroundColor3 = THEME.Element
	col.BorderSizePixel = 0
	col.Position = UDim2.fromOffset(x, 58)
	col.Size = UDim2.new(0, 228, 1, -70)
	col.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Stroke
	stroke.Parent = col
	local head = Instance.new("TextLabel")
	head.BackgroundTransparency = 1
	head.Position = UDim2.fromOffset(12, 10)
	head.Size = UDim2.new(1, -24, 0, 18)
	head.Font = Enum.Font.GothamBold
	head.TextSize = 11
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.TextColor3 = THEME.SubText
	head.Text = string.upper(title)
	head.Parent = col
	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(12, 36)
	body.Size = UDim2.new(1, -24, 1, -46)
	body.Parent = col
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = body
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = THEME.Accent
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.Parent = body
	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.Padding = UDim.new(0, 4)
	scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	scrollLayout.Parent = scroll
	return scroll
end

local loaderFrame
local loadPercent
local loadFill
local loadStatus

local function buildMenu()
	if screenGui then
		screenGui:Destroy()
	end
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NameHubAstralUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1_000_000
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	resolveHudParent(screenGui)
	protectGui(screenGui)

	toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.fromOffset(36, 36)
	toggleButton.Position = UDim2.new(0, 12, 0.5, -18)
	toggleButton.BackgroundColor3 = THEME.Background
	toggleButton.TextColor3 = THEME.Accent
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 12
	toggleButton.Text = "NH"
	toggleButton.AutoButtonColor = false
	toggleButton.ZIndex = 1000
	toggleButton.Parent = screenGui
	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = THEME.Stroke
	toggleStroke.Parent = toggleButton
	toggleButton.MouseButton1Click:Connect(function()
		if uiLoading then
			return
		end
		setMenuVisible(not menuOpen)
	end)

	menuFrame = Instance.new("Frame")
	menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	menuFrame.Position = UDim2.fromScale(0.5, 0.5)
	menuFrame.Size = UDim2.fromOffset(732, 420)
	menuFrame.BackgroundColor3 = THEME.Background
	menuFrame.BorderSizePixel = 0
	menuFrame.Visible = false
	menuFrame.Parent = screenGui
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = THEME.Stroke
	menuStroke.Parent = menuFrame

	local topbar = Instance.new("Frame")
	topbar.Size = UDim2.new(1, 0, 0, 46)
	topbar.BackgroundColor3 = THEME.Topbar
	topbar.BorderSizePixel = 0
	topbar.Parent = menuFrame
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromOffset(140, 46)
	title.Position = UDim2.fromOffset(16, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Accent
	title.Text = "NAMEHUB"
	title.Parent = topbar
	local tag = Instance.new("TextLabel")
	tag.BackgroundTransparency = 1
	tag.AnchorPoint = Vector2.new(1, 0.5)
	tag.Position = UDim2.new(1, -16, 0.5, 0)
	tag.Size = UDim2.fromOffset(180, 20)
	tag.Font = Enum.Font.Gotham
	tag.TextSize = 12
	tag.TextXAlignment = Enum.TextXAlignment.Right
	tag.TextColor3 = THEME.SubText
	tag.Text = "auto farm"
	tag.Parent = topbar

	local collectCol = makeColumn(menuFrame, 12, "Collect")
	local targetCol = makeColumn(menuFrame, 252, "Commandments")
	local sessionCol = makeColumn(menuFrame, 492, "Session")

	statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Size = UDim2.new(1, 0, 0, 36)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextWrapped = true
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Top
	statusLabel.TextColor3 = THEME.SubText
	statusLabel.Text = "Crystals spawn in Lion Kingdom"
	statusLabel.Parent = collectCol

	createToggle(collectCol, "Auto Collect", function()
		return CONFIG.AutoCollectEnabled
	end, function(on)
		CONFIG.AutoCollectEnabled = on
		if on then
			startCollectLoop()
			statusLabel.Text = "Searching Lion Kingdom"
		else
			statusLabel.Text = "Auto collect paused"
		end
	end)

	for _, commandment in COMMANDMENTS do
		createToggle(targetCol, commandment, function()
			return wanted[commandment] == true
		end, function(on)
			wanted[commandment] = on
		end)
	end

	statsLabel = Instance.new("TextLabel")
	statsLabel.BackgroundTransparency = 1
	statsLabel.Size = UDim2.new(1, 0, 0, 48)
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextSize = 13
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.TextYAlignment = Enum.TextYAlignment.Top
	statsLabel.TextColor3 = THEME.Text
	statsLabel.Text = ""
	statsLabel.Parent = sessionCol
	refreshStats()

	local note = Instance.new("TextLabel")
	note.BackgroundTransparency = 1
	note.Size = UDim2.new(1, 0, 0, 48)
	note.Font = Enum.Font.Gotham
	note.TextSize = 12
	note.TextWrapped = true
	note.TextXAlignment = Enum.TextXAlignment.Left
	note.TextYAlignment = Enum.TextYAlignment.Top
	note.TextColor3 = THEME.SubText
	note.Text = "Spawns about every 20 minutes. Be in Lion Kingdom."
	note.Parent = sessionCol

	local footer = Instance.new("TextLabel")
	footer.BackgroundTransparency = 1
	footer.AnchorPoint = Vector2.new(0, 1)
	footer.Position = UDim2.new(0, 16, 1, -8)
	footer.Size = UDim2.new(1, -32, 0, 16)
	footer.Font = Enum.Font.Gotham
	footer.TextSize = 11
	footer.TextXAlignment = Enum.TextXAlignment.Left
	footer.TextColor3 = THEME.SubText
	footer.Text = "Insert · auto farm"
	footer.Parent = menuFrame

	if uiLoading then
		loaderFrame = Instance.new("Frame")
		loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		loaderFrame.Position = UDim2.fromScale(0.5, 0.5)
		loaderFrame.Size = UDim2.fromOffset(460, 124)
		loaderFrame.BackgroundColor3 = THEME.Background
		loaderFrame.BorderSizePixel = 0
		loaderFrame.ZIndex = 80
		loaderFrame.Parent = screenGui
		local stroke = Instance.new("UIStroke")
		stroke.Color = THEME.Stroke
		stroke.Parent = loaderFrame
		local logo = Instance.new("TextLabel")
		logo.BackgroundTransparency = 1
		logo.Position = UDim2.fromOffset(18, 16)
		logo.Size = UDim2.new(1, -120, 0, 24)
		logo.Font = Enum.Font.GothamBold
		logo.TextSize = 18
		logo.TextXAlignment = Enum.TextXAlignment.Left
		logo.TextColor3 = THEME.Accent
		logo.Text = "NAMEHUB"
		logo.Parent = loaderFrame
		loadPercent = Instance.new("TextLabel")
		loadPercent.BackgroundTransparency = 1
		loadPercent.AnchorPoint = Vector2.new(1, 0)
		loadPercent.Position = UDim2.new(1, -18, 0, 16)
		loadPercent.Size = UDim2.fromOffset(80, 24)
		loadPercent.Font = Enum.Font.GothamBold
		loadPercent.TextSize = 18
		loadPercent.TextXAlignment = Enum.TextXAlignment.Right
		loadPercent.TextColor3 = THEME.Text
		loadPercent.Text = "1%"
		loadPercent.Parent = loaderFrame
		loadStatus = Instance.new("TextLabel")
		loadStatus.BackgroundTransparency = 1
		loadStatus.Position = UDim2.fromOffset(18, 44)
		loadStatus.Size = UDim2.new(1, -36, 0, 18)
		loadStatus.Font = Enum.Font.Gotham
		loadStatus.TextSize = 13
		loadStatus.TextXAlignment = Enum.TextXAlignment.Left
		loadStatus.TextColor3 = THEME.SubText
		loadStatus.Text = "loading"
		loadStatus.Parent = loaderFrame
		local track = Instance.new("Frame")
		track.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
		track.BorderSizePixel = 0
		track.Position = UDim2.fromOffset(18, 78)
		track.Size = UDim2.new(1, -36, 0, 8)
		track.Parent = loaderFrame
		loadFill = Instance.new("Frame")
		loadFill.BackgroundColor3 = THEME.Accent
		loadFill.BorderSizePixel = 0
		loadFill.Size = UDim2.new(0.01, 0, 1, 0)
		loadFill.Parent = track
		local hint = Instance.new("TextLabel")
		hint.BackgroundTransparency = 1
		hint.Position = UDim2.fromOffset(18, 94)
		hint.Size = UDim2.new(1, -36, 0, 16)
		hint.Font = Enum.Font.Gotham
		hint.TextSize = 11
		hint.TextXAlignment = Enum.TextXAlignment.Left
		hint.TextColor3 = THEME.SubText
		hint.Text = "auto farm"
		hint.Parent = loaderFrame
	end
end

buildMenu()

UserInputService.InputBegan:Connect(function(input)
	if not scriptAlive or uiLoading then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.MenuKey then
		setMenuVisible(not menuOpen)
	end
end)

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
				loadStatus.Text = "preparing collect"
			elseif step < 100 then
				loadStatus.Text = "starting"
			else
				loadStatus.Text = "ready"
			end
		end
		task.wait(0.018)
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
	getgenv().NameHubAstralUnload = function()
		scriptAlive = false
		CONFIG.AutoCollectEnabled = false
		if screenGui then
			screenGui:Destroy()
		end
	end
end)

if game.PlaceId ~= PLACE_ID and game.GameId ~= UNIVERSE_ID then
	warn("[NameHub Astral] This script is for Anime Astral Simulator. PlaceId", game.PlaceId)
end

print("[NameHub Astral] Loaded PlaceId", game.PlaceId)
