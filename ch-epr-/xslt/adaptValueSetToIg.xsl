<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns="http://hl7.org/fhir" 
 xmlns:fhir="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="xml" indent="yes" />
    
    <xsl:param name="canonicalBase" required="yes" />
    <xsl:param name="resourceId" required="yes" />
    <xsl:param name="title" required="yes" />
    <xsl:param name="name" required="yes" />

    <xsl:variable name="url" select="//fhir:ValueSet/fhir:url/@value" />

   <xsl:function name="fhir:firstLetterUpperCase" as="xs:string*">
    <xsl:param name="input" as="xs:string*"/>
    <xsl:sequence>
      <xsl:for-each select="$input">
        <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
      </xsl:for-each>
    </xsl:sequence>
  </xsl:function>


    <xsl:template match="fhir:ValueSet/fhir:id">
      <fhir:id>
			<xsl:attribute name="value"><xsl:value-of select="$resourceId" />
     </xsl:attribute>
      </fhir:id>    
    </xsl:template>

    <!-- add meta source value with original url -->
    <xsl:template match="fhir:meta">
      <fhir:meta>
         <fhir:source>
			      <xsl:attribute name="value"><xsl:value-of select="$url" /></xsl:attribute>
         </fhir:source>         
         <xsl:apply-templates />
      </fhir:meta>      
    </xsl:template>

    <xsl:template match="fhir:ValueSet/fhir:url">
      <fhir:url>
			<xsl:attribute name="value"><xsl:value-of select="$canonicalBase" />/ValueSet/<xsl:value-of select="$resourceId" />
         </xsl:attribute>
      </fhir:url>   
    </xsl:template>

    <xsl:template match="fhir:ValueSet/fhir:name">
      <fhir:name>
   			<xsl:attribute name="value"><xsl:value-of select="$name" /></xsl:attribute>
      </fhir:name>   
    </xsl:template>

    <xsl:template match="fhir:ValueSet/fhir:title">
      <fhir:title>
   			<xsl:attribute name="value"><xsl:value-of select="$title" /></xsl:attribute>
      </fhir:title>   
    </xsl:template>

    <xsl:template match="fhir:ValueSet/fhir:compose/fhir:include/fhir:system[@value='http://snomed.info/sct']">
      <fhir:system value="http://snomed.info/sct" />
      <fhir:version value="http://snomed.info/sct/2011000195101" />
    </xsl:template>

    <xsl:template match="fhir:ValueSet/fhir:compose/fhir:include/fhir:system[@value='urn:oid:2.16.756.5.30.1.127.3.4']">
      <fhir:system value="http://snomed.info/sct" />
      <fhir:version value="http://snomed.info/sct/2011000195101" />
    </xsl:template>

    <xsl:template match="fhir:ValueSet/fhir:compose/fhir:include/fhir:system/@value">
      <xsl:attribute name="value" namespace="{namespace-uri()}">
        <xsl:choose>
          <xsl:when test=".='urn:oid:2.16.840.1.113883.6.316'">
            <xsl:value-of select="'urn:ietf:bcp:47'" />
          </xsl:when>
          <xsl:when test=".='urn:oid:2.16.840.1.113883.5.79'">
            <xsl:value-of select="'http://terminology.hl7.org/CodeSystem/v3-mediaType'" />
          </xsl:when>
          <xsl:when test=".='http://ihe.net/fhir/ValueSet/IHE.FormatCode.codesystem'">
            <xsl:value-of select="'http://ihe.net/fhir/ihe.formatcode.fhir/CodeSystem/formatcode'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:template>

    <!-- The Coding provided is not in the value set http://hl7.org/fhir/ValueSet/designation-use (http://hl7.org/fhir/ValueSet/designation-use, and a code should come from this value set unless it has no suitable code) (error message = The code system "http://art-decor.org/ADAR/rv/DECOR.xsd#DesignationType" is not known; The code provided (http://art-decor.org/ADAR/rv/DECOR.xsd#DesignationType#preferred) is not valid in the value set DesignationUse) -->
    <!-- remove it -->
    <xsl:template match="fhir:concept/fhir:designation/fhir:use" />


    <!--ValueSet.compose.include.concept[1].extension.valueString	warning	value should not start or finish with whitespace -->
    <xsl:template match="fhir:valueString/@value">
      <xsl:attribute name="value" namespace="{namespace-uri()}">
        <xsl:value-of select="replace(., '^\s+|\s+$', '')"/>
      </xsl:attribute>
    </xsl:template>

    <!-- ValueSet/DocumentEntry.languageCode: ValueSet.compose.include[3].concept[22].designation[2].value 	value should not start or finish with whitespace -->
    <xsl:template match="fhir:value/@value">
      <xsl:attribute name="value" namespace="{namespace-uri()}">
        <xsl:value-of select="replace(., '^\s+|\s+$', '')"/>
      </xsl:attribute>
    </xsl:template>

    <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:template>
   
</xsl:stylesheet>