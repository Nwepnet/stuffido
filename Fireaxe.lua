-- Variables
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local equipped = false
local sprinting = false
local attacking = false
local cooldown = false
local sprintTime = 0

-- Animation IDs
local defaultIdleAnimId = "rbxassetid://313776454"  -- Idle without axe
local fireaxeIdleAnimId = "rbxassetid://70439247"  -- Idle with axe
local sprintAnimId = "rbxassetid://204055750"  -- Sprint with axe
local attackAnimIds = { "rbxassetid://243641880", "rbxassetid://50248790" }  -- Two attack animations

-- Tool Creation
local tool = Instance.new("Tool")
tool.Name = "Fireaxe"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = player.Backpack

-- Animation Instances
local animations = {
    idleDefault = Instance.new("Animation"),
    idleFireaxe = Instance.new("Animation"),
    sprint = Instance.new("Animation"),
    attack1 = Instance.new("Animation"),
    attack2 = Instance.new("Animation")
}

-- Set Animation IDs
animations.idleDefault.AnimationId = defaultIdleAnimId
animations.idleFireaxe.AnimationId = fireaxeIdleAnimId
animations.sprint.AnimationId = sprintAnimId
animations.attack1.AnimationId = attackAnimIds[1]
animations.attack2.AnimationId = attackAnimIds[2]

-- Animation Tracks
local idleTrack, sprintTrack, attackTrack

-- Function to Play and Return Animation Track
local function playAnimation(anim, looped)
    local track = humanoid:LoadAnimation(anim)
    track.Looped = looped or false
    track:Play()
    return track
end

-- Function to Stop Animation
local function stopAnimation(track)
    if track and track.IsPlaying then
        track:Stop()
    end
end

-- Function to Handle Idles
local function updateIdleAnimation()
    if equipped then
        stopAnimation(idleTrack)
        idleTrack = playAnimation(animations.idleFireaxe, true)
    else
        stopAnimation(idleTrack)
        idleTrack = playAnimation(animations.idleDefault, true)
    end
end

-- Equip and Unequip Functions
tool.Equipped:Connect(function()
    equipped = true
    updateIdleAnimation()
end)

tool.Unequipped:Connect(function()
    equipped = false
    stopAnimation(idleTrack)
    stopAnimation(sprintTrack)
    humanoid.WalkSpeed = 16
    sprintTime = 0
    updateIdleAnimation()
end)

-- Sprinting System
game:GetService("RunService").Heartbeat:Connect(function()
    if equipped and humanoid.MoveDirection.Magnitude > 0 then
        sprintTime = sprintTime + game:GetService("RunService").Heartbeat:Wait()

        if sprintTime >= 5 and not sprinting then
            sprinting = true
            humanoid.WalkSpeed = 25
            sprintTrack = playAnimation(animations.sprint, true)
        end
    else
        if sprinting then
            sprinting = false
            humanoid.WalkSpeed = 16
            stopAnimation(sprintTrack)
        end
        sprintTime = 0
    end
end)

-- Attack System with Random Variants and Cooldown
tool.Activated:Connect(function()
    if not cooldown and equipped then
        cooldown = true
        attacking = true

        -- Randomly select attack animation
        local selectedAttack = math.random(1, 2) == 1 and animations.attack1 or animations.attack2
        attackTrack = playAnimation(selectedAttack, false)

        wait(2.5) -- Cooldown duration
        cooldown = false
        attacking = false
    end
end)

-- Ensure Default Idle Plays on Spawn
updateIdleAnimation()