
internal const mixin LogMsgs {

	static Str assetRedirect(Uri reqUri, Str assDigest, Uri? referrer) {
		"Redirecting `${reqUri}` to digest `/${assDigest}` from referrer `${referrer?.pathOnly}`"
	}
}
