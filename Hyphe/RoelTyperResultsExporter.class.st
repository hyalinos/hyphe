Class {
	#name : 'RoelTyperResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
RoelTyperResultsExporter >> initialize [

	super initialize.
	defaultSource := 'RoelTyper'
]
