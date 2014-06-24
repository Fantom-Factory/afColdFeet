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
	internal static Void contributeMiddlewarePipeline(OrderedConfig config, ColdFeetMiddleware middleware) {
		config.addOrdered("ColdFeet", middleware, ["BEFORE: Routes"])
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[ColdFeetConfigIds.assetPrefix] 		= `/coldFeet/`
		config[ColdFeetConfigIds.assetExpiresIn] 	= 365day * 10
	}
	
	@Advise { serviceId="afBedSheet::FileHandler" }
	static Void adviseFileHandler(MethodAdvisor[] methodAdvisors, DigestStrategy digestStrategy, IocConfigSource configSrc) {
		assetPrefix	:= (Uri) configSrc.get("afColdFeet.assetPrefix", Uri#)
		
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
	static Void contributeRegistryStartup(OrderedConfig conf, IocConfigSource iocConfig) {
		conf.addOrdered("afColdFeet.validateAssetPrefix") |->| {
			assetPrefix := (Uri) iocConfig.get(ColdFeetConfigIds.assetPrefix, Uri#)
			if (!assetPrefix.isPathOnly)
				throw ParseErr(ErrMsgs.assetPrefixMustBePathOnly(assetPrefix))
			if (!assetPrefix.isPathAbs)
				throw ParseErr(ErrMsgs.assetPrefixMustStartWithSlash(assetPrefix))
			if (!assetPrefix.isDir)
				throw ParseErr(ErrMsgs.assetPrefixMustEndWithSlash(assetPrefix))
		}
	}
}
