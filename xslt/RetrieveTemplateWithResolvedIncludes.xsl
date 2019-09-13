<xsl:stylesheet version="2.0" xmlns="" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ahdis="http://ahdis.ch">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="prefix" required="yes"/>
  <xsl:param name="inContains" as="xs:boolean" required="yes"/>
  <xsl:param name="decorservice" as="xs:string"/>
  <xsl:param name="removePrefix" as="xs:string"/>

  <xsl:import href="functions.xsl"/>


  <xsl:template match="include" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
    <xsl:param name="inContains" as="xs:boolean" required="yes"/>
<!--     <xsl:message select="'.. include catched ', @ref"/> -->
    <xsl:variable name="file" select="concat($decorservice,'/RetrieveTemplate?format=xml&amp;prefix=',$prefix,'&amp;id=',@ref,'&amp;effectiveDate=dynamic')"/>
    <xsl:variable name="incltemplate" select="document($file)/return/template/template/element|document($file)/return/template/template/include"/>
    <xsl:apply-templates select="$incltemplate" mode="include">
      <xsl:with-param name="ref" select="@ref"/>
      <xsl:with-param name="inContains" select="$inContains"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="element" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
    <xsl:param name="inContains" as="xs:boolean" required="yes"/>
<!--     <xsl:message select="'.. element catched in mode include ', $ref"/> -->

    <xsl:if test="$removePrefix='CDA' and @name='hl7:patientRole'">
      <!-- recordTarget has no tempateId -->
    </xsl:if>

    <element>
      <xsl:if test="string-length($ref)>0">
        <xsl:attribute name="ref"><xsl:value-of select="$ref"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="$removePrefix='CDA' and @name='hl7:assignedEntity' and count(include)=1">
        <xsl:attribute name="ref"><xsl:value-of select="include/@ref"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@name">
        <xsl:attribute name="name"><xsl:value-of select="ahdis:skipxpath(@name)"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@datatype">
        <xsl:attribute name="datatype"><xsl:value-of select="@datatype"/></xsl:attribute>
        <!-- fix artdecor addbr1 template definition-->
      </xsl:if>
      <xsl:choose>
        <xsl:when test="starts-with(@name,'hl7:templateId') and $removePrefix='CDA'">
          <xsl:attribute name="minimumMultiplicity"><xsl:value-of select="'0'"/></xsl:attribute>
          <xsl:attribute name="maximumMultiplicity"><xsl:value-of select="'*'"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="minimumMultiplicity"><xsl:value-of select="if (@minimumMultiplicity) then (@minimumMultiplicity) else ('0')"/></xsl:attribute>
          <xsl:attribute name="maximumMultiplicity"><xsl:value-of select="if (@maximumMultiplicity) then (@maximumMultiplicity) else ('1')"/></xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@conformance">
        <xsl:attribute name="conformance"><xsl:value-of select="@conformance"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@isMandatory">
        <xsl:attribute name="isMandatory"><xsl:value-of select="@isMandatory"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@contains">
        <xsl:attribute name="contains"><xsl:value-of select="@contains"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="not(starts-with(@name,'hl7:templateId') and $removePrefix='CDA') and not($removePrefix='CDA' and @name='hl7:assignedEntity' and count(include)=1)">
        <xsl:apply-templates mode="include">
          <xsl:with-param name="ref" select="''"/>
          <xsl:with-param name="inContains" select="$inContains"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="string-length(@contains)>0 and ($inContains=false())">
        <xsl:message select="'.. attribute @contains catched in mode include ', @contains"/>
        <contains>
          <xsl:variable name="file" select="concat($decorservice,'/RetrieveTemplate?format=xml&amp;prefix=',$prefix,'&amp;id=',@contains,'&amp;effectiveDate=dynamic')"/>
          <xsl:variable name="incltemplate" select="document($file)/return/template/template/element|document($file)/return/template/template/include|document($file)/return/template/template/choice"/>
          <xsl:apply-templates select="$incltemplate" mode="include">
            <xsl:with-param name="ref" select="@contains"/>
            <xsl:with-param name="inContains" select="true()"/>
          </xsl:apply-templates>
        </contains>
      </xsl:if>
    </element>
  </xsl:template>

  <xsl:template match="example" mode="include">
    <xsl:param name="ref" as="xs:string" required="yes"/>
    <xsl:param name="inContains" as="xs:boolean" required="yes"/>
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
    <xsl:param name="inContains" as="xs:boolean" required="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="include">
        <xsl:with-param name="ref" select="$ref"/>
        <xsl:with-param name="inContains" select="$inContains"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>