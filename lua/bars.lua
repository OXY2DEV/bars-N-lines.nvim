local bars = {};

bars.statuscolumn = require("bars.statuscolumn");
bars.statuslines = require("bars.statusline");
bars.tabline = require("bars.tabline");

_G.bars_n_lines = require("bars.clicks");

local utils = require("bars.utils");

bars.configuration = {
	exclude_filetypes = { "help" },
	exclude_buftypes = { "nofile" },

	statuscolumn = true,
	statusline = true,
	tabline = true
};


bars.setup = function (config_table)
	bars.configuration = vim.tbl_extend("force", bars.configuration, config_table or {});

	vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
		callback = function (event)
			if vim.list_contains(bars.configuration.exclude_filetypes, vim.bo[event.buf].filetype) then
				for _, window in ipairs(utils.list_attached_wins(event.buf)) do
					bars.statuscolumn.disable(window);
					bars.statuslines.disable(window);
				end
				return;
			end

			if vim.islist(bars.configuration.exclude_buftypes) and vim.list_contains(bars.configuration.exclude_buftypes, vim.bo[event.buf].buftype) then
				for _, window in ipairs(utils.list_attached_wins(event.buf)) do
					bars.statuscolumn.disable(window);
					bars.statuslines.disable(window);
				end
				return;
			end

			for _, window in ipairs(utils.list_attached_wins(event.buf)) do
				bars.statuscolumn.init(event.buf, window, bars.configuration);
				bars.statuslines.init(event.buf, window, bars.configuration);
			end

			bars.tabline.init()
		end
	})

end

return bars;
