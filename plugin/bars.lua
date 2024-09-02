local bars = require("bars");

local utils = require("bars.utils");

--- Checks if a module is enabled or not
---@param config boolean | table
---@return boolean
local isEnabled = function (config)
	if not config then
		return false;
	elseif type(config) == "boolean" then
		return config;
	elseif type(config) == "table" and type(config.enable) == "boolean" then
		return config.enable
	end

	return false;
end


bars.add_hls(bars.configuration.highlight_groups);

vim.api.nvim_create_autocmd({ "ColorScheme" }, {
	callback = function ()
		bars.add_hls(bars.configuration.highlight_groups);
	end
});

--- Now, we can call the setup function at anytime
pcall(vim.api.nvim_del_autocmd, bars.autocmd);

--- TODO, Find other events to use
bars.autocmd = vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen" }, {
	callback = function (event)
		if vim.list_contains(bars.configuration.exclude_filetypes, vim.bo[event.buf].filetype) then
			for _, window in ipairs(utils.list_attached_wins(event.buf)) do
				bars.statuscolumn.disable(window);
				bars.statusline.disable(window);
			end

			return;
		end

		if vim.islist(bars.configuration.exclude_buftypes) and vim.list_contains(bars.configuration.exclude_buftypes, vim.bo[event.buf].buftype) then
			for _, window in ipairs(utils.list_attached_wins(event.buf)) do
				bars.statuscolumn.disable(window);
				bars.statusline.disable(window);
			end

			return;
		end

		for _, window in ipairs(utils.list_attached_wins(event.buf)) do
			if isEnabled(bars.configuration.statuscolumn) then
				bars.statuscolumn.init(event.buf, window);
			end

			if isEnabled(bars.configuration.statusline) then
				bars.statusline.init(event.buf, window);
			end
		end

		if isEnabled(bars.configuration.tabline) then
			bars.tabline.init();
		end
	end
})
