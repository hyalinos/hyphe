Class {
	#name : 'TypeMeNameBasedResultsExporter',
	#superclass : 'TypeMeResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
TypeMeNameBasedResultsExporter >> initialize [ 

	super initialize.
	defaultSource := #TypeMeNameBased
]
