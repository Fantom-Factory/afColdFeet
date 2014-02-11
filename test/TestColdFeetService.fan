using afIoc
using afIocConfig::ApplicationDefaults
using afBedSheet
using afBounce::BedServer

internal class TestColdFeetService : ColdFeetTest {
	
	Void testAssetUriIsPathOnly() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).startup.dependencyByType(ColdFeet#)
		verifyErrTypeAndMsg(ArgErr#, ErrMsgs.assetUriMustBePathOnly(`http://myStyles.css`)) {
			coldFeet.assetUri(`http://myStyles.css`)
		}
	}
	
	Void testAssetUriStartsWithSlash() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).startup.dependencyByType(ColdFeet#)
		verifyErrTypeAndMsg(ArgErr#, ErrMsgs.assetUriMustStartWithSlash(`myStyles.css`)) {
			coldFeet.assetUri(`myStyles.css`)
		}
	}

	Void testAssetUriMustBeMapped() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).addModule(T_Module05#).startup.dependencyByType(ColdFeet#)
		verifyErrTypeAndMsg(NotFoundErr#, ErrMsgs.assetUriNotMapped(`/css/myStyles.css`)) {
			coldFeet.assetUri(`/css/myStyles.css`)
		}
	}
	
	Void testAssetUriDoesNotExist() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).addModule(T_Module05#).startup.dependencyByType(ColdFeet#)
		verifyErrTypeAndMsg(ArgErr#, ErrMsgs.assetUriDoesNotExist(`/not-here/myStyles.css`, `doc/myStyles.css`.toFile)) {
			coldFeet.assetUri(`/not-here/myStyles.css`)
		}
	}
	
	Void testAssetUri() {
		coldFeet := (ColdFeet) BedServer(ColdFeetModule#).addModule(T_Module05#).startup.dependencyByType(ColdFeet#)
		uri := coldFeet.assetUri(`/not-here/pod.fandoc`)
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
		config[ChecksumStrategy#] = ChecksumFromConst("ver")
	}
}
