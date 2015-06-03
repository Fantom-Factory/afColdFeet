
** (Service) - 
** Contribute regular expressions to exclude URLs from being handled / altered by ColdFeet. 
** 
** Example, to ignore all local URLs in the directory 'images/':
** 
**   syntax:fantom
** 
**   @Contribute { serviceType=UrlExclusions# }
**   static Void contributeUrlExclusions(Configuration config) {
**       config.add("^/images/".toRegex)
**   }
** 
** Note that the regular expressions are matched against local URLs in [URI standard form]`sys::Uri`. 
** That means the the characters ':/?#[]@\' are (in the path section at least) prefixed with a backslash.  
const mixin UrlExclusions {
	
	** Returns 'true' if the 'localUrl' should *not* be altered by ColdFeet.
	@NoDoc
	abstract Bool excludeUrl(Uri localUrl)
}

internal const class UrlExclusionsImpl : UrlExclusions {
	private const Regex[] filters
	
	new make(Regex[] filters) {
		this.filters = filters
	}
	
	override Bool excludeUrl(Uri localUrl) {
		uriStr := localUrl.toStr
		return filters.any { it.matcher(uriStr).find }
	}
}
