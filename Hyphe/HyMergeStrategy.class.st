Class {
	#name : 'HyMergeStrategy',
	#superclass : 'Object',
	#instVars : [
		'sourceCategories'
	],
	#category : 'Hyphe-Merge',
	#package : 'Hyphe',
	#tag : 'Merge'
}

{ #category : 'initialization' }
HyMergeStrategy >> categoryForSource: sourceName [
    "Get category for a source"

    ^ sourceCategories at: sourceName ifAbsent: [ 'unknown' ]
]

{ #category : 'initialization' }
HyMergeStrategy >> groupTypesByCategory: typesCollection [
    "Group HyType objects by their source category"

    | grouped |
    grouped := Dictionary new.
    
    typesCollection do: [ :hyType |
        | category typeStr |
        category := self categoryForSource: hyType source.
        typeStr := hyType name.
        
        grouped 
            at: category 
            ifAbsentPut: [ Set new ].
        (grouped at: category) add: typeStr ].
    
    ^ grouped
]

{ #category : 'initialization' }
HyMergeStrategy >> initialize [
    super initialize.
    self initializeSourceCategories
]

{ #category : 'initialization' }
HyMergeStrategy >> initializeSourceCategories [

    sourceCategories := Dictionary new
        "Structural analysis - provably correct"
        at: 'StructuralAnalyzer' put: 'structural';
        at: 'FlowAnalysis' put: 'structural';
        at: 'ReturnAnalyzer' put: 'structural';
        
        "Usage analysis - observed at runtime"
        at: 'JInferer' put: 'usage';
        at: 'RoelTyper' put: 'usage';
        at: 'RuntimeProfiler' put: 'usage';
        at: 'TypeMe' put: 'usage';
        
        "Name-based heuristics"
        at: 'NameAnalyzer' put: 'nameHeuristic';
        at: 'TypeHintAnalyzer' put: 'nameHeuristic';
        
        "Static analysis - intermediate reliability"
        at: 'StaticAnalyzer' put: 'static';
        at: 'TypeChecker' put: 'static';
        
        "LLM-based - lower reliability"
        at: 'LLM-Mistral' put: 'llm';
        at: 'GPT-4' put: 'llm';
        yourself
]

{ #category : 'initialization' }
HyMergeStrategy >> mergeTypes: typesCollection [

    self subclassResponsibility
]

{ #category : 'initialization' }
HyMergeStrategy >> setCategory: categoryName forSource: sourceName [
    "Set category for a source"

    sourceCategories at: sourceName put: categoryName
]

{ #category : 'initialization' }
HyMergeStrategy >> strategyName [
    "Return name of this strategy for reporting"

    self subclassResponsibility
]
