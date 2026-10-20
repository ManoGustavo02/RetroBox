return function(Mock,Library,test)
    local function fixture()
        local w=Library:CreateWindow({Id='pixel-lifecycle',Settings=false,FileStorage=false,ReducedMotion=true})
        local tab=w:CreateTab({Title='Icons',Icon='diamond'})
        local s=tab:CreateSection({Title='Tools',Icon='tools'})
        return w,s,s:AddButton({Id='button',Title='Button',Icon='money'})
    end
    local function finish(w)
        w:Destroy(); Mock.pump(40)
        assert(Mock.Connections==0 and next(w._icons)==nil)
        assert((Mock.ParentLockErrors or 0)==0 and (Mock.DestroyedIconWrites or 0)==0)
    end
    for _,deferred in ipairs({false,true}) do
        local function check(name,callback)
            test('pixel lifecycle '..(deferred and 'deferred: ' or 'immediate: ')..name,function()
                Mock.StrictIconLifecycle=true; Mock.DeferDestroying=deferred
                Mock.ParentLockErrors=0; Mock.DestroyedIconWrites=0
                callback()
                Mock.StrictIconLifecycle=false; Mock.DeferDestroying=false
            end)
        end
        check('create and destroy',function()
            local w,s,c=fixture(); local icon=c._titleIcon
            icon:Destroy(); assert(icon.Destroyed and icon.Frame==nil and icon._window==nil and #icon.Nodes==0 and #icon.Foreground==0); finish(w)
        end)
        check('Destroy is idempotent',function()
            local w,s,c=fixture(); local icon=c._titleIcon
            icon:Destroy(); icon:Destroy(); finish(w)
        end)
        check('parent is destroyed before icon cleanup',function()
            local w,s,c=fixture(); local icon=c._titleIcon
            c.Frame:Destroy(); Mock.pump(); icon:Destroy(); icon:Destroy(); finish(w)
        end)
        check('window with many icons',function()
            local w,s=fixture()
            for i=1,24 do s:AddToggle({Id='toggle-'..i,Icon='diamond',Default=true}) end
            finish(w)
        end)
        check('repeated SetIcon',function()
            local w,s,c=fixture()
            for i=1,20 do c:SetIcon('diamond'); c:SetIcon('tools'); c:SetIcon('text:X'); c:SetIcon(false) end
            c:SetIcon('money'); assert(c.Icon:GetAttribute('RetroBoxIcon')=='money'); finish(w)
        end)
        check('theme changes and custom icon replacement',function()
            local w,s,c=fixture()
            Library:RegisterIcon('lifecycle_custom',{'##..','aa..','..##','..aa'}); c:SetIcon('lifecycle_custom')
            for _,theme in ipairs(Library:GetThemeNames()) do w:SetTheme(theme) end
            Library:RegisterIcon('lifecycle_custom',{'aa..','##..','..aa','..##'}); assert(#c._titleIcon.Nodes>0); finish(w)
        end)
        check('PixelIcons off and on',function()
            local w,s=fixture(); s:AddToggle({Id='toggle',Default=true})
            for i=1,20 do w:SetPixelIcons(false); w:SetPixelIcons(true) end
            finish(w)
        end)
        check('reexecution replaces the previous window',function()
            local first=fixture(); local second=fixture()
            assert(first.Destroyed); finish(second)
        end)
        check('Script Hubs create and destroy',function()
            for i=1,3 do
                local hub=Library:CreateScriptHub({Id='lifecycle-hub',Settings=false,FileStorage=false,ReducedMotion=true,
                    Games={{Id='game',Name='Game',Scripts={{Id='script',Title='Script',Icon='diamond',Callback=function() end}}}}})
                hub:Destroy(); Mock.pump(40); assert(Mock.Connections==0)
            end
            assert((Mock.ParentLockErrors or 0)==0)
        end)
        check('queued cleanup never writes or re-destroys a dead icon',function()
            local w,s,c=fixture(); local icon=c._titleIcon
            icon.Frame:Destroy()
            icon:Set('tools'); icon:SetOpacity(.5); icon:SetRole('Accent')
            Mock.pump(); icon:Destroy(); finish(w)
        end)
    end
end
