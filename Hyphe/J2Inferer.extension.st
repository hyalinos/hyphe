Extension { #name : 'J2Inferer' }

{ #category : '*Hyphe' }
J2Inferer class >> hypheExporter [

	^ J2InfererResultsExporter
]

{ #category : '*Hyphe' }
J2Inferer class >> runHypheInference: packageNames [

	| inferer |
	inferer := self withNotifier: J2NullNotifier new.
	^ (packageNames flatCollect: [ :packageName | (PackageOrganizer default packageNamed: packageName) classes ]) collect: [ :aClass |
			  inferer
				  enqueueClass: aClass;
				  enqueueClass: aClass class.
			  inferer runAndWait.
			  inferer typeInfoFor: aClass ]
]

{ #category : '*Hyphe' }
J2Inferer class >> tier [

	^ #observation
]
