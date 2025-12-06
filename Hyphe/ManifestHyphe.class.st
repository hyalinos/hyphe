Class {
	#name : 'ManifestHyphe',
	#superclass : 'PackageManifest',
	#category : 'Hyphe-Manifest',
	#package : 'Hyphe',
	#tag : 'Manifest'
}

{ #category : 'install/uninstall' }
ManifestHyphe class >> unload [
    "Clean up before package removal"
    HypheIcebergEventHandler ifNotNil: [ HypheIcebergEventHandler unsubscribe ]
]
