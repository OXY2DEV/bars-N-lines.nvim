local statusline = {};
local devicons = require("nvim-web-devicons");

--- Artaches a bunch of string together to make a component
---@param component statusline_component_raw
---@return string
local componentConstructor = function (component)
	return table.concat({
		component.default_hl ~= nil and "%#" .. component.default_hl .. "#" or "",
		component.prefix or "",

		component.corner_left_hl ~= nil and "%#" .. component.corner_left_hl .. "#" or "",
		component.corner_left or "",

		component.padding_left_hl ~= nil and "%#" .. component.padding_left_hl .. "#" or "",
		component.padding_left or "",

		component.icon_hl ~= nil and "%#" .. component.icon_hl .. "#" or "",
		component.icon or "",

		component.text_hl ~= nil and "%#" .. component.text_hl .. "#" or "",
		component.text or "",

		component.padding_right_hl ~= nil and "%#" .. component.padding_right_hl .. "#" or "",
		component.padding_right or "",

		component.corner_right_hl ~= nil and "%#" .. component.corner_right_hl .. "#" or "",
		component.corner_right or "",

		component.postfix or ""
	});
end

--- Search for key in a table, return the default value if not found
---@param key string The key to search
---@param current_config table Table where to search for the key
---@param default_config table Table that contains the default value
---@return any
local getDefault = function (key, current_config, default_config)
	if current_config ~= nil and current_config[key] ~= nil then
		return current_config[key];
	end

	return default_config[key];
end

---@type (statusline_options | boolean)[] User configuration tables for the various buffers
statusline.buffer_configs = {};

--- Initializes the statusline for the specified buffer
---@param buffer number The buffer ID
---@param user_config statusline_config? The statusline configuration
statusline.init = function (buffer, user_config)
	if user_config == nil then
		statusline.buffer_configs[buffer] = false;
	elseif user_config.enable == false then
		statusline.buffer_configs[buffer] = {};
	else
		statusline.buffer_configs[buffer] = user_config.options;
	end

	local windows = vim.fn.win_findbuf(buffer);

	if statusline.buffer_configs[buffer] == false then
		for _, window in ipairs(windows) do
			vim.wo[window].statusline = "";
		end
	else
		for _, window in ipairs(windows) do
			if user_config ~= nil and user_config.options ~= nil and user_config.options.set_defaults == true then
				vim.o.cmdheight = 1;
				vim.o.laststatus = 2;
			end

			vim.wo[window].statusline = "%!v:lua.require('bars/statusline').generateStatusline(" .. buffer .. ")";
		end
	end
end

