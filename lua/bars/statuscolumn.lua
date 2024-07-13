local statuscolumn = {};
local ffi = require("ffi");

--- Use some of the internal functions to get fold related information
ffi.cdef([[
	typedef struct {} Error;
	typedef struct {} win_T;
	
	typedef struct {
		int start;
		int level;
		int llevel;
		int lines; // This one only works on closed folds
	} foldinfo_T;

	win_T *find_window_by_handle(int Window, Error *err);
	foldinfo_T fold_info(win_T* wp, int lnum);
]]);

---@type (statuscolumn_options | boolean)[] A list of buffer specific configs
statuscolumn.buffer_configs = {};

---@type { min_priority: number?, max_priority: number?, skip_ns_ids: number[]? }
statuscolumn.signFilter = {};

--- Function to return the value of a specific string/list
---@param property string | table The string/list that will be cut
---@param index number Length of the cut string/list
---@return any
local returnValue = function (property, index)
	if property == nil or index == nil then
		return;
	end

	if vim.islist(property) == false then
		return property;
	end

	if index > #property then
		return property[#property];
	end

	return property[index];
end

--- Take a list of signs and return signs that follow the provided filter(s)
---@param signs sign[] Signs provided to the function
---@param filter_table { min_priority: number?, max_priority: number?, skip_ns_ids: number[]? }
---@return sign[]
local validateSigns = function (signs, filter_table)
	---@type sign[] Validated signs
	local _validated = {};

	if filter_table == nil or vim.tbl_isempty(filter_table) == true then
		return signs;
	end

		for _, sign in ipairs(signs) do
		--[[@as sign_details Sign related details]]
		local details = sign[4];

		local priority = details["priority"];
		local ns_id = details["ns_id"];

		if type(filter_table.min_priority) == "number" and priority < filter_table.min_priority then
			goto skipSign;
		end

		if type(filter_table.max_priority) == "number" and priority > filter_table.max_priority then
			goto skipSign;
		end

		if vim.islist(filter_table.skip_ns_ids) and vim.tbl_contains(filter_table.skip_ns_ids, ns_id) then
			goto skipSign;
		end

		table.insert(_validated, sign)
		::skipSign::
	end

	return _validated;
end


--- Initializes the statuscolumn for a window
---@param buffer number The buffer handle
---@param user_config statuscolumn_config? The user configuration table
statuscolumn.init = function (buffer, user_config)
	if user_config == nil then
		statuscolumn.buffer_configs[buffer] = false;
	elseif user_config.enable == false then
		statuscolumn.buffer_configs[buffer] = {};
	else
		statuscolumn.buffer_configs[buffer] = user_config.options;
	end

	local windows = vim.fn.win_findbuf(buffer);

	if statuscolumn.buffer_configs[buffer] == false then
		for _, window in ipairs(windows) do
			vim.wo[window].statuscolumn = "";
		end
	else
		for _, window in ipairs(windows) do
			if user_config ~= nil and user_config.options ~= nil and user_config.options.set_defaults == true then
				vim.wo[window].relativenumber = true;

				vim.wo[window].foldcolumn = "0";
				vim.wo[window].signcolumn = "no";

				vim.wo[window].numberwidth = 1;
			end

			vim.wo[window].statuscolumn = "%!v:lua.require('bars/statuscolumn').generateStatuscolumn(" .. buffer .. ")";
		end
	end
end

--- Component to add a gap to the statuscolumn
---@param gap_config statuscolumn_gap_config The configuration options
---@return string
statuscolumn.gap = function (gap_config)
	local _output = "";

	if type(gap_config.hl) == "string" then
		_output = "%#" .. gap_config.hl .. "#"
	end

	_output = _output .. gap_config.text;

	return _output;
end

--- Component that adds a custom border to the statuscolumn
---@param border_config statuscolumn_border_config The configuration options
---@return string
statuscolumn.border = function (border_config)
	local _output = "";

	if border_config.hl == nil then
		return border_config.text;
	end

	if vim.islist(border_config.hl) == true then
		if (vim.v.relnum + 1) < #border_config.hl then
			_output = "%#" .. border_config.hl[vim.v.relnum + 1] .. "#";
		else
			_output = "%#" .. border_config.hl[#border_config.hl] .. "#";
		end

		_output = _output .. border_config.text;
	else
		if vim.v.relnum >= border_config.hl.from and vim.v.relnum <= border_config.hl.to then
			_output = "%#" .. border_config.hl.prefix .. vim.v.relnum .. "#";
		else
			_output = "%#" .. border_config.hl.prefix .. border_config.hl.to .. "#";
		end

		_output = _output .. border_config.text
	end

	return _output;
end

--- Component that shows various types of line numbers.
---@param buffer number The buffer handle
---@param number_config statuscolumn_number_config Configuration table for the line numbers
---@return string
statuscolumn.number = function (buffer, number_config)
	local _output, _color = "", "";
	local max_len = vim.fn.strchars(vim.api.nvim_buf_line_count(buffer));

	if vim.islist(number_config.hl) == true then
		if (vim.v.relnum + 1) < #number_config.hl then
			_color = "%#" .. number_config.hl[vim.v.relnum + 1] .. "#";
		else
			_color = "%#" .. number_config.hl[#number_config.hl] .. "#";
		end
	elseif type(number_config.hl) == "table" then
		if vim.v.relnum >= number_config.hl.from and vim.v.relnum <= number_config.hl.to then
			_color = "%#" .. number_config.hl.prefix .. vim.v.relnum .. "#";
		else
			_color = "%#" .. number_config.hl.prefix .. number_config.hl.to .. "#";
		end
	end

	if number_config.mode == "normal" then
		_output = vim.v.lnum;
	elseif number_config.mode == "relative" then
		_output = vim.v.relnum;
	elseif number_config.mode == "hybrid" then
		_output = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum;
	end

	-- Right align the text
	if vim.fn.strchars(_output) <= max_len then
		_output = string.rep(" ", max_len - vim.fn.strchars(_output)) .. _output
	end

	return _color ~= "" and _color .. _output or _output;
end

--- Component to show a custom fold column
---@param fold_config statuscolumn_fold_config The configuration table
---@return string
statuscolumn.fold = function (fold_config)
	local win = ffi.C.find_window_by_handle(0, nil);

	local after = (vim.v.lnum + 1) <= vim.fn.line("$") and (vim.v.lnum + 1) or vim.fn.line("$");

	local foldInfo = ffi.C.fold_info(win, vim.v.lnum)
	local foldInfo_after = ffi.C.fold_info(win, after);

	local _output = "";

	if fold_config.mode == "simple" then
		if type(fold_config.hl.default) == "string" then
			_output = "%#" .. fold_config.hl.default .. "#";
		end

		-- Handle lines with no folds
		if foldInfo.level == 0 then
			_output = type(fold_config.space) == "string" and _output .. fold_config.space or _output .. " ";

			goto mark_added;
		end

		-- Handle lines with a closed fold
		if foldInfo.start == vim.v.lnum and foldInfo.lines ~= 0 then
			_output = type(fold_config.hl.closed) == "string" and _output .. "%#" .. fold_config.hl.closed .. "#" or _output;
			_output = type(fold_config.text.closed) == "string" and _output .. fold_config.text.closed or _output .. "↦";

			goto mark_added;
		end

		-- Handle lines with an open fold
		if foldInfo.start == vim.v.lnum then
			_output = type(fold_config.hl.opened) == "string" and _output .. "%#" .. fold_config.hl.opened .. "#" or _output;
			_output = type(fold_config.text.opened) == "string" and _output .. fold_config.text.opened or _output .. "↧";

			goto mark_added;
		end

		-- Lines that are inside the folds
		_output = type(fold_config.hl.scope) == "string" and _output .. "%#" .. fold_config.hl.scope .. "#" or _output;
		_output = type(fold_config.text.scope) == "string" and _output .. fold_config.text.scope or _output .. " ";
	elseif fold_config.mode == "line" then
		if type(fold_config.hl.default) == "string" then
			_output = "%#" .. fold_config.hl.default .. "#";
		end

		-- Handle lines with no folds
		if foldInfo.level == 0 then
			_output = type(fold_config.space) == "string" and _output .. fold_config.space or _output .. " ";

			goto mark_added;
		end

		local _color, _icon;

		-- Handle lines with a closed fold
		if foldInfo.start == vim.v.lnum and foldInfo.lines ~= 0 then
			_color = returnValue(fold_config.hl.closed, foldInfo.level);
			_icon = returnValue(fold_config.text.closed, foldInfo.level);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		end

		-- Handle lines in an open fold
		if foldInfo.start == vim.v.lnum then
			_color = returnValue(fold_config.hl.opened, foldInfo.llevel);
			_icon = returnValue(fold_config.text.opened, foldInfo.llevel);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		elseif foldInfo_after.level == 0 or vim.v.lnum == after then
			_color = returnValue(fold_config.hl.edge, foldInfo.level);
			_icon = returnValue(fold_config.text.edge, foldInfo.level);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		elseif foldInfo.level >= foldInfo_after.level and foldInfo.start ~= foldInfo_after.start then
			_color = returnValue(fold_config.hl.branch, foldInfo.level);
			_icon = returnValue(fold_config.text.branch, foldInfo.level);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		else
			_color = returnValue(fold_config.hl.scope, foldInfo.level);
			_icon = returnValue(fold_config.text.scope, foldInfo.level);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		end
	end

	::mark_added::
	return _output;
end

--- Function to create a sign column
---@param buf number Buffer handle
---@param user_config statuscolumn_sign_config Configuration table for the sign column
---@return string
statuscolumn.sign = function (buf, user_config)
	---@type statuscolumn_sign_config
	local merged_config = vim.tbl_deep_extend("keep", user_config, {
		resize = true,
		space = "  ",
		resize_space = " "
	});

	local bufSigns = vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { type = "sign" })
	local signs = validateSigns(vim.api.nvim_buf_get_extmarks(buf, -1, { vim.v.lnum - 1, 0 }, { vim.v.lnum - 1, -1 }, { type = "sign", details = true }), merged_config.rules);

	if statuscolumn.signFilter ~= nil and vim.tbl_isempty(statuscolumn.signFilter) == false then
		signs = validateSigns(signs, statuscolumn.signFilter)
	end

	if vim.tbl_isempty(signs) == true then
		if merged_config.resize == true and #bufSigns == 0 then
			return merged_config.resize_space;
		end

		return merged_config.space;
	end

	local visible_sign;
	local current_priority = 0;

	for _, sign in ipairs(signs) do
		local priority = sign[4]["priority"];

		if priority >= current_priority then
			visible_sign = sign[4];
		end

		current_priority = priority;
	end

	-- return 'H';
	if visible_sign["sign_hl_group"] ~= nil and visible_sign["sign_text"] ~= nil then
		return "%#" .. visible_sign["sign_hl_group"] .. "#" .. visible_sign["sign_text"];
	elseif visible_sign["sign_text"] ~= nil then
		return visible_sign["sign_text"];
	else
		return merged_config.space;
	end
end

--- Creates a statuscolumn for the given window
---@param buf number The buffer handle
---@return string
statuscolumn.generateStatuscolumn = function (buf)
	local _output = "";

	--[[@as statuscolumn_options]]
	local loaded_config = statuscolumn.buffer_configs[buf];

	-- Current buffer is one of the buffers to skip
	if loaded_config == nil then
		return _output;
	end

	if loaded_config.default_hl ~= nil and loaded_config.default_hl ~= "" then
		_output = "%#" .. loaded_config.default_hl .. "#";
	end

	for _, component in ipairs(loaded_config.components or {}) do
		if component.type == "gap" then
			_output = _output .. statuscolumn.gap(component --[[@as statuscolumn_gap_config]])
		elseif component.type == "border" then
			_output = _output .. statuscolumn.border(component --[[@as statuscolumn_border_config]])
		elseif component.type == "number" then
			_output = _output .. statuscolumn.number(buf, component --[[@as statuscolumn_number_config]])
		elseif component.type == "fold" then
			_output = _output .. statuscolumn.fold(component --[[@as statuscolumn_fold_config]])
		elseif component.type == "sign" then
			_output = _output .. statuscolumn.sign(buf, component --[[@as statuscolumn_sign_config]])
		end
	end

	return _output;
end


return statuscolumn;
