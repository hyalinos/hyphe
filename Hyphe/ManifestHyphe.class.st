Class {
	#name : 'ManifestHyphe',
	#superclass : 'PackageManifest',
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'install/uninstall' }
ManifestHyphe class >> unload [
    "Clean up before package removal"
    HypheIcebergEventHandler ifNotNil: [ HypheIcebergEventHandler unsubscribe ]
]
