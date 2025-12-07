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
HypheReturnsCollectorTestFixture >> testAndOr [
    | result1 result2 |
    result1 := true and: [ false ].
    result2 := false or: [ true ].
    ^ result1 or: [ result2 ]
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
HypheReturnsCollectorTestFixture >> testBlockValue [
    | block result |
    block := [ 10 + 20 ].
    result := block value.
    ^ result
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testBlockWithArgument [
    | block result |
    block := [ :x | x * 2 ].
    result := block value: 21.
    ^ result
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
HypheReturnsCollectorTestFixture >> testEnsure [
    | result |
    result := [ 42 ] ensure: [ Transcript show: 'cleanup'; cr ].
    ^ result
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testIfNilIfNotNil [
    | value result |
    value := nil.
    result := value ifNil: [ 0 ] ifNotNil: [ :v | v + 1 ].
    ^ result
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testIfNilIfNotNilWithValue [
    | value result |
    value := 42.
    result := value ifNil: [ 0 ] ifNotNil: [ :v | v + 1 ].
    ^ result
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
HypheReturnsCollectorTestFixture >> testNestedBlocks [
    | outer |
    outer := [ | inner | inner := [ 42 ]. inner value ].
    ^ outer value
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testOnDo [
    | result |
    result := [ 1 / 0 ] on: Error do: [ :ex | -1 ].
    ^ result
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
HypheReturnsCollectorTestFixture >> testToDo [
    | sum |
    sum := 0.
    1 to: 5 do: [ :i | sum := sum + i ].
    ^ sum
]

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testWhileTrue [
    | counter |
    counter := 0.
    [ counter < 3 ] whileTrue: [ counter := counter + 1 ].
    ^ counter
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

{ #category : 'tests' }
HypheReturnsCollectorTestFixture >> testWithOrderedCollection [

|aCollection|
aCollection := OrderedCollection new.
aCollection add:1.
self assert: aCollection size equals: 1
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
