using concurrent
using afIoc
using afIocConfig::Config
using afIocEnv
using afBedSheet

** (Service) - Creates client-side asset URIs. 
const mixin ColdFeet {

	** Converts the given client URI into a cachable 'Cold Feet' URI that can be used by clients / browsers. 
	** Essentially this adds the prefix and checksum to the given URI, as well as checking for URI validity and that 
	** the corresponding file exists.   
	** 
	** The URI **must** 
	** be mapped by [BedSheet's]`http://www.fantomfactory.org/pods/afBedSheet` 'FileHandler' service.
	abstract Uri assetUri(Uri uri)
	
	** Converts the given asset File into a cachable 'Cold Feet' URI that can be used by clients / browsers. 
	** 
	** The asset **must** exist on the file system and 
	** be mapped by [BedSheet's]`http://www.fantomfactory.org/pods/afBedSheet` 'FileHandler' service.
	abstract Uri assetFile(File asset)
	
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

		// TODO: create an easy method in file handler
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
	
	override Uri assetFile(File asset) {
		if (asset.isDir)
			throw ArgErr(ErrMsgs.assetFileIsDir(asset))
		if (!asset.exists)
			throw ArgErr(ErrMsgs.assetFileDoesNotExist(asset))
		
		// TODO: create a method in FileHandler
		// TODO: normalise all the files in directoryMappings
		assetUriStr := asset.normalize.uri.toStr
		matchedUri  := fileHandler.directoryMappings.findAll |file, uri->Bool| { assetUriStr.startsWith(file.normalize.uri.toStr) }.keys.sort |u1, u2 -> Int| { u1.toStr.size <=> u2.toStr.size }.last
		matchedFile := fileHandler.directoryMappings[matchedUri].normalize
		remaining	:= assetUriStr[matchedFile.uri.toStr.size..-1]
		assetUri	:= matchedUri + remaining.toUri
		checksum 	:= checksumStrategy.checksum(asset)
		return clientUri(checksum, assetUri)
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
