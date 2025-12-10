Class {
	#name : 'HypheASTTypeResolverForTesting',
	#superclass : 'HypheASTTypeResolver',
	#instVars : [
		'testStore'
	],
	#category : 'Hyphe-Tests',
	#package : 'Hyphe-Tests'
}

{ #category : 'initialization' }
HypheASTTypeResolverForTesting >> initializeWithStore: aStore [
	"Initialize with a specific test store instead of the singleton"
	super initialize.
	store := aStore
]
