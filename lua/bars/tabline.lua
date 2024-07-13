local tabline = {};
local devicons = require("nvim-web-devicons");

tabline.buffer_list = {};

--- Function that renders the text to the tabline
---@param list tabline_component_raw[] List of components to render
---@param width number? Maximum character length
---@param separator_config tabline_separator_config? Configuration table for the separator
---@return string
tabline.renderer = function (list, width, separator_config)
	local max_len = width ~= nil and (separator_config ~= nil and width - vim.fn.strchars(separator_config.text) or width) or 999;
	local len = 0;

	local fitted_in_space = true;
	local _o = "";

	local exceeds_length = function (current_len, text)
		if text == nil then
			return false;
		end

		if current_len + vim.fn.strchars(text) > max_len then
			return true;
		end

		return false;
	end

	local truncate = function (text)
		if exceeds_length(len, text) then
			local short_len = max_len - len;

			fitted_in_space = false;
			len = len + short_len;
			return string.sub(text, 1, short_len);
		end

		len = len + vim.fn.strchars(text);
		return text;
	end

	for _, part in ipairs(list) do
		if part.prefix ~= nil then
			_o = _o .. part.prefix;
		end

		if part.click ~= nil then
			_o = _o .. "%@" .. part.click .. "@";
		end

		if part.bg ~= nil then
			_o = _o .. "%#" .. part.bg .. "#";
		end


		if exceeds_length(len, part.corner_left) == false and part.corner_left_hl ~= nil then
			_o = _o .. "%#" .. part.corner_left_hl .. "#";
		end

		if type(part.corner_left) == "string" then
			_o = _o .. truncate(part.corner_left);
		end


		if exceeds_length(len, part.padding_left) == false and part.padding_left_hl ~= nil then
			_o = _o .. "%#" .. part.padding_left_hl .. "#";
		end

		if type(part.padding_left) == "string" then
			_o = _o .. truncate(part.padding_left);
		end


		if exceeds_length(len, part.icon) == false and part.icon_hl ~= nil then
			_o = _o .. "%#" .. part.icon_hl .. "#";
		end

		if type(part.icon) == "string" then
			_o = _o .. truncate(part.icon);
		end

		if type(part.text) == "string" then
			_o = _o .. truncate(part.text);
		end


		if exceeds_length(len, part.padding_right) == false and part.padding_right_hl ~= nil then
			_o = _o .. "%#" .. part.padding_right_hl .. "#";
		end

		if type(part.padding_right) == "string" then
			_o = _o .. truncate(part.padding_right);
		end


		if exceeds_length(len, part.corner_right) == false and part.corner_right_hl ~= nil then
			_o = _o .. "%#" .. part.corner_right_hl .. "#";
		end

		if type(part.corner_right) == "string" then
			_o = _o .. truncate(part.corner_right);
		end

		if part.postfix ~= nil then
			_o = _o .. part.postfix;
		end
	end

	if separator_config ~= nil and separator_config.on_skip ~= nil and pcall(separator_config.on_skip) then
		separator_config.on_skip();
	end


	if fitted_in_space == false and separator_config ~= nil then
		local _s = "";

		if separator_config.condition ~= nil and pcall(separator_config.condition) == true and separator_config.condition() == false then
			goto separator_disabled;
		end

		if separator_config.hl ~= nil then
			_s = "%#" .. separator_config.hl .. "#";
		end

		_s = _s .. separator_config.text;

		if separator_config.direction == "after" or separator_config.direction == nil then
			_o = _o .. _s;
		elseif separator_config.direction == "before" then
			_o = _s .. _o;
		end

		if separator_config.on_complete ~= nil and pcall(separator_config.on_complete) then
			separator_config.on_complete();
		end

		::separator_disabled::
	end

	return _o;
end

---@type tabline_options User configuration table for the tabline
tabline.config = {};

---@type boolean Default variable to control the rendering of separators from different components
tabline.separator_set = false;

--- Function to set the global tabline
---@param user_config tabline_config
tabline.init = function (user_config)
	if user_config == nil or user_config.enable == false then
		return;
	else
		tabline.config = user_config.options;
	end

	-- tabline.buffer_list = vim.api.nvim_list_bufs();
	vim.o.tabline = "%!v:lua.require('bars/tabline').generateTabline()";
end

--- Validates the lizt of buffers to remove unwanted ones
---@param buffers number[] List of unfiltered buffers
---@param conditions tabline_buf_filter_config Table used for filtering the list of buffers
---@return number[]
tabline.bufValidate = function (buffers, conditions)
	if buffers == nil then
		return {};
	elseif conditions == nil then
		return buffers;
	end

	local _o = {};

	for _, buf in ipairs(buffers) do
		if conditions.filetypes ~= nil and vim.list_contains(conditions.filetypes, vim.bo[buf].filetype) == true then
			goto skip;
		elseif conditions.buftypes ~= nil and vim.list_contains(conditions.buftypes, vim.bo[buf].buftype) == true then
			goto skip;
		else
			if conditions.names == nil then
				table.insert(_o, buf);
				goto skip;
			end

			for _, name in ipairs(conditions.names) do
				if string.match(vim.api.nvim_buf_get_name(buf), name) ~= nil then
					goto skip;
				end
			end

			table.insert(_o, buf);
		end

		::skip::
	end

	return _o;
