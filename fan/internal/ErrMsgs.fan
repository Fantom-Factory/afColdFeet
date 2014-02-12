
internal const class ErrMsgs {

	static Str assetPrefixMustBePathOnly(Uri assetPrefix) {
		"Asset prefix `${assetPrefix}` must ONLY be a path. e.g. `/coldFeet/`"
	}

	static Str assetPrefixMustStartWithSlash(Uri assetPrefix) {
		"Asset prefix `${assetPrefix}` must start with a slash. e.g. `/coldFeet/`"
	}

	static Str assetPrefixMustEndWithSlash(Uri assetPrefix) {
		"Asset prefix `${assetPrefix}` must end with a slash. e.g. `/coldFeet/`"
	}

//	static Str assetUriMustBePathOnly(Uri assetUri) {
//		"Asset URI `${assetUri}` must ONLY be a path. e.g. `/css/my-styles.css`"
//	}
//
//	static Str assetUriMustStartWithSlash(Uri assetUri) {
//		"Asset URI `${assetUri}` must start with a slash. e.g. `/css/my-styles.css`"
//	}
//
//	static Str assetUriNotMapped(Uri assetUri) {
//		"Asset URI `${assetUri}` does not map to any known FileHandler prefixes."
//	}
//
//	static Str assetUriDoesNotExist(Uri assetUri, File file) {
//		"Asset URI `${assetUri}` does not exist -> ${file.normalize.osPath}"
//	}
//
//	static Str assetFileIsDir(File assetFile) {
//		"Asset File `${assetFile.normalize.osPath}` is a directory!?"
//	}
	
//	static Str assetFileDoesNotExist(File assetFile) {
//		"Asset File `${assetFile.normalize.osPath}` does not exist."
//	}
	
}
