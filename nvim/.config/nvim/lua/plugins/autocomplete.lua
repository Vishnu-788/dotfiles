return {
   "saghen/blink.cmp",
   version = "*",
   event = { "InsertEnter" },
   opts = {
      keymap = {
         preset      = "default",
         ["<Tab>"]   = { "select_next", "fallback" },
         ["<S-Tab>"] = { "select_prev", "fallback" },
         ["<CR>"]    = { "accept", "fallback" },
         ["<C-b>"]   = { "scroll_documentation_up", "fallback" },
         ["<C-f>"]   = { "scroll_documentation_down", "fallback" },
         ["<C-e>"]   = { "cancel", "fallback" },
      },

      appearance = {
         use_nvim_cmp_as_default = false,
         nerd_font_variant = "mono",
         kind_icons = {
            Text          = "󰉿",
            Method        = "󰆧",
            Function      = "󰊕",
            Constructor   = "",
            Field         = "󰜢",
            Variable      = "󰀫",
            Class         = "󰠱",
            Interface     = "",
            Module        = "",
            Property      = "󰜢",
            Unit          = "󰑭",
            Value         = "󰎠",
            Enum          = "",
            Keyword       = "󰌋",
            Snippet       = "",
            Color         = "󰏘",
            File          = "󰈙",
            Reference     = "󰈇",
            Folder        = "󰉋",
            EnumMember    = "",
            Constant      = "󰏿",
            Struct        = "󰙅",
            Event         = "",
            Operator      = "󰆕",
            TypeParameter = "",
         },
      },

      sources = {
         default = { "lsp", "path", "snippets", "buffer" },
         providers = {
            lsp      = { name = "LSP", },
            path     = { name = "Path", },
            snippets = { name = "Snippet", },
            buffer   = { name = "Buffer", },
         },
      },

      completion = {
         documentation = {
            auto_show = true,
            auto_show_delay_ms = 100,
            window = {
               border       = "rounded",
               min_width    = 50,
               max_width    = 70,
               max_height   = 20,
               winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
               scrollbar    = true,
            },
         },

         ghost_text = { enabled = true },

         menu = {
            border = "rounded",
            min_width = 40,
            max_height = 20,

            direction_priority = { "s", "n" },
            winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection",
            draw = {
               gap = 3,
               columns = {
                  { "kind_icon",  gap = 1 },
                  { "label",      "label_description", gap = 2 },
                  { "kind",       gap = 2 },
                  { "source_name" },
               },
               components = {
                  kind_icon = {
                     ellipsis  = false,
                     text      = function(ctx) return " " .. ctx.kind_icon .. " " end,
                     highlight = function(ctx) return ctx.kind_hl end,
                  },
                  label = {
                     width     = { min = 20, max = 30 },
                     text      = function(ctx) return ctx.label end,
                     highlight = "BlinkCmpLabel",
                  },
                  label_description = {
                     width     = { max = 20 },
                     text      = function(ctx) return ctx.label_description end,
                     highlight = "BlinkCmpLabelDescription",
                  },
                  kind = {
                     width     = { min = 10 },
                     text      = function(ctx) return "(" .. ctx.kind .. ")" end,
                     highlight = "BlinkCmpKind",
                  },
                  source_name = {
                     text      = function(ctx) return "[" .. ctx.source_name .. "]" end,
                     highlight = "BlinkCmpSource",
                  },
               },
               treesitter = { "lsp" },
            },
         },
      },

      signature = {
         enabled = true,
         window = {
            border = "rounded",
            winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
         },
      },
   },

   config = function(_, opts)
      require("blink.cmp").setup(opts)

      vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { link = "PmenuSel" })

      vim.api.nvim_set_hl(0, "BlinkCmpDoc", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "FloatBorder" })

      vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { link = "FloatBorder" })

      vim.api.nvim_set_hl(0, "BlinkCmpLabel", { link = "Normal" })
      vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", { link = "Comment" })
      vim.api.nvim_set_hl(0, "BlinkCmpKind", { link = "Special" })
      vim.api.nvim_set_hl(0, "BlinkCmpSource", { link = "NonText" })
   end,
}
