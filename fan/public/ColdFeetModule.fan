using afIoc
using afIocConfig
using afBedSheet

** The [IoC]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class ColdFeetModule {

	static Void defineServices(RegistryBuilder defs) {
		defs.addService(ColdFeetMiddleware#)
		defs.addService(UrlExclusions#)
		defs.addService(DigestStrategy#, Adler32Digest#)
		defs.addService(UrlTransformer#, PathTransformer#)
		
		// hook into BedSheet
		defs.overrideService(ClientAssetCache#.qname).withImplType(ColdFeetAssetCache#).withOverrideId(ColdFeetAssetCache#.qname)
	}

	@Contribute { serviceType=MiddlewarePipeline# }
	internal static Void contributeMiddlewarePipeline(Configuration config, ColdFeetMiddleware middleware) {
		config.set("afColdFeet", middleware).before("afBedSheet.assets")
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[ColdFeetConfigIds.urlPrefix]	= "coldFeet"
		config[ColdFeetConfigIds.expiresIn]	= 365day
	}
	
	@Contribute { serviceType=StackFrameFilter# }
	static Void contributeStackFrameFilter(Configuration config) {
		// remove meaningless and boring stack frames
		config.add("^afColdFeet::ColdFeetMiddleware.+\$")
	}
	
	static Void onRegistryStartup(Configuration config, ConfigSource iocConfig) {
		config["afColdFeet.validateConfig"] = |->| {
			urlPrefix := (Str) iocConfig.get(ColdFeetConfigIds.urlPrefix, Str#)
			if (!Uri.isName(urlPrefix))
				throw ParseErr(ErrMsgs.assetPrefixMustBeUriName(urlPrefix))
		}
	}
}
