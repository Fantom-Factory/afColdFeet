using afIoc
using afIocConfig
using afIocEnv
using afBedSheet


internal const class ColdFeetMiddleware : Middleware {

	@Inject private const ChecksumStrategy		checksumStrategy
	@Inject private const HttpRequest			req
	@Inject private const HttpResponse			res
	@Inject private const FileHandler			fileHandler
	@Inject private const ResponseProcessors	processors
	@Inject private const IocEnv				iocEnv
	@Inject private const ColdFeet				coldFeet
	
	@Config { id="afColdFeet.assetPrefix" }
	@Inject private const Uri					assetPrefix 
	
	new make(|This|in) { in(this) }

	override Bool service(MiddlewarePipeline pipeline) {
		reqUri := req.modRel
		if (!reqUri.toStr.lower.startsWith(assetPrefix.toStr.lower) || reqUri.path.size <= 2)
			return pipeline.service

		uriNoPrefix	:= reqUri.toStr[assetPrefix.toStr.size..-1].toUri
		assetUri	:= uriNoPrefix.getRangeToPathAbs(1..-1)
		uriChecksum	:= uriNoPrefix.getRange(0..0).toStr[0..-2]
		matchedUri	:= matchPrefix(fileHandler.directoryMappings.keys, assetUri.toStr)

		if (matchedUri == null)
			return pipeline.service			

		remainUri	:= assetUri.toStr[matchedUri.toStr.size..-1].toUri
		assetFile 	:= fileHandler.directoryMappings[matchedUri].plus(remainUri, false)
		checksum	:= checksumStrategy.checksum(assetFile)

		if (uriChecksum != checksum) {
			clientUri := coldFeet.clientUri(checksum, assetUri)
			return processors.processResponse(Redirect.movedPermanently(clientUri))
		}

		if (assetFile.exists && iocEnv.isProd) {
			// yeah, a far future expiration header! 10 years baby!
			res.headers.expires = DateTime.now.plus(365day * 10)
		}
		
		return processors.processResponse(assetFile)
	}

	// TODO: Move to BedSheet::FileHandler
	** Returns the URI with the closest / deepest match.
	internal static Uri? matchPrefix(Uri[] keys, Str uri) {
		keys.findAll { uri.startsWith(it.toStr) }.sort |u1, u2 -> Int| { u1.toStr.size <=> u2.toStr.size }.last
	}
}
