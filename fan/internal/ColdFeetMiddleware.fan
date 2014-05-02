using afIoc
using afIocConfig
using afIocEnv
using afBedSheet


internal const class ColdFeetMiddleware : Middleware {

	@Inject private const Log					log
	@Inject private const DigestStrategy		digestStrategy
	@Inject private const HttpRequest			request
	@Inject private const HttpResponse			response
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
		reqUri := request.modRel
		if (!reqUri.toStr.lower.startsWith(assetPrefix.toStr.lower) || reqUri.path.size <= 2)
			return pipeline.service
		
		try {
			uriNoPrefix	:= reqUri.toStr[assetPrefix.toStr.size..-1].toUri
			uriDigest	:= uriNoPrefix.getRange(0..0).toStr[0..-2]
			assetUri	:= uriNoPrefix.getRangeToPathAbs(1..-1)	
			assetFile	:= fileHandler.fromClientUri(assetUri, true)	// this line may die!
			assDigest	:= digestStrategy.digest(assetFile)
	
			if (uriDigest != assDigest) {
				clientUri := coldFeet.clientUri(assDigest, assetUri)
				referrer  := request.headers.referrer
				log.warn(LogMsgs.assetRedirect(reqUri, assDigest, referrer))
				return processors.processResponse(Redirect.movedPermanently(clientUri))
			}
	
			if (assetFile.exists && iocEnv.isProd) {
				// yeah, a far future expiration header! 10 years baby!
				response.headers.expires = DateTime.now.plus(expiresIn)
			}
			
			return processors.processResponse(assetFile)
			
		} catch (Err e)
			// if there's something wrong with the URI, return a 404
			return pipeline.service
	}
}
