-- RetroBox Designer 2.5.1 | API 2 | generated Luau

-- Reopen JSON in the Designer. Connect custom actions in the actions table.

return function(Library, actions)

actions = actions or {}

assert(type(Library.GetDesignerCatalog) == "function", "RetroBox 2.5.1 or later is required")

local window = Library:CreateWindow({
    ["Id"] = "reusable-form",
    ["Locale"] = "auto",
    ["SourceLocale"] = "pt-BR",
    ["Subtitle"] = "Monte, conecte e exporte",
    ["Theme"] = "Hacker",
    ["Title"] = "Meu projeto",
    ["Translations"] = {
        ["amount.Title"] = {
            ["Context"] = "amount / Title",
            ["Source"] = "Quantidade",
            ["Values"] = {}
        },
        ["enabled.Title"] = {
            ["Context"] = "enabled / Title",
            ["Source"] = "Ativar recurso",
            ["Values"] = {}
        },
        ["flow.format.Text"] = {
            ["Context"] = "format",
            ["Source"] = "Quantidade: {value}",
            ["Values"] = {}
        },
        ["flow.notice.Text"] = {
            ["Context"] = "notice",
            ["Source"] = "Você acionou um evento visual.",
            ["Values"] = {}
        },
        ["flow.notice.Title"] = {
            ["Context"] = "notice",
            ["Source"] = "Meu projeto",
            ["Values"] = {}
        },
        ["geral.Title"] = {
            ["Context"] = "geral / Title",
            ["Source"] = "Controles",
            ["Values"] = {}
        },
        ["principal.Title"] = {
            ["Context"] = "principal / Title",
            ["Source"] = "Principal",
            ["Values"] = {}
        },
        ["run.Text"] = {
            ["Context"] = "run / Text",
            ["Source"] = "Executar",
            ["Values"] = {}
        },
        ["run.Title"] = {
            ["Context"] = "run / Title",
            ["Source"] = "Executar",
            ["Values"] = {}
        },
        ["settings.Title"] = {
            ["Context"] = "settings / Title",
            ["Source"] = "Configurações",
            ["Values"] = {}
        },
        ["settings/enabled.Title"] = {
            ["Context"] = "settings/enabled / Title",
            ["Source"] = "Ativar",
            ["Values"] = {}
        },
        ["settings/name.Title"] = {
            ["Context"] = "settings/name / Title",
            ["Source"] = "Nome",
            ["Values"] = {}
        },
        ["summary.Title"] = {
            ["Context"] = "summary / Title",
            ["Source"] = "Quantidade: 25",
            ["Values"] = {}
        },
        ["template.stats/coins.Title"] = {
            ["Context"] = "template.stats/coins / Title",
            ["Source"] = "Moedas",
            ["Values"] = {}
        },
        ["template.stats/key.Title"] = {
            ["Context"] = "template.stats/key / Title",
            ["Source"] = "Atalho",
            ["Values"] = {}
        },
        ["window.Subtitle"] = {
            ["Context"] = "window / Subtitle",
            ["Source"] = "Monte, conecte e exporte",
            ["Values"] = {}
        },
        ["window.Title"] = {
            ["Context"] = "window / Title",
            ["Source"] = "Meu projeto",
            ["Values"] = {}
        }
    }
,
    ["Size"] = Vector2.new(790, 570)
})

local controls, states = {}, {}

window:BindText(window.TitleLabel, "Text", "window.Title")

window:BindText(window.SubtitleLabel, "Text", "window.Subtitle")

local componentName_0 = "designer-" .. Library:SHA256("reusable-form/stats"):sub(1,24)

Library:RegisterComponent(componentName_0, function(ctx, props)

    do

        local options = {
    ["Default"] = 5,
    ["Id"] = "coins",
    ["Title"] = "Moedas"
}

        for key,value in pairs(props["coins"] or {}) do if key ~= "Id" then options[key] = value end end

        ctx:Add("StatCard", options)

    end

    do

        local options = {
    ["Default"] = "F",
    ["Id"] = "key",
    ["Title"] = "Atalho"
}

        for key,value in pairs(props["key"] or {}) do if key ~= "Id" then options[key] = value end end

        ctx:Add("Keybind", options)

    end

end, {Replace=true})

local tab_1 = window:CreateTab({
    ["Columns"] = 1,
    ["Icon"] = "grid",
    ["Title"] = "Principal"
})

window:BindText(tab_1.Label, "Text", "principal.Title")

