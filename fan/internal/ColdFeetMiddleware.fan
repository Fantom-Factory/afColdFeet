using afIoc
using afIocConfig
using afIocEnv
using afBedSheet

internal const class ColdFeetMiddleware : Middleware {

	@Inject private const Log					log
	@Inject private const HttpRequest			request
	@Inject private const HttpResponse			response
	@Inject private const ClientAssetCache		assetCache
	@Inject private const ResponseProcessors	processors
	@Inject private const IocEnv				iocEnv
	@Inject private const UrlTransformer		urlTransformer
	
	@Config
	@Inject private const Duration				expiresIn 
	
	new make(|This|in) { in(this) }

	override Void service(MiddlewarePipeline pipeline) {
		if (request.httpMethod == "GET" || request.httpMethod == "HEAD") {
			reqUrl := request.url
			
			if (urlTransformer.isColdFeet(reqUrl)) {

				assetUrl	:= urlTransformer.fromColdFeet(reqUrl)
				assetFile	:= assetCache.getAndUpdateOrProduce(assetUrl)
				if (assetFile != null) {

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
					return
				}
			}
		}
		pipeline.service
	}
}
