Extension { #name : 'TestCase' }

{ #category : '*Hyphe' }
TestCase >> performTestForHyphe [
    "Execute the test method and return its actual return value.
    Based on performTest but captures and returns the value."
    | testReturnValue |
    
    testReturnValue := self perform: testSelector asSymbol.
    ^ testReturnValue
]

{ #category : '*Hyphe' }
TestCase >> runCaseForHyphe [
    "Run the test case exactly like runCase, but return the actual test method return value.
    Based on TestCase>>runCase but captures and returns the test return value."
    | testReturnValue |
    
    self resources do: [ :each | each availableFor: self ].
    [ [
        self setUp.
        testReturnValue := self performTestForHyphe
    ] ensure: [ self tearDown ] ] ensure: [ self cleanUpInstanceVariables ].
    
    ^ testReturnValue
]
