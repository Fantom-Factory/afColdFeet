using afIoc
using afIocConfig::Config
using afIocEnv
using afBedSheet

const mixin ColdFeet {

	abstract Uri assetUri(Uri uri)
	
	abstract File? assetFile(File asset)
}

const class ColdFeetImpl : ColdFeet {
	@Inject private const FileHandler		fileHandler
	@Inject private const ChecksumStrategy	checksumStrategy
	
	@Config { id="afColdFeet.assetPrefix" }
	@Inject private const Uri				assetPrefix 

	new make(|This|in) { in(this) }
	
	override Uri assetUri(Uri uri) {
		if (!uri.isPathOnly)
			throw ArgErr(ErrMsgs.assetUriMustBePathOnly(uri))
		if (!uri.isPathAbs)
			throw ArgErr(ErrMsgs.assetUriMustStartWithSlash(uri))

		matchedUri := matchPrefix(fileHandler.directoryMappings.keys, uri.toStr)
		if (matchedUri == null)
			throw NotFoundErr(ErrMsgs.assetUriNotMapped(uri), fileHandler.directoryMappings.keys)
		
		remainingUri := uri.getRange(matchedUri.path.size..-1)
		file := fileHandler.directoryMappings[matchedUri].plus(remainingUri, false)

		if (!file.exists)
			throw ArgErr(ErrMsgs.assetUriDoesNotExist(uri, file))
		
		checksum := checksumStrategy.checksum(file).toUri.plusSlash
		
		return assetPrefix + checksum + uri.toStr[1..-1].toUri
	}
	
	override File? assetFile(File asset) {
		throw Err("Not implemented")
	}
	
	// TODO: Move to  BedSheet::FileHandler
	** Returns the URI with the closest / deepest match.
	internal static Uri? matchPrefix(Uri[] keys, Str uri) {
		keys.findAll { uri.startsWith(it.toStr) }.sort |u1, u2 -> Int| { u1.toStr.size <=> u2.toStr.size }.last
	}
}
