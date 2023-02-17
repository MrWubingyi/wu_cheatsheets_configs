vim.o.syntax = "enable"
vim.o.relativenumber = true
vim.o.number = true
vim.o.wrap = true
vim.o.ruler = true
vim.o.incsearch = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true<Paste>
vim.g.mapleader = " "
vim.api.nvim_set_keymap("n", "<leader>ee", ":vs $MYVIMRC<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<leader>ss", ":source $MYVIMRC<CR>:q<CR>", {silent = true, noremap = true})
