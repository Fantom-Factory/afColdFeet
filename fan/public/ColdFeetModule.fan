using afIoc
using afIocConfig
using afBedSheet

const class ColdFeetModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bind(ColdFeet#)
		binder.bind(ColdFeetMiddleware#)
		binder.bind(ChecksumStrategy#, ChecksumFromAppVersion#)
	}
	
	@Contribute { serviceType=MiddlewarePipeline# }
	internal static Void contributeMiddlewarePipeline(OrderedConfig config, ColdFeetMiddleware middleware) {
		config.addOrdered("ColdFeet", middleware, ["BEFORE: Routes"])
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config) {
		config[ColdFeetConfigIds.assetPrefix] 	= `/coldFeet/`
	}
	
	@Contribute { serviceType=RegistryStartup# }
	static Void contributeRegistryStartup(OrderedConfig conf, IocConfigSource iocConfig) {
		conf.add |->| {
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
