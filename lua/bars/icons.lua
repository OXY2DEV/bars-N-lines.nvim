local icons = {};

icons.default = "󱀶 ";

icons.by_name = {
};

icons.by_ft= {
    ["python"] = " ",
    ["javascript"] = "󰌞 ",
    ["java"] = " ",
    ["cs"] = " ",          -- C#
    ["c"] = " ",         -- C++
    ["cpp"] = " ",         -- C++
    ["php"] = " ",
    ["swift"] = "󰛥 ",
    ["go"] = " ",
    ["ruby"] = " ",
    ["kotlin"] = "󱈙 ",
    ["typescript"] = "󰛦",
    ["rust"] = " ",
    ["scala"] = " ",
    ["perl"] = " ",
    ["lua"] = " ",
    ["r"] = "󰟔 ",
    ["dart"] = " ",
    ["haskell"] = " ",
    ["elixir"] = " ",
    ["clojure"] = " ",
    ["sh"] = " ",          -- Shell
    ["fsharp"] = " ",      -- F#
    ["asm"] = " ",         -- Assembly
    ["sql"] = " ",
    ["fortran"] = "󱈚 ",
    ["erlang"] = " ",
    ["prolog"] = " ",
    ["lisp"] = " ",
    ["julia"] = " ",
    ["bash"] = " ",
    ["ocaml"] = " ",
    ["d"] = " ",
    ["nim"] = " ",
    ["crystal"] = " ",
    ["zig"] = " ",
    ["sass"] = " ",
    ["wolfram"] = "",
    ["zsh"] = " ",
	["html"] = " ",
	["css"] = " ",
	["yaml"] = " ",
	["conf"] = " ",
	["json"] = "󰘦 ",
	["vim"] = " ",
	["txt"] = "󰈚 ",
	["markdown"] = " ",
	["quarto"] = " ",
	["rmd"] = " ",
}


icons.get = function (name)
	local ft = vim.filetype.match({ filename = name });
	local ext = vim.fn.fnamemodify(name, ":e");

	if icons.by_ft[ft or ext] then
		return icons.by_ft[ft or ext];
	else
		return "";
	end
end

return icons;
