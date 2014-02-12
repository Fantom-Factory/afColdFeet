using afIoc
using afIocConfig::ApplicationDefaults
using afBedSheet
using afBounce::BedServer

internal class TestColdFeetService : ColdFeetTest {
	
	Void testAssetUri() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).addModule(T_Module05#).startup.dependencyByType(ColdFeet#)
		uri := coldFeet.assetUri(`/not-here/pod.fandoc`)
		verifyEq(uri, `/coldFeet/ver/not-here/pod.fandoc`)
	}	
	
	Void testAssetFile() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).addModule(T_Module05#).startup.dependencyByType(ColdFeet#)
		uri := coldFeet.assetFile(`doc/pod.fandoc`.toFile)
		verifyEq(uri, `/coldFeet/ver/not-here/pod.fandoc`)
	}
}

internal class T_Module05 {
	@Contribute { serviceType=FileHandler# }
	static Void contributeFileHandler(MappedConfig config) {
		config[`/not-here/`] = `doc/`
	}
	@Contribute { serviceType=ServiceOverride# }
	static Void contributeOverrides(MappedConfig config) {
		config[ChecksumStrategy#] = ChecksumFromConstValue("ver")
	}
}
