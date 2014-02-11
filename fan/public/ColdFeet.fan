using concurrent
using afIoc
using afIocConfig::Config
using afIocEnv
using afBedSheet

** (Service) - Creates client-side asset URIs. 
const mixin ColdFeet {

	** Converts the given URI into a 'Cold Feet' URI. 
	** The URI **must** exist on the file system and be mapped by [BedSheet's]`http://www.fantomfactory.org/pods/afBedSheet`
	** 'FileHandler' service.
	abstract Uri assetUri(Uri uri)
	
	@NoDoc
	abstract File? assetFile(File asset)
	
	@NoDoc
	abstract Uri clientUri(Str checksum, Uri absUri)
}

internal const class ColdFeetImpl : ColdFeet {
	@Inject private const FileHandler		fileHandler
	@Inject private const HttpRequest		httpRequest
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
		
		remainingUri := uri.getRange(matchedUri.path.size..-1).relTo(`/`)
		file := fileHandler.directoryMappings[matchedUri].plus(remainingUri, false)

		if (!file.exists)
			throw ArgErr(ErrMsgs.assetUriDoesNotExist(uri, file))
		
		checksum := checksumStrategy.checksum(file)
		return clientUri(checksum, uri)
	}
	
	override File? assetFile(File asset) {
		throw Err("Not implemented")
	}
	
	override Uri clientUri(Str checksum, Uri absUri) {
		// add extra WebMod paths - but only if we're part of a web request!
		clientUri := (Actor.locals["web.req"] != null && httpRequest.modBase != `/`) ? httpRequest.modBase : ``
		return clientUri.plusSlash + assetPrefix.relTo(`/`).plusSlash + checksum.toUri.plusSlash + absUri.relTo(`/`)
	}
	
	// TODO: Move to  BedSheet::FileHandler
	** Returns the URI with the closest / deepest match.
	internal static Uri? matchPrefix(Uri[] keys, Str uri) {
		keys.findAll { uri.startsWith(it.toStr) }.sort |u1, u2 -> Int| { u1.toStr.size <=> u2.toStr.size }.last
	}
}
