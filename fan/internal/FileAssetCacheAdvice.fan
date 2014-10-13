using afIoc
using afIocConfig

internal const class FileAssetCacheAdvice {
	
	@Config	@Inject	private const Uri				urlPrefix
			@Inject	private const UrlExclusions		urlExclusions
			@Inject	private const DigestStrategy	digestStrategy
	
	new make(|This|in) { in(this) }
	
	Obj? adviseToClientUrl(MethodInvocation invocation) {
		localUrl 	:= (Uri)  invocation.args[0]
		if (!urlExclusions.excludeUrl(localUrl)) {
			file	 	:= (File) invocation.args[1]
			digest	 	:= digestStrategy.digest(file).toUri
			clientUrl	:= urlPrefix.plusSlash + digest.plusSlash + localUrl.relTo(`/`)
			invocation.args[0] = clientUrl
		}
		return invocation.invoke
	}
}
