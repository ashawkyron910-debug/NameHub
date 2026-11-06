-- NameHub · Blox Strike
warn("[NameHub] Boot Blox Strike")
--[[
	NameHub · Blox Strike
	Base menu build — place check + NameHub UI
]]

local PLACE_ID = 114234929420007
local UNIVERSE_ID = 7633926880

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
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
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubBloxStrikeUnload) == "function" then
		g.NameHubBloxStrikeUnload()
	end
end)

local scriptAlive = true
local menuOpen = false
local uiLoading = true

local screenGui
local menuFrame
local toggleButton
local statusLabel

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text or title,
			Duration = 5,
		})
	end)
end

local function resolveHudParent(gui)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		gui.Parent = playerGui
	end
	local ok = pcall(function()
		return gui.Parent
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

local loaderFrame
local loadPercent
local loadFill
local loadStatus

local function buildMenu()
	if screenGui then
		screenGui:Destroy()
	end
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NameHubBloxStrikeUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1_000_000
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	resolveHudParent(screenGui)
	protectGui(screenGui)

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
	menuFrame.Size = UDim2.fromOffset(420, 280)
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
	title.Size = UDim2.new(1, -32, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Text
	title.Text = "NameHub · Blox Strike"
	title.Parent = top

	local body = Instance.new("Frame")
	body.BackgroundColor3 = THEME.Element
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(16, 60)
	body.Size = UDim2.new(1, -32, 1, -88)
	body.Parent = menuFrame
	local bodyStroke = Instance.new("UIStroke")
	bodyStroke.Color = THEME.Stroke
	bodyStroke.Parent = body
	local bodyCorner = Instance.new("UICorner")
	bodyCorner.CornerRadius = UDim.new(0, 8)
	bodyCorner.Parent = body

	local head = Instance.new("TextLabel")
	head.BackgroundTransparency = 1
	head.Position = UDim2.fromOffset(14, 12)
	head.Size = UDim2.new(1, -28, 0, 18)
	head.Font = Enum.Font.GothamBold
	head.TextSize = 11
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.TextColor3 = THEME.SubText
	head.Text = "INFO"
	head.Parent = body

	statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Position = UDim2.fromOffset(14, 40)
	statusLabel.Size = UDim2.new(1, -28, 1, -54)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 13
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Top
	statusLabel.TextColor3 = THEME.Text
	statusLabel.TextWrapped = true
	statusLabel.Text =
		"Base build is live.\n\nInsert opens this menu.\nTell staff what to add next for Blox Strike."
	statusLabel.Parent = body

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not scriptAlive then
		return
	end
	if input.KeyCode == CONFIG.MenuKey then
		setMenuVisible(not menuOpen)
	end
end)

buildMenu()

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
			if step < 40 then
				loadStatus.Text = "loading"
			elseif step < 80 then
				loadStatus.Text = "building menu"
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
		if screenGui then
			screenGui:Destroy()
		end
	end
end)

if game.PlaceId ~= PLACE_ID and game.GameId ~= UNIVERSE_ID then
	warn("[NameHub Blox Strike] This script is for Blox Strike. PlaceId", game.PlaceId)
end

print("[NameHub Blox Strike] Loaded PlaceId", game.PlaceId)
