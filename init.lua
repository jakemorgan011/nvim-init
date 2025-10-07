require("jake.core.keymaps")

vim.g.maplocalleader = ","

-- line numbers
vim.wo.relativenumber = true
vim.wo.number = true

-- tabs
local opt = vim.opt
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrap
opt.wrap = false

-- searching
opt.ignorecase = true
opt.smartcase = true

-- backspace key
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- better colors
opt.termguicolors = true

-- ====================
-- PACKER SETUP
-- ====================
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- autocommand that reloads neovim when this file is saved
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]])

local status, packer = pcall(require, "packer")
if not status then
  return
end

-- ====================
-- PLUGINS
-- ====================
packer.startup(function(use)
  use("wbthomason/packer.nvim")
  use("nvim-lua/plenary.nvim")
  use("christoomey/vim-tmux-navigator")
  use("szw/vim-maximizer")
  use("tpope/vim-surround")
  use("inkarkat/vim-ReplaceWithRegister")

  -- commenting
  use("numToStr/Comment.nvim")

  -- file explorer
  use("nvim-tree/nvim-tree.lua")
  use("nvim-tree/nvim-web-devicons") -- optional, for file icons

  -- statusline
  use("nvim-lualine/lualine.nvim")

  -- fuzzy finder
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" })

  -- autocompletion
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-nvim-lsp")

  -- snippets
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use("rafamadriz/friendly-snippets")

  -- LSP
  use("neovim/nvim-lspconfig")

  -- formatting & linting
  use("jose-elias-alvarez/null-ls.nvim")

  -- treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })

  -- git
  use("lewis6991/gitsigns.nvim")

  -- language support
  use("tikhomirov/vim-glsl")
  use("wilsaj/chuck.vim")
  use("tidalcycles/vim-tidal")
  
  -- colorscheme
  use("rktjmp/lush.nvim")
  use({
    "uloco/bluloco.nvim",
    config = function()
      vim.o.background = "light"
      vim.cmd("colorscheme bluloco")
      vim.api.nvim_set_hl(0,"String",{fg = "#76CC35"}) 
    end,
  })

  if packer_bootstrap then
    require("packer").sync()
  end
end)

-- ====================
-- PLUGIN CONFIGURATIONS
-- ====================

-- Comment.nvim
require("Comment").setup()

-- nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

-- keymaps for nvim-tree
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- lualine
require("lualine").setup({
  options = {
    theme = "auto",
    component_separators = "|",
    section_separators = "",
  },
})

-- telescope
local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      },
    },
  },
})

telescope.load_extension("fzf")

-- telescope keymaps
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })

-- JUCE/CMake build keymaps
-- First time setup: run ,bg to generate the build
vim.keymap.set("n", "<leader>bg", ":!cmake -B build -DCMAKE_BUILD_TYPE=Debug<CR>", { desc = "Generate CMake build" })
vim.keymap.set("n", "<leader>bb", ":!cmake --build build --config Debug<CR>", { desc = "Build project" })
vim.keymap.set("n", "<leader>bc", ":!rm -rf build && cmake -B build -DCMAKE_BUILD_TYPE=Debug<CR>", { desc = "Clean and regenerate" })
vim.keymap.set("n", "<leader>br", ":!cmake --build build --config Debug && open build/*_artefacts/Debug/Standalone/*.app<CR>", { desc = "Build and run" })

-- treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { 
    "c", 
    "cpp", 
    "rust", 
    "python", 
    "javascript", 
    "typescript", 
    "html", 
    "css",
    "lua", 
    "vim", 
    "vimdoc",
    "glsl"
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

-- luasnip
require("luasnip.loaders.from_vscode").lazy_load()

-- nvim-cmp (autocompletion)
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- LSP configuration
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local capabilities = cmp_nvim_lsp.default_capabilities()

-- C/C++ LSP (clangd) - for JUCE development
lspconfig.clangd.setup({
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
  },
})

-- Uncomment and configure other LSPs as you install them:
-- For lua: install lua-language-server from https://github.com/LuaLS/lua-language-server
-- lspconfig.lua_ls.setup({
--   capabilities = capabilities,
--   settings = {
--     Lua = {
--       diagnostics = {
--         globals = { "vim" },
--       },
--       workspace = {
--         library = {
--           [vim.fn.expand("$VIMRUNTIME/lua")] = true,
--           [vim.fn.stdpath("config") .. "/lua"] = true,
--         },
--       },
--     },
--   },
-- })

-- Add other LSPs as you install them:
-- lspconfig.rust_analyzer.setup({ capabilities = capabilities })  -- for Rust
-- lspconfig.pyright.setup({ capabilities = capabilities })  -- for Python
-- lspconfig.tsserver.setup({ capabilities = capabilities })  -- for JS/TS

-- LSP keymaps (these activate when an LSP attaches to a buffer)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- gitsigns
require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
})

-- null-ls (formatting and linting)
-- Uncomment formatters as you install them on your system
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    -- Uncomment after installing: npm install -g prettier
    -- null_ls.builtins.formatting.prettier,
    
    -- Uncomment after installing: cargo install stylua (or via package manager)
    -- null_ls.builtins.formatting.stylua,
    
    -- Uncomment after installing: pip install black
    -- null_ls.builtins.formatting.black,
  },
})

-- Format on save (only works if you have formatters configured above)
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })
