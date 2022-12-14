<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:fhir="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ahdis="http://ahdis.ch">

  <xsl:output method="xml" indent="yes"/>

  <xsl:param name="canonicalBase" required="yes"/>
  <xsl:param name="resourceId" required="yes"/>
  <xsl:param name="codeSystem" required="yes"/>
  <xsl:param name="name" required="yes"/>
  <xsl:param name="title" required="yes"/>
  <xsl:param name="sourceUri" required="yes"/>
  <xsl:param name="targetUri" required="yes"/>

  <xsl:variable name="system" select="concat('urn:oid:',$codeSystem)"/>
  <xsl:variable name="codes" select="//fhir:ValueSet/fhir:compose/fhir:include[fhir:system[@value=$system]]/fhir:concept"/>

  <xsl:variable name="url" select="//fhir:ValueSet/fhir:url/@value"/>


  <xsl:function name="ahdis:oid2fhir" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence>
      <xsl:choose>
        <xsl:when test="$input='2.16.840.1.113883.6.96'">
          <xsl:value-of select="'http://snomed.info/sct'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('urn:oid:',$input)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:template match="valueSets/project/valueSet">
    <fhir:ConceptMap>

      <!-- <xsl:apply-templates /> -->

      <fhir:id>
        <xsl:attribute name="value"><xsl:value-of select="$resourceId" /></xsl:attribute>
      </fhir:id> 

      <fhir:url>
        <xsl:attribute name="value"><xsl:value-of select="$canonicalBase"/>/ConceptMap/<xsl:value-of select="$resourceId"/></xsl:attribute>
      </fhir:url>

      <fhir:version>
        <xsl:attribute name="value"><xsl:value-of select="@versionLabel"/></xsl:attribute>
      </fhir:version>

      <fhir:name>
        <xsl:attribute name="value"><xsl:value-of select="$name"/></xsl:attribute>
      </fhir:name>

      <fhir:title>
        <xsl:attribute name="value"><xsl:value-of select="$title"/></xsl:attribute>
      </fhir:title>
      <fhir:status value="active"/>

      <!-- <fhir:date value="2012-06-13"/> -->
      <fhir:publisher value="HL7 Switzerland"/>

      <fhir:contact>
        <fhir:name>
          <xsl:attribute name="value"><xsl:value-of select="publishingAuthority/@name"/></xsl:attribute>
        </fhir:name>
      </fhir:contact>

      <fhir:description>
        <xsl:attribute name="value"><xsl:value-of select="desc"/></xsl:attribute>
      </fhir:description>
      <fhir:copyright>
        <xsl:attribute name="value"><xsl:value-of select="copyright"/></xsl:attribute>
      </fhir:copyright>


      <fhir:sourceUri>
        <xsl:attribute name="value"><xsl:value-of select="$sourceUri"/></xsl:attribute>
      </fhir:sourceUri>
      <fhir:targetUri>
        <xsl:attribute name="value"><xsl:value-of select="$targetUri"/></xsl:attribute>
      </fhir:targetUri>


      <xsl:for-each-group select="conceptList/concept" group-starting-with="*[@level='0']">

        <xsl:variable name="sourceCode" select="@code"/>
        <xsl:variable name="sourceCodeSystem" select="@codeSystem"/>
        <xsl:variable name="sourceDisplayName" select="@displayName"/>

        <xsl:for-each-group select="current-group()[@level='1']" group-by="@codeSystem">
          <fhir:group>
            <fhir:source>
              <xsl:attribute name="value"><xsl:value-of select="ahdis:oid2fhir($sourceCodeSystem)"/></xsl:attribute>
            </fhir:source>
            <fhir:target>
              <xsl:attribute name="value"><xsl:value-of select="ahdis:oid2fhir(@codeSystem)"/></xsl:attribute>
            </fhir:target>
            <fhir:element>
              <fhir:code>
                <xsl:attribute name="value"><xsl:value-of select="$sourceCode"/></xsl:attribute>
              </fhir:code>
              <fhir:display>
                <xsl:attribute name="value"><xsl:value-of select="$sourceDisplayName"/></xsl:attribute>
              </fhir:display>
              <xsl:for-each select="current-group()">
                <fhir:target>
                  <fhir:code>
                    <xsl:attribute name="value"><xsl:value-of select="@code"/></xsl:attribute>
                  </fhir:code>
                  <fhir:display>
                    <xsl:attribute name="value"><xsl:value-of select="@displayName"/></xsl:attribute>
                  </fhir:display>
                  <fhir:equivalence value="specializes"/>
                </fhir:target>
              </xsl:for-each>
            </fhir:element>
          </fhir:group>
        </xsl:for-each-group>
      </xsl:for-each-group>

    </fhir:ConceptMap>
  </xsl:template>


</xsl:stylesheet>