local section_1 = tab_1:CreateSection({
    ["Collapsed"] = nil,
    ["Collapsible"] = nil,
    ["Icon"] = "settings",
    ["Side"] = nil,
    ["Title"] = "Controles"
})

window:BindText(section_1.Header, "Text", "geral.Title")

controls["enabled"] = section_1:AddToggle({
    ["Default"] = true,
    ["Id"] = "enabled",
    ["Title"] = "Ativar recurso"
})

window:BindText(controls["enabled"].TitleLabel, "Text", "enabled.Title")

controls["amount"] = section_1:AddSlider({
    ["Default"] = 25,
    ["Id"] = "amount",
    ["Max"] = 100,
    ["Min"] = 0,
    ["Step"] = 1,
    ["Title"] = "Quantidade"
})

window:BindText(controls["amount"].TitleLabel, "Text", "amount.Title")

controls["summary"] = section_1:AddLabel({
    ["Id"] = "summary",
    ["Title"] = "Quantidade: 25"
})

window:BindText(controls["summary"].TitleLabel, "Text", "summary.Title")

controls["run"] = section_1:AddButton({
    ["Id"] = "run",
    ["Text"] = "Executar",
    ["Title"] = "Executar"
})

window:BindText(controls["run"].TitleLabel, "Text", "run.Title")

window:BindText(controls["run"].Button, "Text", "run.Text")

controls["stats1"] = section_1:AddComponent(componentName_0, {
    ["Id"] = "stats1",
    ["Props"] = {}
})

for id,control in pairs(controls["stats1"].Children) do controls["stats1/" .. id] = control end

controls["settings"] = section_1:CreateForm({
    ["Fields"] = {
        {
            ["Default"] = "Gustavo",
            ["Id"] = "name",
            ["Required"] = true,
            ["TextKeys"] = {
                ["Title"] = "settings/name.Title"
            },
            ["Title"] = "Nome",
            ["Type"] = "Input"
        },
        {
            ["Default"] = false,
            ["Id"] = "enabled",
            ["TextKeys"] = {
                ["Title"] = "settings/enabled.Title"
            },
            ["Title"] = "Ativar",
            ["Type"] = "Toggle"
        }
    },
    ["Id"] = "settings",
    ["Title"] = "Configurações"
})

if controls["settings"].Header then window:BindText(controls["settings"].Header.TitleLabel, "Text", "settings.Title") end

controls["settings/name"] = controls["settings"].Fields["name"]

window:BindText(controls["settings"].Fields["name"].TitleLabel, "Text", "settings/name.Title")

controls["settings/enabled"] = controls["settings"].Fields["enabled"]

window:BindText(controls["settings"].Fields["enabled"].TitleLabel, "Text", "settings/enabled.Title")

local flow = window:CreateFlowGraph({
    ["Edges"] = {
        {
            ["From"] = "read-amount",
            ["Input"] = "Value",
            ["Out"] = "Value",
            ["To"] = "format"
        },
        {
            ["From"] = "format",
            ["Input"] = "Value",
            ["Out"] = "Value",
            ["To"] = "summary-binding"
        },
        {
            ["From"] = "click",
            ["Input"] = "Execute",
            ["Out"] = "Then",
            ["To"] = "notice"
        }
    },
    ["Id"] = "principal",
    ["Nodes"] = {
        {
            ["Control"] = "amount",
            ["Id"] = "read-amount",
            ["Position"] = {
                ["X"] = 40,
                ["Y"] = 40
            },
            ["Type"] = "Value"
        },
        {
            ["Id"] = "format",
            ["Position"] = {
                ["X"] = 340,
                ["Y"] = 40
            },
            ["Text"] = "flow.format.Text",
            ["Type"] = "Format"
        },
        {
            ["Control"] = "summary",
            ["Id"] = "summary-binding",
            ["Position"] = {
                ["X"] = 640,
                ["Y"] = 40
            },
            ["Property"] = "Text",
            ["Type"] = "Binding"
        },
        {
            ["Control"] = "run",
            ["Id"] = "click",
            ["Position"] = {
                ["X"] = 40,
                ["Y"] = 270
            },
            ["Type"] = "Click"
        },
        {
            ["Id"] = "notice",
            ["Kind"] = "success",
            ["Position"] = {
                ["X"] = 340,
                ["Y"] = 270
            },
            ["Text"] = "flow.notice.Text",
            ["Title"] = "flow.notice.Title",
            ["Type"] = "Notify"
        }
    }
}, {Controls=controls, States=states, Actions=actions})

return {Window=window, Controls=controls, States=states, Flow=flow}

end
