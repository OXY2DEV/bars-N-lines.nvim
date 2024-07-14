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

return utils;
