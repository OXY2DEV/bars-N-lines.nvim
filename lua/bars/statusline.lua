local statusline = {};
local devicons = require("nvim-web-devicons");
local utils = require("bars/utils");

statusline.configuration = {
	default = {
		{
			type = "mode",

			padding_left = " ",
			padding_left_hl = {
				-- __is_hl = true,

				["n"] = "mode_normal_alt",
				["i"] = "mode_insert_alt",

				["v"] = "mode_visual_alt",
				[""] = "mode_visual_block_alt",
				["V"] = "mode_visual_line_alt",

				["c"] = "mode_cmd_alt"
			},

			icon = {
				["n"] = " ",
				["i"] = " ",

				["v"] = "󰸿 ",
				[""] = "󰹀 ",
				["V"] = "󰸽 ",

				["c"] = " ",
			},

			text = {
				default = function ()
					return vim.api.nvim_get_mode().mode;
				end,

				["n"] = "Normal",
				["i"] = "Insert",

				["v"] = "Visual",
				[""] = "Visual",
				["V"] = "Visual",

				["c"] = "Command"
			},

			padding_right = " ", padding_right_hl = nil,

			corner_right = "",
			corner_right_hl = {
				["n"] = "mode_normal",
				["i"] = "mode_insert",

				["v"] = "mode_visual",
				[""] = "mode_visual_block",
				["V"] = "mode_visual_line",

				["c"] = "mode_cmd"
			},
		},

		{
			type = "bufname",
			padding_left = " ",
			padding_left_hl = "buf_name",
			padding_right = " ",
			corner_right = "",
			corner_right_hl = "buf_name_alt"
		},
		{
			type = "raw",
			text = "%="
		},
		{
			type = "data",
			value = function (part)
				local ls, rs;

				if not _G.bars_display_mode then
					_G.bars_display_mode = 1;
				end

				if _G.bars_display_mode == 1 then
					part.icon = "  ";

					ls = "%l";
					rs = "%c";
				elseif _G.bars_display_mode == 2 then
					part.icon = "󰳽 ";

					ls = "%b";
					rs = nil
				elseif _G.bars_display_mode == 3 then
					part.icon = "󰆾 ";

					ls = "%o";
					rs = nil
				elseif _G.bars_display_mode == 4 then
					part.icon = "󰈙 ";

					ls = "%L";
					rs = nil
				elseif _G.bars_display_mode == 5 then
					part.icon = "󰏰 ";

					ls = "%p";
					rs = nil
				end

				part.before = "%@v:lua.bars_n_lines.switch_display_mode@"
				part.text = (ls and rs) and ls .. "  " .. rs or (ls or "") .. (rs or "");
				part.after = "%X"

				return part;
			end,

			corner_left = "",
			corner_left_hl = "cursor_position_alt",

			padding_left = " ",
			padding_left_hl = "cursor_position",

			icon_hl = "cursor_position",

			padding_right = " "
		}
	},

	custom = {}
};

statusline.render_mode = function (config_table)
	return utils.create_segmant(config_table, function (part)
		local mode = vim.api.nvim_get_mode().mode;

		if part[mode] then
			return part[mode];
		elseif part.default and pcall(part.default) then
			return part.default();
		elseif not part.__is_hl and part.n then
			return part.n;
		else
			return "";
		end
	end)
end

statusline.render_bufname = function (buffer, config_table)
	local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":t");

	local icon, _ = devicons.get_icon(buffer_name);

	if buffer_name == "" then
		buffer_name = "No name";
		icon = " "
	end

	config_table.text = (icon or "") .. " "  .. buffer_name;

	return utils.create_segmant(config_table)
end

statusline.render_data = function (config_table)
	if config_table.value and pcall(config_table.value, config_table) then
		config_table = config_table.value(config_table);
	end

	return utils.create_segmant(config_table)
end

statusline.draw = function (window, buffer)
	local conf = utils.find_config(statusline.configuration, buffer);
	local _o = "%#Normal#";

	for _, part in ipairs(conf) do
		if part.type == "mode" then
			_o = _o .. statusline.render_mode(part);
		elseif part.type == "bufname" then
			_o = _o .. statusline.render_bufname(buffer, part);
		elseif part.type == "raw" then
			_o = _o .. (part.text or "");
		elseif part.type == "data" then
			_o = _o .. statusline.render_data(part);
		end
	end

	return _o;
end

statusline.init = function (buffer, window, config_table)
	vim.g.cmdheight = 0;
	vim.wo[window].statusline = "%!v:lua.require('bars.statusline').draw(" .. window .. "," .. buffer .. ")";
end

statusline.disable = function (window)
	vim.wo[window].statusline = "";
end

return statusline;
