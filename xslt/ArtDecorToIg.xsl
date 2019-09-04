<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:fhir="http://hl7.org/fhir" xmlns:ahdis="http://ahdis.ch" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="text" indent="yes"/>

  <xsl:param name="prefix" required="yes"/> <!-- art-decor prefix for project -->
  <xsl:param name="ig" required="yes"/> <!--  folder relativ to art-decor2ig -->
  <xsl:param name="projectUri" required="yes"/>  <!-- location of project.xml (actually also as input to this xml ...) -->
  <xsl:param name="projectUriSkip" required="yes"/>  <!-- location of project.xml, elements inside will be skipped -->
  <xsl:param name="projectUriChEpr" required="yes"/>
  <xsl:param name="canonicalBase" required="yes"/>  <!-- location of project.xml (actually also as input to this xml ...) -->
  <xsl:param name="language" required="yes"/>  <!-- e.g en_US ...) -->
  <xsl:param name="decorservice" as="xs:string" />
  <xsl:param name="canonicalCda" as="xs:string" />
  <xsl:param name="removePrefix" as="xs:string"  />

  <xsl:import href="functions.xsl"/>

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
          <xsl:variable name="pathoutput" select="concat('../',$prefix,'/output/',current-grouping-key(),'.xml')"/>
          <xsl:variable name="templateResolvedRecursive" select="document($pathoutput)"/>

          <xsl:choose>
            <xsl:when test="$templateResolvedRecursive/return/template/template">
              <xsl:variable name="pathresources" select="concat('../',$prefix,'/resources/',ahdis:idFromArtDecorTemplate(current-group()[1]/@name,$removePrefix),'.xml')"/>
              <xsl:message select="'.. generate logical model with name in ',$pathresources"/>
              <xsl:value-of select="$ig"/>
              <xsl:value-of select="current-group()[1]/@name"/>
              <xsl:variable name="logicalmodel">
                <xsl:apply-templates select="$templateResolvedRecursive" mode="logical">
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:result-document method="xml" href="{$pathresources}">
                <xsl:copy-of select="$logicalmodel"/>
              </xsl:result-document>
              
              <!--  need to generate contained profiles  -->

              <xsl:variable name="relationships" select="$templateResolvedRecursive//element[@name='hl7:entryRelationship']"/>
              <xsl:for-each select="$relationships">
                <xsl:variable name="containedoids" select="contains/element/element[@name='hl7:templateId']/attribute[@name='root']/@value"/>
                <xsl:if test="$containedoids">
                  <xsl:variable name="referstocontainedtemplate" select="ahdis:hasoneprofilefortemplate($containedoids,$project)"/>
                  <xsl:variable name="containedprofile" select="ahdis:profilefortemplate($containedoids[1],$project)"/>
                  <xsl:if test="$containedprofile">
                    <xsl:variable name="logicalid" as="xs:string" select="concat('ER',$containedprofile)"/>
                    <xsl:variable name="pathprofile" select="concat('../',$prefix,'/resources/',$logicalid,'.xml')"/>

                    <xsl:variable name="fileExists" select="unparsed-text-available($pathprofile)"/>

                    <xsl:if test="$fileExists=false()">
                      <xsl:message select="'.. generate profile with name in ',$pathprofile"/>
                      <xsl:variable name="profile">
                        <xsl:apply-templates select="." mode="containsprofile">
                        </xsl:apply-templates>
                      </xsl:variable>

                      <xsl:result-document method="xml" href="{$pathprofile}">
                        <xsl:copy-of select="$profile"/>
                      </xsl:result-document>
                    </xsl:if>

                  </xsl:if>
                </xsl:if>
              </xsl:for-each>
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