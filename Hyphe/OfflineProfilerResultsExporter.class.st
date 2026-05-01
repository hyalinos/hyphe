Class {
	#name : 'OfflineProfilerResultsExporter',
	#superclass : 'HyResultsExporter',
	#category : 'Hyphe-Export',
	#package : 'Hyphe',
	#tag : 'Export'
}

{ #category : 'initialization' }
OfflineProfilerResultsExporter >> initialize [     
	 super initialize.
    defaultSource := 'Offline Test Profiling'.
]
