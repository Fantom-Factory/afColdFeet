using afIoc::Inject
using afIocEnv::IocEnv
using afIocConfig::Config
using afConcurrent::ActorPools
using afBedSheet::ClientAsset
using afBedSheet::ClientAssetCacheImpl

internal const class ColdFeetAssetCache : ClientAssetCacheImpl {
	
	@Config	@Inject	private const Uri				urlPrefix
			@Inject	private const UrlExclusions		urlExclusions
			@Inject	private const DigestStrategy	digestStrategy
			@Inject private const UrlTransformer	urlTransformer
	
	new make(IocEnv env, ActorPools actorPools, |This|? in) : super.make(env, actorPools, in) { }
	
	override Uri toClientUrl(Uri localUrl, ClientAsset asset) {
		if (!urlExclusions.excludeUrl(localUrl)) {
			
			// don't process invalid local urls
			if (localUrl.host == null && localUrl.isRel && asset.exists) {
				digest := digestStrategy.digest(asset)
				if (digest != null) {
					coldFeetUrl := urlTransformer.toColdFeet(localUrl, digest) 
					localUrl 	= coldFeetUrl
				}
			}
		}
		return super.toClientUrl(localUrl, asset)
	}
}
