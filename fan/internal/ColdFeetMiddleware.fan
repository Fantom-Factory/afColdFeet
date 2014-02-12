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

	@Config { id="afColdFeet.assetExpiresIn" }
	@Inject private const Duration				expiresIn 
	
	new make(|This|in) { in(this) }

	override Bool service(MiddlewarePipeline pipeline) {
		reqUri := req.modRel
		if (!reqUri.toStr.lower.startsWith(assetPrefix.toStr.lower) || reqUri.path.size <= 2)
			return pipeline.service

		try {
			uriNoPrefix	:= reqUri.toStr[assetPrefix.toStr.size..-1].toUri
			uriChecksum	:= uriNoPrefix.getRange(0..0).toStr[0..-2]
			assetUri	:= uriNoPrefix.getRangeToPathAbs(1..-1)	
			assetFile	:= fileHandler.fromClientUri(assetUri, true)
			checksum	:= checksumStrategy.checksum(assetFile)
	
			if (uriChecksum != checksum) {
				clientUri := coldFeet.clientUri(checksum, assetUri)
				return processors.processResponse(Redirect.movedPermanently(clientUri))
			}
	
			if (assetFile.exists && iocEnv.isProd) {
				// yeah, a far future expiration header! 10 years baby!
				res.headers.expires = DateTime.now.plus(expiresIn)
			}
			
			return processors.processResponse(assetFile)
			
		} catch (Err e)
			// if there's something wrong with the URI, return a 404
			return pipeline.service
	}
}
