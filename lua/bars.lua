local bars = {};

---@type bars.storage
_G.__bars = {
	tabline = {
		__func_id = 1,
		__var_id = 1,

		vars = {},
		funcs = {}
	},
	statusline = {
		__func_id = 1,
		__var_id = 1,

		vars = {},
		funcs = {}
	},
	statuscolumn = {
		__func_id = 1,
		__var_id = 1,

		vars = {},
		funcs = {}
	}
};


--- Configures a module
---@param part (boolean | table)?
---@param config table
local configure = function (part, config)
	if not config then
		return;
	elseif config == false then
		return;
	elseif type(config) == "table" then
		if config.enable ~= true then
			return;
		elseif part then
			part.setup(config.opts);
		end
	end
end

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

bars.statuscolumn = require("bars.statuscolumn");
bars.statusline = require("bars.statusline");
bars.tabline = require("bars.tabline");

local utils = require("bars.utils");

bars.autocmd = nil;

---@type bars.config
bars.configuration = {
	exclude_filetypes = { "help", "query" },
	exclude_buftypes = { "nofile", "prompt" },

	statuscolumn = true,
	statusline = true,
	tabline = true
};


--- Setup for the plugin
---@param config_table table
bars.setup = function (config_table)
	-- Merge both configuration tables
	if type(config_table) == "table" then
		bars.configuration = vim.tbl_extend("force", bars.configuration, config_table);
	end

	--- Last parameter can be a boolean | table | nil
	--- Ignore them
	---@diagnostic disable
	configure(bars.statusline, bars.configuration.statusline);
	configure(bars.statuscolumn, bars.configuration.statuscolumn);
	configure(bars.tabline, bars.configuration.tabline);
	---@diagnostic enable

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
end

return bars;