--- Shows the current mode with icons
---@param mode_config statusline_mode_config User configuration for the component
---@return string
statusline.mode = function (mode_config)
	local mode = vim.api.nvim_get_mode().mode;

	---@type statusline_mode_config Table containing a merge of default options(ones that aren't provided) and user options(ones that are provided)
	local merged_config = vim.tbl_deep_extend("keep", mode_config or {}, {
		default = {
			icon = " ", icon_hl = nil,
			text = mode, text_hl = nil,

			corner_left = "", corner_left_hl = "mode_normal_alt",
			corner_right = "", corner_right_hl = "mode_normal",

			padding_left = " ", padding_left_hl = nil,
			padding_right = " ", padding_right_hl = nil,

			bg = "mode_normal_alt"
		},
		modes = {
			["n"] = { icon = " ", text = "Normal" },
			["i"] = { icon = " ", text = "Insert", bg = "mode_insert_alt", corner_left_hl = "mode_insert_alt", corner_right_hl = "mode_insert" },

			["v"] = { icon = "󰸿 ", text = "Visual", bg = "mode_visual_alt", corner_left_hl = "mode_visual_alt", corner_right_hl = "mode_visual" },
			[""] = { icon = "󰹀 ", text = "Visual", bg = "mode_visual_block_alt", corner_left_hl = "mode_visual_block_alt", corner_right_hl = "mode_visual_block" },
			["V"] = { icon = "󰸽 ", text = "Visual", bg = "mode_visual_line_alt", corner_left_hl = "mode_visual_line_alt", corner_right_hl = "mode_visual_line" },

			["c"] = { icon = " ", text = "Command", bg = "mode_cmd_alt", corner_left_hl = "mode_cmd_alt", corner_right_hl = "mode_cmd" },
		}
	});


	return componentConstructor({
		default_hl = getDefault("bg", merged_config.modes[mode], merged_config.default),

		corner_left_hl = getDefault("corner_left_hl", merged_config.modes[mode], merged_config.default),
		corner_left = getDefault("corner_left", merged_config.modes[mode], merged_config.default),

		padding_left_hl = getDefault("padding_left_hl", merged_config.modes[mode], merged_config.default),
		padding_left = getDefault("padding_left", merged_config.modes[mode], merged_config.default),

		icon_hl = getDefault("icon_hl", merged_config.modes[mode], merged_config.default),
		icon = getDefault("icon", merged_config.modes[mode], merged_config.default),

		text_hl = getDefault("text_hl", merged_config.modes[mode], merged_config.default),
		text = getDefault("text", merged_config.modes[mode], merged_config.default),

		padding_right_hl = getDefault("padding_right_hl", merged_config.modes[mode], merged_config.default),
		padding_right = getDefault("padding_right", merged_config.modes[mode], merged_config.default),

		corner_right_hl = getDefault("corner_right_hl", merged_config.modes[mode], merged_config.default),
		corner_right = getDefault("corner_right", merged_config.modes[mode], merged_config.default),
	});
end

--- Creates a component to show the buffer's file name
---@param buffer number Buffer ID
---@param buf_name_config statusline_buf_name_config Configuration table for the component
---@return string
statusline.buf_name = function (buffer, buf_name_config)
	local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":t");
	local icon, _ = devicons.get_icon(buffer_name);

	---@type statusline_buf_name_config Table containing a merge of default options(ones that aren't provided) and user options(ones that are provided)
	local merged_config = vim.tbl_deep_extend("keep", buf_name_config or {}, {
		corner_left = "", corner_left_hl = nil,
		corner_right = "", corner_right_hl = "buf_name_alt",

		padding_left = " ", padding_left_hl = nil,
		padding_right = " ", padding_right_hl = nil,

		default_hl = "buf_name",
	});

	return componentConstructor({
		default_hl = merged_config.default_hl,

		corner_left_hl = merged_config.corner_left_hl,
		corner_left = merged_config.corner_left,

		padding_left_hl = merged_config.padding_left_hl,
		padding_left = merged_config.padding_left,

		icon = icon,
		text = buffer_name ~= "" and " " .. buffer_name or "No name",

		padding_right_hl = merged_config.padding_right_hl,
		padding_right = merged_config.padding_right,

		corner_right_hl = merged_config.corner_right_hl,
		corner_right = merged_config.corner_right,
	});
end

--- Adds padding between components, optionally allows setting the highlight group for it
---@param gap_config statusline_gap_config Configuration table for the component
---@return string
statusline.gap = function (gap_config)
	local _o = "";

	if gap_config ~= nil and gap_config.hl ~= nil then
		_o = _o .. "%#" .. gap_config.hl .. "#";
	end

	_o = _o .. "%=";

	return _o;
end

--- Shows the current cursor position, optionally allows custom text to be shown
---@param position_config statusline_position_config User configuration table for the component
---@return string
statusline.cursor_position = function (position_config)
	---@type statusline_position_config Table containing a merge of default options(ones that aren't provided) and user options(ones that are provided)
	local merged_config = vim.tbl_deep_extend("keep", position_config or {}, {
		corner_left = "", corner_left_hl = "cursor_position_alt",
		corner_right = "", corner_right_hl = nil,

		padding_left = " ", padding_left_hl = "cursor_position",
		padding_right = " ", padding_right_hl = nil,

		segmant_left = "%l",
		segmant_right = "%c",
		separator = "  ",

		icon = "  ", icon_hl = nil,

		bg = "cursor_position"
	});

	return componentConstructor({
		default_hl = merged_config.default_hl,

		corner_left_hl = merged_config.corner_left_hl,
		corner_left = merged_config.corner_left,

		padding_left_hl = merged_config.padding_left_hl,
		padding_left = merged_config.padding_left,

		icon = merged_config.icon,
		text = merged_config.segmant_left .. merged_config.separator .. merged_config.segmant_right,

		padding_right_hl = merged_config.padding_right_hl,
		padding_right = merged_config.padding_right,

		corner_right_hl = merged_config.corner_right_hl,
		corner_right = merged_config.corner_right,
	});
end

--- Function to return the statusline for the specified buffer
---@param buf number Buffer ID
---@return string
statusline.generateStatusline = function (buf)
	local _output = "";

	--[[@as statusline_options]]
	local loaded_config = statusline.buffer_configs[buf];

	-- Current buffer is one of the buffers to skip
	if loaded_config == nil then
		return _output;
	end

	if loaded_config.default_hl ~= nil and loaded_config.default_hl ~= "" then
		_output = "%#" .. loaded_config.default_hl .. "#";
	end


	for _, component in ipairs(loaded_config.components or {}) do
		if component.type == "mode" then
			_output = _output .. statusline.mode(component);
		elseif component.type == "buf_name" then
			_output = _output .. statusline.buf_name(buf, component);
		elseif component.type == "gap" then
			_output = _output .. statusline.gap(component);
		elseif component.type == "cursor_position" then
			_output = _output .. statusline.cursor_position(component);
		end
	end

	return _output;
end

return statusline;
