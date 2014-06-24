using afIoc
using afIocConfig::ApplicationDefaults
using afBounce::BedServer

internal class TestConfigValidation : ColdFeetTest {
	
	override Void setup() { }
	
	Void testPrefixMustBePathOnly() {
		server := BedServer(T_Module01#).addModule(ColdFeetModule#)
		verifyErrMsg(IocErr#, ErrMsgs.assetPrefixMustBePathOnly(`http://coldFeet/`)) {
			server.startup
		}
	}
	
	Void testPrefixMustStartWithSlash() {
		server := BedServer(T_Module02#).addModule(ColdFeetModule#)
		verifyErrMsg(IocErr#, ErrMsgs.assetPrefixMustStartWithSlash(`coldFeet/`)) {
			server.startup
		}
	}	
	
	Void testPrefixMustEndWithSlash() {
		server := BedServer(T_Module03#).addModule(ColdFeetModule#)
		verifyErrMsg(IocErr#, ErrMsgs.assetPrefixMustEndWithSlash(`/coldFeet`)) {
			server.startup
		}
	}	
}

internal class T_Module01 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[ColdFeetConfigIds.assetPrefix] = `http://coldFeet/`
	}
}

internal class T_Module02 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[ColdFeetConfigIds.assetPrefix] = `coldFeet/`
	}
}

internal class T_Module03 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[ColdFeetConfigIds.assetPrefix] = `/coldFeet`
	}
}
