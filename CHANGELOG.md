# Changelog

## [3.0.0](https://github.com/OXY2DEV/bars.nvim/compare/v2.2.0...v3.0.0) (2026-05-31)


### ⚠ BREAKING CHANGES

* **winhar:** Changed name for TSNode component(`__lockup -> _ellipsis`)
* Preparation for exposing internal variables
* Removed unnecessary config value

### rrfactir

* Removed unnecessary config value ([6c8cf9b](https://github.com/OXY2DEV/bars.nvim/commit/6c8cf9b40540f903c6373b64e8e4493c81bfe468))


### Features

* Added `Start` & `Stop` sub-commands ([db9dca8](https://github.com/OXY2DEV/bars.nvim/commit/db9dca8a8465275a3e203caedbd6093b2778104a))
* Listen to OptionSet ([0246e9d](https://github.com/OXY2DEV/bars.nvim/commit/0246e9d063b8b186983e502411b01ffa9537e8cf))
* **statuscolumn, statusline, winbar:** Added ability to ignore custom values ([c03c3ee](https://github.com/OXY2DEV/bars.nvim/commit/c03c3eeb5629c77a392b1ed5760df60568b84a8a))
* **statuscolumn:** Added `Toggle`, `Enable`, `Disable` etc. command support ([6079b0d](https://github.com/OXY2DEV/bars.nvim/commit/6079b0dba3726af26baa303b6a6e8056dc802cf4))
* **statusline:** Added action support ([3588177](https://github.com/OXY2DEV/bars.nvim/commit/3588177eae189079ed5aeba16a2da70852f4a408))
* **statusline:** Added missing `Toggle` function ([8d8085c](https://github.com/OXY2DEV/bars.nvim/commit/8d8085c9001f4de928e07cdfe53b211bc9b19be2))
* **statusline:** Statusline no longer gets overwritten by `quickfix` window ([745c5a4](https://github.com/OXY2DEV/bars.nvim/commit/745c5a4d164703ce45cc181457e2d4318aed87cd))
* **statusline:** Support for other icon providers ([acc6f04](https://github.com/OXY2DEV/bars.nvim/commit/acc6f04076db7924c862f208449ea3e5cdbd1d3a))
* **statusline:** Use `gitsigns.nvim` when available for branch name ([b774825](https://github.com/OXY2DEV/bars.nvim/commit/b7748251cb0e44a11c32d40d6d9bfb756e0ca307))
* **tabline:** Added `Toggle`, `Enable`, `Disable` etc. command support ([a8beb06](https://github.com/OXY2DEV/bars.nvim/commit/a8beb066266e204eeac9adbe9b45226ebb56dcb6))
* Update styles when filetype & buftype changes ([a6725bc](https://github.com/OXY2DEV/bars.nvim/commit/a6725bcf01d88241770ce77cde2c4c68df344777))
* **winbar:** Added `Toggle`, `Enable`, `Disable` etc. command support ([4976871](https://github.com/OXY2DEV/bars.nvim/commit/4976871625c35e2e93b0dfabed7d5105649236c5))


### Bug Fixes

* Added missing setup function ([6cdecdb](https://github.com/OXY2DEV/bars.nvim/commit/6cdecdb091f5aa8c1c842024a9176b799a8b2446))
* Allow user specified styles ([71124bb](https://github.com/OXY2DEV/bars.nvim/commit/71124bbbbed090588fcdbc529bc9fabc02756500))
* Fixed attachmemt issues for some windows ([2ad6549](https://github.com/OXY2DEV/bars.nvim/commit/2ad6549f559f4cd1b1664cf86185b757f6e98027))
* Fixed flashing of default bars when `OptionSet` is triggered ([0cdb6ef](https://github.com/OXY2DEV/bars.nvim/commit/0cdb6ef7de5090b141db3bcc81b8c0be4a2be756))
* **generics:** `Toggle` now works as expected ([a533c68](https://github.com/OXY2DEV/bars.nvim/commit/a533c686e811c64b932e431ad0c989a26b18ec50))
* **global:** Fixed a bug with incorrect state variable access ([329ef0a](https://github.com/OXY2DEV/bars.nvim/commit/329ef0ac29db65bcf9518b4542974fad004ae8c8))
* **highlights:** Updated `BarsFt6` definition ([06ad70f](https://github.com/OXY2DEV/bars.nvim/commit/06ad70f9fadff10ff1a16864516a6bcd822c47f7))
* **statuscolumn, statusline, winbar:** Custom values set by user & plugins is now respected ([6f40fa4](https://github.com/OXY2DEV/bars.nvim/commit/6f40fa452b4df8101514add507c4232f5bb47071))
* **statuscolumn:** Fixed a bug with `setup()` overriding incorrect variable ([6ec55c1](https://github.com/OXY2DEV/bars.nvim/commit/6ec55c1df6c9d7c27e00767016a717b384581664))
* **statuscolumn:** Fixed a bug with signs not showing up in normal mode ([bf475c5](https://github.com/OXY2DEV/bars.nvim/commit/bf475c563a5d26c11054ea39b4c9b43195785f05))
* **statuscolumn:** Fixed invalid functiom call ([da46fe2](https://github.com/OXY2DEV/bars.nvim/commit/da46fe27ff638c57a7780481eed51297c03edb08))
* **statuscolumn:** Reverted a change causing `numberwidth` & `relativenumber` to not be restored correctly ([89e8f63](https://github.com/OXY2DEV/bars.nvim/commit/89e8f63ccea81823389f23b76e54be6c1afb09c4))
* **statusline, diagnostics:** `auto_hide`&lt; now works when diagnostics count is empty ([af5ead8](https://github.com/OXY2DEV/bars.nvim/commit/af5ead8d9b651add2f54387e7f567941020fe008))
* **statusline, statuscolumn, winbar:** Fixed a bug preventing windows from attaching ([7aa6057](https://github.com/OXY2DEV/bars.nvim/commit/7aa60575e8db3b3003267b616255b8c150ad5225))
* **statusline:** `remove()` now only works on attached windows ([823ec48](https://github.com/OXY2DEV/bars.nvim/commit/823ec48f1b8bdb9ea40b2cc275450f4789b957dd))
* **statusline:** Changed behavior of `Enable`, `Disable` & `Toggle` ([56504e4](https://github.com/OXY2DEV/bars.nvim/commit/56504e4aef1dc49d960cc568eda74f3495e49598))
* **statusline:** Do not attach to `nofile` buffers by default ([d6c6d9b](https://github.com/OXY2DEV/bars.nvim/commit/d6c6d9bb600df9ce2acf8045e44a240373f722c9))
* **statusline:** Fixed issue with getting icons from `icons.nvim` ([6d7915a](https://github.com/OXY2DEV/bars.nvim/commit/6d7915a5dde134a3f188567fdc43dc3dd3ce376e))
* **winbar:** Fixed `Toggle` command ([97600c2](https://github.com/OXY2DEV/bars.nvim/commit/97600c21b261ce01772e477cacaf83bc8ac38fd5))
* **winbar:** Fixed an issue with `Toggle` not working ([ddedfd8](https://github.com/OXY2DEV/bars.nvim/commit/ddedfd889dc76a385c748ce39b90bb0e89c51986))
* **winbar:** Fixed attachment logic for windows ([5100872](https://github.com/OXY2DEV/bars.nvim/commit/510087262fc8b4d99f850070c3fc6aa1c01c657d))


### Code Refactoring

* Preparation for exposing internal variables ([0663d47](https://github.com/OXY2DEV/bars.nvim/commit/0663d473915a4d4613d69ee76089fe1b60385133))
* **winhar:** Changed name for TSNode component(`__lockup -> _ellipsis`) ([30cc0d3](https://github.com/OXY2DEV/bars.nvim/commit/30cc0d37e025d83ddccaedc5eae9f5ebca5e1c1b))

## [2.2.0](https://github.com/OXY2DEV/bars.nvim/compare/v2.1.0...v2.2.0) (2025-07-03)


### Features

* **config:** Added custom statuscolumn for terminal windows ([f05d0ea](https://github.com/OXY2DEV/bars.nvim/commit/f05d0ead4e5cb7aa16d9c6d5a3436736969fd2e5))
* Custom statusline for help files ([d09dbc7](https://github.com/OXY2DEV/bars.nvim/commit/d09dbc78eb816b66353b70d37a970d277c64d02e))
* **statusline:** Added an option to make diagnostics more compact ([227a7d3](https://github.com/OXY2DEV/bars.nvim/commit/227a7d3d1f464edf62e350838fc6ceb1c74a4103))
* **statusline:** Added custom statusline for the quickfix menu ([1ec73ce](https://github.com/OXY2DEV/bars.nvim/commit/1ec73cec7db5166f6c4ebb6ae64abc58bfc3399c))
* **statusline:** Added progress component ([55dc87d](https://github.com/OXY2DEV/bars.nvim/commit/55dc87d18553b04955f0841bd33e105421ea1bc9))


### Bug Fixes

* Fixed a bug with default setup fumction not working ([fa288e8](https://github.com/OXY2DEV/bars.nvim/commit/fa288e8bdc39bb0eddc3b167f73af3c9e9c532c4))
* **statuscolumn:** Fixed a bug with current line number not having correct highlight ([7ed1b16](https://github.com/OXY2DEV/bars.nvim/commit/7ed1b16069f8bc587eba2cccbfd9afc9706e5ba5))
* **statusline:** Bufname now uses `icon_hl` as fallback ([6c719a3](https://github.com/OXY2DEV/bars.nvim/commit/6c719a3aa8a35bb41f554644468ed0c8bf85b775))
* **statusline:** Updated help file statusline ([b498c72](https://github.com/OXY2DEV/bars.nvim/commit/b498c7294ab12e01ce471f54306cb88e5f02a3b8))

## [2.1.0](https://github.com/OXY2DEV/bars.nvim/compare/v2.0.1...v2.1.0) (2025-05-11)


### Features

* Added ability to disable bars per buffer or window ([5ae59c2](https://github.com/OXY2DEV/bars.nvim/commit/5ae59c2e3134b3bbed7500a8afa55dae1e7a64c6))
* **statusline:** Added Macro preview module ([941f4bf](https://github.com/OXY2DEV/bars.nvim/commit/941f4bf303ab23d457383260f1319a61e31d2023))


### Bug Fixes

* **core:** Fixed delays of loading modules in new windows ([1d05806](https://github.com/OXY2DEV/bars.nvim/commit/1d0580654f8908d4d199e63cc217bb5772b24c60))
* **core:** Modules now get loaded globally on VimEnter ([76818e6](https://github.com/OXY2DEV/bars.nvim/commit/76818e6762dd2e58b21cf40092e017ee27d44723))
* Fixed a bug that resets special windows bars & lines ([6f37dfb](https://github.com/OXY2DEV/bars.nvim/commit/6f37dfbe80e68cd022ed138fe05fda1bb1ca49d5))
* Fixed a bug with sub-modules not attaching in `global_attach()` ([eb0b080](https://github.com/OXY2DEV/bars.nvim/commit/eb0b080186c339cf4f4d6d129bd8f8c1a7845061))
* Fixed command typo ([6dd4c57](https://github.com/OXY2DEV/bars.nvim/commit/6dd4c57be8fb53ca21e8df15069966b7b87c7b0a))
* Fixed incorrect function names ([55fff14](https://github.com/OXY2DEV/bars.nvim/commit/55fff149e90c7c6131bad9a1c53bf22bace1b54b))
* **hl:** Fixed an issue with statusline's highlight group not matching with other segments in the statusline ([55231b3](https://github.com/OXY2DEV/bars.nvim/commit/55231b3e3680d008021d8a77031c433ba7528609))
* Optimized module imports ([7f18b76](https://github.com/OXY2DEV/bars.nvim/commit/7f18b7640cb08d17e4e4a3c70d61891226a7fb98))
* **tabline:** The `tabs` component now shows windows of the specific tab instead of all tabs ([8e0b8b8](https://github.com/OXY2DEV/bars.nvim/commit/8e0b8b8da786e68b4a86f5565b1d831b9caa4d82))
* **winbar:** Wrapped callback functions for detaching ([7ad7fd1](https://github.com/OXY2DEV/bars.nvim/commit/7ad7fd182f6617a0a1e55772fd56490b582ef842))

## [2.0.1](https://github.com/OXY2DEV/bars.nvim/compare/v2.0.0...v2.0.1) (2025-03-14)


### Bug Fixes

* Changed file names due to character restrictions on Windows(& MacOS) ([3729d8c](https://github.com/OXY2DEV/bars.nvim/commit/3729d8cf218ade8a34cf4d7f018515185329bb90)), closes [#4](https://github.com/OXY2DEV/bars.nvim/issues/4)

## [2.0.0](https://github.com/OXY2DEV/bars.nvim/compare/v1.0.0...v2.0.0) (2025-03-14)


### ⚠ BREAKING CHANGES

* Changed internal name from `part` to `component`

### Features

* Added ability to disable modules with `setup()` ([db076b4](https://github.com/OXY2DEV/bars.nvim/commit/db076b4ffa509aace45c57d7a165ee59a1c79c49))
* **core:** Added a `global_attach()` functions ([09ba2e0](https://github.com/OXY2DEV/bars.nvim/commit/09ba2e0e84d17907a776a10d34a7639f599ea0dd))
* **core:** Added ability to update different bars & lines on filetype ([1b59ff5](https://github.com/OXY2DEV/bars.nvim/commit/1b59ff5bfe19203f575eb3ee94f3c57a95f09113))
* **core:** Added actions for the plugin ([900bc9d](https://github.com/OXY2DEV/bars.nvim/commit/900bc9d03d852549ccb4fd73dd22c664c7df78f3))
* **core:** Added command support. ([2e11413](https://github.com/OXY2DEV/bars.nvim/commit/2e114131dd15c602dec63d11f41944c7de367f4f))
* **core:** Added custom section/column support ([8a76c1b](https://github.com/OXY2DEV/bars.nvim/commit/8a76c1b69e54e717643dc55c80a0a235057c89be))
* **core:** Added sub-module configuration via `bars.setup()` ([1165c50](https://github.com/OXY2DEV/bars.nvim/commit/1165c501f60f505999c89f744fe2a0d3cbad1840))
* **core:** Added support for dynamic values in `bars.setup()` ([c5d61d0](https://github.com/OXY2DEV/bars.nvim/commit/c5d61d0366e905575fb4111003ea0552cedcdecb))
* **core:** Mode changes now update the bars & lines ([909ba6c](https://github.com/OXY2DEV/bars.nvim/commit/909ba6c4ddf2af70f5217fe5b301c6f050c2d489))
* **global:** Added functions to scroll through tab list ([f433250](https://github.com/OXY2DEV/bars.nvim/commit/f433250f88a5cedd44b4132d3a9e03d8b364c71d))
* **statuscolumn:** Added ability to Toggle statuscolumn ([6133947](https://github.com/OXY2DEV/bars.nvim/commit/6133947bc23243668c0fbc754184601bdda0aa02))
* **statuscolumn:** Added click support for lnum ([de3c702](https://github.com/OXY2DEV/bars.nvim/commit/de3c70293edb96cf1730b9de3462ea22fc70406a))
* **statuscolumn:** Added Enabling & Disabling commands ([6c26f92](https://github.com/OXY2DEV/bars.nvim/commit/6c26f92c4dfa9b7e93063adbe94caae73ba36234))
* **statuscolumn:** Added filter support for signs ([2369dcf](https://github.com/OXY2DEV/bars.nvim/commit/2369dcf02bc882551bb36db126df1043cb33527b))
* **statusline:** Added ability to Toggle statusline ([cc1931f](https://github.com/OXY2DEV/bars.nvim/commit/cc1931fe2a0267f7b87e8eaa94568ffaab0eab22))
* **statusline:** Added detached HEAD branch support ([feecfa0](https://github.com/OXY2DEV/bars.nvim/commit/feecfa0de0d56701322f2551db66c5fd9134573f))
* **statusline:** Added Enable & Disable function ([4d68f88](https://github.com/OXY2DEV/bars.nvim/commit/4d68f8802f2aae8bcd2d03d9102515b39b7338ca))
* **statusline:** Help window's statusline now shows the ruler in Visual ([37e819f](https://github.com/OXY2DEV/bars.nvim/commit/37e819fa6f972fe85fc6bed131e243afd612fd09))
* **tabline:** Added a tab list for the tabline ([339b0bb](https://github.com/OXY2DEV/bars.nvim/commit/339b0bb297673e4368bca4d9440f68fc2e7ff6cd))
* **tabline:** Added ability to Toggle tabline ([404dfb0](https://github.com/OXY2DEV/bars.nvim/commit/404dfb0aacac1d5ff5c716ea44211fd2b554e1fe))
* **tabline:** Added buffer list part ([8c43622](https://github.com/OXY2DEV/bars.nvim/commit/8c43622ff2604da1b9229fd4227a097888461736))
* **tabline:** Added current bufname support for tabline ([0bd5395](https://github.com/OXY2DEV/bars.nvim/commit/0bd5395bbf600c0bef2e05e468a28be18208cedb))
* **tabline:** Added Enable & Disable functions ([8065320](https://github.com/OXY2DEV/bars.nvim/commit/8065320ed8ffb6e9f3ac09b6735a16075934a80a))
* **tabline:** Added tabline component to show tabs ([5b42f8e](https://github.com/OXY2DEV/bars.nvim/commit/5b42f8ede6594f8992719f88568a8aaf308353ff))
* **tabline:** Added tabpage list locking ([a0d03ec](https://github.com/OXY2DEV/bars.nvim/commit/a0d03ece2db249068f30c160545594e17faa7990))
* **winbar:** Added ability to Toggle winbar ([2d5de92](https://github.com/OXY2DEV/bars.nvim/commit/2d5de92158e971924b38e237c01eb5c1cc6b91db))
* **winbar:** Added Enable & Disable functions ([18d43b2](https://github.com/OXY2DEV/bars.nvim/commit/18d43b28d3c16d98b1f2ee955c9f8d4d5839ba0e))
* **winbar:** Added file path support for winbar ([f938cf5](https://github.com/OXY2DEV/bars.nvim/commit/f938cf59c4564848ba5f2e355ff1a3d5cec03c0d))
* **winbar:** Added lua_patterns support ([65a4340](https://github.com/OXY2DEV/bars.nvim/commit/65a4340437bc521092dde9ef1acf4b8b8d51f523))
* **winbar:** Added new winbar ([da5a456](https://github.com/OXY2DEV/bars.nvim/commit/da5a4560f9ba426855b3d2c594a4f9e4c6e30283))
* **winbar:** LuaDoc support ([7396456](https://github.com/OXY2DEV/bars.nvim/commit/73964561eb3ab8a5919be9b89e642354139779b6))


### Bug Fixes

* Added background to BarsLineNr ([237ff67](https://github.com/OXY2DEV/bars.nvim/commit/237ff67b103c5678c1976157520bcafcb5ccd84f))
* Added window validity check for statusline detaching ([17ecf91](https://github.com/OXY2DEV/bars.nvim/commit/17ecf9137bafef1199878bd6099db72d8a26a2a4))
* **core:** Fixed a bug with `setup()` not causing the cached IDs to update ([24b92af](https://github.com/OXY2DEV/bars.nvim/commit/24b92afbcbe04a3efa8780b05a359493158b8a29))
* **core:** Fixed how toggling of modules work ([4a8cdd6](https://github.com/OXY2DEV/bars.nvim/commit/4a8cdd6a62d81354c29667ed2fa4752156293f46))
* **core:** setup() now gets called when loading this plugin ([500245f](https://github.com/OXY2DEV/bars.nvim/commit/500245f462d6d912a9169a958cf52f4fac3f2df5))
* Finished adding remaining highlight groups ([cf6a4c8](https://github.com/OXY2DEV/bars.nvim/commit/cf6a4c8955b10c5aa92787630c6605deeec7b853))
* **statuscolumn:** `relativenumber` & `numberwidth` are now applied with ([8dcbf60](https://github.com/OXY2DEV/bars.nvim/commit/8dcbf60e7fe1856e0701b10dc1f8756e971a0a15))
* **statuscolumn:** Added check for module state before attching to new buffer ([6c26f92](https://github.com/OXY2DEV/bars.nvim/commit/6c26f92c4dfa9b7e93063adbe94caae73ba36234))
* **statuscolumn:** Changed when options are set ([e801a2d](https://github.com/OXY2DEV/bars.nvim/commit/e801a2d5a4e0031374a656dd46b4e188531f2675))
* **statuscolumn:** Fixed a bug with errors when trying to detach from invalid windows ([1d5ab23](https://github.com/OXY2DEV/bars.nvim/commit/1d5ab238fc77465f142e5325c1bc77a74a26d484))
* **statuscolumn:** Fixed incorrect fold marker on the last line of a buffer ([607a208](https://github.com/OXY2DEV/bars.nvim/commit/607a20802d5aa2c237116c266307053d1c0054b2))
* **statuscolumn:** Fold column no longer shows incorrect symbol on final buffer line ([d6cd485](https://github.com/OXY2DEV/bars.nvim/commit/d6cd485618bb2ba34a7960b5e377bcea3b67978b))
* **statuscolumn:** Global statuscolumn now gets cached too ([338985b](https://github.com/OXY2DEV/bars.nvim/commit/338985b9a361f33b5b0cb89361cbe3fcd5b57913))
* **statuscolumn:** List values now get properly applied for folds ([3a4c93f](https://github.com/OXY2DEV/bars.nvim/commit/3a4c93f1889690fdf792070225ce29770d45b035))
* **statuscolumn:** No longer detach from windows that weren't attached ([1d5ab23](https://github.com/OXY2DEV/bars.nvim/commit/1d5ab238fc77465f142e5325c1bc77a74a26d484))
* **statusline:** Calling `statusline.toggle()` no longer toggles it globally(when the cached value is "" or nil) ([34ee471](https://github.com/OXY2DEV/bars.nvim/commit/34ee471b7f02c41f38e3a885271800c7aeaf6602))
* **statusline:** Chnaged when statusline is set ([2d117bd](https://github.com/OXY2DEV/bars.nvim/commit/2d117bd9ca6314d36fb0c42a04f9cd605394e90e))
* **statusline:** Diagnoatics are now shown per buffer ([339a4ca](https://github.com/OXY2DEV/bars.nvim/commit/339a4ca80556e8427f9ef9b9a49817fdf0ce63a0))
* **statusline:** Fixdd issues with detaching from attached buffers ([d924e1a](https://github.com/OXY2DEV/bars.nvim/commit/d924e1a1d0d8b8273977eda7161698f2353a4676))
* **statusline:** Fixed a bug with `ignore_*` not being respected ([ede5576](https://github.com/OXY2DEV/bars.nvim/commit/ede55763c95c8001d742b511e7514dd5838a42c5))
* **statusline:** Fixed a bug with not getting a branch causing errors ([586e94a](https://github.com/OXY2DEV/bars.nvim/commit/586e94aa462a52c93b5a866b79e148a287dca690))
* **statusline:** Fixed issues with detaching from attached buffers ([d924e1a](https://github.com/OXY2DEV/bars.nvim/commit/d924e1a1d0d8b8273977eda7161698f2353a4676))
* **statusline:** Statusline module's state is now checked before attaching to new windows ([80fc8d3](https://github.com/OXY2DEV/bars.nvim/commit/80fc8d36fae094ff1f9b79d935a8d93ce4f8eea4))
* **statusline:** Updated bufname icons ([680036b](https://github.com/OXY2DEV/bars.nvim/commit/680036bb248f3e8b15efeed2b8f8287c45f9295c))
* **tabline:** `setup()` no longer disables tabline ([043cae8](https://github.com/OXY2DEV/bars.nvim/commit/043cae8524d88ca2b30a8651db43b550abaab8c3))
* **tabline:** Fixed navigation function ([8c43622](https://github.com/OXY2DEV/bars.nvim/commit/8c43622ff2604da1b9229fd4227a097888461736))
* **winbar:** Fixed a big with the `node` part ([6834630](https://github.com/OXY2DEV/bars.nvim/commit/683463074a461887bf0b84055974c0cdbd122b3e))
* **winbar:** Winbar module's state is now checked before attaching to new windows ([ef9d737](https://github.com/OXY2DEV/bars.nvim/commit/ef9d737c62e86fac094b1ffa0f528a6776b805ee))
* **winbr:** Changed when winbar is set ([2d117bd](https://github.com/OXY2DEV/bars.nvim/commit/2d117bd9ca6314d36fb0c42a04f9cd605394e90e))


### Code Refactoring

* Changed internal name from `part` to `component` ([d0dcda9](https://github.com/OXY2DEV/bars.nvim/commit/d0dcda966825a9c010f5fbb7fc6419a14709dc10))
