using build

class Build : BuildPod {

	new make() {
		podName = "afColdFeet"
		summary = "An asset caching strategy for your Bed Application"
		version = Version("1.2.7")

		meta = [
			"proj.name"		: "Cold Feet",
			"afIoc.module"	: "afColdFeet::ColdFeetModule",
			"internal"		: "true",
			"tags"			: "web",
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.6+", 
			"afIoc 2.0.0+", 
			"afIocConfig 1.0.16+", 
			"afIocEnv 1.0.14+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.16+",
			
			// ---- Test ------------------------
			"afBounce 1.0.14+",
			"afButter 1.0.2+"
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
