--  {{{

local tsinstall = require('nvim-treesitter.install')

--  }}}

-- TODO treesitters
-- TODO lsp
-- TODO formatters

if vim.fn.has("win32") == 1 then -- {{{
  tsinstall.compilers = { "zig", "cl", "cc", "gcc", "clang" }
  -- }}}
else -- {{{

end -- }}}
