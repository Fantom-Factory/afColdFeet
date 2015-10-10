using afIoc
using afIocConfig
using afBedSheet
using afBounce

internal class TestColdFeetService : ColdFeetTest {
	BedServer? server
	@Inject FileHandler? fileHandler
	
	override Void setup() {
		server = BedServer(ColdFeetModule#).addModule(T_Module05#).startup
		server.injectIntoFields(this)		
	}
	
	override Void teardown() {
		server.shutdown
	}
	
	Void testAssetUri() {
		assFile := fileHandler.fromLocalUrl(`/not-here/pod.fandoc`)
		verifyEq(assFile.clientUrl, `/coldFeet/ver/not-here/pod.fandoc`)
	}	
	
	Void testAssetFile() {
		assFile := fileHandler.fromServerFile(`doc/pod.fandoc`.toFile)
		verifyEq(assFile.clientUrl, `/coldFeet/ver/not-here/pod.fandoc`)
	}
}

internal const class T_Module05 {
	@Contribute { serviceType=FileHandler# }
	static Void contributeFileHandler(Configuration config) {
		config[`/not-here/`] = `doc/`
	}

	@Override
	static DigestStrategy overrideDigestStrategy() {
		FixedValueDigest("ver")
	}
}
