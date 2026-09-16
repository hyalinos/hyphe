"
Class to store logic around inference tools
"
Class {
	#name : 'HyInferenceToolsManager',
	#superclass : 'HyInferenceSettingsManager',
	#instVars : [
		'inferenceTools'
	],
	#classInstVars : [
		'defaultInferenceTools'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'accessing' }
HyInferenceToolsManager class >> defaultInferenceTools [

	^ defaultInferenceTools
]

{ #category : 'class initialization' }
HyInferenceToolsManager class >> initializeDefaultValues [

	defaultInferenceTools := OrderedCollection new
		                         add: (HyInferenceTool new
				                          name: 'AST-based inference';
				                          clazz: ARTIReturnTypeInferrer;
				                          defaultConfidence: '1.0';
				                          confidence: '1.0';
				                          level: (HyConfidenceManager getLevelByScore: '1.0');
				                          yourself);
		                         add: (HyInferenceTool new
				                          name: 'Name-based Heuristics';
				                          clazz: ARTHClassifier;
				                          defaultConfidence: '0.5';
				                          confidence: '0.5';
				                          level: (HyConfidenceManager getLevelByScore: '0.5');
				                          yourself);
		                         add: (HyInferenceTool new
				                          name: 'Offline Test Profiling';
				                          clazz: HypheReturnsCollectorMethodNodes;
				                          defaultConfidence: '0.6';
				                          confidence: '0.7';
				                          level: (HyConfidenceManager getLevelByScore: '0.6');
				                          yourself);
		                         add: (HyInferenceTool new
				                          name: 'Constraint-based inference (CTI)';
				                          clazz: CTIInferer;
				                          defaultConfidence: '0.6';
				                          confidence: '0.7';
				                          level: (HyConfidenceManager getLevelByScore: '0.6');
				                          yourself);
		                         add: (HyInferenceTool new
				                          name: 'RoelTyper';
				                          clazz: TypeCollector;
				                          defaultConfidence: '0.6';
				                          confidence: '0.7';
				                          level: (HyConfidenceManager getLevelByScore: '0.6');
				                          yourself);
		                         yourself
]

{ #category : 'accessing' }
HyInferenceToolsManager >> inferenceTools [

	^ inferenceTools
]

{ #category : 'initialization' }
HyInferenceToolsManager >> initialize [ 

	inferenceTools := self class defaultInferenceTools deepCopy 
]

{ #category : 'initialization' }
HyInferenceToolsManager >> recalculateConfidenceLevels [

	inferenceTools do: [:t | t level: (HyConfidenceManager user getLevelByScore: (t confidence)) ]
]
