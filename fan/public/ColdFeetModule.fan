using afIoc
using afIocConfig
using afBedSheet

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class ColdFeetModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bind(ColdFeetMiddleware#)
		binder.bind(DigestStrategy#, Adler32Digest#)
	}

	@Contribute { serviceType=MiddlewarePipeline# }
	internal static Void contributeMiddlewarePipeline(Configuration config, ColdFeetMiddleware middleware) {
		config.set("afColdFeet", middleware).before("afBedSheet.routes")
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[ColdFeetConfigIds.urlPrefix]	= `/coldFeet/`
		config[ColdFeetConfigIds.expiresIn]	= 365day
	}
	
	@Advise { serviceType=FileAssetCache# }
	static Void adviseFileHandler(MethodAdvisor[] methodAdvisors, DigestStrategy digestStrategy, IocConfigSource configSrc) {
		assetPrefix	:= (Uri) configSrc.get("afColdFeet.urlPrefix", Uri#)
		
		methodAdvisors
			.find { it.method.name == "toClientUrl" }
			.addAdvice |invocation -> Obj?| {
				localUrl 	:= (Uri)  invocation.args[0]
				file	 	:= (File) invocation.args[1]
				digest	 	:= digestStrategy.digest(file).toUri
				clientUrl	:= assetPrefix.plusSlash + digest.plusSlash + localUrl.relTo(`/`)
				invocation.args[0] = clientUrl
				return invocation.invoke
			} 
	}
	
	@Contribute { serviceType=RegistryStartup# }
	static Void contributeRegistryStartup(Configuration config, IocConfigSource iocConfig) {
		config["afColdFeet.validateConfig"] = |->| {
			urlPrefix := (Uri) iocConfig.get(ColdFeetConfigIds.urlPrefix, Uri#)
			if (!urlPrefix.isPathOnly)
				throw ParseErr(ErrMsgs.assetPrefixMustBePathOnly(urlPrefix))
			if (!urlPrefix.isPathAbs)
				throw ParseErr(ErrMsgs.assetPrefixMustStartWithSlash(urlPrefix))
			if (!urlPrefix.isDir)
				throw ParseErr(ErrMsgs.assetPrefixMustEndWithSlash(urlPrefix))
		}
	}
}
