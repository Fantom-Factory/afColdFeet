using concurrent
using afIoc
using afIocConfig::Config
using afIocEnv
using afBedSheet

** (Service) - Creates client-side asset URIs. 
const mixin ColdFeet {

	** Converts the given client URI (one that would normally be used by the browser to access the resource) into a cachable 'Cold Feet' URI. 
	** Essentially this adds a 'Cold Feet' prefix and digest to the given URI, as well as checking for URI validity and that 
	** the corresponding file exists.   
	** 
	** The URI **must** 
	** be mapped by [BedSheet's]`http://www.fantomfactory.org/pods/afBedSheet` 'FileHandler' service.
	abstract Uri fromClientUri(Uri uri)

	** Converts the given asset File (on the server's file system) into a cachable 'Cold Feet' URI that can be used by clients / browsers. 
	** 
	** The asset **must** exist on the file system and 
	** be mapped by [BedSheet's]`http://www.fantomfactory.org/pods/afBedSheet` 'FileHandler' service.
	abstract Uri fromServerFile(File asset)
	
	@NoDoc
	abstract Uri clientUri(Str digest, Uri absUri)
}

internal const class ColdFeetImpl : ColdFeet {
	@Inject private const FileHandler		fileHandler
	@Inject private const HttpRequest		httpRequest
	@Inject private const DigestStrategy	digestStrategy
	
	@Config { id="afColdFeet.assetPrefix" }
	@Inject private const Uri				assetPrefix 

	new make(|This|in) { in(this) }
	
	override Uri fromClientUri(Uri uri) {
		asset	:= fileHandler.fromClientUri(uri, true)
		digest	:= digestStrategy.digest(asset)
		return clientUri(digest, uri)
	}
	
	override Uri fromServerFile(File asset) {
		uri		:= fileHandler.fromServerFile(asset)
		digest	:= digestStrategy.digest(asset)
		return clientUri(digest, uri)
	}

	override Uri clientUri(Str digest, Uri absUri) {
		// add extra WebMod paths - but only if we're part of a web request!
		clientUri := (Actor.locals["web.req"] != null && httpRequest.modBase != `/`) ? httpRequest.modBase : ``
		return clientUri.plusSlash + assetPrefix.relTo(`/`).plusSlash + digest.toUri.plusSlash + absUri.relTo(`/`)
	}
}
