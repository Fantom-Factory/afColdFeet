
internal class TestPathUrlTransformer : ColdFeetTest {
	
	// this is only brief for most of this is covered elsewhere, before UrlTransformer existed  
	Void testPathTransforms() {
		transformer := PathTransformer("poo")
	
		verifyEq(transformer.toColdFeet(`/bar.txt`, "foo"), `/poo/foo/bar.txt`)
		
		verifyEq(transformer.isColdFeet(`/poo/foo/bar.txt`), true)
		verifyEq(transformer.isColdFeet(`/poo/foo.txt`), false)
		verifyEq(transformer.isColdFeet(`/foo.txt`), false)
		
		verifyEq(transformer.fromColdFeet(`/poo/foo/bar.txt`), `/bar.txt`)

		verifyEq(transformer.extractDigest(`/poo/foo/bar.txt`), "foo")
	}
	
	Void testNameTransforms() {
		transformer := NameTransformer("poo")
	
		verifyEq(transformer.toColdFeet(`/bar`, "foo"), `/bar.poo.foo`)
		verifyEq(transformer.toColdFeet(`/bar.txt`, "foo"), `/bar.poo.foo.txt`)
		
		verifyEq(transformer.isColdFeet(`/bar.poo.foo.txt`), true)
		verifyEq(transformer.isColdFeet(`/bar.poo.foo`), true)
		verifyEq(transformer.isColdFeet(`/poo/foo.txt`), false)
		verifyEq(transformer.isColdFeet(`/poo/foo`), false)
		verifyEq(transformer.isColdFeet(`/foo.txt`), false)
		verifyEq(transformer.isColdFeet(`/foo`), false)
		
		verifyEq(transformer.fromColdFeet(`/bar.poo.foo.txt`), `/bar.txt`)
		verifyEq(transformer.fromColdFeet(`/bar.poo.foo`), `/bar`)

		verifyEq(transformer.extractDigest(`/bar.poo.foo.txt`), "foo")
		verifyEq(transformer.extractDigest(`/bar.poo.foo`), "foo")
		
		transformer = NameTransformer("coldFeet")
		url := `/css/bootstrap.min.coldFeet.JglBFw==.css`
		verifyEq(transformer.toColdFeet(`/css/bootstrap.min.css`, "JglBFw=="), url)
		verifyEq(transformer.isColdFeet(url), true)
		verifyEq(transformer.fromColdFeet(url), `/css/bootstrap.min.css`)
		verifyEq(transformer.extractDigest(url), "JglBFw==")

		url  = `/coldFeet/JglBFw==/css/bootstrap.min.css`
		iscf := transformer.isColdFeet(url)
		fmcf := transformer.fromColdFeet(url)
		cfdg := transformer.extractDigest(url)
	}
	
}
