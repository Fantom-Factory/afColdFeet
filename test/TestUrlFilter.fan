using afIoc
using afIocEnv
using afIocConfig::ApplicationDefaults
using afBedSheet
using afBounce::BedServer
using afBounce::BedClient
using afButter::ButterDish

internal class TestUrlFilter : ColdFeetTest {
	
	@Inject	FileHandler?	fileHandler
	
	Void testWithoutFilter() {
		server 	:= BedServer(ColdFeetModule#).addModule(T_Module04#).startup
		server.injectIntoFields(this)

		clientUrl := fileHandler.fromLocalUrl(`/doc/pod.fandoc`).clientUrl
		verifyEq(clientUrl, `/coldFeet/checksum/doc/pod.fandoc`)
	}

	Void testWithFilter() {
		server 	:= BedServer(ColdFeetModule#).addModule(T_Module04#).addModule(T_Module06#).startup
		server.injectIntoFields(this)

		clientUrl := fileHandler.fromLocalUrl(`/doc/pod.fandoc`).clientUrl
		verifyEq(clientUrl, `/doc/pod.fandoc`)
	}
}

internal const class T_Module06 {
	@Contribute { serviceType=UrlExclusions# }
	static Void contributeUrlExclusions(Configuration config) {
		config.add("^/doc/".toRegex)
	}
}