end

--- Function to scroll the buffer list to the left
tabline.scrollLeft = function ()
	if tabline.buffer_list == nil then
		return;
	end

	if tabline.buffer_list[1] == vim.api.nvim_get_current_buf() then
		local tmp = table.remove(tabline.buffer_list, 2);

		table.insert(tabline.buffer_list, #tabline.buffer_list + 1, tmp);
	else
		local tmp = table.remove(tabline.buffer_list, 1);

		table.insert(tabline.buffer_list, #tabline.buffer_list + 1, tmp);
	end
end

--- Function to scroll the buffer list to the right
tabline.scrollRight = function ()
	if tabline.buffer_list == nil then
		return;
	end

	if tabline.buffer_list[1] == vim.api.nvim_get_current_buf() then
		local tmp = table.remove(tabline.buffer_list, #tabline.buffer_list);

		table.insert(tabline.buffer_list, 2, tmp);
	else
		local tmp = table.remove(tabline.buffer_list, #tabline.buffer_list);

		table.insert(tabline.buffer_list, 1, tmp);
	end
end

--- Function to show all the active tabs,like workspaces
---@param tab_config tabline_list_item_config Configuration table for the tb component
---@return string
tabline.tabs = function (tab_config)
	local tabs = vim.api.nvim_list_tabpages();
	local current_tab = vim.api.nvim_get_current_tabpage();

	---@type tabline_list_item_config
	local merged_config = vim.tbl_deep_extend("keep", tab_config, {
		inactive = {
			corner_left = "", corner_left_hl = "tabline_tab_inactive",
			corner_right = "", corner_right_hl = "tabline_tab_inactive",

			padding_left = " ", padding_left_hl = "tabline_tab_inactive_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		active = {
			corner_left = "", corner_left_hl = "tabline_tab_active",
			corner_right = "", corner_right_hl = "tabline_tab_active",

			padding_left = " ", padding_left_hl = "tabline_tab_active_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		max_entries = 5,
	});

	local tmp = {};
	for label, id in ipairs(tabs) do
		if id == current_tab then
			if #tmp >= merged_config.max_entries then
				table.insert(tmp, 1, vim.tbl_extend("keep", merged_config.active, {
					prefix = "%" .. label .. "T", postfix = "%X",
					text = tostring(id)
				}));
			else
				table.insert(tmp, vim.tbl_extend("keep", merged_config.active, {
					prefix = "%" .. label .. "T", postfix = "%X",
					text = tostring(id)
				}));
			end
		else
			table.insert(tmp, vim.tbl_extend("keep", merged_config.inactive, {
				prefix = "%" .. label .. "T", postfix = "%X",
				text = tostring(id)
			}));
		end
	end

	return tabline.renderer(tmp, merged_config.width or 25, merged_config.separator);
end

--- Adds gap between components, optionally allows colors
---@param gap_config tabline_gap_config Configuration table for the gap component
---@return string
tabline.gap = function (gap_config)
	local _o = "";

	if gap_config.hl ~= nil then
		_o = _o .. "%#" .. gap_config.hl .. "#";
	end

	_o = _o .. "%=";

	return _o;
end

--- Function to show some text
---@param txt_config tabline_component_raw
---@return string
tabline.text = function (txt_config)
	return tabline.renderer({ txt_config });
end

--- Shows all the opened buffers(ones that are in some window)
---@param buf_config tabline_list_item_config
---@return string
tabline.windows = function (buf_config)
	local this_tabpage = vim.api.nvim_get_current_tabpage();
	local windows = vim.api.nvim_tabpage_list_wins(this_tabpage);

	---@type tabline_list_item_config Merged configuration table
	local merged_config = vim.tbl_deep_extend("keep", buf_config, {
		inactive = {
			corner_left = "", corner_left_hl = "tabline_tab_inactive",
			corner_right = "", corner_right_hl = "tabline_tab_inactive",

			padding_left = " ", padding_left_hl = "tabline_tab_inactive_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		active = {
			corner_left = "", corner_left_hl = "tabline_tab_active",
			corner_right = "", corner_right_hl = "tabline_tab_active",

			padding_left = " ", padding_left_hl = "tabline_tab_active_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		separator = {
			text = "", hl = "tabline_buf_inactive",
			direction = "after",

			condition = function ()
				if tabline.separator_set == true then
					return false;
				end

				return true
			end,

			on_complete = function ()
				tabline.separator_set = true;
			end,

			on_skip = function ()
				tabline.separator_set = false;
			end
		},

		max_entries = 4
	})

	local tmp = {};
	local checked_bufs = {};

	for _, win in ipairs(windows) do
		local buffer = vim.api.nvim_win_get_buf(win);
		local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":t");
		local icon, _ = devicons.get_icon(buffer_name, nil, { default = true })

		if buffer == vim.api.nvim_get_current_buf() and vim.list_contains(checked_bufs, buffer) == false then
			if #tmp >= merged_config.max_entries then
				table.insert(tmp, 1, vim.tbl_extend("keep", merged_config.active, {
					icon = icon .. " ",
					text = buffer_name ~= "" and buffer_name or "No name"
				}));
			else
				table.insert(tmp, vim.tbl_extend("keep", merged_config.active, {
					icon = icon .. " ",
					text = buffer_name ~= "" and buffer_name or "No name"
				}));
			end
		elseif buffer ~= vim.api.nvim_get_current_buf() then
			table.insert(tmp, vim.tbl_extend("keep", merged_config.inactive, {
				icon = icon .. " ",
				text = buffer_name ~= "" and buffer_name or "No name"
			}));
		end

		table.insert(checked_bufs, buffer);
	end

	return tabline.renderer(tmp, merged_config.width ~= nil and merged_config.width or vim.o.columns - 26, merged_config.separator);
end

---Lists all the buffers that have been loaded
---@param buf_config tabline_buffers_config User provided configuration table
---@return string
tabline.buffers = function (buf_config)
	---@type tabline_buffers_config Merged configuration table
	local merged_config = vim.tbl_deep_extend("keep", buf_config, {
		ignore = {
			filetypes = { "" },
			buftypes = {},

			names = {}
		},

		inactive = {
			corner_left = "", corner_left_hl = "tabline_buf_inactive",
			corner_right = "", corner_right_hl = "tabline_buf_inactive",

			padding_left = " ", padding_left_hl = "tabline_buf_inactive_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		active = {
			corner_left = "", corner_left_hl = "tabline_buf_active",
			corner_right = "", corner_right_hl = "tabline_buf_active",

			padding_left = " ", padding_left_hl = "tabline_buf_active_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		separator = {
			text = "", hl = "tabline_buf_inactive",
			direction = "after",

			condition = function ()
				if tabline.separator_set == true then
					return false;
				end

				return true
			end,

			on_complete = function ()
				tabline.separator_set = true;
			end,

			on_skip = function ()
				tabline.separator_set = false;
			end
		},

		max_entries = 4
	});

	if vim.tbl_isempty(tabline.buffer_list) or #tabline.buffer_list ~= #tabline.bufValidate(vim.api.nvim_list_bufs(), merged_config.ignore) then
		tabline.buffer_list = tabline.bufValidate(vim.api.nvim_list_bufs(), merged_config.ignore)
	end

	local tmp = {};
	local checked_bufs = {};

	for buf_index, buf in ipairs(tabline.buffer_list) do
		if vim.api.nvim_buf_is_valid(buf) == false then
			table.remove(tabline.buffer_list, buf_index);
			goto bufSkip;
		end

		local bufType = vim.bo[buf].buftype;
		local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t");
		local icon, _ = devicons.get_icon(buffer_name, nil, { default = true });

		if buffer_name == "" or vim.api.nvim_buf_is_loaded(buf) == false or bufType == "help" then
			goto bufSkip;
		end

		if buf == vim.api.nvim_get_current_buf() and vim.list_contains(checked_bufs, buf) == false then
			if #tmp >= merged_config.max_entries then
				table.insert(tmp, 1, vim.tbl_extend("keep", merged_config.active, {
					prefix = "%@v:lua.__bufOpen.buffer_" .. buf .. "@", postfix = "%X",
					icon = icon .. " ",
					text = buffer_name or "No name"
				}));
			else
				table.insert(tmp, vim.tbl_extend("keep", merged_config.active, {
					prefix = "%@v:lua.__bufOpen.buffer_" .. buf .. "@", postfix = "%X",
					icon = icon .. " ",
					text = buffer_name or "No name"
				}));
			end
		elseif buf ~= vim.api.nvim_get_current_buf() then
			table.insert(tmp, vim.tbl_extend("keep", merged_config.inactive, {
					prefix = "%@v:lua.__bufOpen.buffer_" .. buf .. "@", postfix = "%X",
				icon = icon .. " ",
				text = buffer_name or "No name"
			}));
		end

		table.insert(checked_bufs, buf);
		::bufSkip::
	end

	return tabline.renderer(tmp, merged_config.width ~= nil and merged_config.width or vim.o.columns - 26, merged_config.separator);
end

--- Function to generate the tabline, it is global
---@return string
tabline.generateTabline = function ()
	local _output = "";

	if tabline.config.default_hl ~= nil and tabline.config.default_hl ~= "" then
		_output = "%#" .. tabline.config.default_hl .. "#";
	end

	for _, component in ipairs(tabline.config.components or {}) do
		if component.type == "gap" then
			_output = _output .. tabline.gap(component);
		elseif component.type == "text" then
			_output = _output .. tabline.text(component);
		elseif component.type == "tabs" then
			_output = _output .. tabline.tabs(component);
		elseif component.type == "windows" then
			_output = _output .. tabline.windows(component);
		elseif component.type == "buffers" then
			_output = _output .. tabline.buffers(component);
		end
	end

	return _output;
end

return tabline;
