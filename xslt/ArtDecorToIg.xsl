<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:fhir="http://hl7.org/fhir" xmlns:ahdis="http://ahdis.ch" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="text" indent="yes"/>

  <xsl:param name="prefix" required="yes"/> <!-- art-decor prefix for project -->
  <xsl:param name="ig" required="yes"/> <!--  folder relativ to art-decor2ig -->
  <xsl:param name="projectUri" required="yes"/>  <!-- location of project.xml (actually also as input to this xml ...) -->
  <xsl:param name="projectUriSkip" required="yes"/>  <!-- location of project.xml, elements inside will be skipped -->
  <xsl:param name="projectUriChEpr" required="yes" />
  <xsl:param name="canonicalBase" required="yes"/>  <!-- location of project.xml (actually also as input to this xml ...) -->
  <xsl:param name="language" required="yes"/>  <!-- e.g en_US ...) -->

  <xsl:import href="functions.xsl"/>

  <xsl:import href="RetrieveTemplateWithResolvedIncludes.xsl"/>
  
  <xsl:import href="TemplatesToCdaLogicalModel.xsl"/>


  <xsl:variable name="skipId" select="document($projectUriSkip)"/>

  <xsl:template match="//return">
  
    <xsl:for-each-group select="template[@id and @name and not(@statusCode='cancelled')]" group-by="@id">

      <xsl:message select="current-grouping-key(),' ',current-group()[1]/@name"/>

      <xsl:choose>
        <xsl:when test="$skipId/return/template[@id=current-grouping-key()]">
          <xsl:message select="'.. skippping because in projectskip.xml'"/>
        </xsl:when>
        <xsl:otherwise>
        <!--           <xsl:variable name="pathartdecor" select="concat('../',$prefix,'/artdecor/',current-grouping-key(),'.xml')" />
          <xsl:message select="'.. download into ',$pathartdecor"/>
          <xsl:variable name="templateUri" select="concat('http://art-decor.org/decor/services/RetrieveTemplate?format=xml&amp;prefix=',$prefix,'&amp;id=',current-grouping-key(),'&amp;effectiveDate=dynamic')"/>
          <xsl:variable name="template" select="document($templateUri)"/>
          <xsl:result-document method="xml" href="{$pathartdecor}">
            <xsl:copy-of select="$template"/>
          </xsl:result-document>
          <xsl:variable name="pathoutput" select="concat('../',$prefix,'/output/',current-grouping-key(),'.xml')" />
          <xsl:message select="'.. resolving recursive includes into ',$pathoutput"/>
          <xsl:variable name="templateResolvedRecursive">
            <xsl:apply-templates select="$template" mode="include">
              <xsl:with-param name="ref" select="current-grouping-key()"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:result-document method="xml" href="{$pathoutput}">
            <xsl:copy-of select="$templateResolvedRecursive"/>
          </xsl:result-document>          
          -->
          <xsl:variable name="pathoutput" select="concat('../',$prefix,'/output/',current-grouping-key(),'.xml')" />
          <xsl:variable name="templateResolvedRecursive" select="document($pathoutput)"/>
          
          <xsl:choose>
            <xsl:when test="count($templateResolvedRecursive/return/template/template/element)=1">
              <xsl:variable name="pathresources" select="concat('../',$prefix,'/resources/',ahdis:idFromArtDecorTemplate(current-group()[1]/@name),'.xml')" />
              <xsl:message select="'.. generate logical model with name in ',$pathresources" />
              <xsl:value-of select="$ig"/>
              <xsl:value-of select="current-group()[1]/@name"/>
              <xsl:variable name="logicalmodel">
                <xsl:apply-templates select="$templateResolvedRecursive" mode="logical">
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:result-document method="xml" href="{$pathresources}">
                <xsl:copy-of select="$logicalmodel"/>
              </xsl:result-document>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="'.. no logical model generated for ', current-group()[1]/@name,'  elements zero or multiple',count($templateResolvedRecursive/element)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each-group>




  </xsl:template>

</xsl:stylesheet>