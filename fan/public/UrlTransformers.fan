using afIoc
using afIocConfig
using afBedSheet

** (Service) -
** ColdFeet's strategy for transforming URLs. 
const mixin UrlTransformer {
	
	** Transforms the given URL with the digest to a ColdFeet URL.
	abstract Uri toColdFeet(Uri localUrl, Str digest)

	** Is the URL a recognisable ColdFeet URL?
	** 
	** The given URL will always start with a slash.  
	abstract Bool isColdFeet(Uri localUrl)

	** Converts the given ColdFeet URL to a local URL.
	** 
	** Both should always start with a slash.
	abstract Uri fromColdFeet(Uri coldFeetUrl)

	** Extracts and returns the digest embedded within the given ColdFeet URL.
	** 
	** Both should always start with a slash.
	abstract Str extractDigest(Uri coldFeetUrl)
}

** `UrlTransformer` that generates ColdFeet URLs in the format '/coldFeet/XXXX/css/myStyle.css'
const class PathTransformer : UrlTransformer {

	@Config	@Inject private const Str urlPrefix 

	@NoDoc @Inject
	new make(|This|in) { in(this) }

	@NoDoc
	new makeForTesting(Str urlPrefix) {
		this.urlPrefix = urlPrefix
	}
	
	@NoDoc // boring
	override Uri toColdFeet(Uri url, Str digest) {
		`/` + urlPrefix.toUri.plusSlash + digest.toUri.plusSlash + url.relTo(`/`)
	}

	@NoDoc // boring
	override Bool isColdFeet(Uri url) {
		path := url.path
		return path.size > 2 && path.first.equalsIgnoreCase(urlPrefix)
	}

	@NoDoc // boring
	override Uri fromColdFeet(Uri url) {
		url.getRangeToPathAbs(2..-1)
	}

	@NoDoc // boring
	override Str extractDigest(Uri url) {
		url.path[1]
	}
}

** `UrlTransformer` that generates ColdFeet URLs in the format '/css/myStyle.coldFeet.XXXX.css'
const class NameTransformer : UrlTransformer {

	@Config	@Inject private const Str urlPrefix 

	@NoDoc @Inject
	new make(|This|in) { in(this) }

	@NoDoc
	new makeForTesting(Str urlPrefix) {
		this.urlPrefix = urlPrefix
	}

	@NoDoc // boring
	override Uri toColdFeet(Uri url, Str digest) {
		name := (url.ext == null) 
			? "${url.name}.${urlPrefix}.${digest}" 
			: "${url.name[0..<-(url.ext.size+1)]}.${urlPrefix}.${digest}.${url.ext}"
		// url cannot be a dir, see FileAssetCacheAdvice
		return url.parent.plusName(name)
	}

	@NoDoc // boring
	override Bool isColdFeet(Uri url) {
		segs := url.name.split('.')
		return (segs.size >= 4 && segs[-3].equalsIgnoreCase(urlPrefix)) || (segs.size >= 3 && segs[-2].equalsIgnoreCase(urlPrefix))
	}

	@NoDoc // boring
	override Uri fromColdFeet(Uri url) {
		segs := url.name.split('.')
		name := segs[-2].equalsIgnoreCase(urlPrefix)
			? segs[0..<-2].join(".")
			: segs[0..<-3].join(".") + ".${segs[-1]}"
		return url.parent.plusName(name)
	}

	@NoDoc // boring
	override Str extractDigest(Uri url) {
		segs := url.name.split('.')
		return segs[-2].equalsIgnoreCase(urlPrefix)
			? segs[-1]
			: segs[-2]
	}
}