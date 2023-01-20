local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local doorAddedFunction = getconnections(CollectionService:GetInstanceAddedSignal("Door"))[1].Function
local openDoor = getupvalue(getproto(getupvalue(doorAddedFunction, 2), 1, true)[1], 7)
local doors = getupvalue(doorAddedFunction, 1)

local camera = workspace.CurrentCamera
local enabled = true

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("Door")
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

local highlight = Instance.new("Highlight")
highlight.FillTransparency = 1

local function GetDoorAncestor(part)
    for _, door in next, doors do
        local doorModel = door.Model

        if doorModel and part:IsDescendantOf(doorModel) then
            return door
        end
    end
end

local function GetClickedDoor(mousePosition)
    local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
    
    if raycastResult then
        return GetDoorAncestor(raycastResult.Instance)
    end
end

-- yes the mouse object would make this easier but its deprecated so yea
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if enabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local door = GetClickedDoor(input.Position)
        
        if door then
            openDoor(door)
        end
    elseif input.KeyCode == Enum.KeyCode.RightAlt then
        enabled = not enabled

        if not enabled then
            highlight.Parent = nil
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if enabled and input.UserInputType == Enum.UserInputType.MouseMovement then
        local door = GetClickedDoor(input.Position)
        
        highlight.Parent = door and door.Model
    end
end)
