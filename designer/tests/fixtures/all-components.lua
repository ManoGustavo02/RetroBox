-- RetroBox Designer 2.5.0 | API 2 | generated Luau

-- Reopen JSON in the Designer. Connect custom actions in the actions table.

return function(Library, actions)

actions = actions or {}

assert(type(Library.GetDesignerCatalog) == "function", "RetroBox 2.5.0 or later is required")

local window = Library:CreateWindow({
    ["Id"] = "all-components",
    ["Locale"] = "auto",
    ["SourceLocale"] = "pt-BR",
    ["Subtitle"] = "Monte, conecte e exporte",
    ["Theme"] = "Hacker",
    ["Title"] = "Meu projeto",
    ["Translations"] = {
        ["button.Text"] = {
            ["Context"] = "button / Text",
            ["Source"] = "Executar",
            ["Values"] = {}
        },
        ["button.Title"] = {
            ["Context"] = "button / Title",
            ["Source"] = "Executar",
            ["Values"] = {}
        },
        ["cardgrid.Title"] = {
            ["Context"] = "cardgrid / Title",
            ["Source"] = "Catálogo",
            ["Values"] = {}
        },
        ["chart.Title"] = {
            ["Context"] = "chart / Title",
            ["Source"] = "Histórico",
            ["Values"] = {}
        },
        ["colorpicker.Title"] = {
            ["Context"] = "colorpicker / Title",
            ["Source"] = "Cor",
            ["Values"] = {}
        },
        ["console.Title"] = {
            ["Context"] = "console / Title",
            ["Source"] = "Console",
            ["Values"] = {}
        },
        ["datatable.Title"] = {
            ["Context"] = "datatable / Title",
            ["Source"] = "Tabela",
            ["Values"] = {}
        },
        ["dropdown.Title"] = {
            ["Context"] = "dropdown / Title",
            ["Source"] = "Opção",
            ["Values"] = {}
        },
        ["form.Title"] = {
            ["Context"] = "form / Title",
            ["Source"] = "Configurações",
            ["Values"] = {}
        },
        ["form/enabled.Title"] = {
            ["Context"] = "form/enabled / Title",
            ["Source"] = "Ativar",
            ["Values"] = {}
        },
        ["form/name.Title"] = {
            ["Context"] = "form/name / Title",
            ["Source"] = "Nome",
            ["Values"] = {}
        },
        ["geral.Title"] = {
            ["Context"] = "geral / Title",
            ["Source"] = "Controles",
            ["Values"] = {}
        },
        ["image.Title"] = {
            ["Context"] = "image / Title",
            ["Source"] = "Imagem",
            ["Values"] = {}
        },
        ["input.Placeholder"] = {
            ["Context"] = "input / Placeholder",
            ["Source"] = "Digite aqui",
            ["Values"] = {}
        },
        ["input.Title"] = {
            ["Context"] = "input / Title",
            ["Source"] = "Nome",
            ["Values"] = {}
        },
        ["keybind.Title"] = {
            ["Context"] = "keybind / Title",
            ["Source"] = "Atalho",
            ["Values"] = {}
        },
        ["label.Title"] = {
            ["Context"] = "label / Title",
            ["Source"] = "Seu texto aqui",
            ["Values"] = {}
        },
        ["preview.Title"] = {
            ["Context"] = "preview / Title",
            ["Source"] = "Preview",
            ["Values"] = {}
        },
        ["principal.Title"] = {
            ["Context"] = "principal / Title",
            ["Source"] = "Principal",
            ["Values"] = {}
        },
        ["progress.Title"] = {
            ["Context"] = "progress / Title",
            ["Source"] = "Progresso",
            ["Values"] = {}
        },
        ["separator.Title"] = {
            ["Context"] = "separator / Title",
            ["Source"] = "Detalhes",
            ["Values"] = {}
        },
        ["slider.Title"] = {
            ["Context"] = "slider / Title",
            ["Source"] = "Intensidade",
            ["Values"] = {}
        },
        ["statcard.Title"] = {
            ["Context"] = "statcard / Title",
            ["Source"] = "Total",
            ["Values"] = {}
        },
        ["stepper.Title"] = {
            ["Context"] = "stepper / Title",
            ["Source"] = "Etapas",
            ["Values"] = {}
        },
        ["toggle.Title"] = {
            ["Context"] = "toggle / Title",
            ["Source"] = "Ativar recurso",
            ["Values"] = {}
        },
        ["treeview.Title"] = {
            ["Context"] = "treeview / Title",
            ["Source"] = "Árvore",
            ["Values"] = {}
        },
        ["virtuallist.Title"] = {
            ["Context"] = "virtuallist / Title",
            ["Source"] = "Lista",
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

controls["toggle"] = section_1:AddToggle({
    ["Default"] = false,
    ["Id"] = "toggle",
    ["Title"] = "Ativar recurso"
})

window:BindText(controls["toggle"].TitleLabel, "Text", "toggle.Title")

controls["slider"] = section_1:AddSlider({
    ["Default"] = 50,
    ["Id"] = "slider",
    ["Max"] = 100,
    ["Min"] = 0,
    ["Title"] = "Intensidade"
})

window:BindText(controls["slider"].TitleLabel, "Text", "slider.Title")

controls["button"] = section_1:AddButton({
    ["Id"] = "button",
    ["Text"] = "Executar",
    ["Title"] = "Executar"
})

window:BindText(controls["button"].TitleLabel, "Text", "button.Title")

window:BindText(controls["button"].Button, "Text", "button.Text")

controls["input"] = section_1:AddInput({
    ["Default"] = "",
    ["Id"] = "input",
    ["Placeholder"] = "Digite aqui",
    ["Title"] = "Nome"
})

window:BindText(controls["input"].TitleLabel, "Text", "input.Title")

window:BindText(controls["input"].Input, "PlaceholderText", "input.Placeholder")

controls["dropdown"] = section_1:AddDropdown({
    ["Default"] = "Opção A",
    ["Id"] = "dropdown",
    ["Options"] = {
        "Opção A",
        "Opção B"
    },
    ["Title"] = "Opção"
})

window:BindText(controls["dropdown"].TitleLabel, "Text", "dropdown.Title")

controls["colorpicker"] = section_1:AddColorPicker({
    ["Default"] = "#32df7b",
    ["Id"] = "colorpicker",
    ["Title"] = "Cor"
})

window:BindText(controls["colorpicker"].TitleLabel, "Text", "colorpicker.Title")

controls["label"] = section_1:AddLabel({
    ["Id"] = "label",
    ["Title"] = "Seu texto aqui"
})

window:BindText(controls["label"].TitleLabel, "Text", "label.Title")

controls["separator"] = section_1:AddSeparator({
    ["Id"] = "separator",
    ["Title"] = "Detalhes"
})

window:BindText(controls["separator"].TitleLabel, "Text", "separator.Title")

controls["progress"] = section_1:AddProgress({
    ["Default"] = 25,
    ["Id"] = "progress",
    ["Max"] = 100,
    ["Min"] = 0,
    ["Title"] = "Progresso"
})

window:BindText(controls["progress"].TitleLabel, "Text", "progress.Title")

controls["statcard"] = section_1:AddStatCard({
    ["Default"] = 1250,
    ["Format"] = "Compact",
    ["Id"] = "statcard",
    ["Title"] = "Total",
    ["Unit"] = "itens"
})

window:BindText(controls["statcard"].TitleLabel, "Text", "statcard.Title")

controls["chart"] = section_1:AddChart({
    ["Data"] = {
        10,
        30,
        20,
        45
    },
    ["Height"] = 180,
    ["Id"] = "chart",
    ["Title"] = "Histórico",
    ["Type"] = "Line"
})

window:BindText(controls["chart"].TitleLabel, "Text", "chart.Title")

controls["console"] = section_1:AddConsole({
    ["Height"] = 150,
    ["Id"] = "console",
    ["Title"] = "Console"
})

window:BindText(controls["console"].TitleLabel, "Text", "console.Title")

controls["image"] = section_1:AddImage({
    ["Height"] = 120,
    ["Id"] = "image",
    ["Image"] = "",
    ["Title"] = "Imagem"
})

window:BindText(controls["image"].TitleLabel, "Text", "image.Title")

controls["virtuallist"] = section_1:AddVirtualList({
    ["Height"] = 180,
    ["Id"] = "virtuallist",
    ["Items"] = {
        {
            ["Id"] = "a",
            ["Text"] = "Item A"
        },
        {
            ["Id"] = "b",
            ["Text"] = "Item B"
        }
    },
    ["Title"] = "Lista"
})

window:BindText(controls["virtuallist"].TitleLabel, "Text", "virtuallist.Title")

controls["datatable"] = section_1:AddDataTable({
    ["Columns"] = {
        {
            ["Key"] = "Name",
            ["Title"] = "Nome"
        },
        {
            ["Key"] = "Value",
            ["Title"] = "Valor"
        }
    },
    ["Height"] = 180,
    ["Id"] = "datatable",
    ["Rows"] = {
        {
            ["Id"] = "a",
            ["Name"] = "Exemplo",
            ["Value"] = 10
        }
    },
    ["Title"] = "Tabela"
})

window:BindText(controls["datatable"].TitleLabel, "Text", "datatable.Title")

controls["treeview"] = section_1:AddTreeView({
    ["Height"] = 180,
    ["Id"] = "treeview",
    ["Nodes"] = {
        {
            ["Children"] = {
                {
                    ["Id"] = "child",
                    ["Text"] = "Item"
                }
            },
            ["Id"] = "root",
            ["Text"] = "Categoria"
        }
    },
    ["Title"] = "Árvore"
})

window:BindText(controls["treeview"].TitleLabel, "Text", "treeview.Title")

controls["preview"] = section_1:AddPreview({
    ["Height"] = 180,
    ["Id"] = "preview",
    ["Image"] = "",
    ["Mode"] = "Image",
    ["Title"] = "Preview"
})

window:BindText(controls["preview"].TitleLabel, "Text", "preview.Title")

controls["stepper"] = section_1:AddStepper({
    ["Id"] = "stepper",
    ["Steps"] = {
        {
            ["Id"] = "one",
            ["Title"] = "Preparar"
        },
        {
            ["Id"] = "two",
            ["Title"] = "Concluir"
        }
    },
    ["Title"] = "Etapas"
})

window:BindText(controls["stepper"].TitleLabel, "Text", "stepper.Title")

controls["cardgrid"] = section_1:AddCardGrid({
    ["Height"] = 340,
    ["Id"] = "cardgrid",
    ["Items"] = {
        {
            ["Badges"] = {
                "Destaque"
            },
            ["Description"] = "Seu componente ou recurso",
            ["Icon"] = "diamond",
            ["Id"] = "one",
            ["Title"] = "Ferramenta A"
        },
        {
            ["Badges"] = {
                "Novo"
            },
            ["Description"] = "Personalize no painel",
            ["Icon"] = "tools",
            ["Id"] = "two",
            ["Title"] = "Ferramenta B"
        }
    },
    ["Title"] = "Catálogo"
})

window:BindText(controls["cardgrid"].TitleLabel, "Text", "cardgrid.Title")

controls["form"] = section_1:CreateForm({
    ["Fields"] = {
        {
            ["Default"] = "Gustavo",
            ["Id"] = "name",
            ["Required"] = true,
            ["TextKeys"] = {
                ["Title"] = "form/name.Title"
            },
            ["Title"] = "Nome",
            ["Type"] = "Input"
        },
        {
            ["Default"] = false,
            ["Id"] = "enabled",
            ["TextKeys"] = {
                ["Title"] = "form/enabled.Title"
            },
            ["Title"] = "Ativar",
            ["Type"] = "Toggle"
        }
    },
    ["Id"] = "form",
    ["Title"] = "Configurações"
})

if controls["form"].Header then window:BindText(controls["form"].Header.TitleLabel, "Text", "form.Title") end

controls["form/name"] = controls["form"].Fields["name"]

window:BindText(controls["form"].Fields["name"].TitleLabel, "Text", "form/name.Title")

controls["form/enabled"] = controls["form"].Fields["enabled"]

window:BindText(controls["form"].Fields["enabled"].TitleLabel, "Text", "form/enabled.Title")

controls["keybind"] = section_1:AddKeybind({
    ["Default"] = "F",
    ["Id"] = "keybind",
    ["Mode"] = "Press",
    ["Title"] = "Atalho"
})

window:BindText(controls["keybind"].TitleLabel, "Text", "keybind.Title")

local flow = window:CreateFlowGraph({
    ["Edges"] = {},
    ["Id"] = "all-components",
    ["Nodes"] = {}
}, {Controls=controls, States=states, Actions=actions})

return {Window=window, Controls=controls, States=states, Flow=flow}

end
