local bars = {};
local statuscolumn = require("bars/statuscolumn");
local statusline = require("bars/statusline");
local tabline = require("bars/tabline");

---@type table A table containing functions to open a specific buffer
_G.__bufOpen = {};

---+ Title: "Default configuration"
---
--- A table containing various configuration related options for the plugin.
--- Used by the setup() function after merging(extending) with the user's
--- config table.
---

---+2 Title: "Code"

---@class setup_table Default configuration table, it will be merged with the user config
bars.default_config = {
	global_disable = {
		filetypes = { "help", "lazy", "TelescopePrompt", "TelescopeResults", "lspinfo" },
		buftypes = { "terminal", "nofile" }
	},
	custom_configs = {
		{
			filetypes = { "query" },
			buftypes = { "terminal" },
			config = {
				statuscolumn = {
					enable = false
				}
			}
		}
	},

	default = {
		tabline = {
			enable = true,
			options = {
				components = {
					{ type = "buffers" },
					{ type = "gap" },
					-- { type = "separator" },
					{ type = "tabs" }
				}
			}
		},
		statusline = {
			enable = true,
			options = {
				set_defaults = true,

				components = {
					{ type = "mode" },
					{ type = "buf_name" },

					{ type = "gap" },

					{ type = "cursor_position" }
				}
			}
		},
		statuscolumn = {
			enable = true,
			options = {
				set_defaults = true,

				default_hl = "statuscol_bg",
				components = {
					{
						type = "sign",
						text = ""
					},
					{
						type = "fold",
						mode = "line",

						text = {
							default = " ",
							closed = {
								"", "", ""
							},
							opened = {
								"", "", ""
							},

							edge = "╰",
							branch = "┝",
							scope = "│"
						},

						hl = {
							--default = "FloatShadow",
							closed = { "fold_1", "fold_2", "fold_3" },
							opened = { "fold_1_open", "fold_2_open", "fold_3_open" },

							scope = { "fold_1", "fold_2", "fold_3" },
							edge = { "fold_1", "fold_2", "fold_3" },
							branch = { "fold_1", "fold_2", "fold_3" }
						}
					},
					{
						type = "gap",

						text = " "
					},
					{
						type = "number",
						mode = "hybrid",

						hl = {
							prefix = "glow_num_",
							from = 0, to = 9
						},
						right_align = true
					},
					{
						type = "gap",

						text = " "
					},
					{
						type = "border",

						hl = {
							prefix = "glow_",
							from = 0, to = 7
						},
						text = "│"
					},
					{
						type = "gap",

						text = " "
					},
				}
			}
		}
	}
};

---_2
---_

--- Inherits value from the specified table
---@param table table Original table
---@param inherit_from table Table to inherit from
---@return table
local inherit = function (table, inherit_from)
	if table == nil or inherit_from == nil then
		return {};
	end

	for key, value in pairs(table) do
		if value == "inherit" then
			table[key] = inherit_from[key];
		end
	end

	return table;
end

--- Validates the provided buffer
---@param buffer number Buffer handle(Buffer number)
---@param config table User configuration table
bars.bufValidate = function (buffer, config)
	local use_config = {};

	if vim.tbl_contains(config.global_disable.filetypes or {}, vim.bo[buffer].filetype) then
		goto config_set
	end

	if vim.tbl_contains(config.global_disable.buftypes or {}, vim.bo[buffer].buftype) then
		goto config_set
	end

	if vim.islist(config.custom_configs) == true then
		for _, conf in ipairs(config.custom_configs) do
			if vim.tbl_contains(conf.filetypes or {}, vim.bo[buffer].filetype) and vim.tbl_contains(conf.buftypes or {}, vim.bo[buffer].buftype) then
				use_config = inherit(conf.config, config.default or {});

				goto config_set
			elseif vim.tbl_contains(conf.filetypes or {}, vim.bo[buffer].filetype) or vim.tbl_contains(conf.buftypes or {}, vim.bo[buffer].buftype) then
				use_config = inherit(conf.config, config.default or {});

				goto config_set
			end
		end
	end

	use_config = config.default;
	::config_set::

	statuscolumn.init(buffer, use_config.statuscolumn);
	statusline.init(buffer, use_config.statusline);
	tabline.init(use_config.tabline);
end

--- Sets up the plugin
---@param user_config setup_table?
bars.setup = function (user_config)
	local merged_config = vim.tbl_deep_extend("force", bars.default_config, user_config or {});

	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = "*",
		callback = function (data)
			local buffer = data.buf;

			bars.bufValidate(buffer, merged_config);
		end
	})

	vim.api.nvim_create_autocmd({ "BufWinEnter", "TermOpen" }, {
		pattern = "*",
		callback = function (data)
			local buffer = data.buf;

			bars.bufValidate(buffer, merged_config);

			_G.__bufOpen["buffer_" .. buffer] = function ()
				local tabs = vim.api.nvim_list_tabpages();

				for _, tab in ipairs(tabs) do
					local windows = vim.api.nvim_tabpage_list_wins(tab);

					for _, window in ipairs(windows) do
						local buf = vim.api.nvim_win_get_buf(window);

						if buf == buffer then
							vim.api.nvim_set_current_tabpage(tab);
							return;
						end
					end
				end

				vim.api.nvim_set_current_buf(buffer);
			end
		end
	});

	-- vim.api.nvim_create_autocmd({ "LspTokenUpdate" }, {
	-- 	pattern = "*",
	-- 	callback = function ()
	-- 		vim.print("Token update")
	-- 	end
	-- })
end

return bars;
