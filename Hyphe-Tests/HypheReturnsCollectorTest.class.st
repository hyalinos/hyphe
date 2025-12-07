Class {
	#name : 'HypheReturnsCollectorTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testAndOrInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testAndOr.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
]

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

{ #category : 'tests - blocks' }
HypheReturnsCollectorTest >> testBlockValueInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testBlockValue.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
]

{ #category : 'tests - blocks' }
HypheReturnsCollectorTest >> testBlockWithArgumentInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testBlockWithArgument.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
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
    self assert: (collections anySatisfy: [ :item | item methodSelector = #firstMethod ]).
    self assert: (collections anySatisfy: [ :item | item methodSelector = #secondMethod ]).
    self assert: (collections anySatisfy: [ :item | item methodSelector = #thirdMethod ])
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

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testEnsureInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testEnsure.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
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

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testIfNilIfNotNilInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testIfNilIfNotNil.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testIfNilIfNotNilWithValueInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testIfNilIfNotNilWithValue.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
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
    | testCase collector result collections dataItem |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    dataItem := collections detect: [ :item | item methodSelector = #testSimpleReturn ].
    
    self assert: dataItem definingClass = HypheReturnsCollectorTestFixture
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
    stringData := collections detect: [ :item | item methodSelector = #getStringValue ].
    numberData := collections detect: [ :item | item methodSelector = #getNumberValue ].
    
    self assert: stringData returnClass = ByteString.
    self assert: numberData returnClass = SmallInteger
]

{ #category : 'tests - blocks' }
HypheReturnsCollectorTest >> testNestedBlocksInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testNestedBlocks.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
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

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testOnDoInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testOnDo.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
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
    | testCase collector result collections dataItem |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testWithMessageSends.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    "Find helper method data point"
    dataItem := collections detect: [ :item | item methodSelector = #helperMethod ].
    
    self assert: dataItem receiverClass = HypheReturnsCollectorTestFixture
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorTest >> testReturnTypeCollection [
    | testCase collector result collections dataItem |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    collections := result collections.
    "Find the data point for testSimpleReturn"
    dataItem := collections detect: [ :item | item methodSelector = #testSimpleReturn ].
    
    self assert: dataItem returnClass = ByteString "Return type should be String"
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

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testToDoInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testToDo.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
]

{ #category : 'tests - control flow' }
HypheReturnsCollectorTest >> testWhileTrueInstrumentation [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testWhileTrue.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty
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
    self assert: (collections anySatisfy: [ :item | item methodSelector = #helperMethod ])
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorTest >> testWithOrderedCollection [
    | testCase collector result collections |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testWithOrderedCollection.
    collector := HypheReturnsCollector on: testCase.
    result := collector run.
    
    self assert: result isCompleted.
    collections := result collections.
    self assert: collections notEmpty.
    
    "Should have collected data from both testWithMessageSends and helperMethod"
    self assert: (collections anySatisfy: [ :item | item methodSelector = #helperMethod ])
]
