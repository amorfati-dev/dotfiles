vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- System clipboard, explicitly. Plain yy/dd stay in vim's registers so
-- deleting a line never clobbers what you copied from the browser.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Paste from macOS. Capital P because <leader>p* is the telescope/netrw
-- prefix (pf, ps, pv) and a bare <leader>p would stall all three.
vim.keymap.set("n", "<leader>P", [["+p]])

-- Paste over a selection without the deleted text stealing your register.
vim.keymap.set("x", "<leader>p", [["_dP]])
