local getinfo = getinfo or debug.getinfo
		local DEBUG = false
		local Hooked = {}

		local Detected, Kill

		setthreadidentity(2)

		for i, v in getgc(true) do
			if typeof(v) == "table" then
				local DetectFunc = rawget(v, "Detected")
				local KillFunc = rawget(v, "Kill")
			
				if typeof(DetectFunc) == "function" and not Detected then
					Detected = DetectFunc
					
					local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
						if Action ~= "_" then
							if DEBUG then
								warn(`Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info}`)
							end
						end
						
						return true
					end)

					table.insert(Hooked, Detected)
				end

				if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
					Kill = KillFunc
					local Old; Old = hookfunction(Kill, function(Info)
						if DEBUG then
							warn(`Adonis AntiCheat tried to kill (fallback): {Info}`)
						end
					end)

					table.insert(Hooked, Kill)
				end
			end
		end

		local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
			local LevelOrFunc, Info = ...

			if Detected and LevelOrFunc == Detected then
				if DEBUG then
					warn(`zins | adonis bypassed`)
				end

				return coroutine.yield(coroutine.running())
			end
			
			return Old(...)
		end))
		-- setthreadidentity(9)
		setthreadidentity(7)

	end

 	local players = game:GetService('Players')
		local lplr = players.LocalPlayer
		local lastCF, stop, heartbeatConnection
		local function start()
			heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
				if stop then
					return 
				end 
				lastCF = lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame
			end)
			lplr.Character:FindFirstChildOfClass('Humanoid').RootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
				stop = true
				lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame = lastCF
				game:GetService('RunService').Heartbeat:Wait()
				stop = false
			end)    
			lplr.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				heartbeatConnection:Disconnect()
			end)
		end

		lplr.CharacterAdded:Connect(function(character)
			repeat 
				game:GetService('RunService').Heartbeat:Wait() 
			until character:FindFirstChildOfClass('Humanoid')
			repeat 
				game:GetService('RunService').Heartbeat:Wait() 
			until character:FindFirstChildOfClass('Humanoid').RootPart
			start()
		end)

		lplr.CharacterRemoving:Connect(function()
			heartbeatConnection:Disconnect()
		end)

		start()

	end
