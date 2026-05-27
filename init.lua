-- Esta configuración sirve para NeoVim 0.12 o mayor

vim.o.cursorline = true
vim.o.relativenumber = true -- Mostrar líneas relativas a la actual
vim.o.number = true  -- Mostrar número
vim.o.tabstop = 4    -- cuántos espacios valle un Tab 
vim.o.shiftwidth = 4 -- cuántos espacios al usar comandos de indent
vim.o.ignorecase = true -- En búsqueda ignorar mayúsuclas
vim.o.smartcase = true  -- Buscar mayúsuculas solo si hay en la búsqueda
-- vim.o.wrap = false  -- evitar corte de línea cuando es muy larga
vim.o.hlsearch = true -- Descativar resaltado permanente en la búsqueda
-- vim.o.signcolumn = 'yes'
vim.opt.updatetime = 300 -- Actualizado más rápido (deafult 4000, sirve para mostrar error de línea más rápido)


-- Espacio como tecla lider
vim.g.mapleader = vim.keycode('<Space>')

-- Interacción con clipboard
vim.keymap.set({'n', 'x'}, 'gy', '"+y', {desc = 'Copiar en el portapapeles'})
vim.keymap.set({'n', 'x'}, 'gp', '"+p', {desc = 'Pegar desde el portapapeles'})

vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', {desc = 'Guardar archivo'})
vim.keymap.set('n', '<leader>q', '<cmd>quitall<cr>', {desc = 'Salir de vim'})

vim.keymap.set('n', 'K', '5k', {desc = 'Moverse 5 lineas hacia arriba'})
vim.keymap.set('n', 'J', '5j', {desc = 'Moverse 5 lineas hacia abajo'})
vim.keymap.set('n', ';', 'A;<ESC>', {desc = 'Poner ";" al final de la línea'})

-- Moverse entre buffers
vim.keymap.set('n', '<S-h>', ':bprevious<cr>', {desc = 'Moverse al buffer anterior'})
vim.keymap.set('n', '<S-l>', ':bnext<cr>', {desc = 'Moverse al siguiente buffer'})
vim.keymap.set('n', '<S-w>', ':bd<cr>', {desc = 'Cerrar buffer actual'})

vim.cmd.colorscheme('retrobox')


vim.pack.add({
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/nvim-mini/mini.nvim',
	'https://github.com/mrjones2014/smart-splits.nvim'
})

				
require('smart-splits').setup({})
require('mini.pairs').setup({})
require('mini.snippets').setup({})
require('mini.surround').setup({})
require('mini.tabline').setup({})


------------- Completar código ----------------
require('mini.completion').setup({})

vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<Tab>'
end, { expr = true })

vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<S-Tab>'
end, { expr = true })

vim.keymap.set({ 'i', 's' }, '<C-l>', function()
  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-h>', function()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  end
end, { silent = true })

-----------------------------------------------

require('mini.files').setup({})
vim.keymap.set('n', '<leader>nt', '<cmd>lua MiniFiles.open()<cr>', {desc = 'File explorer'})

require('mini.pick').setup({})
vim.keymap.set('n', '<leader><space>', '<cmd>Pick buffers<cr>', {desc = 'Search open files'})
-- vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', {desc = 'Search all files'})
-- vim.keymap.set('n', '<leader>fh', '<cmd>Pick help<cr>', {desc = 'Search help tags'})

-- List of compatible language servers is here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
vim.lsp.enable({'pyright', 'clangd', 'lua_ls'})
vim.lsp.config('clangd', {
  cmd = { "clangd", "--query-driver=C:/Users/sila_/gcc/bin/gcc.exe" }
})
vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			diagnostics = {
				-- Reconoce la variable global 'vim' para que no tire advertencias
				globals = {'vim'},
			},
		},
	},
})

-- Ver mensaje de error al estar por sobre la línea del error
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})



-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)
-- moving between splits
vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)




local function CompileCode()
	local extension = vim.fn.expand("%:e")
	local file = vim.fn.expand("%")
	local filename = vim.fn.expand("%:t:r")

	-- Guardar archivo
	vim.cmd('write')

	-- Abrir terminal abajo
	vim.cmd("belowright split")
	vim.cmd("resize 10")

	local commands = {
		py = string.format('python3 %s', file),
		f90 = string.format(
			'gfortran -Wall %s -o %s && ./%s',
			file,
			filename,
			filename
		),
		c = string.format(
			'gcc -Wall %s -lm -o %s && ./%s',
			file,
			filename,
			filename
		),
		cpp = string.format(
			'g++ -Wall %s -o %s && ./%s',
			file,
			filename,
			filename
		),

	}

	local cmd = commands[extension]
	if cmd then
		vim.cmd('terminal ' .. cmd)
	else
		vim.notify(
			'No hay comando configurado para *.' .. extension,
			vim.log.levels.WARN
		)
	end

end

vim.api.nvim_create_user_command("CompileCode", CompileCode, {})

vim.keymap.set('n', '<leader>f', CompileCode, {desc = "Compilar/Ejecutar código"})
vim.cmd([[autocmd TermOpen * startinsert]])
-- vim.o.shell = 'powershell.exe'

