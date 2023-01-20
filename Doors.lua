local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")

local doorAddedFunction = getconnections(CollectionService:GetInstanceAddedSignal("Door"))[1].Function
local openDoor = getupvalue(getproto(getupvalue(doorAddedFunction, 2), 1, true)[1], 7)
local camera = workspace.CurrentCamera
local enabled = true

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("Door")
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

local highlight = Instance.new("Highlight")
highlight.FillTransparency = 1

local sortedDoors = {}

for _, doorData in next, getupvalue(doorAddedFunction, 1) do
    if doorData.Model then
        sortedDoors[doorData.Model] = doorData
    end
end

local function getDoor(mousePosition)
    local mouseRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)
    
    if raycastResult then
        local instance = raycastResult.Instance
        local doorModel = instance:FindFirstAncestor("SlideDoor") or instance:FindFirstAncestor("SwingDoor")
        
        return sortedDoors[doorModel]
    end
end

ContextActionService:BindAction("Doors", function(name, state, input)
    if enabled and input.UserInputType == Enum.UserInputType.MouseButton1 and state == Enum.UserInputState.Begin then
        local door = getDoor(input.Position)
        
        if door then
            openDoor(door)
        end
    elseif enabled and input.UserInputType == Enum.UserInputType.MouseMovement and state == Enum.UserInputState.Change then
        local door = getDoor(input.Position)
        
        highlight.Parent = door and door.Model
    elseif input.KeyCode == Enum.KeyCode.Q and state == Enum.UserInputState.Begin then
        enabled = not enabled

        if not enabled then
            highlight.Parent = nil
        end
    end
end, false, Enum.UserInputType.MouseMovement, Enum.KeyCode.Q, Enum.UserInputType.MouseButton1)
