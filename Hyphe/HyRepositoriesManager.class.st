"
Class for storing logic and data related to manipulation of ice repositories subscrubed for type inference
"
Class {
	#name : 'HyRepositoriesManager',
	#superclass : 'HyInferenceSettingsManager',
	#instVars : [
		'monitorAllNewRepositories',
		'subscribedRepositories'
	],
	#category : 'Hyphe-Inference',
	#package : 'Hyphe',
	#tag : 'Inference'
}

{ #category : 'repositories' }
HyRepositoriesManager >> addSubscribedRepositories: repoList [

	subscribedRepositories addAll: repoList
]

{ #category : 'repositories' }
HyRepositoriesManager >> addSubscribedRepository: repo [

	subscribedRepositories add: repo
]

{ #category : 'repositories' }
HyRepositoriesManager >> clearRepositories [

	subscribedRepositories clear
]

{ #category : 'initialization' }
HyRepositoriesManager >> initialize [ 

	monitorAllNewRepositories := false.
	subscribedRepositories := OrderedCollection new.
]

{ #category : 'accessing' }
HyRepositoriesManager >> monitorAllNewRepositories [

	^ monitorAllNewRepositories
]

{ #category : 'accessing' }
HyRepositoriesManager >> monitorAllNewRepositories: aBoolean [

	monitorAllNewRepositories := aBoolean
]

{ #category : 'repositories' }
HyRepositoriesManager >> removeSubscribedRepository: repo [

	subscribedRepositories remove: repo
]

{ #category : 'repositories' }
HyRepositoriesManager >> subscribedRepositories [

	^ subscribedRepositories
]
