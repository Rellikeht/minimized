local success, val = pcall(function() return CODE_LOADED end)
if success and val then return end

-- helpers {{{

local function commandRep(fn, arg)
  return function() for _ = 1, vim.v.count1 do fn(arg) end end
end

---@diagnostic disable-next-line: unused-local, unused-function
local function copy_table(tbl)
  local result = {}
  for k, v in pairs(tbl) do result[k] = v end
  return result
end

--  }}}

-- plugins {{{

PCKR.add(
  { -- {{{

    {
      "jpalardy/vim-slime",   --  {{{

      config_pre = function() --  {{{
        vim.g.slime_paste_file = vim.fn.tempname()
        vim.g.slime_dont_ask_default = true
        vim.g.slime_bracketed_paste = true
        vim.g.slime_no_mappings = true
      end,                --  }}}

      config = function() --  {{{
        vim.keymap.set(
          "n", "gs:", ":<C-u>SlimeConfigAll<CR>", { noremap = true }
        )
        vim.keymap.set(
          "n", "gss", "<Plug>SlimeLineSend", { noremap = true }
        )
        vim.keymap.set(
          "n", "gs", "<Plug>SlimeMotionSend", { noremap = true }
        )
        vim.keymap.set(
          "n", "gsi", "<Plug>SlimeParagraphSend", { noremap = true }
        )
        vim.keymap.set(
          "x", "gsi", "<Plug>SlimeRegionSend", { noremap = true }
        )
        vim.keymap.set("n", "gs;", ":SlimeSend<CR>", { noremap = true })
        vim.keymap.set("x", "gs;", ":SlimeSend<CR>", { noremap = true })

        vim.api.nvim_create_user_command(
          "SlimeConfigAll", function(_)
            vim.cmd.SlimeConfig()
            vim.g.slime_default_config = vim.b.slime_config
          end, { nargs = 0 }
        )

        function Slime_setup_tmux()
          local function slime_tmux_uniform_config()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              local has, _ = pcall(
                vim.api.nvim_buf_get_var, bufnr, "slime_config"
              )
              if has then
                vim.api.nvim_buf_set_var(
                  bufnr, "slime_config", vim.g.slime_default_config
                )
              end
            end
          end

          vim.api.nvim_create_user_command(
            "SlimeTmuxPane", function(opts)
              vim.g.slime_default_config = {
                socket_name = vim.g.slime_default_config.socket_name,
                target_pane = opts.fargs[1],
              }
              slime_tmux_uniform_config()
            end, { nargs = 1 }
          )
          vim.api.nvim_create_user_command(
            "SlimeTmuxSocket", function(opts)
              vim.g.slime_default_config = {
                socket_name = opts.fargs[1],
                target_pane = vim.g.slime_default_config.target_pane,
              }
              slime_tmux_uniform_config()
            end, { nargs = 1 }
          )

          vim.g.slime_target = "tmux"
          vim.g.slime_default_config = {
            socket_name = vim.fn.get(vim.fn.split(vim.env.TMUX, ","), 0),
            target_pane = "{top-right}",
          }
        end

        function Slime_setup_nvim()
          vim.g.slime_target = "neovim"
          vim.g.slime_suggest_default = false
          vim.g.slime_menu_config = false
          vim.g.slime_input_pid = false

          -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/targets/neovim.md
          vim.g.slime_get_jobid = function()
            -- iterate over all buffers to find the first terminal with a valid job
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ==
                  "terminal" then
                local chan = vim.api.nvim_get_option_value(
                  "channel", { buf = bufnr }
                )
                if chan and chan > 0 then return chan end
              end
            end
            return nil
          end

          pcall(vim.api.nvim_del_user_command, "SlimeTmuxPane")
          pcall(vim.api.nvim_del_user_command, "SlimeTmuxSocket")
        end

        -- There may be repl running in tmux that
        -- should be reused so this is global even with
        -- gui running
        if vim.env.TMUX then
          Slime_setup_tmux()
        else
          Slime_setup_nvim()
        end
      end --  }}}
    },    --  }}}

    {
      "mhinz/vim-signify", --  {{{
      config = function()
        vim.keymap.set("n", "+", "<Plug>(signify-next-hunk)", { noremap = true })
        vim.keymap.set("n", "-", "<Plug>(signify-prev-hunk)", { noremap = true })
        vim.keymap.set("n", "<Leader>gt", vim.cmd.SignifyToggle, { noremap = true })
        vim.keymap.set("n", "<Leader>gs", vim.cmd.SignifyHunkDiff, { noremap = true })
        vim.keymap.set("n", "<Leader>gS", vim.cmd.SignifyDiff, { noremap = true })
        vim.keymap.set("n", "<Leader>gu", vim.cmd.SignifyHunkUndo, { noremap = true })
        vim.keymap.set("n", "<Leader>gR", vim.cmd.SignifyRefresh, { noremap = true })
        vim.keymap.set("n", "<Leader>gh", vim.cmd.SignifyToggleHighlight, { noremap = true })

        vim.api.nvim_create_autocmd(
          "User", {
            pattern = "SignifyHunk",
            callback = function()
              local h = vim.fn["sy#util#get_hunk_stats"]()
              if vim.fn.empty(h) == 0 then
                print("[Hunk " .. h.current_hunk .. "/" .. h.total_hunks .. "]")
              end
            end
          }
        )
      end
    }, --  }}}

    {
      "norcalli/nvim-colorizer.lua", --  {{{
      config = function()
        local color_css_conf = {
          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css = true,
          -- Enable all CSS *functions*: rgb_fn, hsl_fn
          css_fn = true,
        }
        local color_vim_conf = { names = true }

        require("colorizer").setup( --  {{{
          {
            "*",
            html = color_css_conf,
            css = color_css_conf,
            js = color_css_conf,
            ts = color_css_conf,
            vim = color_vim_conf,
            lua = color_vim_conf,
          }, {
            -- #RGB hex codes
            RGB = true,
            -- #RRGGBB hex codes
            RRGGBB = true,
            -- "Name" codes like Blue
            names = false,
            -- #RRGGBBAA hex codes
            RRGGBBAA = true,
            -- CSS rgb() and rgba() functions
            rgb_fn = true,
            -- CSS hsl() and hsla() functions
            hsl_fn = true,
            -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
            css = false,
            -- Enable all CSS *functions*: rgb_fn, hsl_fn
            css_fn = false,
            -- Set the display mode.
            -- Available modes: foreground, background
            mode = "background",
          }
        ) --  }}}
      end,
    },    --  }}}

    {
      "neovim/nvim-lspconfig", --  {{{
      requires = {},
      config = function()
        if vim.fn.has("nvim-0.10") == 0 then return end
        if vim.fn.has("nvim-0.11") == 1 then -- {{{
          -- for backwards compatibility
          function NvimDiagPrev()
            vim.diagnostic.jump({ count = -1, float = true })
          end

          function NvimDiagNext()
            vim.diagnostic.jump({ count = 1, float = true })
          end
        else
          function NvimDiagNext()
            ---@diagnostic disable-next-line: deprecated
            vim.diagnostic.goto_next()
          end

          function NvimDiagPrev()
            ---@diagnostic disable-next-line: deprecated
            vim.diagnostic.goto_prev()
          end
        end --  }}}

        local lspconfig = require("lspconfig")
        lspconfig.util.default_config = vim.tbl_extend(
          "force", lspconfig.util.default_config,
          { message_level = nil }
        )

        -- commands {{{

        vim.keymap
            .set("n", "<Leader>dqi", ":<C-u>LspInfo<CR>", {})
        vim.keymap
            .set("n", "<Leader>dql", ":<C-u>LspLog<CR>", {})
        vim.keymap.set(
          "n", "<Leader>dqr", ":<C-u>LspRestart<CR>", {}
        )
        vim.keymap.set(
          "n", "<Leader>de", vim.diagnostic.open_float,
          { desc = "show diagnostics" }
        )

        vim.keymap.set(
          "n", "<Leader>dp", commandRep(
            NvimDiagPrev, {
              severity = {
                vim.diagnostic.severity.ERROR,
                vim.diagnostic.severity.WARN,
              },
            }
          ), { desc = "[N] prev error or warning" }
        )
        vim.keymap.set(
          "n", "<Leader>dn", commandRep(
            NvimDiagNext, {
              severity = {
                vim.diagnostic.severity.ERROR,
                vim.diagnostic.severity.WARN,
              },
            }
          ), { desc = "[N] next error or warning" }
        )

        vim.keymap.set(
          "n", "<Leader>dP", commandRep(
            NvimDiagPrev,
            { severity = { vim.diagnostic.severity.ERROR } }
          ), { desc = "[N] prev error" }
        )
        vim.keymap.set(
          "n", "<Leader>dN", commandRep(
            NvimDiagNext,
            { severity = { vim.diagnostic.severity.ERROR } }
          ), { desc = "[N] next error" }
        )

        vim.keymap.set(
          "n", "<Leader>dk", commandRep(
            NvimDiagPrev, {
              severity = {
                vim.diagnostic.severity.INFO,
                vim.diagnostic.severity.HINT,
              },
            }
          ), { desc = "[N] prev hint/info" }
        )
        vim.keymap.set(
          "n", "<Leader>dj", commandRep(
            NvimDiagNext, {
              severity = {
                vim.diagnostic.severity.INFO,
                vim.diagnostic.severity.HINT,
              },
            }
          ), { desc = "[N] next hint/info" }
        )

        -- }}}

        vim.api.nvim_create_autocmd( -- {{{
          "LspAttach", {
            group = vim.api
                .nvim_create_augroup("UserLspConfig", {}),
            callback = function(args)
              -- helpers {{{

              local bufnr = args.buf
              local client = vim.lsp.get_client_by_id(
                args.data.client_id
              )

              -- }}}

              -- insert mode {{{

              if client and
                  client.server_capabilities.completionProvider then
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
              end
              if client and
                  client.server_capabilities.definitionProvider then
                vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
              end

              --  }}}

              -- navigation {{{

              vim.keymap.set(
                "n", "<Leader>dd", vim.lsp.buf.definition,
                { desc = "go to definition", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dD", vim.lsp.buf.declaration,
                { desc = "go to declaration", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>di", vim.lsp.buf.implementation,
                { desc = "go to implementation", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dt", vim.lsp.buf.type_definition,
                { desc = "go to type definition", buffer = bufnr }
              )

              --  }}}

              -- info {{{

              vim.keymap.set(
                "n", "<Leader>ds", vim.lsp.buf.signature_help,
                { desc = "signature help", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dh", vim.lsp.buf.hover, {
                  desc = "display hover information about the symbol under the cursor",
                  buffer = bufnr,
                }
              )

              vim.keymap.set(
                "n", "<Leader>dlr", vim.lsp.buf.references, {
                  desc = "populate quickfix list with references",
                  buffer = bufnr,
                }
              )

              -- }}}

              -- actions {{{

              vim.keymap.set(
                "n", "<Leader>dr", vim.lsp.buf.rename, {
                  desc = "rename symbol under cursor",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>df", function()
                  vim.lsp.buf.format({ async = false })
                  vim.cmd.norm("zv")
                end, {
                  desc = "format buffer using lsp",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>da", vim.lsp.buf.code_action,
                { desc = "execute code action", buffer = bufnr }
              )

              -- }}}
            end,
          }
        ) -- }}}
      end,
    },

    {
      "Rellikeht/nvim-lsp-config",
      requires = {
        "neovim/nvim-lspconfig",
        "Rellikeht/lazy-utils",
        "mfussenegger/nvim-jdtls",
        "p00f/clangd_extensions.nvim",
      },
    }, --  }}}

    -- TODO C rainbow ?
    -- TODO formatters
    -- TODO snippets ?
  }
) -- }}}

-- post setup {{{

local lazy_utils = require("lazy_utils")

-- treesitter {{{

local tsinstall = require("nvim-treesitter.install")

do
  -- This is because FileType is not triggered on first file
  -- sometimes
  -- TODO is this proper solution
  vim.cmd.filetype("detect")
  lazy_utils.load_on_startup(
    function() vim.cmd.filetype("detect") end
  )
end

local function lazy_ts_ensure_installed(name, filetypes)
  if filetypes == nil then filetypes = name end
  lazy_utils.load_on_filetypes(
    filetypes, function()
      -- TODO B failing silently
      vim.cmd.TSUpdate(name)
    end
  )
end

for key, name in pairs(
  {
    [{ "sh", "bash", "zsh" }] = "bash",
    "python",
    "powershell",
    "go",
    "rust",
    "cpp",
    "c",
    "html",
    "css",
    "java",
    "elixir",
    "julia",
    "ocaml",
    "haskell",
    "typst",
    "latex",
  }
) do
  local filetypes = nil
  if type(key) == "string" or type(key) == "table" then
    filetypes = key
  end
  lazy_ts_ensure_installed(name, filetypes)
end

--  }}}

--  }}}

--  }}}

if vim.fn.has("win32") == 1 then -- {{{
  tsinstall.compilers = { "zig", "cl", "cc", "gcc", "clang" }

  -- }}}
else -- {{{

end  -- }}}

CODE_LOADED = true
