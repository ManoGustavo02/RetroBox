return function(Mock,Library,test)
    local root="https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main"
    local version=Library.Version
    test("new updater defaults to the confirmed new account",function()
        assert(Library:CompareVersions(version,"2.3.1")>=0 and Library.APIVersion==2)
        assert(Library:CreateUpdater():GetStatus().Root==root)
        assert(Library:CreateUpdater({Root="https://example.test/custom"}):GetStatus().Root=="https://example.test/custom")
    end)
    for _,channel in ipairs({"stable","preview","pinned"}) do
        test("new-origin "..channel.." bootstrap loads the actual shipped manifest and artifact",function()
            local previousHTTP,previousLoad=game.HttpGet,loadstring
            local requests={}
            game.HttpGet=function(_,url)
                assert(url:sub(1,#root+1)==root.."/","Unexpected origin: "..url)
                local path=url:sub(#root+2)
                assert(path:match("^dist/") and not path:find("..",1,true))
                requests[#requests+1]=path
                local f=assert(io.open("../../"..path,"rb"));local bytes=f:read("*a");f:close();return bytes
            end
            loadstring=load
            local remote,report=assert(loadfile("Loader.lua"))({Channel=channel,Version=channel=="pinned" and version or nil,MinVersion=version,Cache=false})
            assert(remote.Version==version and remote.APIVersion==2 and report.State=="Loaded" and report.Root==root)
            assert(report.Channel==channel and #requests==2)
            assert(requests[1]==(channel=="pinned" and "dist/releases/"..version.."/manifest.json" or "dist/channels/"..channel.."/v2.json"))
            assert(requests[2]=="dist/releases/"..version.."/RetroBox.lua")
            local window=remote:CreateWindow({Id="origin-"..channel,Theme="Hacker",FileStorage=false})
            local section=window:CreateTab("Principal"):CreateSection("Controles")
            local calls=0
            section:AddButton({Id="notice",Title="Aviso",Icon="info",Callback=function() calls=calls+1 end}):Press()
            Mock.pump();assert(calls==1 and window.Theme=="Hacker")
            remote:DestroyAll();Mock.pump(100)
            assert(Mock.Connections==0 and #Mock.Warnings==0)
            game.HttpGet,loadstring=previousHTTP,previousLoad
        end)
    end
end
