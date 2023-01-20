local CollectionService = game:GetService('CollectionService')
local UserInputService = game:GetService('UserInputService')

local doorAddedFunction = getconnections(CollectionService:GetInstanceAddedSignal('Door'))[1].Function
local doors = getupvalue(doorAddedFunction, 1)
local doorModels = {}
local openDoor = getupvalue(getproto(getupvalue(doorAddedFunction, 2), 1, true)[1], 7)
local camera = workspace.CurrentCamera
local enabled = false

for _, v in next, doors do
    if v.Model then
        doorModels[v.Model] = v
    end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = CollectionService:GetTagged('Door')
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

local function GetDoor(mousePos)
    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
    
    if raycastResult then
        local instance = raycastResult.Instance
        local doorModel = instance:FindFirstAncestor('Door') or instance:FindFirstAncestor('SlideDoor') or instance:FindFirstAncestor('SwingDoor')
        
        return doorModels[doorModel]
    end
end

local highlight = Instance.new('Highlight')
highlight.FillTransparency = 1

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if enabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local door = GetDoor(input.Position)
        
        if door then
            openDoor(door)
        end
    elseif input.KeyCode == Enum.KeyCode.Q then
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
        local door = GetDoor(input.Position)
        highlight.Parent = door and door.Model
    end
end)
