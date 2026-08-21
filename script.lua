--[[
	NameHub — Aim Assist / ESP / Fly Test System (LocalScript)
	Place in StarterPlayer > StarterPlayerScripts.
	Loading screen: upload NameHubLogo.png as a Roblox Image, then set
	CONFIG.LoadingImageId to "rbxassetid://YOUR_ID".
]]

local CONFIG = {
	ToggleKey = Enum.KeyCode.RightShift,
	MenuKey = Enum.KeyCode.Insert,
	LoadingImageId = "rbxassetid://0",
	LoadingDuration = 2.8,
	FOVRadius = 100,
	ShowFOVCircle = true,
	FOVCircleColor = Color3.fromRGB(255, 255, 255),
	FOVCircleThickness = 2,
	FOVCircleTransparency = 0.35,
	TargetPartName = "Head",
	MaxWorldDistance = 400,
	RequireLineOfSight = true,
	TeamCheckEnabled = true,
	IgnoreNeutralTeams = true,
	Smoothness = 0.18,
	ShowTargetMarker = true,
	TargetMarkerColor = Color3.fromRGB(255, 80, 80),
	RaycastOriginPart = "Head",
	ESPEnabled = false,
	ESPBoxes = true,
	ESPNames = true,
	ESPDistance = true,
	ESPHealthBar = true,
	ESPHighlights = true,
	ESPTracers = false,
	ESPTeamCheck = true,
	ESPMaxDistance = 500,
	ESPEnemyColor = Color3.fromRGB(255, 75, 75),
	ESPTeamColor = Color3.fromRGB(80, 170, 255),
	ESPTextSize = 14,
	FlyKey = Enum.KeyCode.F,
	FlySpeed = 50,
	FlyVerticalMultiplier = 1,
	SilentAimKey = Enum.KeyCode.T,
	SilentAimShowMarker = true,
	SilentAimMarkerColor = Color3.fromRGB(170, 110, 255),
	SilentAimUseClosest = true,
	SilentAimClickFire = true,
	SilentAimShowTracer = true,
	SilentAimFireCooldown = 0.12,
	SilentAimTracerTime = 0.08,
}

local TARGET_PART_OPTIONS = { "Head", "HumanoidRootPart", "UpperTorso" }

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")

local enabled = false
local menuOpen = true
local flyEnabled = false
local silentAimEnabled = false
local currentTarget: Player? = nil
local silentAimTarget: Player? = nil
local silentAimPart: BasePart? = nil
local silentAimPosition: Vector3? = nil
local trackedPlayers: { [Player]: { characterAdded: RBXScriptConnection?, characterRemoving: RBXScriptConnection? } } = {}

local flyAttachment: Attachment? = nil
local flyVelocity: LinearVelocity? = nil
local flyAlign: AlignOrientation? = nil
local flyHumanoid: Humanoid? = nil
local flyWasPlatformStanding = false
local setFlyEnabled: (boolean) -> ()
local flyToggleUI: { Set: (value: boolean) -> () }? = nil
local silentAimToggleUI: { Set: (value: boolean) -> () }? = nil
local setSilentAimEnabled: (boolean) -> ()

type EspVisuals = {
	highlight: Highlight,
	billboard: BillboardGui,
	nameLabel: TextLabel,
	distLabel: TextLabel,
	healthBg: Frame,
	healthFill: Frame,
	box: Frame,
	tracer: Frame,
}

local espVisuals: { [Player]: EspVisuals } = {}

local function resolveLoadingImage(): string
	local fromConfig = CONFIG.LoadingImageId
	if typeof(fromConfig) == "string" and fromConfig ~= "" and fromConfig ~= "rbxassetid://0" then
		return fromConfig
	end
	local embedded = script:FindFirstChild("NameHubLogo")
	if embedded then
		if embedded:IsA("Decal") or embedded:IsA("Texture") then
			return embedded.Texture
		elseif embedded:IsA("ImageLabel") or embedded:IsA("ImageButton") then
			return embedded.Image
		end
	end
	return ""
end

