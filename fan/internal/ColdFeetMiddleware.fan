using afIoc
using afIocConfig
using afIocEnv
using afBedSheet

internal const class ColdFeetMiddleware : Middleware {

	@Inject private const Log					log
	@Inject private const HttpRequest			request
	@Inject private const HttpResponse			response
	@Inject private const FileHandler			fileHandler
	@Inject private const PodHandler			podHandler
	@Inject private const ResponseProcessors	processors
	@Inject private const IocEnv				iocEnv
	@Inject private const UrlTransformer		urlTransformer
	
	@Config
	@Inject private const Duration				expiresIn 
	
	new make(|This|in) { in(this) }

	override Void service(MiddlewarePipeline pipeline) {
		reqUrl := request.url
		
		if (!urlTransformer.isColdFeet(reqUrl)) {
			pipeline.service
			return
		}
		
		try {
			assetUrl	:= urlTransformer.fromColdFeet(reqUrl)

			// is it a pod or a file resource? Note this is a crappy way to decide so this line may die...
			assetFile	:=	podHandler.baseUrl != null && assetUrl.toStr.startsWith(podHandler.baseUrl.toStr)
						?	podHandler.fromLocalUrl(assetUrl)
						:	fileHandler.fromLocalUrl(assetUrl)

			urlDigest	:= urlTransformer.extractDigest(reqUrl)
			assDigest	:= urlTransformer.extractDigest(assetFile.clientUrl)

			if (urlDigest != assDigest) {
				clientUri := assetFile.clientUrl
				referrer  := request.headers.referrer
				log.warn(LogMsgs.assetRedirect(reqUrl, assDigest, referrer))
				processors.processResponse(Redirect.movedPermanently(clientUri))
				return
			}
	
			if (assetFile.exists && iocEnv.isProd) {
				// yeah, a far future expiration header! 1 year baby!
				response.headers.expires = DateTime.now.plus(expiresIn)
				response.headers.cacheControl = "max-age=${expiresIn.toSec}"
			}
			
			processors.processResponse(assetFile)
			
		} catch
			// if there's something wrong with the URI, return a 404
			pipeline.service
	}
}
