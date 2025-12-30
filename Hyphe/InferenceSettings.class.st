"
This class stores all information related to inference settings:

	- List of the available inference tools
	- Inference confidence levels
	- List of available merging strategies
	- Repositories subscribed for automatic inference
"
Class {
	#name : 'InferenceSettings',
	#superclass : 'Object',
	#instVars : [
		'repositoriesManager',
		'mergeStrategy',
		'inferenceTools',
		'confidenceManager',
		'mergeStrategies'
	],
	#classInstVars : [
		'defaultInferenceTools',
		'defaultConfidenceManager',
		'defaultMergeStrategy',
		'defaultMergeStrategies',
		'user'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'confidence' }
InferenceSettings class >> defaultConfidenceManager [

	^ defaultConfidenceManager
	
]

{ #category : 'tools' }
InferenceSettings class >> defaultInferenceTools [ 

	^ defaultInferenceTools 
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> defaultMergeStrategies [

	^ defaultMergeStrategies
]

{ #category : 'mergeStrategies' }
InferenceSettings class >> defaultMergeStrategy [

	^ defaultMergeStrategy 
]

{ #category : 'class initialization' }
InferenceSettings class >> initialize [

	<script>
	self initializeGlobalSettings.
	self initializeUserSettings.
]

{ #category : 'initialization' }
InferenceSettings class >> initializeConfidenceLevels [	
	
	defaultConfidenceManager := HyConfidenceManager 

]

{ #category : 'class initialization' }
InferenceSettings class >> initializeGlobalSettings [

	self initializeConfidenceLevels.
	self initializeInferenceTools.
	self initializeMergingStrategies.
]

{ #category : 'initialization' }
InferenceSettings class >> initializeInferenceTools [
	
	defaultInferenceTools := OrderedCollection new
		add: (HyInferenceTool new name: 'AST-based inference'; clazz: TypeMeConfident; defaultConfidence: '1.0'; confidence: '1.0'; level: (HyConfidenceManager getLevelByScore: '1.0'); yourself);
		add: (HyInferenceTool new name: 'Type Info Tools'; clazz: TITMethodReturnTypesGatherer; defaultConfidence: '0.8'; confidence: '0.8'; level: (HyConfidenceManager getLevelByScore: '0.8');yourself);
		add: (HyInferenceTool new name: 'Name-based Heuristics'; clazz: TypeMeNameBased; defaultConfidence: '0.5'; confidence: '0.5'; level: (HyConfidenceManager getLevelByScore: '0.5');yourself);
		add: (HyInferenceTool new name: 'Offline Test Profiling'; clazz: HypheReturnsCollectorMethodNodes; defaultConfidence: '0.6'; confidence: '0.6'; level: (HyConfidenceManager getLevelByScore: '0.6');yourself);
		yourself.


]

{ #category : 'class initialization' }
InferenceSettings class >> initializeMergingStrategies [

	defaultMergeStrategy := HyTieredStrategy new.
	
	defaultMergeStrategies := OrderedCollection new 
		add: HyConsensusStrategy new;
		add: HyBiasedConsensusStrategy new;
		add: defaultMergeStrategy;
		add: HyWeightedVotingStrategy new;
		add: HyBiasedWeightedVotingStrategy new; 
		yourself.
	
	 
]

{ #category : 'class initialization' }
InferenceSettings class >> initializeUserSettings [

	user := self new.
]

{ #category : 'class initialization' }
InferenceSettings class >> user [ 

	^ user
]

{ #category : 'accessing' }
InferenceSettings >> inferenceTools [

	^ inferenceTools
]

{ #category : 'accessing' }
InferenceSettings >> initialize [

	mergeStrategies := self class defaultMergeStrategies.
	mergeStrategy := self class defaultMergeStrategy.
	confidenceManager := self class defaultConfidenceManager user.
	inferenceTools := self class defaultInferenceTools.
	repositoriesManager := HyRepositoriesManager new. 
]

{ #category : 'accessing' }
InferenceSettings >> mergeStrategies [

	^ mergeStrategies
]

{ #category : 'mergeStrategies' }
InferenceSettings >> mergeStrategy [

	^ mergeStrategy
]

{ #category : 'mergeStrategies' }
InferenceSettings >> mergeStrategy: aHyMergingStrategy [

	mergeStrategy := aHyMergingStrategy
	 
]

{ #category : 'accessing' }
InferenceSettings >> repositoriesManager [

	^ repositoriesManager
]
