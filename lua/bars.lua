local bars = {};
local column = require("bars/column");
local lines = require("bars/lines");
local tabs = require("bars/tabs");

_G.bars_n_lines = require("bars/clicks");

local utils = require("bars/utils");

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
					column.disable(window);
					lines.disable(window);
				end
				return;
			end

			if vim.islist(bars.configuration.exclude_buftypes) and vim.list_contains(bars.configuration.exclude_buftypes, vim.bo[event.buf].buftype) then
				for _, window in ipairs(utils.list_attached_wins(event.buf)) do
					column.disable(window);
					lines.disable(window);
				end
				return;
			end

			for _, window in ipairs(utils.list_attached_wins(event.buf)) do
				column.init(event.buf, window, bars.configuration);
				lines.init(event.buf, window, bars.configuration);
			end

			tabs.init()
		end
	})

end

return bars;
