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
	@Inject private const PodHandler			podHandler
	@Inject private const ResponseProcessors	processors
	@Inject private const IocEnv				iocEnv
	
	@Config
	@Inject private const Uri					urlPrefix 

	@Config
	@Inject private const Duration				expiresIn 
	
	new make(|This|in) { in(this) }

	override Bool service(MiddlewarePipeline pipeline) {
		reqUri := request.url
		if (!reqUri.toStr.lower.startsWith(urlPrefix.toStr.lower) || reqUri.path.size <= 2)
			return pipeline.service
		
		try {
			uriNoPrefix	:= reqUri.toStr[urlPrefix.toStr.size..-1].toUri
			uriDigest	:= uriNoPrefix.getRange(0..0).toStr[0..-2]
			assetUri	:= uriNoPrefix.getRangeToPathAbs(1..-1)

			// this line may die!
			assetFile	:=	podHandler.baseUrl != null && assetUri.toStr.startsWith(podHandler.baseUrl.toStr)
						?	podHandler.fromLocalUrl(assetUri)
						:	fileHandler.fromLocalUrl(assetUri)
			
			assDigest	:= assetFile.clientUrl.getRange(1..1).toStr[0..<-1]

			if (uriDigest != assDigest) {
				clientUri := assetFile.clientUrl
				referrer  := request.headers.referrer
				log.warn(LogMsgs.assetRedirect(reqUri, assDigest, referrer))
				return processors.processResponse(Redirect.movedPermanently(clientUri))
			}
	
			if (assetFile.exists && iocEnv.isProd) {
				// yeah, a far future expiration header! 1 year baby!
				response.headers.expires = DateTime.now.plus(expiresIn)
				response.headers.cacheControl = "max-age=${expiresIn.toSec}"
			}
			
			return processors.processResponse(assetFile)
			
		} catch
			// if there's something wrong with the URI, return a 404
			return pipeline.service
	}
}
