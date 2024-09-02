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

bars.add_hls = function (obj)
	local use_hl = {};

	for _, hl in ipairs(obj) do
		if hl.output and type(hl.output) == "function" and pcall(hl.output) then
			use_hl = vim.list_extend(use_hl, hl.output());
		else
			table.insert(use_hl, hl);
		end
	end

	for _, hl in ipairs(use_hl) do
		if not hl.value then
			goto continue;
		end

		local opt = hl.value;

		if type(hl.value) == "function" and pcall(hl.value) then
			opt = hl.value();
		end

		if type(opt) == "table" then
			vim.api.nvim_set_hl(0, hl.group_name, opt);
		end

		::continue::
	end
end

bars.statuscolumn = require("bars.statuscolumn");
bars.statusline = require("bars.statusline");
bars.tabline = require("bars.tabline");
bars.colors = require("bars.colors");

bars.autocmd = nil;

---@type bars.config
bars.configuration = {
	highlight_groups = {
		---+ ${hl, Highlight groups}
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "@comment.note", "bg"),
					bars.colors.get_hl_value(0, "@comment.note", "fg"),
					bars.colors.get_hl_value(0, "Title", "fg"),
					vim.o.background == "dark" and "#89b4fa" or "#1e66f5"
				});

				local sep_fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(fg);

				return {
					{
						group_name = "BarsStatuslineNormal",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineNormalSep",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "Normal", "fg"),
					vim.o.background == "dark" and "#CDD6F4" or "#4C4F69"
				});

				local sep_fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(fg);

				return {
					{
						group_name = "BarsStatuslineInsert",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineInsertSep",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "Define", "fg"),
					vim.o.background == "dark" and "#F5C2E7" or "#EA76CB"
				});

				local sep_fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(fg);

				return {
					{
						group_name = "BarsStatuslineVisual",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineVisualSep",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "Constant", "fg"),
					vim.o.background == "dark" and "#FAB387" or "#FE640B"
				});

				local sep_fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(fg);

				return {
					{
						group_name = "BarsStatuslineVBlock",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineVBlockSep",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "Keyword", "fg"),
					vim.o.background == "dark" and "#CBA6F7" or "#8839EF"
				});

				local sep_fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(fg);

				return {
					{
						group_name = "BarsStatuslineVLine",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineVLineSep",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "diffAdded", "fg"),
					vim.o.background == "dark" and "#a6e3a1" or "#40a02b"
				});

				local sep_fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(fg);

				return {
					{
						group_name = "BarsStatuslineCmd",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineCmdSep",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_fg, sep_fg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local fg = bars.colors.bg();
				local bg = bars.colors.get({
					bars.colors.get_hl_value(0, "Character", "fg"),
					vim.o.background == "dark" and "#94E2D5" or "#179299"
				});

				return {
					{
						group_name = "BarsStatuslineRuler",
						value = { fg = fg, bg = bg }
					},
					{
						group_name = "BarsStatuslineRulerSep",
						value = { fg = bg, bg = fg }
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Normal", "fg"),
					vim.o.background == "dark" and "#CDD6F4" or "#4C4F69"
				});

				local sep_bg = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#6c7086" or "#9ca0b0"
				});

				local luminosity = bars.colors.get_brightness(bg);

				return {
					{
						group_name = "BarsStatuslineBuf",
						value = luminosity < 0.5 and
							{ fg = fg, bg = bars.colors.mix(sep_bg, sep_bg, 0.5, math.max(luminosity, 0.05)) } or
							{ fg = bg, bg = bars.colors.mix(sep_bg, sep_bg, 1, math.min(1 + luminosity, 0.05) * -1) }
						;
					},
					{
						group_name = "BarsStatuslineBufSep",
						value = luminosity < 0.5 and
							{ bg = bg, fg = bars.colors.mix(sep_bg, sep_bg, 0.5, math.max(luminosity, 0.05)) } or
							{ bg = bg, fg = bars.colors.mix(sep_bg, sep_bg, 1, math.min(1 - luminosity, 0.05) * -1) }
						;
					}
				};
			end
		},


		{
			group_name = "BarsStatuscolumnNum",
			value = function ()
				local bg = bars.colors.get_hl_value(0, "LineNr", "bg");
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Title", "fg"),
					vim.o.background == "dark" and "#89b4fa" or "#1e66f5"
				});

				return { bg = bg, fg = fg, bold = true };
			end
		},
		{
			output = function ()
				local from = bars.colors.get({
					bars.colors.get_hl_value(0, "Title", "fg"),
					vim.o.background == "dark" and "#89b4fa" or "#1e66f5"
				});
				local to = bars.colors.get({
					bars.colors.get_hl_value(0, "Comment", "fg"),
					vim.o.background == "dark" and "#585B70" or "#ACB0BE"
				});

				return bars.colors.create_gradient("BarsStatuscolumnGlow", from, to, 9, "fg");
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "DiagnosticVirtualTextOk", "fg"),
					bars.colors.get_hl_value(0, "DiagnosticOk", "fg"),
					vim.o.background == "dark" and "#a6e3a1" or "#40a02b"
				});

				local lineNr = bars.colors.get_hl_value(0, "LineNr", "bg");
				local marker_fg = bars.colors.get({
					vim.o.background == "dark" and bars.colors.mix(bg, fg, 0.5, 0.5) or bars.colors.mix(bg, fg, 0.25, 1),
				})

				return {
					{
						group_name = "BarsStatuscolumnFold1",
						value = { fg = fg, bg = lineNr }
					},
					{
						group_name = "BarsStatuscolumnFold1Marker",
						value = { fg = marker_fg, bg = lineNr }
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "DiagnosticVirtualTextHint", "fg"),
					bars.bars.colors.get_hl_value(0, "DiagnosticHint", "fg"),
					vim.o.background == "dark" and "#94e2d5" or "#179299"
				});

				local lineNr = bars.colors.get_hl_value(0, "LineNr", "bg");
				local marker_fg = bars.colors.get({
					vim.o.background == "dark" and bars.colors.mix(bg, fg, 0.5, 0.5) or bars.colors.mix(bg, fg, 0.25, 1),
				})

				return {
					{
						group_name = "BarsStatuscolumnFold2",
						value = { fg = fg, bg = lineNr }
					},
					{
						group_name = "BarsStatuscolumnFold2Marker",
						value = { fg = marker_fg, bg = lineNr }
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "DiagnosticVirtualTextInfo", "fg"),
					bars.colors.get_hl_value(0, "DiagnosticInfo", "fg"),
					vim.o.background == "dark" and "#89dceb" or "#179299";
				});

				local lineNr = bars.colors.get_hl_value(0, "LineNr", "bg");
				local marker_fg = bars.colors.get({
					vim.o.background == "dark" and bars.colors.mix(bg, fg, 0.5, 0.5) or bars.colors.mix(bg, fg, 0.25, 1),
				})

				return {
					{
						group_name = "BarsStatuscolumnFold3",
						value = { fg = fg, bg = lineNr }
					},
					{
						group_name = "BarsStatuscolumnFold3Marker",
						value = { fg = marker_fg, bg = lineNr }
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Special", "fg"),
					vim.o.background == "dark" and "#F5C2E7" or "#EA76CB";
				});

				local lineNr = bars.colors.get_hl_value(0, "LineNr", "bg");
				local marker_fg = bars.colors.get({
					vim.o.background == "dark" and bars.colors.mix(bg, fg, 0.5, 0.5) or bars.colors.mix(bg, fg, 0.25, 1),
				})

				return {
					{
						group_name = "BarsStatuscolumnFold4",
						value = { fg = fg, bg = lineNr }
					},
					{
						group_name = "BarsStatuscolumnFold4Marker",
						value = { fg = marker_fg, bg = lineNr }
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "DiagnosticVirtualTextWarn", "fg"),
					bars.colors.get_hl_value(0, "DiagnosticWarn", "fg"),
					vim.o.background == "dark" and "#F9E3AF" or "#DF8E1D";
				});

				local lineNr = bars.colors.get_hl_value(0, "LineNr", "bg");
				local marker_fg = bars.colors.get({
					vim.o.background == "dark" and bars.colors.mix(bg, fg, 0.5, 0.5) or bars.colors.mix(bg, fg, 0.25, 1),
				})

				return {
					{
						group_name = "BarsStatuscolumnFold5",
						value = { fg = fg, bg = lineNr }
					},
					{
						group_name = "BarsStatuscolumnFold5Marker",
						value = { fg = marker_fg, bg = lineNr }
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "DiagnosticVirtualTextError", "fg"),
					bars.colors.get_hl_value(0, "DiagnosticError", "fg"),
					vim.o.background == "dark" and "#F38BA8" or "#D20F39";
				});

				local lineNr = bars.colors.get_hl_value(0, "LineNr", "bg");
				local marker_fg = bars.colors.get({
					vim.o.background == "dark" and bars.colors.mix(bg, fg, 0.5, 0.5) or bars.colors.mix(bg, fg, 0.25, 1),
				})

				return {
					{
						group_name = "BarsStatuscolumnFold6",
						value = { fg = fg, bg = lineNr }
					},
					{
						group_name = "BarsStatuscolumnFold6Marker",
						value = { fg = marker_fg, bg = lineNr }
					}
				};
			end
		},


		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Normal", "fg"),
					vim.o.background == "dark" and "#CDD6F4" or "#4C4F69"
				});

				local luminosity = bars.colors.get_brightness(bg);

				return {
					{
						group_name = "BarsTablineBufActive",
						value = luminosity < 0.5 and
							{ fg = bg, bg = fg } or
							{ fg = bg, bg = fg }
						;
					},
					{
						group_name = "BarsTablineBufActiveSep",
						value = luminosity < 0.5 and
							{ bg = bg, fg = fg } or
							{ bg = bg, fg = fg }
						;
					},
					{
						group_name = "BarsTablineBufInactive",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(fg, fg, 0.4, 0.2) } or
							{ fg = bg, bg = bars.colors.mix(fg, fg, 0.4, 0.2) }
						;
					},
					{
						group_name = "BarsTablineBufInactiveSep",
						value = luminosity < 0.5 and
							{ bg = bg, fg = bars.colors.mix(fg, fg, 0.4, 0.2) } or
							{ bg = bg, fg = bars.colors.mix(fg, fg, 0.4, 0.2) }
						;
					}
				};
			end
		},
		{
			output = function ()
				local bg = bars.colors.bg();
				local fg = bars.colors.get({
					bars.colors.get_hl_value(0, "Special", "fg"),
					vim.o.background == "dark" and "#F5C2E7" or "#EA76CB";
				});

				local luminosity = bars.colors.get_brightness(bg);

				return {
					{
						group_name = "BarsTablineTabActive",
						value = luminosity < 0.5 and
							{ fg = bg, bg = fg } or
							{ fg = bg, bg = fg }
						;
					},
					{
						group_name = "BarsTablineTabActiveSep",
						value = luminosity < 0.5 and
							{ bg = bg, fg = fg } or
							{ bg = bg, fg = fg }
						;
					},
					{
						group_name = "BarsTablineTabInactive",
						value = luminosity < 0.5 and
							{ fg = bg, bg = bars.colors.mix(fg, fg, 0.4, 0.2) } or
							{ fg = bg, bg = bars.colors.mix(fg, fg, 0.4, 0.2) }
						;
					},
					{
						group_name = "BarsTablineTabInactiveSep",
						value = luminosity < 0.5 and
							{ bg = bg, fg = bars.colors.mix(fg, fg, 0.4, 0.2) } or
							{ bg = bg, fg = bars.colors.mix(fg, fg, 0.4, 0.2) }
						;
					}
				};
			end
		}
		---_
	},

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
end

return bars;
