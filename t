--====================================================
-- SERVICES
--====================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

--====================================================
-- CONFIG
--====================================================
local RAW_URL = "https://raw.githubusercontent.com/allanxsix/Teste/refs/heads/main/tt"

--====================================================
-- LOAD FUNCTIONS (RAW GITHUB)
--====================================================
local Functions
do
	local success, result = pcall(function()
		return loadstring(game:HttpGet(RAW_URL))()
	end)

	if not success then
		warn("Falha ao carregar funções do GitHub")
		return
	end

	Functions = result
end

--====================================================
-- CLEAN OLD UI
--====================================================
if CoreGui:FindFirstChild("Status_UI") then
	CoreGui.Status_UI:Destroy()
end

--====================================================
-- SCREEN GUI
--====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Status_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

--====================================================
-- MAIN PANEL
--====================================================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 540, 0, 320)
Main.Position = UDim2.new(0.5, 0, 0.08, 0)
Main.AnchorPoint = Vector2.new(0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(12,12,12)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255,80,80)

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(255,90,90)

--====================================================
-- TITLE
--====================================================
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Lonely Stats Checker"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,90,90)

--====================================================
-- SUBTITLE
--====================================================
local Sub = Instance.new("TextLabel", Main)
Sub.Position = UDim2.new(0, 0, 0, 32)
Sub.Size = UDim2.new(1, 0, 0, 22)
Sub.BackgroundTransparency = 1
Sub.Text = "Gravity Hub • Kaitun"
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 14
Sub.TextColor3 = Color3.fromRGB(200,200,200)

--====================================================
-- STATS COLUMN
--====================================================
local StatsFrame = Instance.new("Frame", Main)
StatsFrame.Position = UDim2.new(0, 10, 0, 70)
StatsFrame.Size = UDim2.new(0.45, -10, 1, -80)
StatsFrame.BackgroundTransparency = 1

local StatsTitle = Instance.new("TextLabel", StatsFrame)
StatsTitle.Size = UDim2.new(1, 0, 0, 24)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Text = "Account Stats"
StatsTitle.Font = Enum.Font.GothamBold
StatsTitle.TextSize = 14
StatsTitle.TextColor3 = Color3.fromRGB(255,90,90)
StatsTitle.TextXAlignment = Left

local StatsList = Instance.new("UIListLayout", StatsFrame)
StatsList.Padding = UDim.new(0, 6)

StatsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	StatsFrame.CanvasSize = UDim2.new(0,0,0,StatsList.AbsoluteContentSize.Y)
end)

--====================================================
-- ITEMS COLUMN
--====================================================
local ItemsFrame = Instance.new("Frame", Main)
ItemsFrame.Position = UDim2.new(0.52, 0, 0, 70)
ItemsFrame.Size = UDim2.new(0.45, -10, 1, -80)
ItemsFrame.BackgroundTransparency = 1

local ItemsTitle = Instance.new("TextLabel", ItemsFrame)
ItemsTitle.Size = UDim2.new(1, 0, 0, 24)
ItemsTitle.BackgroundTransparency = 1
ItemsTitle.Text = "Account Items"
ItemsTitle.Font = Enum.Font.GothamBold
ItemsTitle.TextSize = 14
ItemsTitle.TextColor3 = Color3.fromRGB(255,90,90)
ItemsTitle.TextXAlignment = Left

local Grid = Instance.new("UIGridLayout", ItemsFrame)
Grid.CellSize = UDim2.new(0, 160, 0, 28)
Grid.CellPadding = UDim2.new(0, 6, 0, 6)

--====================================================
-- POPULATE DATA
--====================================================
local Stats = Functions:GetStats()
for name, value in pairs(Stats) do
	local Label = Instance.new("TextLabel", StatsFrame)
	Label.Size = UDim2.new(1, 0, 0, 22)
	Label.BackgroundTransparency = 1
	Label.TextXAlignment = Left
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextColor3 = Color3.fromRGB(220,220,220)
	Label.Text = name .. ": " .. value
end

local Items = Functions:GetItems()
for _, item in ipairs(Items) do
	local ItemLabel = Instance.new("TextLabel", ItemsFrame)
	ItemLabel.BackgroundColor3 = Color3.fromRGB(18,18,18)
	ItemLabel.BorderColor3 = Color3.fromRGB(255,90,90)
	ItemLabel.BorderSizePixel = 1
	ItemLabel.Font = Enum.Font.Gotham
	ItemLabel.TextSize = 13
	ItemLabel.TextColor3 = Color3.fromRGB(235,235,235)
	ItemLabel.Text = "● "..item

	local IC = Instance.new("UICorner", ItemLabel)
	IC.CornerRadius = UDim.new(0,6)
end

--====================================================
-- ANIMATION (PULSE)
--====================================================
task.spawn(function()
	while task.wait(1.2) do
		TweenService:Create(Stroke, TweenInfo.new(1.2), {
			Color = Color3.fromRGB(255,140,140)
		}):Play()
		task.wait(1.2)
		TweenService:Create(Stroke, TweenInfo.new(1.2), {
			Color = Color3.fromRGB(255,90,90)
		}):Play()
	end
end)
