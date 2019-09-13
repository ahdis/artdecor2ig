# Notes to the ad1bbr conversion to FHIR CDA model

* Need to find a useful canonical url (now in fhir.ch), will ask for one in the art-decor realm?
* Each ART-DECOR template has a template id as is defined as 0..1, this looks like an internal ART-DECOR needed definition, during xsl model generation this is replaced with a gnereal templateId element 0..*
* There are separate STDC models, these are currently no used in the generation of the CDA Logical model
* Section.text is defined as SD.TEXT Structured Document Text, FHIR has a possibility to flag it as representation value cdaText, in the future the CDA text should be also transformed to a FHIR logical model

    <element id="Section.text">
      <path value="Section.text"/>
      <representation value="cdaText"/>
      <min value="0"/>
      <max value="1"/>
      <type>
        <code value="xhtml"/>
      </type>
      <mustSupport value="true"/>
    </element>

* [CDASubstanceAdministration](https://art-decor.org/art-decor/decor-templates--ad1bbr-?section=templates&id=2.16.840.1.113883.10.12.308&effectiveDate=2005-09-07T00:00:00&language=en-US) hl7:effectiveTime is modeled in Art-Decor with SXCM_TS 0 … 1, 
  in [POCD_MT000040.xsd](file:///Users/oliveregger/Documents/docs/standards/hl7/HL7.org/cda_r2_normativewebedition2010/infrastructure/cda/POCD_MT000040.xsd) it is modeled in with 0..* 
  in [POCD_MT000040.xsd(file:///Users/oliveregger/Documents/docs/standards/hl7/HL7.org/cda_r2_normativewebedition2010/infrastructure/cda/POCD_HD000040.xls) ]effectiveTime  0..1 with GTS 
  XML Implementation Technology Specification - Data Types A.2 General Timing Specification (GTS) specfies that GTS is represented as a sequence of XML elements of type SXCM or its specializations, including IVL<TS>, PIVL, EIVL, SXPR.
  -> the model in Art-Decor should reflect this also with SXCM_TS 0 … *
  
* The ART-DECOR base model does not contain for all RIM classes realmCode/typeId/templateId, this has been added

* PHARM extensions are not modeled in ad1bbr

* Skipping the different ClinicalDocumentTemplates, they would need to be profiles on the base model CDA ClinicalDocument (with nonXMLBody), CDA ClinicalDocument (with StructuredBody)
 


 

