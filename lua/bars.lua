local bars = {};
_G.bars_n_lines = require("bars/clicks");

local utils = require("bars/utils");

bars.configuration = {
	exclude_filetypes = {},
	exclude_buftypes = { "nofile" },

	statuscolumn = true,
	statusline = true,
	tabline = true
};


bars.setup = function (config_table)
	bars.configuration = vim.tbl_extend("force", bars.configuration, config_table or {});

	vim.api.nvim_create_autocmd({ "BufWinEnter"}, {
		callback = function (event)
			if vim.islist(bars.configuration.exclude_filetypes) and vim.list_contains(bars.configuration.exclude_filetypes, vim.bo[event.buf].filetype) then
				return;
			end

			if vim.islist(bars.configuration.exclude_buftypes) and vim.list_contains(bars.configuration.exclude_buftypes, vim.bo[event.buf].buftype) then
				return;
			end

			for _, window in ipairs(utils.list_attached_wins(event.buf)) do
				vim.wo[window].relativenumber = true; -- Redraw on cursor

				vim.wo[window].foldcolumn = "0";
				vim.wo[window].signcolumn = "no";

				vim.wo[window].numberwidth = 1; -- Prevent Click related bug

				vim.wo[window].statuscolumn = "%!v:lua.require('bars.column').draw(" .. window .. "," .. event.buf .. ")"
			end
		end
	})

end

return bars;
