<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:fhir="http://hl7.org/fhir" xmlns:ahdis="http://ahdis.ch" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="text" indent="yes"/>

  <xsl:param name="prefix" required="yes"/> <!-- art-decor prefix for project -->
  <xsl:param name="inContains" as="xs:boolean" />
  <xsl:param name="decorservice" as="xs:string" />
  <xsl:param name="removePrefix" as="xs:string"  />

  <xsl:import href="functions.xsl"/>

  <xsl:import href="RetrieveTemplateWithResolvedIncludes.xsl"/>

  <xsl:template match="//return">

    <xsl:for-each-group select="template[@id and @name and not(@statusCode='cancelled')]" group-by="@id">
    
      <xsl:message select="current-grouping-key(),' ',current-group()[1]/@name"/>
      
      <xsl:variable name="name" select="current-grouping-key()"/>
            
      <xsl:variable name="pathartdecor" select="concat('../',$prefix,'/artdecor/',$name,'.xml')"/>
      <xsl:message select="'.. download into ',$pathartdecor"/>
      <xsl:variable name="templateUri" select="concat($decorservice,'/RetrieveTemplate?format=xml&amp;prefix=',$prefix,'&amp;id=',current-grouping-key(),'&amp;effectiveDate=dynamic')"/>
      <xsl:variable name="template" select="document($templateUri)"/>
      <xsl:result-document method="xml" href="{$pathartdecor}">
        <xsl:copy-of select="$template"/>
      </xsl:result-document>
      <xsl:variable name="pathoutput" select="concat('../',$prefix,'/output/',$name,'.xml')"/>
      <xsl:message select="'.. resolving recursive includes into ',$pathoutput"/>
      <xsl:variable name="templateResolvedRecursive">
        <xsl:apply-templates select="$template" mode="include">
          <xsl:with-param name="ref" select="''"/>
          <xsl:with-param name="inContains" select="false()"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:result-document method="xml" href="{$pathoutput}">
        <xsl:copy-of select="$templateResolvedRecursive"/>
      </xsl:result-document>
    </xsl:for-each-group>




  </xsl:template>

</xsl:stylesheet>