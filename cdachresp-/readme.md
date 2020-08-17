#Terminology for ch-ems

The ValueSets for ch-ems are managed in th CDA-CH RESP art-decor project.
To export them for hte ch-ems perform the following steps:

```
ant clean
ant
ant dist,
```

To generate the IVR Codesystem out of the ValueSets use the project
ValueSetsToCSV and execute ch.ahdis.camel.aggregator.CodeSystemAggregator,
this wil generate a CodeSystem IVR-VS-bedding.xml, rename it to
2.16.756.5.30.1.143.5.1.xml, copy it to the ch-ems and check that
the metadata of the CodeSystem is not overwritten.



