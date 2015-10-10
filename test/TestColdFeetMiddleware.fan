using afIoc
using afIocEnv
using afIocConfig::ApplicationDefaults
using afBedSheet
using afBounce::BedServer
using afBounce::BedClient
using afButter::ButterDish

internal class TestColdFeetMiddleware : ColdFeetTest {
	
	BedServer?	server
	BedClient?	client
	
	Void testPassThrough() {
		res := client.get(`/index.html`)
		verifyEq(res.body.str, "Terminated")
	}

	Void test404() {
		client.errOn4xx.enabled = false

		res := client.get(`/coldfeet`)
		verifyEq(res.statusCode, 404)
		
		res = client.get(`/coldfeet/`)
		verifyEq(res.statusCode, 404)

		res = client.get(`/coldfeet/wotever`)
		verifyEq(res.statusCode, 404)

		res = client.get(`/coldfeet/checksum/wotever`)
		verifyEq(res.statusCode, 404)
	}
	
	Void testRedirect() {
		client.followRedirects.enabled = false
		
		res := client.get(`/coldfeet/whoops/doc/pod.fandoc`)
		verifyEq(res.statusCode, 308)
		verifyEq(res.headers.location, `/coldFeet/checksum/doc/pod.fandoc`)
	}

	Void testFileIsServed() {
		client.followRedirects.enabled = false
		
		res := client.get(`/coldFeet/checksum/doc/pod.fandoc`)
		verifyEq(res.statusCode, 200)
		verify(res.body.str.startsWith("Overview\n********\n"))
	}

	Void testQueryParamsAreIgnored() {
		client.followRedirects.enabled = true
		
		res := client.get(`/coldFeet/whoops/doc/pod.fandoc?wot`)
		verifyEq(res.statusCode, 200)
		verify(res.body.str.startsWith("Overview\n********\n"))

		res = client.get(`/coldFeet/whoops/doc/pod.fandoc?wot&ever`)
		verifyEq(res.statusCode, 200)
		verify(res.body.str.startsWith("Overview\n********\n"))

		res = client.get(`/coldFeet/whoops/doc/pod.fandoc#wotever`)
		verifyEq(res.statusCode, 200)
		verify(res.body.str.startsWith("Overview\n********\n"))
	}

	Void testFarFutureHeader() {
		client.followRedirects.enabled = false
		expiresInTenYears := DateTime.now.plus(365day)
		
		res := client.get(`/coldFeet/checksum/doc/pod.fandoc`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.headers.expires.floor(1min).toHttpStr, expiresInTenYears.floor(1min).toHttpStr)
		verifyEq(res.headers.cacheControl, "max-age=${365day.toSec}")		
	}

	override Void setup() {
		super.setup
		server 	= BedServer(ColdFeetModule#).addModule(T_Module04#).startup
		server.injectIntoFields(this)
		client	= server.makeClient
	}
	
	override Void teardown() {
		client?.shutdown
	}
}

internal const class T_Module04 {
	@Contribute { serviceType=FileHandler# }
	static Void contributeFileHandler(Configuration config) {
		config[`/doc/`] = `doc/`
	}

	@Override
	static DigestStrategy overrideDigestStrategy() {
		FixedValueDigest("checksum")
	}

	@Override
	static IocEnv overrideIocEnv() {
		IocEnv.fromStr("Prod")
	}

	@Contribute { serviceType=Routes# }
	internal static Void contributeRoutes(Configuration config) {
		config.add(Route(`/index.html`, Text.fromPlain("Terminated")))
	}
}
