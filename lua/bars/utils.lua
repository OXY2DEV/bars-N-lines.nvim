local utils = {};

utils.list_attached_wins = function (buffer)
	local windows = vim.api.nvim_list_wins();
	local filtered = {};

	for _, window in ipairs(windows) do
		if vim.api.nvim_win_get_buf(window) == buffer then
			table.insert(filtered, window);
		end
	end

	return filtered;
end

utils.find_config = function (config, buf)
	local filetype = vim.bo[buf].filetype;
	local buftype = vim.bo[buf].buftype;

	if config.custom then
		for _, custom in ipairs(config.custom) do
			if vim.islist(custom.filetypes) and vim.list_contains(custom.filetypes, filetype) then
				return custom
			elseif vim.islist(custom.buftypes) and vim.list_contains(custom.buftypes, buftype) then
				return custom
			end
		end
	end

	return config.default or {};
end

---@param hl string
---@return string | nil
utils.set_hl = function (hl)
	if type(hl) ~= "string" then
		return;
	end

	if hl:match("%#(.-)#") then
		return hl;
	end

	return "%#" .. hl .. "#"
end

utils.get_len = function (string)
	string = string:gsub("(%%#.-#)", "");

	return vim.fn.strchars(string);
end

utils.text_out = function (inp)
	if type(inp) == "string" then
		return inp;
	elseif type(inp) == "function" and pcall(inp) then
		return inp();
	end

	return "";
end

utils.clamp = function (val, min, max)
	return math.min(math.max(val, min), max)
end

utils.format_input = function (input, number)
	if not vim.islist(input) then
		return input;
	end

	return input[utils.clamp(number, 1, #input)] or "";
end

utils.sort_by_priority = function (list, min_lval)
	local _item = {};
	local lval = min_lval or 0;

	for _, item in ipairs(list or {}) do
		if item[4] and item[4]["priority"] and item[4]["priority"] > lval then
			table.insert(_item, item)
		end
	end

	return _item;
end

utils.truncate = function (text, max_len)
	if vim.fn.strchars(text) <= max_len then
		return text;
	else
		return vim.fn.strcharpart(text, 0, max_len);
	end
end

utils.create_truncated_segmants = function (segmants, max_size)
	local size = 0;
	local _o = "";

	for _, segmant in ipairs(segmants) do
		local pad_after = vim.fn.strchars(segmant.padding_right or "");
		local cor_after = vim.fn.strchars(segmant.corner_right or "");
		--
		if segmant.before then
			_o = _o .. segmant.before;
		end

		if segmant.corner_left then
			if segmant.corner_left_hl then
				_o = _o .. utils.set_hl(segmant.corner_left_hl);
			end

			_o = _o .. utils.truncate(segmant.corner_left, max_size - (size + (pad_after + cor_after)));
			size = size + vim.fn.strchars(utils.truncate(segmant.corner_left, max_size - (size + (pad_after + cor_after))));
		end

		if segmant.padding_left then
			if segmant.padding_left_hl then
				_o = _o .. utils.set_hl(segmant.padding_left_hl);
			end

			_o = _o .. utils.truncate(segmant.padding_left, max_size - (size + (pad_after + cor_after)));
			size = size + vim.fn.strchars(utils.truncate(segmant.padding_left, max_size - (size + (pad_after + cor_after))));
		end

		if segmant.icon then
			if segmant.icon_hl then
				_o = _o .. utils.set_hl(segmant.icon_hl);
			end

			_o = _o .. utils.truncate(segmant.icon, max_size - (size + (pad_after + cor_after)));
			size = size + vim.fn.strchars(utils.truncate(segmant.icon, max_size - (size + (pad_after + cor_after))));
		end

		if segmant.text then
			if segmant.text_hl then
				_o = _o .. utils.set_hl(segmant.text_hl);
			end

			_o = _o .. utils.truncate(segmant.text, max_size - (size + (pad_after + cor_after)));
			size = size + vim.fn.strchars(utils.truncate(segmant.text, max_size - (size + (pad_after + cor_after))));
		end

		if segmant.padding_right then
			if segmant.padding_right_hl then
				_o = _o .. utils.set_hl(segmant.padding_right_hl);
			end

			_o = _o .. utils.truncate(segmant.padding_right, max_size - size);
			size = size + vim.fn.strchars(segmant.padding_right);
		end

		if segmant.corner_right then
			if segmant.corner_right_hl then
				_o = _o .. utils.set_hl(segmant.corner_right_hl);
			end

			_o = _o .. utils.truncate(segmant.corner_right, max_size - size);
			size = size + vim.fn.strchars(segmant.corner_right);
		end
	end

	return _o;
end

utils.create_segmant = function (segmant, validator)
	local _o = "";

	---@param val (string | string[])?
	---@return string
	local get_val = function (val)
		if type(val) ~= "table" then
			return val --[[@as string]];
		elseif val and validator then
			return validator(val)
		end

		return "";
	end

	if segmant.before then
		_o = _o .. segmant.before;
	end

	if segmant.corner_left then
		if segmant.corner_left_hl then
			_o = _o .. utils.set_hl(get_val(segmant.corner_left_hl)) --[[@as string]];
		end

		_o = _o .. get_val(segmant.corner_left);
	end

	if segmant.padding_left then
		if segmant.padding_left_hl then
			_o = _o .. utils.set_hl(get_val(segmant.padding_left_hl)) --[[@as string]];
		end

		_o = _o .. get_val(segmant.padding_left);
	end

	if segmant.icon then
		if segmant.icon_hl then
			_o = _o .. utils.set_hl(get_val(segmant.icon_hl)) --[[@as string]];
		end

		_o = _o .. get_val(segmant.icon);
	end


	if segmant.text then
		if segmant.text_hl then
			_o = _o .. utils.set_hl(get_val(segmant.text_hl)) --[[@as string]];
		end

		_o = _o .. get_val(segmant.text);
	end

	if segmant.padding_right then
		if segmant.padding_right_hl then
			_o = _o .. utils.set_hl(get_val(segmant.padding_right_hl)) --[[@as string]];
		end

		_o = _o .. get_val(segmant.padding_right);
	end

	if segmant.corner_right then
		if segmant.corner_right_hl then
			_o = _o .. utils.set_hl(get_val(segmant.corner_right_hl)) --[[@as string]];
		end

		_o = _o .. get_val(segmant.corner_right);
	end

	if segmant.after then
		_o = _o .. segmant.after;
	end

	return _o;
end

utils.get_index = function (list, value)
	for i, v in ipairs(list) do
		if v == value then
			return i;
		end
	end
end

utils.switch_to_buf = function (buf)
	local tabs = vim.api.nvim_list_tabpages();

	for _, tab in ipairs(tabs) do
		local windows = vim.api.nvim_tabpage_list_wins(tab);

		for _, window in ipairs(windows) do
			if vim.api.nvim_win_get_buf(window) == buf then
				vim.api.nvim_set_current_tabpage(tab);
				vim.api.nvim_set_current_win(window);
				return;
			end
		end
	end
end

return utils;
