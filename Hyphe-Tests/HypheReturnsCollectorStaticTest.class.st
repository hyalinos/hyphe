Class {
	#name : 'HypheReturnsCollectorStaticTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests - basic' }
HypheReturnsCollectorStaticTest >> testBasicStaticInstrumentation [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - cleanup' }
HypheReturnsCollectorStaticTest >> testCleanup [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result isCompleted
]

{ #category : 'tests - data collection' }
HypheReturnsCollectorStaticTest >> testDataCollection [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testArithmetic.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty.
    self assert: (result collections allSatisfy: [ :item | 
        item isKindOf: HypheReturnDataItem ])
]

{ #category : 'tests - domain methods' }
HypheReturnsCollectorStaticTest >> testDomainMethodsCollection [
    | testCase collector |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    collector collectDomainMethods.
    
    self assert: collector domainMethods notEmpty
]

{ #category : 'tests - error handling' }
HypheReturnsCollectorStaticTest >> testErrorHandling [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testThatFails.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: result notNil.
    self assert: result hasErrors
]

{ #category : 'tests - instrumentation' }
HypheReturnsCollectorStaticTest >> testInstrumentationCount [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests').
    
    result := collector run.
    
    self assert: (collector logger contents includesSubstring: '[COLLECT] Found')
]

{ #category : 'tests - packages' }
HypheReturnsCollectorStaticTest >> testMultiplePackages [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testChainedCalls.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('Hyphe-Tests' 'Hyphe').
    
    result := collector run.
    
    self assert: result isCompleted.
    self assert: result collections notEmpty
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorStaticTest >> testWithEmptyPackageList [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #().
    
    result := collector run.
    
    self assert: result isCompleted
]

{ #category : 'tests - edge cases' }
HypheReturnsCollectorStaticTest >> testWithNonExistentPackage [
    | testCase collector result |
    testCase := HypheReturnsCollectorTestFixture new.
    testCase setTestSelector: #testSimpleReturn.
    
    collector := HypheReturnsCollectorStatic 
        on: testCase 
        forPackages: #('NonExistentPackage123').
    
    result := collector run.
    
    self assert: result isCompleted
]
