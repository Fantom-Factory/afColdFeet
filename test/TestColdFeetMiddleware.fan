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
		verifyEq(res.asStr, "Terminated")
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
		
		res := client.get(`/coldfeet/whoops/doc/pod.fdoc`)
		verifyEq(res.statusCode, 308)
		verifyEq(res.headers.location, `/coldFeet/checksum/doc/pod.fdoc`)
	}

	Void testFileIsServed() {
		client.followRedirects.enabled = false
		
		res := client.get(`/coldFeet/checksum/doc/pod.fdoc`)
		verifyEq(res.statusCode, 200)
		verify(res.asStr.startsWith("Overview [#overview]"))
	}

	Void testQueryParamsAreIgnored() {
		client.followRedirects.enabled = true
		
		res := client.get(`/coldFeet/whoops/doc/pod.fdoc?wot`)
		verifyEq(res.statusCode, 200)
		verify(res.asStr.startsWith("Overview [#overview]"))

		res = client.get(`/coldFeet/whoops/doc/pod.fdoc?wot&ever`)
		verifyEq(res.statusCode, 200)
		verify(res.asStr.startsWith("Overview [#overview]"))

		res = client.get(`/coldFeet/whoops/doc/pod.fdoc#wotever`)
		verifyEq(res.statusCode, 200)
		verify(res.asStr.startsWith("Overview [#overview]"))
	}

	Void testFarFutureHeader() {
		client.followRedirects.enabled = false
		expiresInTenYears := DateTime.now.plus(365day * 10)
		
		res := client.get(`/coldFeet/checksum/doc/pod.fdoc`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.headers.expires.floor(1min).toHttpStr, expiresInTenYears.floor(1min).toHttpStr)
	}

	override Void setup() {
		server 	= BedServer(ColdFeetModule#).addModule(T_Module04#).startup
		server.injectIntoFields(this)
		client	= server.makeClient
	}
	
	override Void teardown() {
		client?.shutdown
	}
}

internal class T_Module04 {
	@Contribute { serviceType=FileHandler# }
	static Void contributeFileHandler(MappedConfig config) {
		config[`/doc/`] = `doc/`
	}
	@Contribute { serviceType=ServiceOverrides# }
	static Void contributeOverrides(MappedConfig config) {
		config[DigestStrategy#] = FixedValueDigest("checksum")
        config["IocEnv"] 		= IocEnv.fromStr("Prod")
	}
	@Contribute { serviceType=Routes# }
	internal static Void contributeRoutes(OrderedConfig config) {
		config.add(Route(`/index.html`, Text.fromPlain("Terminated")))
	}
}
