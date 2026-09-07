return {
   {
      "nvim-tree/nvim-web-devicons",
      lazy = true,
   },
   {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
         local lualine = require "lualine"

         local function get_hl_color(group, attr)
            local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            if hl and hl[attr] then
               return string.format("#%06x", hl[attr])
            end
            return nil
         end

         local colors = {
            bg       = get_hl_color("StatusLine", "bg") or get_hl_color("Normal", "bg") or '#202328',
            fg       = get_hl_color("StatusLine", "fg") or get_hl_color("Normal", "fg") or '#bbc2cf',
            yellow   = get_hl_color("WarningMsg", "fg") or '#ECBE7B',
            cyan     = get_hl_color("Special", "fg") or '#008080',
            darkblue = get_hl_color("CursorLine", "bg") or '#081633',
            green    = get_hl_color("String", "fg") or '#98be65',
            orange   = get_hl_color("Constant", "fg") or '#FF8800',
            violet   = get_hl_color("Statement", "fg") or '#a9a1e1',
            magenta  = get_hl_color("Type", "fg") or '#c678dd',
            blue     = get_hl_color("Function", "fg") or '#51afef',
            red      = get_hl_color("Error", "fg") or '#ec5f67',
         }

         local conditions = {
            buffer_not_empty = function()
               return vim.fn.empty(vim.fn.expand "%:t") ~= 1
            end,
            hide_in_width = function()
               return vim.fn.winwidth(0) > 80
            end,
            check_git_workspace = function()
               local filepath = vim.fn.expand "%:p:h"
               local gitdir = vim.fn.finddir(".git", filepath .. ";")
               return gitdir and #gitdir > 0 and #gitdir < #filepath
            end,
         }

         local config = {
            options = {
               component_separators = "",
               section_separators = "",
               theme = {
                  normal = { c = { fg = colors.fg, bg = colors.bg } },
                  inactive = { c = { fg = colors.fg, bg = colors.bg } },
               },
            },
            sections = {
               lualine_a = {},
               lualine_b = {},
               lualine_y = {},
               lualine_z = {},
               lualine_c = {},
               lualine_x = {},
            },
            inactive_sections = {
               lualine_a = {},
               lualine_b = {},
               lualine_y = {},
               lualine_z = {},
               lualine_c = {},
               lualine_x = {},
            },
         }

         local mode_name = {
            n = "NORMAL",
            i = "INSERT",
            v = "VISUAL",
            [""] = "V-BLOCK",
            V = "V-LINE",
            c = "COMMAND",
            no = "O-PENDING",
            s = "SELECT",
            S = "S-LINE",
            [""] = "S-BLOCK",
            ic = "INSERT",
            R = "REPLACE",
            Rv = "V-REPLACE",
            cv = "EX",
            ce = "EX",
            r = "PROMPT",
            rm = "MORE",
            ["r?"] = "CONFIRM",
            ["!"] = "SHELL",
            t = "TERMINAL",
         }
         local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            [""] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.red,
            t = colors.red,
         }



         local function ins_left(component)
            table.insert(config.sections.lualine_c, component)
         end

         local function ins_right(component)
            table.insert(config.sections.lualine_x, component)
         end

         ins_left {
            function()
               return "▊"
            end,
            color = { fg = colors.blue },
            padding = { left = 0, right = 1 },
         }

         ins_left {
            function()
               return ""
            end,
            color = function()
               return { fg = mode_color[vim.fn.mode()] }
            end,
            padding = { right = 2 },
         }

         ins_left {
            function()
               return "[" .. (mode_name[vim.fn.mode()] or "") .. "]"
            end,
            color = function()
               return { fg = mode_color[vim.fn.mode()], gui = "bold" }
            end,
            padding = { right = 1 },
         }

         ins_left {
            "filesize",
            cond = conditions.buffer_not_empty,
         }

         ins_left {
            "filename",
            cond = conditions.buffer_not_empty,
            color = { fg = colors.magenta, gui = "bold" },
         }

         ins_left { "location" }

         ins_left { "progress", color = { fg = colors.fg, gui = "bold" } }

         ins_left {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " " },
            diagnostics_color = {
               error = { fg = colors.red },
               warn = { fg = colors.yellow },
               info = { fg = colors.cyan },
            },
         }

         ins_left {
            function()
               return "%="
            end,
         }

         ins_left {
            function()
               local msg = "No Active Lsp"
               local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
               local clients = vim.lsp.get_clients({ bufnr = 0 }) -- Check only current buffer
               if next(clients) == nil then
                  return msg
               end
               for _, client in ipairs(clients) do
                  if client.name == "jdtls" then
                     return "jdtls"
                  end
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                     return client.name
                  end
               end
               return msg
            end,
            icon = " LSP:",
            color = { fg = "#ffffff", gui = "bold" },
         }

         ins_right {
            "o:encoding",
            fmt = string.upper,
            cond = conditions.hide_in_width,
            color = { fg = colors.green, gui = "bold" },
         }

         ins_right {
            "fileformat",
            fmt = string.upper,
            icons_enabled = false,
            color = { fg = colors.green, gui = "bold" },
         }

         ins_right {
            "branch",
            icon = "",
            color = { fg = colors.violet, gui = "bold" },
         }

         ins_right {
            "diff",
            symbols = { added = " ", modified = "󰝤 ", removed = " " },
            diff_color = {
               added = { fg = colors.green },
               modified = { fg = colors.orange },
               removed = { fg = colors.red },
            },
            cond = conditions.hide_in_width,
         }

         ins_right {
            function()
               return "▊"
            end,
            color = { fg = colors.blue },
            padding = { left = 1 },
         }

         lualine.setup(config)

         vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
               package.loaded["lualine"] = nil
               require("lualine").setup(config)
            end,
         })
      end,
   },
}
