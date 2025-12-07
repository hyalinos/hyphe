Class {
	#name : 'HypheReturnsCollectorTestFixture',
	#superclass : 'TestCase',
	#instVars : [
		'value'
	],
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'helpers' }
HypheReturnsCollectorTestFixture >> firstMethod [
    ^ self secondMethod
]

{ #category : 'helpers' }
HypheReturnsCollectorTestFixture >> getNumberValue [
    ^ 123
]

{ #category : 'helpers' }
HypheReturnsCollectorTestFixture >> getStringValue [
    ^ 'test string'
]

{ #category : 'helpers' }
HypheReturnsCollectorTestFixture >> helperMethod [
    ^ 'helper result'
]

{ #category : 'initialization' }
HypheReturnsCollectorTestFixture >> initialize [
    super initialize.
    value := 0
]

{ #category : 'helpers' }
HypheReturnsCollectorTestFixture >> secondMethod [
    ^ self thirdMethod
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testArithmetic [
    | a b sum |
    a := 5.
    b := 3.
    sum := a + b.
    ^ sum
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testChainedCalls [
    ^ self firstMethod
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testCollections [
    | array |
    array := Array with: 1 with: 2 with: 3.
    ^ array size
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testMixedReturnTypes [
    | str num array |
    str := self getStringValue.
    num := self getNumberValue.
    array := Array with: str with: num.
    ^ array
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testPrimitives [
    | num |
    num := 5.
    ^ num + 3
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testSimpleReturn [
    ^ 'hello'
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testStrings [
    | str1 str2 |
    str1 := 'Hello'.
    str2 := ' World'.
    ^ str1, str2
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testThatFails [
    self assert: false
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testWithBlock [
    | block result |
    block := [ 10 * 2 ].
    result := block value.
    ^ result
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testWithMessageSends [
    | result |
    result := self helperMethod.
    ^ result
]

{ #category : 'helpers' }
HypheReturnsCollectorTestFixture >> thirdMethod [
    ^ 42
]

{ #category : 'accessing' }
HypheReturnsCollectorTestFixture >> value [
    ^ value
]

{ #category : 'accessing' }
HypheReturnsCollectorTestFixture >> value: anObject [
    value := anObject
]
