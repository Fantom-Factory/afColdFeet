
internal const mixin ErrMsgs {

	static Str assetPrefixMustBePathOnly(Uri assetPrefix) {
		"Asset prefix `${assetPrefix}` must ONLY be a path. e.g. `/coldFeet/`"
	}

	static Str assetPrefixMustStartWithSlash(Uri assetPrefix) {
		"Asset prefix `${assetPrefix}` must start with a slash. e.g. `/coldFeet/`"
	}

	static Str assetPrefixMustEndWithSlash(Uri assetPrefix) {
		"Asset prefix `${assetPrefix}` must end with a slash. e.g. `/coldFeet/`"
	}
	
}
