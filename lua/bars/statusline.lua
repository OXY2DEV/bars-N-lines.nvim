---@diagnostic disable: duplicate-set-field
local statusline = require("bars.generic").new();

statusline.custom = "%!v:lua.require('bars.statusline').render()";
statusline.var_name = "bars_statusline_style";

--[[ Reusable configuration templates. ]]
---@type table<string, bars.statusline.component>
local TEMPLATES;

TEMPLATES = {
	---|fS

	---@type bars.statusline.mode
	mode = {
		---|fS "Mode configuration"

		kind = "mode",

		compact = function (_, window)
			if window ~= vim.api.nvim_get_current_win() then
				return true;
			else
				return vim.api.nvim_win_get_width(window) < math.ceil(vim.o.columns * 0.5);
			end
		end,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "BarsNormal",
		},

		["^n"] = { text = "Normal" },

		["^t"] = { text = "Terminal" },

		["^v$"] = {
			icon = "󰸿 ",
			text = "Visual",

			hl = "BarsVisual",
		},
		["^V$"]    = {
			icon = "󰹀 ",
			text = "Visual",

			hl = "BarsVisualLine",
		},
		["^$"]   = {
			icon = "󰸽 ",
			text = "Visual",

			hl = "BarsVisualBlock",
		},

		["^s$"]    = {
			icon = "󰕠 ",
			text = "Select",

			hl = "BarsVisual",
		},
		["^S$"]    = {
			icon = "󰕞 ",
			text = "Select",

			hl = "BarsVisualLine",
		},
		["^$"]   = {
			icon = " ",
			text = "Select",

			hl = "BarsVisualBlock",
		},

		["^i$"]    = {
			icon = " ",
			text = "Insert",

			hl = "BarsInsert",
		},
		["^ic$"]   = {
			icon = " ",
			text = "Completion",

			hl = "BarsInsert",
		},
		["^ix$"]   = {
			text = "Inser8",

			hl = "BarsInsert",
		},

		["^R$"]    = {
			icon = " ",
			text = "Replace",

			hl = "BarsInsert",
		},
		["^Rc$"]   = {
			icon = " ",
			text = "Completion",

			hl = "BarsInsert",
		},

		["^c"]    = {
			icon = " ",
			text = "Command",

			hl = "BarsCommand",
		},

		["^r"] = { text = "Prompt" },

		["^%!"] = {
			icon = " ",
			text = "Shell",

			hl = "BarsCommand"
		},

		---|fE
	},
	---@type bars.statusline.bufname
	bufname = {
		---|fS

		kind = "bufname",
		condition = function (_, win)
			return vim.api.nvim_win_get_width(win) >= 42;
		end,

		max_len = 25,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = "",
			nomodifiable_icon_hl = "BarsFt1",
			nomodifiable_icon = "󰌾 ",
			icon_hl = {
				"BarsFt0", "BarsFt1", "BarsFt2", "BarsFt3", "BarsFt4", "BarsFt5", "BarsFt6"
			},
		},

		["^$"] = {
			icon = "󰂵 ",
			text = "New file",

			hl = "BarsFt0"
		},

		["^config"] = {
			icon = "󰒓 ",

			hl = "BarsFt6"
		},

		---|fE
	},
	---@type bars.statusline.diagnostics
	diagnostics = {
		---|fS

		kind = "diagnostics",
		default_mode = 5,
		compact = true,

		padding_left = " ",
		padding_right = " ",

		empty_icon = "󰂓 ",
		empty_hl = "@comment",

		error_icon = "󰅙 ",
		error_hl = "DiagnosticError",

		warn_icon = "󰀦 ",
		warn_hl = "DiagnosticWarn",

		hint_icon = "󰁨 ",
		hint_hl = "DiagnosticHint",

		info_icon = "󰁤 ",
		info_hl = "DiagnosticInfo"

		---|fE
	},
	---@type bars.statusline.macro
	macro = {
		---|fS

		kind = "macro",

		record_icon = "󰦚 ",
		exec_icon = "󰥠 ",

		record_hl = "@constant",
		exec_hl = "DiagnosticOk",

		---|fE
	},
	progress = {
		---|fS

		kind = "progress",

		check = "lsp_loader_state",
		update_delay = 250,

		start = "󰐌 ",
		progress = { "󰋙 ", "󰫃 ", "󰫄 ", "󰫅 ", "󰫆 ", "󰫇 ", "󰫈 " },
		finish = "󰗠 ",

		start_hl = "@comment",
		progress_hl = {
			"BarsNormal4",
			"BarsNormal3",
			"BarsNormal3",
			"BarsNormal2",
			"BarsNormal2",
			"BarsNormal1",
			"BarsNormal1",
		},
		finish_hl = "DiagnosticOk"

		---|fE
	},
	---@type bars.statusline.branch
	git_branch = {
		---|fS

		kind = "branch",
		condition = function (_, win)
			return win == vim.api.nvim_get_current_win();
		end,

		default = {
			padding_left = " ",
			padding_right = " ",
			icon = "󰊢 ",

			hl = "@comment"
		}

		---|fE
	},
	---@type bars.statusline.custom
	lsp = {
		---|fS

		kind = "custom",

		condition = function (_, window)
			if window ~= vim.api.nvim_get_current_win() then
				return true;
			else
				return vim.api.nvim_win_get_width(window) > math.ceil(vim.o.columns * 0.5);
			end
		end,

		value = function (buffer)
			local clients = vim.lsp.get_clients({ bufnr = buffer });

			if #clients == 0 or vim.b[buffer].lsp_loader_state then
				return "";
			end

			local name_maps = {
				default = { icon = "󰒋 ", hl = "BarsFt0" },
				lua_ls = { icon = " ", name = "LuaLS", hl = "BarsFt5" },
				html = { icon = " ", name = "HTML", hl = "BarsFt2" },
				emmet_language_server = { icon = "󱡴 ", name = "Emmet", hl = "BarsFt4" },
			}
			local output = "";

			for c, client in ipairs(clients) do
				local name = client.name or "";

				if name_maps[name] then
					if name_maps[name].hl then
						output = output .. string.format("%%#%s#", name_maps[name].hl);
					end

					output = output .. (c > 1 and "" or " ").. name_maps[name].icon .. name_maps[name].name .. " ";
				else
					if name_maps.default.hl then
						output = output .. string.format("%%#%s#", name_maps.default.hl);
					end

					output = output .. (c > 1 and "" or " ") .. name_maps.default.icon .. name .. " ";
				end
			end

			return output;
		end

		---|fE
	},

	---@type bars.statusline.ruler
	ruler = {
		---|fS

		kind = "ruler",
		mode = function ()
			local mode = vim.api.nvim_get_mode().mode;
			local visual_modes = { "v", "V", "" };

			return vim.list_contains(visual_modes, mode) and "visual" or "normal";
		end,

		-- NOTE: You can turn most component options into functions,
		---@diagnostic disable: assign-type-mismatch
		default = function ()
			---|fS

			local hl = TEMPLATES.mode.default.hl;
			local mode = vim.api.nvim_get_mode().mode;

			local ignore = { "default", "min_width", "kind", "condition", "kind" };
			---@type mode.opts
			local config = require("bars.utils").match(TEMPLATES.mode, mode, ignore);

			hl = config.hl or hl;

			return {
				padding_left = " ",
				padding_right = " ",
				icon = "󰆤 ",

				separator = " 󰇛 ",

				hl = hl or "BarsRuler"
			};

			---|fE
		end,

		visual = function ()
			---|fS

			local hl = TEMPLATES.mode.default.hl;
			local mode = vim.api.nvim_get_mode().mode;

			local ignore = { "default", "min_width", "kind", "condition", "kind" };
			---@type mode.opts
			local config = require("bars.utils").match(TEMPLATES.mode, mode, ignore);

			hl = config.hl or hl;

			return {
				padding_left = " ",
				padding_right = " ",
				icon = "󰆣 ",

				separator = " 󰇛 ",

				hl = hl or "BarsRuler"
			};

			---|fE
		end
		---@diagnostic enable: assign-type-mismatch

		---|fE
	},

	---|fE
};

