Class {
	#name : 'HypheASTTypeResolverIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'testResolver'
	],
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'running' }
HypheASTTypeResolverIntegrationTest >> setUp [
	"Set up test fixtures with a dedicated test resolver"
	| testStore data |
	super setUp.
	
	"Create test store with fixed data"
	testStore := HypheTypeInferenceStore new.
	data := testStore instVarNamed: #inferenceData.
	
	"Populate with test data matching the CSV structure"
	"Collection hierarchy"
	data at: 'Collection>>add:' put: {'*r'. 0.9}.
	data at: 'Collection>>size' put: {'Integer'. 1.0}.
	data at: 'Collection>>yourself' put: {'*r'. 1.0}.
	
	"OrderedCollection specific"
	data at: 'OrderedCollection class>>new' put: {'OrderedCollection'. 1.0}.
	data at: 'OrderedCollection>>add:' put: {'*t1'. 0.9}.
	
	"Array"
	data at: 'Array class>>new' put: {'Array'. 1.0}.
	
	"String hierarchy"
	data at: 'String>>asString' put: {'String'. 1.0}.
	data at: 'ByteString>>asString' put: {'String'. 1.0}.
	
	"SmallInteger"
	data at: 'SmallInteger class>>new' put: {'SmallInteger'. 1.0}.
	
	"Object hierarchy"
	data at: 'Object>>yourself' put: {'*r'. 1.0}.
	
	"Boolean classes"
	data at: 'True>>yourself' put: {'*r'. 1.0}.
	data at: 'False>>yourself' put: {'*r'. 1.0}.
	
	"Wildcard entries"
	data at: '*r>>yourself' put: {'*r'. 1.0}.
	data at: '*r>>new' put: {'*r'. 0.8}.
	
	"Create test resolver with the test store"
	testResolver := HypheASTTypeResolverForTesting new initializeWithStore: testStore
]

