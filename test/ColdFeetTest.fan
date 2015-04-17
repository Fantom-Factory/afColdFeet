using afIoc
using afBounce

internal abstract class ColdFeetTest : Test { 
	
	override Void setup() {
		Log.get("afIoc").level 		= LogLevel.warn
		Log.get("afIocEnv").level 	= LogLevel.warn
		Log.get("afBedSheet").level = LogLevel.warn
	}
	
}
