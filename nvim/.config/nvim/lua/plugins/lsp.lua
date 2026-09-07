return {
   {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
         vim.diagnostic.config({
            virtual_text = false,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            signs = false
         })

         vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#f38ba8", bold = true })
         vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#f9e2af", bold = true })
         vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#89b4fa", bold = true })
         vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#a6e3a1", bold = true })

         vim.lsp.config('qmlls', {
            cmd = { 'qmlls6' },
         })
      end,
   },

   {
      "mason-org/mason.nvim",
      opts = {
         ui = {
            icons = {
               package_installed = "✓",
               package_pending = "➜",
               package_uninstalled = "✗",
            },
         },
      },
   },
   {
      "mason-org/mason-lspconfig.nvim",
      dependencies = {
         "mason-org/mason.nvim",
         "neovim/nvim-lspconfig",
         "saghen/blink.cmp",
      },
      opts = {
         ensure_installed = {
            "lua_ls", "pyright", "html", "ts_ls",
            "gopls", "kotlin_language_server", "angularls", "jdtls", "clangd", "qmlls"
         },
         automatic_enable = {
            exclude = {
               'jdtls'
            }
         }
      }
   },
   {
      "saghen/blink.cmp",
      opts = {
         enabled = function()
            return not vim.tbl_contains({ "NvimTree", "TelescopePrompt" }, vim.bo.filetype)
                and vim.bo.buftype ~= "prompt"
         end,
      },
   },


   { 'mfussenegger/nvim-jdtls' }
}
