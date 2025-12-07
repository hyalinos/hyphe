Class {
	#name : 'HypheReturnsCollectorLoggerTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testClear [
    | logger |
    logger := HypheReturnsCollectorLogger new.
    logger disableTranscriptLogging.
    
    logger log: 'test'.
    self deny: logger contents isEmpty.
    
    logger clear.
    self assert: logger contents isEmpty
]

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testCr [
    | logger |
    logger := HypheReturnsCollectorLogger new.
    logger disableTranscriptLogging.
    
    logger log: 'line 1'.
    logger cr.
    logger log: 'line 2'.
    
    "Contents should have multiple lines"
    self assert: logger contents lines size > 2
]

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testInitialization [
    | logger |
    logger := HypheReturnsCollectorLogger new.
    
    self assert: logger contents isEmpty.
    self assert: logger logToTranscript
]

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testLogging [
    | logger |
    logger := HypheReturnsCollectorLogger new.
    logger disableTranscriptLogging.
    
    logger log: 'test message'.
    self assert: (logger contents includesSubstring: 'test message')
]

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testPrintOn [
    | logger printed |
    logger := HypheReturnsCollectorLogger new.
    logger disableTranscriptLogging.
    logger log: 'test'.
    
    printed := logger printString.
    self assert: (printed includesSubstring: 'HypheReturnsCollectorLogger').
    self assert: (printed includesSubstring: 'characters')
]

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testShow [
    | logger |
    logger := HypheReturnsCollectorLogger new.
    logger disableTranscriptLogging.
    
    logger show: 'test message'.
    self assert: (logger contents includesSubstring: 'test message')
]

{ #category : 'tests' }
HypheReturnsCollectorLoggerTest >> testTranscriptToggle [
    | logger |
    logger := HypheReturnsCollectorLogger new.
    
    self assert: logger logToTranscript.
    
    logger disableTranscriptLogging.
    self deny: logger logToTranscript.
    
    logger enableTranscriptLogging.
    self assert: logger logToTranscript
]
