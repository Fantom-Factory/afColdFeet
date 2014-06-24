using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "An asset caching strategy for your Bed App"
		version = Version("1.2.0")

		meta = [
			"proj.name"		: "Cold Feet",
			"afIoc.module"	: "afColdFeet::ColdFeetModule",
			"internal"		: "true",
			"tags"			: "web",
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.6+", 
			"afIoc 1.6.4+", 
			"afIocConfig 1.0.8+", 
			"afIocEnv 1.0.6+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.10+",
			
			// ---- Test ------------------------
			"afBounce 1.0.4+",
			"afButter 1.0.0+"
		]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [,]
	}
	
	@Target
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
