Class {
	#name : 'HypheReturnsCollectorResultTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testCollectionsManagement [
    | result data |
    result := HypheReturnsCollectorResult new.
    data := {Object . #testMethod . Object . SmallInteger}.
    
    result addCollection: data.
    self assert: result collections size equals: 1.
    self assert: result collections first equals: data
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testErrorMessageSetting [
    | result message |
    result := HypheReturnsCollectorResult new.
    message := 'Test error'.
    
    result errorMessage: message.
    self assert: result errorMessage equals: message
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testExecutionTimeSetting [
    | result duration |
    result := HypheReturnsCollectorResult new.
    duration := 5 seconds.
    
    result executionTime: duration.
    self assert: result executionTime equals: duration
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testHasErrors [
    | result |
    result := HypheReturnsCollectorResult new.
    
    self deny: result hasErrors.
    
    result status: #error.
    self assert: result hasErrors.
    
    result status: #fatalError.
    self assert: result hasErrors
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testInitialization [
    | result |
    result := HypheReturnsCollectorResult new.
    
    self assert: result collections isEmpty.
    self assert: result status = #notStarted.
    self assert: result executionTime isNil.
    self assert: result errorMessage isNil
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testIsCompleted [
    | result |
    result := HypheReturnsCollectorResult new.
    
    self deny: result isCompleted.
    
    result status: #completed.
    self assert: result isCompleted
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testPrintOn [
    | result printed |
    result := HypheReturnsCollectorResult new.
    result status: #completed.
    result executionTime: 100 milliSeconds.
    
    printed := result printString.
    self assert: (printed includesSubstring: 'completed').
    self assert: (printed includesSubstring: '100ms')
]

{ #category : 'tests' }
HypheReturnsCollectorResultTest >> testStatusSetting [
    | result |
    result := HypheReturnsCollectorResult new.
    
    result status: #running.
    self assert: result status = #running.
    
    result status: #completed.
    self assert: result status = #completed
]
