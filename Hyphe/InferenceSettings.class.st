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
		'inferenceToolsManager',
		'confidenceManager',
		'mergeStrategies'
	],
	#classInstVars : [
		'defaultConfidenceManager',
		'defaultMergeStrategy',
		'defaultMergeStrategies',
		'user',
		'defaultInferenceToolsManager'
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
InferenceSettings class >> defaultInferenceToolsManager [ 

	^ defaultInferenceToolsManager 
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
	self initializeGlobalValues.
	self initializeUserSettings.
]

{ #category : 'initialization' }
InferenceSettings class >> initializeConfidenceLevels [	
	
	defaultConfidenceManager := HyConfidenceManager 

]

{ #category : 'class initialization' }
InferenceSettings class >> initializeGlobalValues [

	self initializeConfidenceLevels.
	self initializeInferenceTools.
	self initializeMergingStrategies.
]

{ #category : 'initialization' }
InferenceSettings class >> initializeInferenceTools [

	defaultInferenceToolsManager := HyInferenceToolsManager 
	
	
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
InferenceSettings >> confidenceManager [

	^ confidenceManager
]

{ #category : 'accessing' }
InferenceSettings >> inferenceToolsManager [

	^ inferenceToolsManager
]

{ #category : 'accessing' }
InferenceSettings >> initialize [

	mergeStrategies := self class defaultMergeStrategies.
	mergeStrategy := self class defaultMergeStrategy.
	confidenceManager := self class defaultConfidenceManager user.
	inferenceToolsManager := self class defaultInferenceToolsManager user.
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
