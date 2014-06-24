using afIoc
using afBedSheet
using afColdFeet

class Example {
  @Inject FileHandler? fileHandler

  Text coldFeetUris() {
    asset := fileHandler.fromServerFile(`Example.fan`.toFile)
    msg   := "Normal URL   : ${asset.localUrl} \n"
    msg   += "Cold Feet URL: ${asset.clientUrl}\n"
    return Text.fromPlain(msg)
  }
}

@SubModule { modules=[ColdFeetModule#] }
class AppModule {
  @Contribute { serviceType=Routes# }
  static Void contributeRoutes(OrderedConfig conf) {
    conf.add(Route(`/`, Example#coldFeetUris))
  }

  @Contribute { serviceType=FileHandler# }
  static Void contributeFileHandler(MappedConfig config) {
    config[`/`] = `./`
  }
}

class Main {
  Int main() {
    afBedSheet::Main().main([AppModule#.qname, "8080"])
  }
}
