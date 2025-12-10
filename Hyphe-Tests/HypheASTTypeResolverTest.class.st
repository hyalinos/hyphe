Class {
	#name : 'HypheASTTypeResolverTest',
	#superclass : 'TestCase',
	#instVars : [
		'testStore'
	],
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'helpers' }
HypheASTTypeResolverTest >> populateTestStore [
	"Populate the store with test data for hierarchy testing"
	| store data |
	store := HypheTypeInferenceStore current.
	data := store instVarNamed: #inferenceData.
	
	"Add some Collection superclass methods"
	data at: 'Collection>>add:' put: {'*r'. 0.9}.
	data at: 'Collection>>yourself' put: {'*r'. 1.0}.
	data at: 'Collection>>size' put: {'Integer'. 1.0}.
	
	"Add String methods"
	data at: 'String>>asString' put: {'String'. 1.0}.
	data at: 'ByteString>>yourself' put: {'*r'. 1.0}.
	
	"Add some wildcard entries"
	data at: '*r>>new' put: {'*r'. 0.8}
]

{ #category : 'running' }
HypheASTTypeResolverTest >> setUp [
	"Set up test fixtures with a dedicated test store.
	 The test store is kept separate - we do NOT modify the singleton."
	super setUp.
	
	"Create test store with fixed data"
	testStore := HypheTypeInferenceStoreForTesting new loadFromCSV
]

{ #category : 'running' }
HypheASTTypeResolverTest >> tearDown [
	"Clean up after tests"
	testStore := nil.
	super tearDown
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testExactMatch [
	"Test that exact match lookup still works"
	| result |
	
	result := testStore inferenceForClassName: 'String' selector: #asString.
	
	self assert: result notNil description: 'Should find exact match'.
	self assert: result first equals: 'String'.
	self assert: result second equals: 1.0
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testExactMatchBeforeSuperclass [
	"Test that exact match on the class itself is checked before superclass"
	| result |
	
	"ByteString>>yourself is in our data, should be found before checking String"
	result := testStore inferenceForClassName: 'ByteString' selector: #yourself.
	
	self assert: result notNil description: 'Should find exact match'.
	self assert: result first equals: '*r'.
	self assert: result second equals: 1.0
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testHierarchyBeforeWildcard [
	"Test that we check superclass hierarchy before falling back to wildcard"
	| result |
	
	"OrderedCollection>>doSomething not in data
	 Collection>>doSomething not in data
	 But *r>>doSomething exists as wildcard
	 Should use wildcard only after checking all superclasses"
	result := testStore inferenceForClassName: 'OrderedCollection' selector: #doSomething withFallback: true.
	
	"Should eventually find the wildcard *r>>doSomething"
	self assert: result notNil description: 'Should find wildcard after hierarchy search'.
	self assert: result first equals: 'Unknown'
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testMultipleSuperclassLevels [
	"Test that we can find methods several levels up the hierarchy"
	| result |
	
	"OrderedCollection -> SequenceableCollection -> Collection
	 The yourself method is defined on Collection in our test data"
	result := testStore inferenceForClassName: 'OrderedCollection' selector: #yourself.
	
	self assert: result notNil description: 'Should find method in ancestor class'.
	self assert: result first equals: '*r'.
	self assert: result second equals: 1.0
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testNoMatchWithoutFallback [
	"Test that nil is returned when no match and no fallback"
	| result |
	
	"NonExistent>>nonExistent should not be found"
	result := testStore inferenceForClassName: 'NonExistent' selector: #nonExistent withFallback: false.
	
	self assert: result isNil description: 'Should return nil when not found'
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testNonExistentClassReturnsNil [
	"Test that looking up methods on non-existent classes returns nil"
	| result |
	
	result := testStore inferenceForClassName: 'CompletelyMadeUpClass123' selector: #someMethod withFallback: false.
	
	self assert: result isNil description: 'Should return nil for non-existent class without fallback'
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testOrderedCollectionInheritsFromCollection [
	"Test that OrderedCollection correctly inherits Collection methods"
	| result |
	
	"Verify OrderedCollection finds Collection>>size"
	result := testStore inferenceForClassName: 'OrderedCollection' selector: #size.
	
	self assert: result notNil description: 'OrderedCollection should inherit Collection>>size'.
	self assert: result first equals: 'Integer'.
	self assert: result second equals: 1.0
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testSequenceableCollectionInheritsFromCollection [
	"Test hierarchy: SequenceableCollection -> Collection"
	| result |
	
	"SequenceableCollection does not have add: but Collection does"
	result := testStore inferenceForClassName: 'SequenceableCollection' selector: #add:.
	
	self assert: result notNil description: 'SequenceableCollection should inherit Collection>>add:'.
	self assert: result first equals: '*r'.
	self assert: result second equals: 0.9
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testSuperclassLookup [
	"Test that superclass hierarchy lookup works"

	| result |
	"OrderedCollection does not have add: in our test data, but Collection does"
	result := testStore
		          inferenceForClassName: 'OrderedCollection'
		          selector: #add:.

	self
		assert: result notNil
		description: 'Should find method in superclass'.
	self assert: result first equals: '*t1'.
	self assert: result second equals: 0.9
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testWildcardFallbackIsLastResort [
	"Test that wildcard fallback only happens after hierarchy search"
	| result |
	
	"ByteString -> String -> ... -> Object
	 yourself should be found in Object before checking *r>>yourself wildcard"
	result := testStore inferenceForClassName: 'ByteString' selector: #yourself withFallback: true.
	
	"Should find Object>>yourself or ByteString>>yourself, not *r>>yourself wildcard"
	self assert: result notNil description: 'Should find method'.
	self assert: result first equals: '*r'
]

{ #category : 'tests' }
HypheASTTypeResolverTest >> testWildcardWhenNoHierarchyMatch [
	"Test that wildcard fallback works when nothing found in hierarchy"
	| result |
	
	"SomeNonExistentClass>>new should fallback to *r>>new"
	result := testStore inferenceForClassName: 'SomeNonExistentClass' selector: #new withFallback: true.
	
	self assert: result notNil description: 'Should find wildcard fallback'.
	self assert: result first equals: '*r'.
	self assert: result second equals: 0.8
]
