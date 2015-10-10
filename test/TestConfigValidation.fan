using afIoc
using afIocConfig::ApplicationDefaults
using afBounce::BedServer

internal class TestConfigValidation : ColdFeetTest {
	
	override Void setup() { }
	
	Void testPrefixMustBePathOnly() {
		server := BedServer(T_Module01#).addModule(ColdFeetModule#)
		verifyErrMsg(ParseErr#, ErrMsgs.assetPrefixMustBeUriName("http://coldFeet/")) {
			server.startup
		}
	}
	
	Void testPrefixMustStartWithSlash() {
		server := BedServer(T_Module02#).addModule(ColdFeetModule#)
		verifyErrMsg(ParseErr#, ErrMsgs.assetPrefixMustBeUriName("coldFeet/")) {
			server.startup
		}
	}	
	
	Void testPrefixMustEndWithSlash() {
		server := BedServer(T_Module03#).addModule(ColdFeetModule#)
		verifyErrMsg(ParseErr#, ErrMsgs.assetPrefixMustBeUriName("/coldFeet")) {
			server.startup
		}
	}	
}

internal const class T_Module01 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(Configuration config) {
		config[ColdFeetConfigIds.urlPrefix] = "http://coldFeet/"
	}
}

internal const class T_Module02 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(Configuration config) {
		config[ColdFeetConfigIds.urlPrefix] = "coldFeet/"
	}
}

internal const class T_Module03 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(Configuration config) {
		config[ColdFeetConfigIds.urlPrefix] = "/coldFeet"
	}
}
