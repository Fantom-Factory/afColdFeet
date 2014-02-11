
internal class TestMisc : Test {
	
	Void testUriMatch() {
		match := ColdFeetMiddleware.matchPrefix([`/dude`, `/dude/ab`, `/dude/ab/ba`, ], "/dude/ab/ba")
		verifyEq(match, `/dude/ab/ba`)

		match = ColdFeetMiddleware.matchPrefix([`/dude/ab/ba`, `/dude/ab`, `/dude/`], "/dude/ab/ba")
		verifyEq(match, `/dude/ab/ba`)
	}
}
