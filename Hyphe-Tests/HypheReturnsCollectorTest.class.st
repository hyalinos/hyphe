Class {
	#name : 'HypheReturnsCollectorTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests - data collection' }
HypheReturnsCollectorTest >> testArithmeticCollection [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testArithmetic.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorTest >> testChainedCallsPropagation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testChainedCalls.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    
    "Should have instrumented and collected from firstMethod, secondMethod, and thirdMethod"
    self assert: (collections anySatisfy: [ :data | data second = #firstMethod ]).
    self assert: (collections anySatisfy: [ :data | data second = #secondMethod ]).
    self assert: (collections anySatisfy: [ :data | data second = #thirdMethod ])
]

{ #category : 'tests - error handling' }
HypheReturnsCollectorTest >> testCleanupOnError [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testThatFails.
    collector := HypheReturnsCollector on: testCase.
    
    "Disable transcript logging to avoid clutter"
    collector logger disableTranscriptLogging.
    
    result := collector run.
    
    "Result should still be returned with execution time"
    self assert: result notNil.
    self assert: result executionTime notNil
]

{ #category : 'tests - basic' }
HypheReturnsCollectorTest >> testCollectorCreation [
    | testCase collector |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    
    self assert: collector notNil.
    self assert: collector result notNil.
    self assert: collector logger notNil
]

{ #category : 'tests - result' }
HypheReturnsCollectorTest >> testExecutionTimeTracking [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result executionTime notNil.
    self assert: result executionTime >= Duration zero
]

{ #category : 'tests - error handling' }
HypheReturnsCollectorTest >> testHandleFailingTest [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testThatFails.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    "Should not be completed due to failure"
    self deny: result isCompleted.
    self assert: result status = #error."THIS WILL LIKELY TRIGGER AN ERROR NOT A TESTFAILURE"
    self assert: result errorMessage notNil
]

{ #category : 'tests - logger' }
HypheReturnsCollectorTest >> testLoggerAccess [
    | testCase collector |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    
    self assert: collector logger notNil.
    self assert: collector logger class = HypheReturnsCollectorLogger
]

{ #category : 'tests - logger' }
HypheReturnsCollectorTest >> testLoggerTranscriptCanBeDisabled [
    | testCase collector |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    
    collector logger disableTranscriptLogging.
    self deny: collector logger logToTranscript.
    
    "Should still work with transcript disabled"
    collector run.
    self assert: collector logger contents notEmpty
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorTest >> testMethodClassCollection [
    | testCase collector result collections dataPoint |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    dataPoint := collections detect: [ :data | data second = #testSimpleReturn ].
    
    "Third element is method class"
    self assert: dataPoint third = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorTest >> testMixedReturnTypes [
    | testCase collector result collections stringData numberData |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testMixedReturnTypes.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    
    "Should have different return types"
    stringData := collections detect: [ :data | data second = #getStringValue ].
    numberData := collections detect: [ :data | data second = #getNumberValue ].
    
    self assert: stringData fourth = ByteString.
    self assert: numberData fourth = SmallInteger
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorTest >> testNoDuplicateInstrumentation [
    | testCase collector result collections firstSize secondSize |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    firstSize := result collections size.
    
    "Run again with same test"
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    secondSize := result collections size.
    
    "Should collect similar amount of data (not exponentially more)"
    self assert: secondSize equals: firstSize
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorTest >> testPrimitiveMethodHandling [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testPrimitives.
    collector := HypheReturnsCollector on: testCase.
    
    "Should not crash on primitive methods"
    result := collector run.
    self assert: result notNil
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorTest >> testReceiverClassCollection [
    | testCase collector result collections dataPoint |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testWithMessageSends.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    "Find helper method data point"
    dataPoint := collections detect: [ :data | data second = #helperMethod ].
    
    "First element is receiver class"
    self assert: dataPoint first = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorTest >> testReturnTypeCollection [
    | testCase collector result collections dataPoint |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    "Find the data point for testSimpleReturn"
    dataPoint := collections detect: [ :data | data second = #testSimpleReturn ].
    
    "dataPoint structure: {receiverClass . selector . methodClass . returnClass}"
    self assert: dataPoint fourth = ByteString "Return type should be String"
]

{ #category : 'tests - basic' }
HypheReturnsCollectorTest >> testSimpleReturnCollection [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result notNil.
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - result' }
HypheReturnsCollectorTest >> testStatusTracking [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result status = #completed
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorTest >> testWithMessageSends [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testWithMessageSends.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty.
    
    "Should have collected data from both testWithMessageSends and helperMethod"
    self assert: (collections anySatisfy: [ :data | data second = #helperMethod ])
]
