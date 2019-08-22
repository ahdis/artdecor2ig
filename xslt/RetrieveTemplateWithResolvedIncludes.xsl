<xsl:stylesheet version="2.0" xmlns="" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="prefix" required="yes"/>

  <xsl:import href="functions.xsl"/>


  <xsl:template match="include" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
<!--     <xsl:message select="'.. include catched ', @ref"/> -->
    <xsl:variable name="file" select="concat('http://art-decor.org/decor/services/RetrieveTemplate?format=xml&amp;prefix=',$prefix,'&amp;id=',@ref,'&amp;effectiveDate=dynamic')"/>
    <xsl:variable name="incltemplate" select="document($file)/return/template/template/element|document($file)/return/template/template/include"/>
    <xsl:apply-templates select="$incltemplate" mode="include">
      <xsl:with-param name="ref" select="@ref"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="element" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
<!--     <xsl:message select="'.. element catched in mode include ', $ref"/> -->
    <element>
      <xsl:attribute name="ref"><xsl:value-of select="$ref"/></xsl:attribute>
      <xsl:if test="@name">
        <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@datatype">
        <xsl:attribute name="datatype"><xsl:value-of select="@datatype"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@minimumMultiplicity">
        <xsl:attribute name="minimumMultiplicity"><xsl:value-of select="@minimumMultiplicity"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@maximumMultiplicity">
        <xsl:attribute name="maximumMultiplicity"><xsl:value-of select="@maximumMultiplicity"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@conformance">
        <xsl:attribute name="conformance"><xsl:value-of select="@conformance"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@isMandatory">
        <xsl:attribute name="isMandatory"><xsl:value-of select="@isMandatory"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="include">
        <xsl:with-param name="ref" select="$ref"/>
      </xsl:apply-templates>
    </element>
  </xsl:template>

  <xsl:template match="example" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
  </xsl:template>



<!-- 
                     <desc language="en-US">Reusable template wherever a healthcare provider who was the primary performer of an act is used in a CDA-CH V2 document. CDA-CH V2 derivatives, i.e. Swiss exchange formats MAY use this template by either reference or specialisation.</desc>
                     <classification type="notype"/>
                     <relationship type="SPEC"
                                   template="1.3.6.1.4.1.19376.1.5.3.1.1.24.3.5"
                                   flexibility="2017-04-13T21:00:16"/>
                     <context id="**"/>
-->

  <xsl:template match="node()|@*" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="include">
        <xsl:with-param name="ref" select="$ref"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>