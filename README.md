ART-DECOR to FHIR
=================

[ART-DECOR®](https://art-decor.org/mediawiki/index.php/Main_Page) is an open-source tool suite that supports the creation and maintenance of HL7 templates, value sets, scenarios and data sets.

[FHIR®](http://www.hl7.org/fhir/) – Fast Healthcare Interoperability Resources (hl7.org/fhir) – is a next generation standards framework created by HL7. 

This projects goal is to reuse the Templates and ValueSets defined in ART-DECOR within a FHIR based architecture.
1. Transform ART-DECOR defined ValueSets in FHIR ValueSet/CodeSystem Resources
2. Transform ART-DECOR Template definitions to FHIR StructureDefinition Resources
3. Transform ART-DECOR Datasets definitions to FHIR StructureDefinition


# ART-DECOR API

http://art-decor.org/decor/services/ProjectIndex?format=xml&prefix=hl7chcda-
requires saxon9he.jar to be installed for xslt 2.0 support


 ant -lib ../saxon9he.jar