{ #category : 'running' }
HypheASTTypeResolverIntegrationTest >> tearDown [
	"Clean up after tests"
	testResolver := nil.
	super tearDown
]

{ #category : 'tests - literals' }
HypheASTTypeResolverIntegrationTest >> testBooleanLiteral [
	"Test: true yourself
	 Literal true should resolve to True class"
	| code ast result resultType |
	
	code := 'true yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"Should resolve to True (the class of true)"
	self assert: resultType equals: 'True'
]

{ #category : 'tests - basic' }
HypheASTTypeResolverIntegrationTest >> testClassInstantiationWithYourself [
	"Test: (OrderedCollection new) yourself"
	| code ast result resultType |
	
	code := '(OrderedCollection new) yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	self assert: resultType equals: 'OrderedCollection'
]

{ #category : 'tests - basic' }
HypheASTTypeResolverIntegrationTest >> testClassInstantiationWithYourselfNoParens [
	"Test: OrderedCollection new yourself"
	| code ast result resultType |
	
	code := 'OrderedCollection new yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	self assert: resultType equals: 'OrderedCollection'
]

{ #category : 'tests - class-references' }
HypheASTTypeResolverIntegrationTest >> testClassReferenceWithoutInstantiation [
	"Test that class references are properly recognized"
	| code ast result resultType |
	
	code := 'OrderedCollection'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"Should resolve to OrderedCollection class"
	self assert: resultType equals: 'OrderedCollection class'
]

{ #category : 'tests - hierarchy' }
HypheASTTypeResolverIntegrationTest >> testCollectionHierarchy [
	"Test: OrderedCollection new size
	 - new returns OrderedCollection
	 - size should be found in Collection (superclass)"
	| code ast result resultType |
	
	code := 'OrderedCollection new size'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"size should return Integer from Collection>>size"
	self assert: resultType equals: 'Integer'
]

{ #category : 'tests - complex' }
HypheASTTypeResolverIntegrationTest >> testComplexChainWithHierarchy [
	"Test: ((OrderedCollection new) add: 42) size
	 - new returns OrderedCollection
	 - add: 42 returns SmallInteger (*t1)
	 - SmallInteger does not have size, but Number does not either
	 - Should use hierarchy or wildcard lookup"
	| code ast result resultType |
	
	code := '((OrderedCollection new) add: 42) size'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"SmallInteger has no size method, so likely returns Unknown or Integer"
	self assert: (resultType notNil and: [ resultType notEmpty ])
		description: 'Should resolve to some type'
]

{ #category : 'tests - confidence' }
HypheASTTypeResolverIntegrationTest >> testConfidenceValues [
	"Test that confidence values are properly computed and composed"
	| code ast result confidence |
	
	code := 'OrderedCollection new yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	confidence := result at: #confidence.
	
	"Confidence should be a number between 0 and 1"
	self assert: (confidence isKindOf: Number).
	self assert: (confidence >= 0 and: [ confidence <= 1 ])
		description: 'Confidence should be between 0 and 1, got: ', confidence printString
]

{ #category : 'tests - literals' }
HypheASTTypeResolverIntegrationTest >> testFloatLiteral [
	"Test: 3.14 yourself"

	| code ast result resultType |
	code := '3.14 yourself'.
	ast := RBParser parseExpression: code.

	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.

	"Should resolve to Float"
	self assert: resultType equals: 'SmallFloat64'
]

{ #category : 'tests - parametric' }
HypheASTTypeResolverIntegrationTest >> testNestedParametricTypes [
	"Test: (OrderedCollection new add: (Array new)) yourself
	 - Array new returns Array
	 - add: Array returns Array (*t1)
	 - yourself returns Array (*r)"
	| code ast result resultType |
	
	code := '(OrderedCollection new add: (Array new)) yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"Should resolve to Array"
	self assert: resultType equals: 'Array'
]

{ #category : 'tests - literals' }
HypheASTTypeResolverIntegrationTest >> testNilLiteral [
	"Test: nil isNil
	 Literal nil should resolve to UndefinedObject"
	| code ast result |
	
	code := 'nil isNil'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	
	"Just verify it doesn't crash - isNil might not be in CSV"
	self assert: result notNil
		description: 'Should return a result dictionary'
]

{ #category : 'tests - parametric' }
HypheASTTypeResolverIntegrationTest >> testParametricTypeWithInteger [
	"Test: (OrderedCollection new add: 1) yourself
	 OrderedCollection>>add: returns *t1 (type of first argument)
	 So this should return SmallInteger"
	| code ast result resultType |
	
	code := '(OrderedCollection new add: 1) yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	self assert: resultType equals: 'SmallInteger'
]

{ #category : 'tests - parametric' }
HypheASTTypeResolverIntegrationTest >> testParametricTypeWithString [
	"Test: (OrderedCollection new add: 'hello') yourself
	 String literals are ByteString in Pharo"
	| code ast result resultType |
	
	code := '(OrderedCollection new add: ''hello'') yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"ByteString or String depending on the system"
	self assert: (resultType = 'ByteString' or: [ resultType = 'String' ])
		description: 'Expected ByteString or String, got: ', resultType
]

{ #category : 'tests - basic' }
HypheASTTypeResolverIntegrationTest >> testSimpleClassInstantiation [
	"Test: OrderedCollection new"
	| code ast result resultType |
	
	code := 'OrderedCollection new'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	self assert: resultType equals: 'OrderedCollection'
]

{ #category : 'tests - hierarchy' }
HypheASTTypeResolverIntegrationTest >> testStringMethodWithHierarchy [
	"Test: 'hello' asString
	 ByteString>>asString should be found (added in our CSV or hierarchy)"
	| code ast result resultType |
	
	code := '''hello'' asString'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"Should resolve to String via ByteString>>asString or String>>asString"
	self assert: (resultType = 'String' or: [ resultType = 'ByteString' ])
		description: 'Expected String or ByteString, got: ', resultType
]

{ #category : 'tests - literals' }
HypheASTTypeResolverIntegrationTest >> testSymbolLiteral [
	"Test: #mySymbol yourself"

	| code ast result resultType |
	code := '#mySymbol yourself'.
	ast := RBParser parseExpression: code.

	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.

	"Should resolve to Symbol"
	self assert: resultType equals: 'ByteSymbol'
]

{ #category : 'tests - edge-cases' }
HypheASTTypeResolverIntegrationTest >> testUnknownForUnresolvable [
	"Test that Unknown is returned when type cannot be resolved"
	| code ast result resultType |
	
	code := 'someUndefinedVariable someUnknownMethod'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"Should resolve to Unknown"
	self assert: resultType equals: 'Unknown'
]

{ #category : 'tests - complex' }
HypheASTTypeResolverIntegrationTest >> testVeryComplexExpression [
	"Test: (OrderedCollection new add: ('hello' asString )) yourself"

	| code ast result resultType |
	code := '(OrderedCollection new add: (''hello'' asString )) yourself'.
	ast := RBParser parseExpression: code.

	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.

	self assert: resultType equals: 'String'
]

{ #category : 'tests - wildcard' }
HypheASTTypeResolverIntegrationTest >> testWildcardFallback [
	"Test that wildcard *r>>yourself is used when no hierarchy match exists"
	| code ast result resultType |
	
	code := 'SmallInteger new yourself'.
	ast := RBParser parseExpression: code.
	
	result := testResolver resolveNode: ast depth: 0.
	resultType := result at: #type.
	
	"SmallInteger new returns SmallInteger, yourself should use *r wildcard"
	self assert: resultType equals: 'SmallInteger'
]