---@class bars.generic.config
statusline.config = {
	force_attach = {
		-- `Quickfix` window's statusline.
		"%t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''} %=%-15(%l,%c%V%) %P",
	},

	ignore_filetypes = {},
	ignore_buftypes = { "nofile" },

	default = {
		---|fS "Default configuration"

		components = {
			TEMPLATES.mode,
			TEMPLATES.bufname,
			{ kind = "section", hl = "StatusLine" },
			TEMPLATES.diagnostics,
			TEMPLATES.macro,
			{ kind = "empty", hl = "StatusLine" },
			TEMPLATES.git_branch,
			TEMPLATES.lsp,
			TEMPLATES.ruler
		}

		---|fE
	},

	["help"] = {
		---|fS "Help statusline"

		condition = function (buffer)
			return vim.bo[buffer].buftype == "help";
		end,
		components = {
			vim.tbl_extend("force", TEMPLATES.mode, {
				compact = true
			}),
			{
				kind = "ruler",

				default = {
					padding_left = " ",
					padding_right = " ",
					icon = " ",

					separator = " 󰇛 ",

					hl = "BarsFt0"
				},
			},
			{ kind = "empty", hl = "StatusLine" },
			{
				kind = "custom",
				value = function ()
					local text = "";

					for i = 15, 2, -1 do
						text = text .. string.format("%%#BarsHelp%d#", i);
						text = text .. "▟";
					end

					return text;
				end
			},
			{
				kind = "bufname",
				max_len = 25,

				default = {
					padding_left = " ",
					padding_right = " ",

					icon = "",
					nomodifiable_icon_hl = "BarsFt1",
					nomodifiable_icon = "󰌾 ",
					icon_hl = {
						"BarsFt0", "BarsFt1", "BarsFt2", "BarsFt3", "BarsFt4", "BarsFt5", "BarsFt6"
					},
				},
			},
		}

		---|fE
	},

	quickfix = {
		---|fS "Help statusline"

		condition = function (buffer)
			return vim.bo[buffer].buftype == "quickfix";
		end,

		components = {
			{
				kind = "custom",
				value = function ()
					local text = "%#BarsQuickfix#";
					text = text .. " 󱌢 Quickfix ";

					for i = 2, 15, 1 do
						text = text .. string.format("%%#BarsQuickfix%d#", i);
						text = text .. "▛";
					end

					return text;
				end
			},
			{ kind = "empty" },
			TEMPLATES.mode,
		}

		---|fE
	},
};

function statusline:original ()
	return vim.g.bars_cache and vim.g.bars_cache.statusline or "";
end

function statusline:current (win) return vim.wo[win].statusline; end

function statusline:start ()
	if not self.state.enable then
		return;
	end

	vim.api.nvim_set_option_value("statusline", statusline.custom, { scope = "global" });

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		statusline:handle_new_window(win);
	end
end

--------------------------------------------------------------------------------

---@param win integer
function statusline:set (win)
	vim.api.nvim_set_option_value("statusline", statusline.custom, {
		scope = "local",
		win = win
	});
end

---@param win integer
function statusline:remove (win)
	vim.api.nvim_win_call(win, function ()
		vim.schedule(function ()
			vim.cmd("set statusline=" .. (statusline:original() or ""));
		end)
	end);
end

function statusline:render ()
	local components = require("bars.components.statusline");
	local win = vim.g.statusline_winid;

	return statusline:get_styled_output(win, components);
end

return statusline;
