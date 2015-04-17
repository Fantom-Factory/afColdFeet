using afIoc
using afIocConfig
using afBedSheet

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class ColdFeetModule {

	static Void defineServices(ServiceDefinitions defs) {
		defs.add(ColdFeetMiddleware#)
		defs.add(FileAssetCacheAdvice#)
		defs.add(UrlExclusions#)
		defs.add(DigestStrategy#, Adler32Digest#)
		defs.add(UrlTransformer#, PathTransformer#)
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

	@Advise { serviceType=ClientAssetCache# }
	internal static Void adviseFileAssetCache(MethodAdvisor[] methodAdvisors, FileAssetCacheAdvice advice) {
		methodAdvisors
			.find { it.method.name == "toClientUrl" }
			.addAdvice |invocation -> Obj?| {
				advice.adviseToClientUrl(invocation)
			} 
	}
	
	@Contribute { serviceType=RegistryStartup# }
	static Void contributeRegistryStartup(Configuration config, ConfigSource iocConfig) {
		config["afColdFeet.validateConfig"] = |->| {
			urlPrefix := (Str) iocConfig.get(ColdFeetConfigIds.urlPrefix, Str#)
			if (!Uri.isName(urlPrefix))
				throw ParseErr(ErrMsgs.assetPrefixMustBeUriName(urlPrefix))
		}
	}
}
