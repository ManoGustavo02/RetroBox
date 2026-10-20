-- Real compiler output runs against the same native constructors as handwritten UI.
return function(Mock,Library,test)
    for _,name in ipairs({'starter','all-components','reusable-form'}) do
        test('Designer generated Luau '..name..' executes and cleans up',function()
            local create=assert(loadfile('../../designer/tests/fixtures/'..name..'.lua'))()
            local built=create(Library,{});Mock.pump()
            assert(built.Window and built.Flow)
            if built.Controls.amount then built.Controls.amount:SetValue(42,true);Mock.pump();assert(built.Controls.summary:GetValue()=='Quantidade: 42') end
            if built.Controls.stats1 then assert(built.Controls.stats1:Get('coins'):GetValue()==5) end
            built.Window:SetLocale('en-US');built.Window:SetTheme('Hacker');built.Window:Destroy();Mock.pump(100)
            assert(built.Flow.Destroyed)
        end)
    end
end
