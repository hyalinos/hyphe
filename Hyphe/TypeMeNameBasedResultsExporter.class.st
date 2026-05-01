Class {
	#name : 'TypeMeNameBasedResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
TypeMeNameBasedResultsExporter >> initialize [ 

	super initialize.
	defaultSource := #TypeMeNameBased
]
