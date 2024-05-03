local Utils = require("utils")
local map = Utils.safe_keymap_set




-- ┣━━━━━━━━━━━━━━━━━━━━━━━┫ General Mappings ┣━━━━━━━━━━━━━━━━━━━━━━━┫

map("n", "<leader>w", "<cmd>w!<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q!<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })
map("n", "<leader><Tab>", "<c-6>", { desc = "Switch buffer" })


-- ┣━━━━━━━━━━━━━━━━━━━┫ Better Window Navigation ┣━━━━━━━━━━━━━━━━━━━┫

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })



-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫ Indentation ┣━━━━━━━━━━━━━━━━━━━━━━━┫

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "p", '"_dP')


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━┫ Resize Windows ┣━━━━━━━━━━━━━━━━━━━━━━━━┫

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })


-- ┣━━━━━━━━━━━━━━━━━━┫ Move Text Up/Down By Line ┣━━━━━━━━━━━━━━━━┫



-- Normal --
map("n", "<A-S-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-S-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
-- Block --
map("x", "<A-S-j>", ":move '>+1<CR>gv-gv", { desc = "Move down" })
map("x", "<A-S-k>", ":move '<-2<CR>gv-gv", { desc = "Move up" })
-- Insert --
map("i", "<A-S-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-S-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- Visual --
map("v", "<A-S-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-S-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━┫ Clear Highlights ┣━━━━━━━━━━━━━━━━━━━━━━━┫

map("n", ";", ":noh<CR>", { desc = "Clear search" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Inspect ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫

map("n", "<F2>", "<cmd>Inspect<CR>", { desc = "Inspect highlight fallback" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━┫ Split Windows ┣━━━━━━━━━━━━━━━━━━━━━━┫

map("n", "<leader>\\", ":vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>/", ":split<CR>", { desc = "Split window horizontally" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫ Swap Window ┣━━━━━━━━━━━━━━━━━━━━━━━┫

map("n", "<A-o>", "<C-w>r", { desc = "Rotate window" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Select All ┣━━━━━━━━━━━━━━━━━━━━━━━━━━┫

map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" }) 


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫ Fuzzy Search ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫

vim.keymap.set("n", "<C-f>", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes"))
end, { desc = "[/] Fuzzily search in current buffer]" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━┫ Save Function ┣━━━━━━━━━━━━━━━━━━━━━━┫

map("v", "<C-s>", "<esc><cmd>wa!<cr>", { desc = "Save file" })
map("i", "<C-s>", "<esc><cmd>wa!<cr>", { desc = "Save file" })
map("n", "<C-s>", "<esc><cmd>wa!<cr>", { desc = "Save file" })
map("x", "<C-s>", "<esc><cmd>wa!<cr>", { desc = "Save file" })


-- ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫ Comment Bars ┣━━━━━━━━━━━━━━━━━━━━━━━━━┫

-- With Titles --
map("v", "<M-->", "<cmd>lua require('comment-box').lcline(11)<cr>", { desc = "comment line" })
map("i", "<M-->", "<cmd>lua require('comment-box').lcline(11)<cr>", { desc = "comment line" })
map("n", "<M-->", "<cmd>lua require('comment-box').lcline(11)<cr>", { desc = "comment line" })
-- No Titles --
map("v", "<C-M-->", "<cmd>lua require('comment-box').line(11)<cr>", { desc = "alternative comment line" })
map("i", "<C-M-->", "<cmd>lua require('comment-box').line(11)<cr>", { desc = "alternative comment line" })
map("n", "<C-M-->", "<cmd>lua require('comment-box').line(11)<cr>", { desc = "alternative comment line" })


