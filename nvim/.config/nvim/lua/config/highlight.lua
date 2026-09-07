local function set_italic_highlights()
   local groups = {
      "@keyword.function",
      "@function",
      "Function",
      "Statement",
   }

   for _, group in ipairs(groups) do
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
      if hl and (hl.fg or hl.ctermfg) then
         vim.api.nvim_set_hl(0, group, {
            italic = false,
            fg = hl.fg,
            ctermfg = hl.ctermfg
         })
      end
   end
end

vim.api.nvim_create_autocmd("ColorScheme", {
   pattern = "*",
   callback = set_italic_highlights,
})

set_italic_highlights()
