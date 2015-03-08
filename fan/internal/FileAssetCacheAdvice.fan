using afIoc
using afIocConfig

internal const class FileAssetCacheAdvice {
	
	@Config	@Inject	private const Uri				urlPrefix
			@Inject	private const UrlExclusions		urlExclusions
			@Inject	private const DigestStrategy	digestStrategy
			@Inject private const UrlTransformer	urlTransformer
	
	new make(|This|in) { in(this) }
	
	Obj? adviseToClientUrl(MethodInvocation invocation) {
		localUrl := (Uri)  invocation.args[0]
		if (!urlExclusions.excludeUrl(localUrl)) {
			
			// don't process invalid local urls
			if (localUrl.host == null && localUrl.isRel) {
				file := (File) invocation.args[1]
				
				// don't process dir urls ('cos wot do we digest on!?)
				if (!file.isDir && file.exists) {
					digest	  := digestStrategy.digest(file)
					clientUrl := urlTransformer.toColdFeet(localUrl, digest) 
					invocation.args[0] = clientUrl
				}
			}
		}
		return invocation.invoke
	}
}
