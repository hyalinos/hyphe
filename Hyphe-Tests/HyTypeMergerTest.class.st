"
I test how HyTypeMerger handles the return types of one method, with every merge strategy (all the subclasses of HyMergeStrategy):
- a method with return types is merged and reported once in the results;
- a method without any return type is skipped (nothing to merge or report) and does not stop the methods that follow it.
Methods are built by hand, so no inference tool is run.
"
Class {
	#name : 'HyTypeMergerTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'helpers' }
HyTypeMergerTest >> mergerWith: aStrategyClass [

	^ HyTypeMerger
		  newWithStrategy: aStrategyClass new
		  tools: HyInferenceToolsManager defaultInferenceTools
]

{ #category : 'helpers' }
HyTypeMergerTest >> methodNamed: aString [

	^ HyMethod new
		  name: aString;
		  yourself
]

{ #category : 'helpers' }
HyTypeMergerTest >> strategyClasses [
	"Every merge strategy, so that the merger is checked with each of them"

	^ HyMergeStrategy allSubclasses
]

{ #category : 'tests' }
HyTypeMergerTest >> testMergeMethodWithReturnTypeIsReported [

	self strategyClasses do: [ :strategyClass |
		| merger method |
		merger := self mergerWith: strategyClass.
		method := self methodNamed: #foo.
		method addReturnType: 'String' source: 'ARTIReturnTypeInferrer'.

		merger
			mergeMethodTypes: method
			class: (HyClass new name: 'Foo'; yourself)
			package: (HyPackage new name: 'Foo-Core'; yourself).

		self assert: merger results size equals: 1.
		self assert: (merger results first at: #methodName) equals: #foo.
		self assert: (merger results first at: #className) equals: 'Foo'.
		self assert: (merger results first at: #packageName) equals: 'Foo-Core' ]
]

{ #category : 'tests' }
HyTypeMergerTest >> testMergeMethodWithoutReturnTypesIsSkipped [

	self strategyClasses do: [ :strategyClass |
		| merger method |
		merger := self mergerWith: strategyClass.
		method := self methodNamed: #foo.

		merger
			mergeMethodTypes: method
			class: (HyClass new name: 'Foo'; yourself)
			package: (HyPackage new name: 'Foo-Core'; yourself).

		self assert: merger results isEmpty.
		self assert: method collected isEmpty ]
]

{ #category : 'tests' }
HyTypeMergerTest >> testMethodsWithoutReturnTypesDoNotStopTheOthers [

	self strategyClasses do: [ :strategyClass |
		| merger class package empty typed |
		merger := self mergerWith: strategyClass.
		class := HyClass new name: 'Foo'; yourself.
		package := HyPackage new name: 'Foo-Core'; yourself.
		empty := self methodNamed: #empty.
		typed := self methodNamed: #typed.
		typed addReturnType: 'String' source: 'ARTIReturnTypeInferrer'.

		merger mergeMethodTypes: empty class: class package: package.
		merger mergeMethodTypes: typed class: class package: package.

		self assert: merger results size equals: 1.
		self assert: (merger results first at: #methodName) equals: #typed ]
]