local function playNameHubLoadingScreen()
	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "NameHubLoadingScreen"
	loadingGui.IgnoreGuiInset = true
	loadingGui.ResetOnSpawn = false
	loadingGui.DisplayOrder = 1000
	loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loadingGui.Parent = playerGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
	backdrop.BorderSizePixel = 0
	backdrop.Parent = loadingGui

	local glow = Instance.new("Frame")
	glow.Name = "Glow"
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.new(0.5, 0, 0.42, 0)
	glow.Size = UDim2.fromOffset(280, 280)
	glow.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
	glow.BackgroundTransparency = 0.82
	glow.BorderSizePixel = 0
	glow.Parent = backdrop

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(1, 0)
	glowCorner.Parent = glow

	local logo = Instance.new("ImageLabel")
	logo.Name = "Logo"
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.new(0.5, 0, 0.38, 0)
	logo.Size = UDim2.fromOffset(160, 160)
	logo.BackgroundTransparency = 1
	logo.ScaleType = Enum.ScaleType.Fit
	logo.Image = resolveLoadingImage()
	logo.Parent = backdrop

	if logo.Image ~= "" then
		pcall(function()
			ContentProvider:PreloadAsync({ logo })
		end)
	end

	local brand = Instance.new("TextLabel")
	brand.Name = "Brand"
	brand.AnchorPoint = Vector2.new(0.5, 0)
	brand.Position = UDim2.new(0.5, 0, 0.38, 95)
	brand.Size = UDim2.fromOffset(320, 40)
	brand.BackgroundTransparency = 1
	brand.Font = Enum.Font.GothamBold
	brand.Text = "NameHub"
	brand.TextColor3 = Color3.fromRGB(230, 235, 245)
	brand.TextSize = 34
	brand.TextStrokeColor3 = Color3.fromRGB(40, 120, 255)
	brand.TextStrokeTransparency = 0.65
	brand.Parent = backdrop

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Position = UDim2.new(0.5, 0, 0.38, 135)
	status.Size = UDim2.fromOffset(280, 20)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.Gotham
	status.Text = "Loading..."
	status.TextColor3 = Color3.fromRGB(140, 160, 200)
	status.TextSize = 14
	status.Parent = backdrop

	local percentLabel = Instance.new("TextLabel")
	percentLabel.Name = "Percent"
	percentLabel.AnchorPoint = Vector2.new(0.5, 0)
	percentLabel.Position = UDim2.new(0.5, 0, 0.72, 0)
	percentLabel.Size = UDim2.fromOffset(200, 36)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Font = Enum.Font.GothamBold
	percentLabel.Text = "100%"
	percentLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
	percentLabel.TextSize = 28
	percentLabel.Parent = backdrop

	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.AnchorPoint = Vector2.new(0.5, 0)
	barBg.Position = UDim2.new(0.5, 0, 0.72, 44)
	barBg.Size = UDim2.fromOffset(220, 6)
	barBg.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
	barBg.BorderSizePixel = 0
	barBg.Parent = backdrop

	local barBgCorner = Instance.new("UICorner")
	barBgCorner.CornerRadius = UDim.new(1, 0)
	barBgCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg

	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(1, 0)
	barFillCorner.Parent = barFill

	local duration = math.max(CONFIG.LoadingDuration, 0.5)
	local startTime = os.clock()
	local currentPct = 100

	while true do
		local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
		local eased = 1 - (1 - alpha) ^ 2
		currentPct = math.clamp(math.floor(100 - eased * 99 + 0.5), 1, 100)
		percentLabel.Text = string.format("%d%%", currentPct)
		barFill.Size = UDim2.fromScale(currentPct / 100, 1)
		if alpha >= 1 then
			break
		end
		RunService.RenderStepped:Wait()
	end

	percentLabel.Text = "1%"
	barFill.Size = UDim2.fromScale(0.01, 1)
	status.Text = "Ready"
	task.wait(0.2)

	local fadeInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(backdrop, fadeInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(glow, fadeInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
	TweenService:Create(brand, fadeInfo, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	TweenService:Create(status, fadeInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(percentLabel, fadeInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(barBg, fadeInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(barFill, fadeInfo, { BackgroundTransparency = 1 }):Play()
	task.wait(0.5)
	loadingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NameHubUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local function createCircleFrame(name: string, color: Color3, thickness: number, transparency: number): (Frame, UIStroke)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromOffset(CONFIG.FOVRadius * 2, CONFIG.FOVRadius * 2)
	frame.Visible = false
	frame.ZIndex = 1
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.Parent = frame
	frame.Parent = screenGui
	return frame, stroke
end

local fovCircle, fovStroke = createCircleFrame("FOVCircle", CONFIG.FOVCircleColor, CONFIG.FOVCircleThickness, CONFIG.FOVCircleTransparency)
local targetMarker = createCircleFrame("TargetMarker", CONFIG.TargetMarkerColor, 2, 0.2)
targetMarker.Size = UDim2.fromOffset(16, 16)
local silentMarker = createCircleFrame("SilentAimMarker", CONFIG.SilentAimMarkerColor, 2, 0.15)
silentMarker.Size = UDim2.fromOffset(14, 14)

local espOverlay = Instance.new("Folder")
espOverlay.Name = "ESPOverlay"
espOverlay.Parent = screenGui

local nameHubApi = Instance.new("Folder")
nameHubApi.Name = "NameHubAPI"
nameHubApi.Parent = playerGui

local getSilentAimTargetFn = Instance.new("BindableFunction")
getSilentAimTargetFn.Name = "GetSilentAimTarget"
getSilentAimTargetFn.Parent = nameHubApi

local getSilentAimDirectionFn = Instance.new("BindableFunction")
getSilentAimDirectionFn.Name = "GetSilentAimDirection"
getSilentAimDirectionFn.Parent = nameHubApi

local silentAimChangedEvent = Instance.new("BindableEvent")
silentAimChangedEvent.Name = "SilentAimChanged"
silentAimChangedEvent.Parent = nameHubApi

local silentAimShotEvent = Instance.new("BindableEvent")
silentAimShotEvent.Name = "SilentAimShot"
silentAimShotEvent.Parent = nameHubApi

getSilentAimTargetFn.OnInvoke = function()
	if not silentAimEnabled or not silentAimPosition then
		return nil
	end
	return silentAimPart, silentAimPosition, silentAimTarget
end

getSilentAimDirectionFn.OnInvoke = function(origin: Vector3?)
	if not silentAimEnabled or not silentAimPosition then
		return nil
	end
	local from = origin
	if typeof(from) ~= "Vector3" then
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		from = if hrp and hrp:IsA("BasePart") then hrp.Position else (camera and camera.CFrame.Position or Vector3.zero)
	end
	local delta = silentAimPosition - from
	if delta.Magnitude < 0.001 then
		return Vector3.zero
	end
	return delta.Unit, silentAimPosition, silentAimPart, silentAimTarget
end

local isSilentAimReadyFn = Instance.new("BindableFunction")
isSilentAimReadyFn.Name = "IsSilentAimReady"
isSilentAimReadyFn.Parent = nameHubApi
isSilentAimReadyFn.OnInvoke = function()
	return silentAimEnabled and silentAimPosition ~= nil and silentAimPart ~= nil
end

local function refreshOverlayFromConfig()
	fovCircle.Size = UDim2.fromOffset(CONFIG.FOVRadius * 2, CONFIG.FOVRadius * 2)
	fovStroke.Color = CONFIG.FOVCircleColor
	fovStroke.Thickness = CONFIG.FOVCircleThickness
	fovStroke.Transparency = CONFIG.FOVCircleTransparency
end

local THEME = {
	Background = Color3.fromRGB(25, 27, 29),
	Topbar = Color3.fromRGB(32, 34, 37),
	Element = Color3.fromRGB(35, 37, 40),
	ElementHover = Color3.fromRGB(42, 44, 48),
	Accent = Color3.fromRGB(100, 120, 255),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(160, 160, 165),
	Stroke = Color3.fromRGB(55, 55, 60),
	Success = Color3.fromRGB(60, 180, 100),
}

local menuFrame = Instance.new("Frame")
menuFrame.Name = "RayfieldStyleMenu"
menuFrame.AnchorPoint = Vector2.new(0, 0.5)
menuFrame.Position = UDim2.new(0, 24, 0.5, 0)
menuFrame.Size = UDim2.fromOffset(340, 520)
menuFrame.BackgroundColor3 = THEME.Background
menuFrame.BorderSizePixel = 0
menuFrame.ZIndex = 50
menuFrame.Visible = false
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = THEME.Stroke
menuStroke.Thickness = 1
menuStroke.Parent = menuFrame

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 44)
topbar.BackgroundColor3 = THEME.Topbar
topbar.BorderSizePixel = 0
topbar.ZIndex = 51
topbar.Parent = menuFrame

local topbarCorner = Instance.new("UICorner")
topbarCorner.CornerRadius = UDim.new(0, 10)
topbarCorner.Parent = topbar

local topbarFix = Instance.new("Frame")
topbarFix.Size = UDim2.new(1, 0, 0, 14)
topbarFix.Position = UDim2.new(0, 0, 1, -14)
topbarFix.BackgroundColor3 = THEME.Topbar
topbarFix.BorderSizePixel = 0
topbarFix.ZIndex = 51
topbarFix.Parent = topbar

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(14, 0)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "NameHub"
titleLabel.TextColor3 = THEME.Text
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 52
titleLabel.Parent = topbar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Position = UDim2.fromOffset(14, 22)
subtitleLabel.Size = UDim2.new(1, -60, 0, 16)
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "Studio test · RightShift = toggle · Insert = menu"
subtitleLabel.TextColor3 = THEME.SubText
subtitleLabel.TextSize = 11
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 52
subtitleLabel.Parent = topbar

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.BackgroundColor3 = THEME.Element
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = THEME.Text
closeButton.TextSize = 12
closeButton.ZIndex = 52
closeButton.Parent = topbar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Position = UDim2.fromOffset(10, 48)
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 51
tabBar.Parent = menuFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local pagesHost = Instance.new("Frame")
pagesHost.Name = "PagesHost"
pagesHost.Position = UDim2.fromOffset(0, 84)
pagesHost.Size = UDim2.new(1, 0, 1, -92)
pagesHost.BackgroundTransparency = 1
pagesHost.ZIndex = 50
pagesHost.Parent = menuFrame

local pages: { [string]: ScrollingFrame } = {}
local tabButtons: { [string]: TextButton } = {}
local controlsParent: ScrollingFrame? = nil
local layoutOrder = 0

local function nextOrder(): number
	layoutOrder += 1
	return layoutOrder
end

local function createPage(id: string): ScrollingFrame
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. id
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = THEME.Accent
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 50
	page.Parent = pagesHost
	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page
	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingTop = UDim.new(0, 8)
	pagePad.PaddingBottom = UDim.new(0, 12)
	pagePad.PaddingLeft = UDim.new(0, 12)
	pagePad.PaddingRight = UDim.new(0, 12)
	pagePad.Parent = page
	pages[id] = page
	return page
end

local function selectTab(id: string)
	for name, page in pages do
		page.Visible = name == id
	end
	for name, btn in tabButtons do
		local active = name == id
		btn.BackgroundColor3 = if active then THEME.Accent else THEME.Element
		btn.TextColor3 = if active then Color3.fromRGB(255, 255, 255) else THEME.Text
	end
	controlsParent = pages[id]
end

local function createTab(id: string, label: string, order: number)
	createPage(id)
	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. id
	btn.BackgroundColor3 = THEME.Element
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.Text = label
	btn.TextColor3 = THEME.Text
	btn.TextSize = 11
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	btn.ZIndex = 52
	btn.Parent = tabBar
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
	btn.Size = UDim2.new(0.2, -5, 1, 0)
	tabButtons[id] = btn
	btn.MouseButton1Click:Connect(function()
		selectTab(id)
	end)
end

createTab("Main", "Main", 1)
createTab("Aim", "Aim", 2)
createTab("Filters", "Filter", 3)
createTab("ESP", "ESP", 4)
createTab("Fly", "Fly", 5)

local function createSection(title: string): Frame
	local section = Instance.new("Frame")
	section.Name = "Section_" .. title
	section.BackgroundTransparency = 1
	section.Size = UDim2.new(1, 0, 0, 22)
	section.LayoutOrder = nextOrder()
	section.ZIndex = 51
	section.Parent = controlsParent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = title
	label.TextColor3 = THEME.Accent
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 51
	label.Parent = section
	return section
end

local function createElementShell(height: number): Frame
	local shell = Instance.new("Frame")
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.Size = UDim2.new(1, 0, 0, height)
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 51
	shell.Parent = controlsParent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	return shell
end

local function createToggle(name: string, description: string, initial: boolean, callback: (boolean) -> ())
	local shell = createElementShell(54)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -70, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -70, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel.Parent = shell
	local switch = Instance.new("TextButton")
	switch.Name = "Switch"
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -12, 0.5, 0)
	switch.Size = UDim2.fromOffset(42, 22)
	switch.BackgroundColor3 = if initial then THEME.Success else Color3.fromRGB(60, 60, 65)
	switch.BorderSizePixel = 0
	switch.Text = ""
	switch.ZIndex = 52
	switch.AutoButtonColor = false
	switch.Parent = shell
	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switch
	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = if initial then UDim2.new(1, -20, 0.5, 0) else UDim2.fromOffset(2, 11)
	knob.Size = UDim2.fromOffset(18, 18)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 53
	knob.Parent = switch
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	local state = initial
	local function applyVisual()
		switch.BackgroundColor3 = if state then THEME.Success else Color3.fromRGB(60, 60, 65)
		knob.Position = if state then UDim2.new(1, -20, 0.5, 0) else UDim2.fromOffset(2, 11)
	end
	switch.MouseButton1Click:Connect(function()
		state = not state
		applyVisual()
		callback(state)
	end)
	return {
		Set = function(value: boolean)
			state = value
			applyVisual()
		end,
	}
end

local function createSlider(name: string, description: string, min: number, max: number, initial: number, decimals: number, callback: (number) -> ())
	local shell = createElementShell(72)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -70, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel.Parent = shell
	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -12, 0, 8)
	valueLabel.Size = UDim2.fromOffset(56, 18)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.ZIndex = 52
	valueLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -24, 0, 14)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel.Parent = shell
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(12, 52)
	track.Size = UDim2.new(1, -24, 0, 8)
	track.BackgroundColor3 = Color3.fromRGB(50, 52, 56)
	track.BorderSizePixel = 0
	track.ZIndex = 52
	track.Parent = shell
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 53
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	local function formatValue(v: number): string
		if decimals <= 0 then
			return tostring(math.floor(v + 0.5))
		end
		local mult = 10 ^ decimals
		return string.format("%." .. decimals .. "f", math.floor(v * mult + 0.5) / mult)
	end
	local function setFromAlpha(alpha: number)
		alpha = math.clamp(alpha, 0, 1)
		local value = min + (max - min) * alpha
		if decimals <= 0 then
			value = math.floor(value + 0.5)
		else
			local mult = 10 ^ decimals
			value = math.floor(value * mult + 0.5) / mult
		end
		fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
		valueLabel.Text = formatValue(value)
		callback(value)
	end
	setFromAlpha((initial - min) / (max - min))
	local dragging = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromAlpha(rel)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
			setFromAlpha(rel)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function createDropdown(name: string, description: string, options: { string }, initial: string, callback: (string) -> ())
	local shell = createElementShell(54)
	local index = table.find(options, initial) or 1
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -120, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -120, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel.Parent = shell
	local cycle = Instance.new("TextButton")
	cycle.AnchorPoint = Vector2.new(1, 0.5)
	cycle.Position = UDim2.new(1, -12, 0.5, 0)
	cycle.Size = UDim2.fromOffset(110, 28)
	cycle.BackgroundColor3 = THEME.Topbar
	cycle.BorderSizePixel = 0
	cycle.Font = Enum.Font.GothamMedium
	cycle.Text = options[index]
	cycle.TextColor3 = THEME.Text
	cycle.TextSize = 12
	cycle.ZIndex = 52
	cycle.Parent = shell
	local cycleCorner = Instance.new("UICorner")
	cycleCorner.CornerRadius = UDim.new(0, 6)
	cycleCorner.Parent = cycle
	cycle.MouseButton1Click:Connect(function()
		index = index % #options + 1
		cycle.Text = options[index]
		callback(options[index])
	end)
end

local listeningForKeybind: { apply: (Enum.KeyCode) -> (), cancel: () -> () }? = nil

local function createKeybind(name: string, description: string, initial: Enum.KeyCode, onChanged: (Enum.KeyCode) -> ())
	local shell = createElementShell(54)
	local currentKey = initial
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -120, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -120, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel.Parent = shell
	local bindButton = Instance.new("TextButton")
	bindButton.AnchorPoint = Vector2.new(1, 0.5)
	bindButton.Position = UDim2.new(1, -12, 0.5, 0)
	bindButton.Size = UDim2.fromOffset(110, 28)
	bindButton.BackgroundColor3 = THEME.Topbar
	bindButton.BorderSizePixel = 0
	bindButton.Font = Enum.Font.GothamBold
	bindButton.Text = currentKey.Name
	bindButton.TextColor3 = THEME.Text
	bindButton.TextSize = 12
	bindButton.ZIndex = 52
	bindButton.Parent = shell
	local bindCorner = Instance.new("UICorner")
	bindCorner.CornerRadius = UDim.new(0, 6)
	bindCorner.Parent = bindButton
	local function showCurrent()
		bindButton.Text = currentKey.Name
		bindButton.TextColor3 = THEME.Text
	end
	bindButton.MouseButton1Click:Connect(function()
		bindButton.Text = "..."
		bindButton.TextColor3 = THEME.Accent
		listeningForKeybind = {
			apply = function(keyCode: Enum.KeyCode)
				currentKey = keyCode
				showCurrent()
				listeningForKeybind = nil
				onChanged(keyCode)
			end,
			cancel = function()
				showCurrent()
				listeningForKeybind = nil
			end,
		}
	end)
end

local function setMenuVisible(visible: boolean)
	menuOpen = visible
	menuFrame.Visible = visible
end

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

do
	local dragging = false
	local dragStart: Vector2? = nil
	local startPos: UDim2? = nil
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
			menuFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function beginPage(id: string)
	controlsParent = pages[id]
	layoutOrder = 0
end

beginPage("Main")
createSection("MAIN")
local enableToggle = createToggle("Aim Assist", "Master enable / disable", enabled, function(value)
	enabled = value
	currentTarget = nil
	if not enabled then
		fovCircle.Visible = false
		targetMarker.Visible = false
	end
end)
createKeybind("Toggle Keybind", "Key to turn aim assist on/off", CONFIG.ToggleKey, function(keyCode)
	CONFIG.ToggleKey = keyCode
end)
createKeybind("Menu Keybind", "Key to open/close this menu", CONFIG.MenuKey, function(keyCode)
	CONFIG.MenuKey = keyCode
end)

beginPage("Aim")
createSection("AIM")
createSlider("FOV Radius", "Pixel radius around the cursor", 20, 400, CONFIG.FOVRadius, 0, function(value)
	CONFIG.FOVRadius = value
	refreshOverlayFromConfig()
end)
createSlider("Smoothness", "Lower = snappier, higher = slower", 0.01, 0.6, CONFIG.Smoothness, 2, function(value)
	CONFIG.Smoothness = value
end)
createSlider("Max Distance", "Ignore targets beyond this (studs)", 50, 1000, CONFIG.MaxWorldDistance, 0, function(value)
	CONFIG.MaxWorldDistance = value
end)
createDropdown("Target Part", "Aim point on the character", TARGET_PART_OPTIONS, CONFIG.TargetPartName, function(value)
	CONFIG.TargetPartName = value
end)
createDropdown("Ray Origin", "Where LOS ray starts from", TARGET_PART_OPTIONS, CONFIG.RaycastOriginPart, function(value)
	CONFIG.RaycastOriginPart = value
end)

createSection("SILENT AIM")
silentAimToggleUI = createToggle("Silent Aim", "Lock target + LMB shoots toward them", silentAimEnabled, function(value)
	setSilentAimEnabled(value)
end)
createKeybind("Silent Aim Key", "Toggle silent aim on/off", CONFIG.SilentAimKey, function(keyCode)
	CONFIG.SilentAimKey = keyCode
end)
createToggle("Click Fire", "Left click fires hitscan at silent target", CONFIG.SilentAimClickFire, function(value)
	CONFIG.SilentAimClickFire = value
end)
createToggle("Silent Marker", "Show purple marker on silent target", CONFIG.SilentAimShowMarker, function(value)
	CONFIG.SilentAimShowMarker = value
	if not value then
		silentMarker.Visible = false
	end
end)
createToggle("Show Tracer", "Brief line when you silent-fire", CONFIG.SilentAimShowTracer, function(value)
	CONFIG.SilentAimShowTracer = value
end)
createSlider("Fire Cooldown", "Seconds between silent shots", 0.05, 0.5, CONFIG.SilentAimFireCooldown, 2, function(value)
	CONFIG.SilentAimFireCooldown = value
end)

beginPage("Filters")
createSection("FILTERS")
createToggle("Team Check", "Skip players on your team", CONFIG.TeamCheckEnabled, function(value)
	CONFIG.TeamCheckEnabled = value
end)
createToggle("Ignore Neutral Teams", "Allow targets with no team", CONFIG.IgnoreNeutralTeams, function(value)
	CONFIG.IgnoreNeutralTeams = value
end)
createToggle("Line of Sight", "Require clear Raycast to target", CONFIG.RequireLineOfSight, function(value)
	CONFIG.RequireLineOfSight = value
end)

beginPage("ESP")
createSection("ESP")
createToggle("ESP Enabled", "Master ESP on/off (works while playing)", CONFIG.ESPEnabled, function(value)
	CONFIG.ESPEnabled = value
end)
createToggle("ESP Team Check", "Hide ESP on teammates", CONFIG.ESPTeamCheck, function(value)
	CONFIG.ESPTeamCheck = value
end)
createSlider("ESP Max Distance", "Hide ESP beyond this range", 50, 1500, CONFIG.ESPMaxDistance, 0, function(value)
	CONFIG.ESPMaxDistance = value
end)

createSection("Visuals")
createToggle("Boxes", "2D box around players", CONFIG.ESPBoxes, function(value)
	CONFIG.ESPBoxes = value
end)
createToggle("Names", "Show player names", CONFIG.ESPNames, function(value)
	CONFIG.ESPNames = value
end)
createToggle("Distance", "Show distance in studs", CONFIG.ESPDistance, function(value)
	CONFIG.ESPDistance = value
end)
createToggle("Health Bar", "Show health bar above players", CONFIG.ESPHealthBar, function(value)
	CONFIG.ESPHealthBar = value
end)
createToggle("Highlights", "Colored outline through walls", CONFIG.ESPHighlights, function(value)
	CONFIG.ESPHighlights = value
end)
createToggle("Tracers", "Line from screen bottom to player", CONFIG.ESPTracers, function(value)
	CONFIG.ESPTracers = value
end)
createToggle("Show FOV Circle", "Draw circle around the mouse", CONFIG.ShowFOVCircle, function(value)
	CONFIG.ShowFOVCircle = value
	if not value then
		fovCircle.Visible = false
	end
end)
createToggle("Show Target Marker", "Highlight the locked target", CONFIG.ShowTargetMarker, function(value)
	CONFIG.ShowTargetMarker = value
	if not value then
		targetMarker.Visible = false
	end
end)
createSlider("FOV Thickness", "Circle outline thickness", 1, 6, CONFIG.FOVCircleThickness, 0, function(value)
	CONFIG.FOVCircleThickness = value
	refreshOverlayFromConfig()
end)
createSlider("FOV Transparency", "Circle outline transparency", 0, 0.9, CONFIG.FOVCircleTransparency, 2, function(value)
	CONFIG.FOVCircleTransparency = value
	refreshOverlayFromConfig()
end)

beginPage("Fly")
createSection("FLY")
flyToggleUI = createToggle("Fly Enabled", "Toggle flight (also works mid-game)", flyEnabled, function(value)
	setFlyEnabled(value)
end)
createKeybind("Fly Keybind", "Key to toggle fly on/off", CONFIG.FlyKey, function(keyCode)
	CONFIG.FlyKey = keyCode
end)
createSlider("Fly Speed", "Studs per second while flying", 10, 250, CONFIG.FlySpeed, 0, function(value)
	CONFIG.FlySpeed = value
end)
createSlider("Vertical Mult", "Up/down speed multiplier (Space / LeftCtrl)", 0.25, 3, CONFIG.FlyVerticalMultiplier, 2, function(value)
	CONFIG.FlyVerticalMultiplier = value
end)

selectTab("Main")

local function getMouseScreenPosition(): Vector2
	local mouse = UserInputService:GetMouseLocation()
	return Vector2.new(mouse.X, mouse.Y)
end

local function getCharacterPart(character: Model, partName: string): BasePart?
	local part = character:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

local function getTargetPart(character: Model): BasePart?
	return getCharacterPart(character, CONFIG.TargetPartName)
		or character:FindFirstChild("HumanoidRootPart") :: BasePart?
		or character:FindFirstChild("UpperTorso") :: BasePart?
end

local function getRaycastOrigin(character: Model): Vector3?
	local part = getCharacterPart(character, CONFIG.RaycastOriginPart)
		or character:FindFirstChild("Head") :: BasePart?
		or character:FindFirstChild("HumanoidRootPart") :: BasePart?
	return if part then part.Position else nil
end

local function isAlive(character: Model): boolean
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	if humanoid.Health <= 0 then
		return false
	end
	return humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

local function passesTeamCheck(otherPlayer: Player): boolean
	if not CONFIG.TeamCheckEnabled then
		return true
	end
	local myTeam = localPlayer.Team
	local theirTeam = otherPlayer.Team
	if CONFIG.IgnoreNeutralTeams and (myTeam == nil or theirTeam == nil) then
		return true
	end
	return myTeam ~= theirTeam
end

local function passesEspTeamCheck(otherPlayer: Player): boolean
	if not CONFIG.ESPTeamCheck then
		return true
	end
	local myTeam = localPlayer.Team
	local theirTeam = otherPlayer.Team
	if CONFIG.IgnoreNeutralTeams and (myTeam == nil or theirTeam == nil) then
		return true
	end
	return myTeam ~= theirTeam
end

local function getEspColor(otherPlayer: Player): Color3
	local myTeam = localPlayer.Team
	local theirTeam = otherPlayer.Team
	if myTeam and theirTeam and myTeam == theirTeam then
		return CONFIG.ESPTeamColor
	end
	return CONFIG.ESPEnemyColor
end

local function clearEspForPlayer(player: Player)
	local visuals = espVisuals[player]
	if not visuals then
		return
	end
	visuals.highlight:Destroy()
	visuals.billboard:Destroy()
	visuals.box:Destroy()
	visuals.tracer:Destroy()
	espVisuals[player] = nil
end

local function clearAllEsp()
	for player in pairs(espVisuals) do
		clearEspForPlayer(player)
	end
end

local function ensureEspVisuals(player: Player, character: Model): EspVisuals
	local existing = espVisuals[player]
	if existing and existing.highlight.Parent and existing.billboard.Parent then
		if existing.highlight.Adornee ~= character then
			existing.highlight.Adornee = character
			existing.highlight.Parent = character
			local adorn = getCharacterPart(character, "Head") or getCharacterPart(character, "HumanoidRootPart")
			if adorn then
				existing.billboard.Adornee = adorn
				existing.billboard.Parent = adorn
			end
		end
		return existing
	end
	if existing then
		clearEspForPlayer(player)
	end

	local color = getEspColor(player)

	local highlight = Instance.new("Highlight")
	highlight.Name = "AimAssistESPHighlight"
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = character
	highlight.Parent = character

	local adornPart = getCharacterPart(character, "Head")
		or getCharacterPart(character, "HumanoidRootPart")
		or character:FindFirstChildWhichIsA("BasePart")

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AimAssistESPBillboard"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(160, 48)
	billboard.StudsOffset = Vector3.new(0, 2.4, 0)
	billboard.MaxDistance = CONFIG.ESPMaxDistance
	if adornPart then
		billboard.Adornee = adornPart
		billboard.Parent = adornPart
	else
		billboard.Parent = character
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.fromOffset(0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = CONFIG.ESPTextSize
	nameLabel.TextColor3 = color
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Text = player.DisplayName
	nameLabel.Parent = billboard

	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size = UDim2.new(1, 0, 0, 14)
	distLabel.Position = UDim2.fromOffset(0, 16)
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextSize = CONFIG.ESPTextSize - 2
	distLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	distLabel.TextStrokeTransparency = 0.5
	distLabel.Text = ""
	distLabel.Parent = billboard

	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBg"
	healthBg.AnchorPoint = Vector2.new(0.5, 0)
	healthBg.Position = UDim2.new(0.5, 0, 0, 32)
	healthBg.Size = UDim2.fromOffset(70, 5)
	healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	healthBg.BorderSizePixel = 0
	healthBg.Parent = billboard

	local healthBgCorner = Instance.new("UICorner")
	healthBgCorner.CornerRadius = UDim.new(1, 0)
	healthBgCorner.Parent = healthBg

	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.fromScale(1, 1)
	healthFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBg

	local healthFillCorner = Instance.new("UICorner")
	healthFillCorner.CornerRadius = UDim.new(1, 0)
	healthFillCorner.Parent = healthFill

	local box = Instance.new("Frame")
	box.Name = "ESPBox_" .. player.Name
	box.BackgroundTransparency = 1
	box.Visible = false
	box.ZIndex = 20
	box.Parent = espOverlay

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Name = "Stroke"
	boxStroke.Thickness = 1.5
	boxStroke.Color = color
	boxStroke.Parent = box

	local tracer = Instance.new("Frame")
	tracer.Name = "ESPTracer_" .. player.Name
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = color
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.ZIndex = 19
	tracer.Parent = espOverlay

	local visuals: EspVisuals = {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		distLabel = distLabel,
		healthBg = healthBg,
		healthFill = healthFill,
		box = box,
		tracer = tracer,
	}
	espVisuals[player] = visuals
	return visuals
end

local function getScreenBox(character: Model): (Vector2?, Vector2?)
	local ok, payload = pcall(function()
		local cf, size = character:GetBoundingBox()
		return { cf = cf, size = size }
	end)
	if not ok or typeof(payload) ~= "table" then
		return nil, nil
	end
	local cf = payload.cf
	local size = payload.size
	if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
		return nil, nil
	end
	local half = size / 2
	local corners = {
		cf * Vector3.new(half.X, half.Y, half.Z),
		cf * Vector3.new(half.X, half.Y, -half.Z),
		cf * Vector3.new(half.X, -half.Y, half.Z),
		cf * Vector3.new(half.X, -half.Y, -half.Z),
		cf * Vector3.new(-half.X, half.Y, half.Z),
		cf * Vector3.new(-half.X, half.Y, -half.Z),
		cf * Vector3.new(-half.X, -half.Y, half.Z),
		cf * Vector3.new(-half.X, -half.Y, -half.Z),
	}
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyOnScreen = false
	for _, worldPos in corners do
		local screenPos = camera:WorldToViewportPoint(worldPos)
		if screenPos.Z > 0 then
			anyOnScreen = true
			minX = math.min(minX, screenPos.X)
			minY = math.min(minY, screenPos.Y)
			maxX = math.max(maxX, screenPos.X)
			maxY = math.max(maxY, screenPos.Y)
		end
	end
	if not anyOnScreen or minX == math.huge then
		return nil, nil
	end
	return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local function updateEsp()
	if not CONFIG.ESPEnabled then
		clearAllEsp()
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local camPos = camera.CFrame.Position
	local seen: { [Player]: boolean } = {}
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer == localPlayer then
			continue
		end
		local character = otherPlayer.Character
		if not character or not isAlive(character) or not passesEspTeamCheck(otherPlayer) then
			clearEspForPlayer(otherPlayer)
			continue
		end
		local root = getCharacterPart(character, "HumanoidRootPart") or getCharacterPart(character, "Head")
		if not root then
			clearEspForPlayer(otherPlayer)
			continue
		end
		local distance = (root.Position - camPos).Magnitude
		if distance > CONFIG.ESPMaxDistance then
			clearEspForPlayer(otherPlayer)
			continue
		end
		seen[otherPlayer] = true
		local visuals = ensureEspVisuals(otherPlayer, character)
		local color = getEspColor(otherPlayer)
		local anyFeature = CONFIG.ESPBoxes or CONFIG.ESPNames or CONFIG.ESPDistance or CONFIG.ESPHealthBar or CONFIG.ESPHighlights or CONFIG.ESPTracers
		if not anyFeature then
			clearEspForPlayer(otherPlayer)
			continue
		end

		visuals.highlight.Enabled = CONFIG.ESPHighlights
		visuals.highlight.FillColor = color
		visuals.highlight.OutlineColor = color

		local showBillboard = CONFIG.ESPNames or CONFIG.ESPDistance or CONFIG.ESPHealthBar
		visuals.billboard.Enabled = showBillboard
		visuals.billboard.MaxDistance = CONFIG.ESPMaxDistance
		visuals.nameLabel.Visible = CONFIG.ESPNames
		visuals.nameLabel.Text = otherPlayer.DisplayName
		visuals.nameLabel.TextColor3 = color
		visuals.distLabel.Visible = CONFIG.ESPDistance
		visuals.distLabel.Text = string.format("[%d studs]", math.floor(distance + 0.5))

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if CONFIG.ESPHealthBar and humanoid then
			visuals.healthBg.Visible = true
			local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
			visuals.healthFill.Size = UDim2.fromScale(ratio, 1)
			visuals.healthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio), 220 * ratio, 60)
		else
			visuals.healthBg.Visible = false
		end

		if CONFIG.ESPBoxes then
			local topLeft, boxSize = getScreenBox(character)
			if topLeft and boxSize and boxSize.X > 2 and boxSize.Y > 2 then
				visuals.box.Visible = true
				visuals.box.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
				visuals.box.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
				local stroke = visuals.box:FindFirstChild("Stroke")
				if stroke and stroke:IsA("UIStroke") then
					stroke.Color = color
				end
			else
				visuals.box.Visible = false
			end
		else
			visuals.box.Visible = false
		end

		if CONFIG.ESPTracers then
			local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen and screenPos.Z > 0 then
				local viewport = camera.ViewportSize
				local from = Vector2.new(viewport.X / 2, viewport.Y)
				local to = Vector2.new(screenPos.X, screenPos.Y)
				local delta = to - from
				local length = delta.Magnitude
				visuals.tracer.Visible = true
				visuals.tracer.BackgroundColor3 = color
				visuals.tracer.Size = UDim2.fromOffset(math.max(length, 1), 1.5)
				visuals.tracer.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
				visuals.tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			else
				visuals.tracer.Visible = false
			end
		else
			visuals.tracer.Visible = false
		end
	end
	for player in pairs(espVisuals) do
		if not seen[player] then
			clearEspForPlayer(player)
		end
	end
end

local function hasLineOfSight(origin: Vector3, targetPart: BasePart, targetCharacter: Model): boolean
	if not CONFIG.RequireLineOfSight then
		return true
	end
	local direction = targetPart.Position - origin
	if direction.Magnitude <= 0.01 then
		return true
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excludeList: { Instance } = {}
	if localPlayer.Character then
		table.insert(excludeList, localPlayer.Character)
	end
	params.FilterDescendantsInstances = excludeList
	local result = workspace:Raycast(origin, direction, params)
	if not result then
		return true
	end
	return targetCharacter:IsAncestorOf(result.Instance)
end

local function worldToScreenDistance(part: BasePart, mousePos: Vector2): (number?, boolean)
	local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
	if not onScreen or screenPos.Z <= 0 then
		return nil, false
	end
	return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude, true
end

local function isValidTargetPlayer(otherPlayer: Player, mousePos: Vector2, rayOrigin: Vector3?): Player?
	if otherPlayer == localPlayer then
		return nil
	end
	local character = otherPlayer.Character
	if not character or not isAlive(character) or not passesTeamCheck(otherPlayer) then
		return nil
	end
	local targetPart = getTargetPart(character)
	if not targetPart then
		return nil
	end
	if (targetPart.Position - camera.CFrame.Position).Magnitude > CONFIG.MaxWorldDistance then
		return nil
	end
	local screenDistance, onScreen = worldToScreenDistance(targetPart, mousePos)
	if not onScreen or not screenDistance or screenDistance > CONFIG.FOVRadius then
		return nil
	end
	if rayOrigin and not hasLineOfSight(rayOrigin, targetPart, character) then
		return nil
	end
	return otherPlayer
end

local function findClosestTarget(): Player?
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local rayOrigin = getRaycastOrigin(character)
	local mousePos = getMouseScreenPosition()
	local closestPlayer: Player? = nil
	local closestDistance = CONFIG.FOVRadius + 1
	for _, otherPlayer in Players:GetPlayers() do
		if isValidTargetPlayer(otherPlayer, mousePos, rayOrigin) then
			local targetPart = getTargetPart(otherPlayer.Character :: Model)
			if targetPart then
				local screenDistance = worldToScreenDistance(targetPart, mousePos)
				if screenDistance and screenDistance < closestDistance then
					closestDistance = screenDistance
					closestPlayer = otherPlayer
				end
			end
		end
	end
	return closestPlayer
end

local function smoothLookAt(lookAtPosition: Vector3, alpha: number)
	local currentCFrame = camera.CFrame
	local goalCFrame = CFrame.lookAt(currentCFrame.Position, lookAtPosition)
	camera.CFrame = currentCFrame:Lerp(goalCFrame, math.clamp(alpha, 0.01, 1))
end

local function untrackPlayer(player: Player)
	local data = trackedPlayers[player]
	if not data then
		clearEspForPlayer(player)
		return
	end
	if data.characterAdded then
		data.characterAdded:Disconnect()
	end
	if data.characterRemoving then
		data.characterRemoving:Disconnect()
	end
	trackedPlayers[player] = nil
	clearEspForPlayer(player)
	if currentTarget == player then
		currentTarget = nil
	end
end

local function trackPlayer(player: Player)
	if player == localPlayer or trackedPlayers[player] then
		return
	end
	trackedPlayers[player] = {
		characterAdded = player.CharacterAdded:Connect(function()
			if currentTarget == player then
				currentTarget = nil
			end
		end),
		characterRemoving = player.CharacterRemoving:Connect(function()
			if currentTarget == player then
				currentTarget = nil
			end
		end),
	}
end

for _, player in Players:GetPlayers() do
	trackPlayer(player)
end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

local function destroyFlyConstraints()
	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity = nil
	end
	if flyAlign then
		flyAlign:Destroy()
		flyAlign = nil
	end
	if flyAttachment then
		flyAttachment:Destroy()
		flyAttachment = nil
	end
	if flyHumanoid then
		flyHumanoid.PlatformStand = flyWasPlatformStanding
		flyHumanoid = nil
	end
end

local function setupFlyConstraints(character: Model): boolean
	local hrp = getCharacterPart(character, "HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return false
	end
	destroyFlyConstraints()
	flyHumanoid = humanoid
	flyWasPlatformStanding = humanoid.PlatformStand
	humanoid.PlatformStand = true
	local attachment = Instance.new("Attachment")
	attachment.Name = "AimAssistFlyAttachment"
	attachment.Parent = hrp
	flyAttachment = attachment
	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "AimAssistFlyVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	velocity.MaxForce = math.huge
	velocity.VectorVelocity = Vector3.zero
	velocity.Parent = hrp
	flyVelocity = velocity
	local align = Instance.new("AlignOrientation")
	align.Name = "AimAssistFlyAlign"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = attachment
	align.Responsiveness = 25
	align.MaxTorque = math.huge
	align.Parent = hrp
	flyAlign = align
	return true
end

setFlyEnabled = function(value: boolean)
	flyEnabled = value
	if flyToggleUI then
		flyToggleUI.Set(flyEnabled)
	end
	if flyEnabled then
		local character = localPlayer.Character
		if character then
			setupFlyConstraints(character)
		end
	else
		destroyFlyConstraints()
	end
end

local function updateFly()
	if not flyEnabled then
		return
	end
	local character = localPlayer.Character
	if not character or not isAlive(character) then
		destroyFlyConstraints()
		return
	end
	if not flyVelocity or not flyVelocity.Parent or not flyAlign or not flyAlign.Parent then
		if not setupFlyConstraints(character) then
			return
		end
	end
	camera = workspace.CurrentCamera
	if not camera or not flyVelocity or not flyAlign then
		return
	end
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude > 0.001 then
		flatLook = flatLook.Unit
	else
		flatLook = Vector3.new(0, 0, -1)
	end
	local flatRight = Vector3.new(right.X, 0, right.Z)
	if flatRight.Magnitude > 0.001 then
		flatRight = flatRight.Unit
	else
		flatRight = Vector3.new(1, 0, 0)
	end
	local move = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		move += flatLook
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		move -= flatLook
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		move += flatRight
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		move -= flatRight
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		move += Vector3.yAxis * CONFIG.FlyVerticalMultiplier
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		move -= Vector3.yAxis * CONFIG.FlyVerticalMultiplier
	end
	if move.Magnitude > 0 then
		move = move.Unit
	end
	flyVelocity.VectorVelocity = move * CONFIG.FlySpeed
	local hrp = getCharacterPart(character, "HumanoidRootPart")
	if hrp then
		local facePos = hrp.Position + flatLook
		flyAlign.CFrame = CFrame.lookAt(hrp.Position, facePos)
	end
end

localPlayer.CharacterAdded:Connect(function()
	if flyEnabled then
		task.defer(function()
			if flyEnabled and localPlayer.Character then
				setupFlyConstraints(localPlayer.Character)
			end
		end)
	else
		destroyFlyConstraints()
	end
end)

localPlayer.CharacterRemoving:Connect(function()
	destroyFlyConstraints()
end)

setSilentAimEnabled = function(value: boolean)
	silentAimEnabled = value
	if silentAimToggleUI then
		silentAimToggleUI.Set(silentAimEnabled)
	end
	if not silentAimEnabled then
		silentAimTarget = nil
		silentAimPart = nil
		silentAimPosition = nil
		silentMarker.Visible = false
		silentAimChangedEvent:Fire(false, nil, nil, nil)
	end
end

local function clearSilentAimLock()
	local hadTarget = silentAimTarget ~= nil
	silentAimTarget = nil
	silentAimPart = nil
	silentAimPosition = nil
	silentMarker.Visible = false
	if hadTarget then
		silentAimChangedEvent:Fire(silentAimEnabled, nil, nil, nil)
	end
end

local function updateSilentAimLock(targetPlayer: Player?)
	if not silentAimEnabled then
		clearSilentAimLock()
		return
	end
	if not targetPlayer then
		clearSilentAimLock()
		return
	end
	local character = targetPlayer.Character
	if not character or not isAlive(character) then
		clearSilentAimLock()
		return
	end
	local part = getTargetPart(character)
	if not part then
		clearSilentAimLock()
		return
	end
	local targetChanged = silentAimTarget ~= targetPlayer or silentAimPart ~= part
	silentAimTarget = targetPlayer
	silentAimPart = part
	silentAimPosition = part.Position
	if CONFIG.SilentAimShowMarker then
		local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
		if onScreen and screenPos.Z > 0 then
			silentMarker.Visible = true
			silentMarker.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
			local stroke = silentMarker:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = CONFIG.SilentAimMarkerColor
			end
		else
			silentMarker.Visible = false
		end
	else
		silentMarker.Visible = false
	end
	if targetChanged then
		silentAimChangedEvent:Fire(true, silentAimPart, silentAimPosition, silentAimTarget)
	end
end

local lastSilentShot = 0
local activeTracer: Beam? = nil
local tracerAtt0: Attachment? = nil
local tracerAtt1: Attachment? = nil
local tracerPart0: BasePart? = nil
local tracerPart1: BasePart? = nil

local function clearTracer()
	if activeTracer then
		activeTracer:Destroy()
		activeTracer = nil
	end
	if tracerAtt0 then
		tracerAtt0:Destroy()
		tracerAtt0 = nil
	end
	if tracerAtt1 then
		tracerAtt1:Destroy()
		tracerAtt1 = nil
	end
	if tracerPart0 then
		tracerPart0:Destroy()
		tracerPart0 = nil
	end
	if tracerPart1 then
		tracerPart1:Destroy()
		tracerPart1 = nil
	end
end

local function showSilentTracer(fromPos: Vector3, toPos: Vector3)
	clearTracer()
	if not CONFIG.SilentAimShowTracer then
		return
	end
	local p0 = Instance.new("Part")
	p0.Name = "NameHubSilentTracer0"
	p0.Anchored = true
	p0.CanCollide = false
	p0.CanQuery = false
	p0.CanTouch = false
	p0.Transparency = 1
	p0.Size = Vector3.new(0.2, 0.2, 0.2)
	p0.CFrame = CFrame.new(fromPos)
	p0.Parent = workspace.CurrentCamera or workspace
	local p1 = Instance.new("Part")
	p1.Name = "NameHubSilentTracer1"
	p1.Anchored = true
	p1.CanCollide = false
	p1.CanQuery = false
	p1.CanTouch = false
	p1.Transparency = 1
	p1.Size = Vector3.new(0.2, 0.2, 0.2)
	p1.CFrame = CFrame.new(toPos)
	p1.Parent = p0.Parent
	local a0 = Instance.new("Attachment")
	a0.Parent = p0
	local a1 = Instance.new("Attachment")
	a1.Parent = p1
	local beam = Instance.new("Beam")
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.12
	beam.Width1 = 0.04
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(CONFIG.SilentAimMarkerColor)
	beam.Transparency = NumberSequence.new(0.15)
	beam.Parent = p0
	activeTracer = beam
	tracerAtt0 = a0
	tracerAtt1 = a1
	tracerPart0 = p0
	tracerPart1 = p1
	task.delay(CONFIG.SilentAimTracerTime, function()
		clearTracer()
	end)
end

local function isMouseOverMenu(): boolean
	if not menuOpen or not menuFrame.Visible then
		return false
	end
	local mouse = UserInputService:GetMouseLocation()
	local objects = playerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
	for _, obj in objects do
		if obj:IsDescendantOf(menuFrame) then
			return true
		end
	end
	return false
end

local function getSilentFireOrigin(): Vector3
	camera = workspace.CurrentCamera
	local character = localPlayer.Character
	if character then
		local originPart = getCharacterPart(character, CONFIG.RaycastOriginPart)
			or getCharacterPart(character, "Head")
			or getCharacterPart(character, "HumanoidRootPart")
		if originPart then
			return originPart.Position
		end
	end
	if camera then
		return camera.CFrame.Position
	end
	return Vector3.zero
end

local function trySilentAimFire()
	if not silentAimEnabled or not CONFIG.SilentAimClickFire then
		return false
	end
	if not silentAimPosition or not silentAimPart then
		return false
	end
	if isMouseOverMenu() then
		return false
	end
	local now = os.clock()
	if now - lastSilentShot < CONFIG.SilentAimFireCooldown then
		return false
	end
	lastSilentShot = now
	local origin = getSilentFireOrigin()
	local aimPos = silentAimPosition
	local toTarget = aimPos - origin
	local distance = toTarget.Magnitude
	if distance < 0.05 then
		return false
	end
	local direction = toTarget.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclude: { Instance } = {}
	if localPlayer.Character then
		table.insert(exclude, localPlayer.Character)
	end
	params.FilterDescendantsInstances = exclude
	local result = workspace:Raycast(origin, direction * (distance + 4), params)
	local hitPos = if result then result.Position else aimPos
	local hitInstance = if result then result.Instance else silentAimPart
	local hitHumanoid: Humanoid? = nil
	local hitCharacter: Model? = nil
	if hitInstance then
		local model = hitInstance:FindFirstAncestorOfClass("Model")
		if model then
			hitCharacter = model
			hitHumanoid = model:FindFirstChildOfClass("Humanoid")
		end
	end
	local lockedCharacter = silentAimTarget and silentAimTarget.Character
	if lockedCharacter and (not hitHumanoid or hitCharacter ~= lockedCharacter) then
		hitCharacter = lockedCharacter
		hitHumanoid = lockedCharacter:FindFirstChildOfClass("Humanoid")
		hitInstance = silentAimPart
		hitPos = aimPos
	end
	showSilentTracer(origin, hitPos)
	silentAimShotEvent:Fire({
		Origin = origin,
		Direction = direction,
		AimPosition = aimPos,
		HitPosition = hitPos,
		HitInstance = hitInstance,
		HitHumanoid = hitHumanoid,
		HitCharacter = hitCharacter,
		TargetPlayer = silentAimTarget,
		TargetPart = silentAimPart,
	})
	local replicated = game:FindFirstChild("ReplicatedStorage")
	if replicated then
		local remote = replicated:FindFirstChild("NameHubSilentHit")
		if remote and remote:IsA("RemoteEvent") and hitHumanoid then
			remote:FireServer(hitHumanoid, hitPos, silentAimTarget)
		end
	end
	return true
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if listeningForKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Escape then
			listeningForKeybind.cancel()
		else
			listeningForKeybind.apply(input.KeyCode)
		end
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if trySilentAimFire() then
			return
		end
	end
	if gameProcessed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if input.KeyCode == CONFIG.MenuKey then
		setMenuVisible(not menuOpen)
		return
	end
	if input.KeyCode == CONFIG.ToggleKey then
		enabled = not enabled
		enableToggle.Set(enabled)
		currentTarget = nil
		if not enabled then
			fovCircle.Visible = false
			targetMarker.Visible = false
		end
		return
	end
	if input.KeyCode == CONFIG.FlyKey then
		setFlyEnabled(not flyEnabled)
		return
	end
	if input.KeyCode == CONFIG.SilentAimKey then
		setSilentAimEnabled(not silentAimEnabled)
	end
end)

RunService.RenderStepped:Connect(function()
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	updateEsp()
	updateFly()
	local targetingActive = enabled or silentAimEnabled
	if not targetingActive then
		fovCircle.Visible = false
		targetMarker.Visible = false
		clearSilentAimLock()
		return
	end
	local mousePos = getMouseScreenPosition()
	if CONFIG.ShowFOVCircle then
		fovCircle.Visible = true
		fovCircle.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
	else
		fovCircle.Visible = false
	end
	local closest = findClosestTarget()
	currentTarget = if enabled then closest else nil
	if silentAimEnabled then
		updateSilentAimLock(closest)
	else
		clearSilentAimLock()
	end
	if not enabled then
		targetMarker.Visible = false
		return
	end
	if not currentTarget then
		targetMarker.Visible = false
		return
	end
	local character = currentTarget.Character
	if not character or not isAlive(character) then
		currentTarget = nil
		targetMarker.Visible = false
		return
	end
	local targetPart = getTargetPart(character)
	if not targetPart then
		currentTarget = nil
		targetMarker.Visible = false
		return
	end
	if CONFIG.ShowTargetMarker then
		local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
		if onScreen and screenPos.Z > 0 then
			targetMarker.Visible = true
			targetMarker.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
		else
			targetMarker.Visible = false
		end
	else
		targetMarker.Visible = false
	end
	smoothLookAt(targetPart.Position, CONFIG.Smoothness)
end)

playNameHubLoadingScreen()
setMenuVisible(true)
print("[NameHub] Loaded. RightShift = aim · T = silent aim · LMB = silent fire · Insert = menu · F = fly.")
