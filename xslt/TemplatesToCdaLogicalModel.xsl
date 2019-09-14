<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:ahdis="http://ahdis.ch" xmlns:fhir="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="canonicalBase" required="yes"/>
  <xsl:param name="projectUri" required="yes"/>
  <xsl:param name="projectUriChEpr" required="yes"/>
  <xsl:param name="decorservice" as="xs:string"/>
  <xsl:param name="canonicalCda" as="xs:string"/>
  <xsl:param name="removePrefix" as="xs:string"/>

  <xsl:param name="language" required="yes"/>


  <xsl:variable name="debug" as="xs:boolean" select="true()"/>

  <xsl:variable name="project" select="document($projectUri)"/>
  <xsl:variable name="projectchepr" select="document($projectUriChEpr)"/>


  <xsl:import href="functions.xsl"/>
  
  
<!-- 
Open Issues
- elementName to type is by convention with exception (manufacturedMaterial), not nice
- multilanguage  support 
- conformance
- binding strength of valuesets
- Schematron Assertions:
     The setId MUST be equal with the document id for version 1 and it MUST differ for all other versions.
- Art-Decor displays the dataset (aka logical model) inside the visualization of the templates     
- choice element conditions 
   - choice of hl7.compoent not yet supporting cardinality and only support for component/choice/section
- text/title elements not supported
- slicing for entry, substanceadministration, author, effectivetime needs to be setup/improved
- vocabulary issues
-->
 
 <!-- utility functions -->

  <xsl:function name="ahdis:isBaseModel" as="xs:boolean">
    <xsl:sequence select="$canonicalCda=$canonicalBase"/>
  </xsl:function>

    <!-- TODO: can be this done via a conceptmap? should be project specifc -->
  <xsl:function name="ahdis:valuesetoidtouri" as="xs:string">
    <xsl:param name="oid" as="xs:string"/>
    <xsl:sequence>
      <xsl:choose>
        <xsl:when test="starts-with($oid,'2.16.840.1.113883.1.11')">
          <xsl:variable name="v3name">
            <xsl:value-of select="$project//return/valueSet[@id=$oid or @ref=$oid][1]/@name"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="string-length($v3name)>0">
              <xsl:value-of select="concat('http://terminology.hl7.org/ValueSet/v3-',$v3name)"/>
            </xsl:when>
            <xsl:when test="$oid='2.16.840.1.113883.1.11.12212'">
              <xsl:value-of select="'http://terminology.hl7.org/ValueSet/v3-MaritalStatus'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$oid='2.16.840.1.113883.1.11.1221'">
          <xsl:value-of select="'http://fhir.ch/ig/ch-epr/ValueSet/DocumentEntry.typeCode'"/>
        </xsl:when>
        <xsl:when test="starts-with($oid,'2.16.756.5.30.1.127.3.10.1.') or starts-with($oid,'2.16.756.5.30.1.127.3.10.8.')">
          <!-- current problem is that project.xml in hl7chcda- has an old name for the valueset and it also not clear that the valueset belongs to ch-epr- (indent is hl7) -->
          <xsl:variable name="valuesetname" select="$projectchepr//return/valueSet[@id=$oid and not(@statusCode='deprecated')][1]/@name"/>
          <xsl:value-of select="if (string-length($valuesetname)>0) then (concat('http://fhir.ch/ig/ch-epr-term/ValueSet/',$valuesetname)) else ('')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="ahdis:typefortemplate" as="xs:string">

    <xsl:param name="oid" as="xs:string"/>
    <xsl:param name="elementName" as="xs:string"/>

    <xsl:sequence>
      <xsl:choose>
        <xsl:when test="string-length($oid)>0">
          <xsl:value-of select="ahdis:idFromArtDecorTemplate($oid,$removePrefix)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
    <!--  TODO: this is a hack, we should lookup oid for the gerneral template name, and derive type from there, now we go trough the elementName -->
            <xsl:when test="$elementName='ManufacturedMaterial'">
              <xsl:value-of select="'Material'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$elementName"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>


  <xsl:function name="ahdis:createslicename" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:variable name="profile">
      <xsl:value-of select="ahdis:profilefortemplate($input,$project)"/>
    </xsl:variable>
    <xsl:variable name="idnodot">
      <xsl:value-of select="replace($input, '\.', '')"/>
    </xsl:variable>
    <xsl:sequence select="if ($profile!='') then ($profile) else (substring($idnodot, string-length($idnodot)-5))"/>
  </xsl:function>

  <xsl:function name="ahdis:id" as="xs:string">
    <xsl:param name="parentid" as="xs:string"/>
    <xsl:param name="isSlice" as="xs:boolean"/>
    <xsl:param name="slice" as="xs:string"/>
    <xsl:param name="elementname" as="xs:string"/>

    <xsl:variable name="idbeforeslice">
      <xsl:choose>
        <xsl:when test="string-length($parentid)>0">
          <xsl:value-of select="concat($parentid,if (string-length($elementname)>0) then ('.') else (''),$elementname)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$elementname"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="$isSlice and exists($slice) and string-length($slice)>0">
          <xsl:value-of select="concat($idbeforeslice,':',$slice)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$idbeforeslice"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$id"/>
  </xsl:function>

  <xsl:function name="ahdis:path" as="xs:string">
    <xsl:param name="parentpath" as="xs:string"/>
    <xsl:param name="elementname" as="xs:string"/>

    <xsl:variable name="path">
      <xsl:choose>
        <xsl:when test="exists($parentpath) and string-length($parentpath)>0">
          <xsl:value-of select="concat($parentpath,if (string-length($elementname)>0) then ('.') else (''),$elementname)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$elementname"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$path"/>
  </xsl:function>

    
<!-- helper functions for  http://www.hl7.org/fhir/elementdefinition.html#ElementDefinition based-->

  <xsl:template name='elementIdPath'>
    <xsl:param name="id" required="yes"/>
    <xsl:param name="path" required="yes"/>
    <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
    <fhir:path>
      <xsl:attribute name="value"><xsl:value-of select="$path"/></xsl:attribute>
    </fhir:path>
  </xsl:template>

  <xsl:template name='elementIdPathDescSlice'>
    <xsl:param name="itselement" required="yes"/>


    <xsl:param name="id" as="xs:string" required="yes"/>
    <xsl:param name="path" as="xs:string" required="yes"/>
    <xsl:param name="sliceName" as="xs:string" required="yes"/>

    <xsl:call-template name="elementIdPath">
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="path" select="$path"/>
    </xsl:call-template>

    <xsl:if test="$sliceName and string-length($sliceName)>0">
      <fhir:sliceName>
        <xsl:attribute name="value"><xsl:value-of select="$sliceName"/></xsl:attribute>
      </fhir:sliceName>
    </xsl:if>
    <xsl:if test="$itselement/desc[@language=$language]">
      <fhir:short>
        <xsl:attribute name="value"><xsl:value-of select="ahdis:cleanwhitespaceshort($itselement/desc[@language=$language])"/></xsl:attribute>
      </fhir:short>
      <fhir:definition>
        <xsl:attribute name="value"><xsl:value-of select="ahdis:cleanwhitespace($itselement/desc[@language=$language])"/></xsl:attribute>
      </fhir:definition>
    </xsl:if>
  </xsl:template>

  <xsl:template name='elementMinMax'>
    <xsl:param name="itselement" required="yes"/>
    <xsl:if test="$itselement/@minimumMultiplicity">
      <fhir:min>
        <xsl:attribute name="value"><xsl:value-of select="$itselement/@minimumMultiplicity"/></xsl:attribute>
      </fhir:min>
    </xsl:if>
    <xsl:if test="$itselement/@maximumMultiplicity">
      <fhir:max>
        <xsl:attribute name="value"><xsl:value-of select="$itselement/@maximumMultiplicity"/></xsl:attribute>
      </fhir:max>
    </xsl:if>
  </xsl:template>


<!--  
       <element name="hl7:typeId" datatype="II" minimumMultiplicity="1" maximumMultiplicity="1" conformance="R" isMandatory="true" id="2.16.756.5.30.1.127.77.11.9.2">
          <desc language="en-US">HL7 CDA R2, 2005</desc>
          <attribute name="root" value="2.16.840.1.113883.1.3" datatype="uid" id="2.16.756.5.30.1.127.77.11.9.3"></attribute>
          <attribute name="extension" value="POCD_HD000040" datatype="st" id="2.16.756.5.30.1.127.77.11.9.4"></attribute>
        </element>
-->
  
      <!-- 
               <desc language="en-US">A unique identifier for each CDA document instance.</desc>
               <attribute name="root" datatype="uid" id="2.16.756.5.30.1.127.77.2.9.196">
                  <desc language="en-US">The document's id as Globally Unique Identifier (GUID).</desc>
               </attribute>
               <attribute name="extension"
                          datatype="st"
                          prohibited="true"
                          id="2.16.756.5.30.1.127.77.2.9.195"/>
     -->
  <xsl:template match="attribute" mode="its">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isHeader" as="xs:boolean" required="yes"/>
    <xsl:param name="force" as="xs:boolean" required="yes"/>

    <xsl:if test="$debug">
      <xsl:message select="'.. attribute parendid ',$parentid,' isSlice ',$isSlice,' parentpath',$parentpath,' isHeader: ',$isHeader"/>
      <xsl:comment select="'.. attribute parendid ',$parentid,' isSlice ',$isSlice,' parentpath',$parentpath,' isHeader: ',$isHeader"/>
    </xsl:if>

<!--     <xsl:if test="$isHeader">  -->

    <xsl:if test="$force or not(exists(../../template))">
      <fhir:element>
        <xsl:call-template name="elementIdPath">
          <xsl:with-param name="id" select="ahdis:id($parentid,false(),'',@name)"/>
          <xsl:with-param name="path" select="ahdis:path($parentpath,@name)"/>
        </xsl:call-template>
        <fhir:representation value="xmlAttr"/>
        <xsl:if test="desc[@language=$language] and string-length(desc[@language=$language])>0">
          <fhir:short>
            <xsl:attribute name="value"><xsl:value-of select="ahdis:cleanwhitespaceshort(desc[@language=$language])"/></xsl:attribute>
          </fhir:short>
          <fhir:definition>
            <xsl:attribute name="value"><xsl:value-of select="ahdis:cleanwhitespace(desc[@language=$language])"/></xsl:attribute>
          </fhir:definition>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@prohibited='true'">
            <fhir:min value="0"/>
            <fhir:max value="0"/>
          </xsl:when>
          <xsl:otherwise>
            <fhir:min value="0"/>
            <fhir:max value="1"/>
          </xsl:otherwise>
        </xsl:choose>
        <fhir:type>
          <fhir:code value="code"/>
        </fhir:type>
        <xsl:if test="@value and string-length(@value)>0">
          <fhir:fixedString>
            <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
          </fhir:fixedString>
        </xsl:if>
      </fhir:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="element" mode="its">


    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>
    <xsl:param name="isHeader" as="xs:boolean" required="yes"/>
    <xsl:param name="force" as="xs:boolean" required="yes"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:typefortemplate('',ahdis:firstLetterUpperCase($differentialchildelement))"/>

    <xsl:variable name="this" select="."/>
    <xsl:variable name="isonlychoice" as="xs:boolean" select="count(element)=0 and count(choice/element)>0"/>
    <xsl:variable name="iscomponentchoiceslice" as="xs:boolean" select="$isonlychoice and @name='hl7:component'"/>
    <xsl:variable name="iscomponentchoiceelement" as="xs:boolean" select="@name='hl7:section' and count(../../element)=0 and count(../../choice/element)>0 and ../../@name='hl7:component'"/>
    
    

<!--        <xsl:value-of select="ahdis:createslicename(if (($iscomponentchoiceelement or @name='hl7:participant') and @ref) then (@ref) else (@id))" -->
    <xsl:variable name="slicename">
      <xsl:choose>
        <xsl:when test="($iscomponentchoiceelement or @name='hl7:participant') and @ref">
          <xsl:value-of select="ahdis:createslicename(@ref)"/>
        </xsl:when>
        <xsl:when test="@name='hl7:templateId' and attribute[@name='root']/@value">
          <xsl:choose>
            <xsl:when test="ahdis:profilefortemplate(attribute[@name='root']/@value,$project)">
              <xsl:value-of select="ahdis:createslicename(attribute[@name='root']/@value)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="ahdis:idFromArtDecorTemplate(attribute[@name='root']/@value,'')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ahdis:idFromArtDecorTemplate(@id,'')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="id" as="xs:string" select="ahdis:id($parentid,$isSlice,$slicename,
                                                         if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <xsl:variable name="path" as="xs:string" select="ahdis:path($parentpath,if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>

    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="referstoelement" select="string-length($parentid)>0 and $ref and ahdis:hasoneprofilefortemplate($ref,$project)"/>

    <xsl:variable name="contains" select="@contains"/>

    <xsl:variable name="oids" select="element[@name='hl7:templateId']/attribute[@name='root']/@value"/>
    <xsl:variable name="containedoids" select="contains/element/element[@name='hl7:templateId']/attribute[@name='root']/@value"/>

    <xsl:variable name="referstotemplate" select="string-length($parentid)>0 and $oids and ahdis:hasoneprofilefortemplate($oids,$project)"/>
    <xsl:variable name="referstocontainedtemplate" select="string-length($parentid)>0 and @contains and $containedoids and ahdis:hasoneprofilefortemplate($containedoids,$project)"/>

    <xsl:if test="$debug">
      <xsl:message select="'.. element: ',$id,' ref: ',$ref,' referstoelement:',$referstoelement,' contains: ',$contains, ' oids: ',$oids, ' referstotemplate:',$referstotemplate,' containedoids: ',$containedoids, ' referstocontainedtemplate:', $referstocontainedtemplate, ' isHeader ',$isHeader, ' attributes ', count(attribute)"/>
      <xsl:comment select="'.. element: ',$id,' ref: ',$ref,' referstoelement:',$referstoelement,' contains: ',$contains, ' oids: ',$oids, ' referstotemplate:',$referstotemplate,' containedoids: ',$containedoids, ' referstocontainedtemplate:', $referstocontainedtemplate, ' isHeader ',$isHeader, ' attributes ', count(attribute)"/>
    </xsl:if>

    <xsl:if test="$isHeader">



      <xsl:if test="$iscomponentchoiceelement">
      <!-- <xsl:message select="'.. iscompomentchoiceelement'"/> -->
        <fhir:element>
          <xsl:call-template name="elementIdPathDescSlice">
            <xsl:with-param name="itselement" select="."/>
            <xsl:with-param name="id" select="ahdis:id($parentid,$isSlice,$slicename,'')"/>
            <xsl:with-param name="path" select="$parentpath"/>
            <xsl:with-param name="sliceName" select="if ($isSlice) then ($slicename) else ('')"/>
          </xsl:call-template>
        </fhir:element>
      </xsl:if>



      <fhir:element>

        <xsl:call-template name="elementIdPathDescSlice">
          <xsl:with-param name="itselement" select="."/>
          <xsl:with-param name="id" select="$id"/>
          <xsl:with-param name="path" select="$path"/>
          <xsl:with-param name="sliceName" select="if ($isSlice and not($iscomponentchoiceelement)) then ($slicename) else ('')"/>
        </xsl:call-template>

        <xsl:if test="@datatype='SD.TEXT'">
          <fhir:representation value="cdaText"/>
        </xsl:if>

        <xsl:call-template name="elementMinMax">
          <xsl:with-param name="itselement" select="."/>
        </xsl:call-template>

        <xsl:if test="$iscomponentchoiceslice and not(ahdis:isBaseModel())">
          <fhir:slicing>
            <fhir:discriminator>
              <fhir:type value="value"/>
              <fhir:path value="section.code.code"/>
            </fhir:discriminator>
            <rules value="open"/>
          </fhir:slicing>
        </xsl:if>

        <xsl:if test="@datatype">

          <xsl:choose>
            <xsl:when test="@datatype='SD.TEXT'">
              <fhir:type>
                <fhir:code value="xhtml"/>
              </fhir:type>
            </xsl:when>

            <xsl:otherwise>
              <xsl:variable name="type">
                <xsl:choose>
                  <xsl:when test="@datatype='CE' or @datatype='CO' or @datatype='CR' or @datatype='CS' or @datatype='CV' or @datatype='PQR' ">
                    <xsl:value-of select="'CD'"/>
                  </xsl:when>
                  <xsl:when test="@datatype='SXCM_TS' or @datatype='PIVL_TS' or @datatype='EIVL_TS' or @datatype='IVL_TS'">
                    <xsl:value-of select="'TS'"/>
                  </xsl:when>
                  <xsl:when test="@datatype='MO' or @datatype='PQ' or @datatype='REAL' or @datatype='RTO_PQ_PQ'">
                    <xsl:value-of select="'QTY'"/>
                  </xsl:when>
                  <xsl:when test="@datatype='ST'">
                    <xsl:value-of select="'ED'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@datatype"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <fhir:type>
                <fhir:code>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',$type)"/></xsl:attribute>
                </fhir:code>
                <fhir:profile>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',@datatype)"/></xsl:attribute>
                </fhir:profile>
              </fhir:type>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:if>

        <xsl:if test="$referstoelement and string-length(@datatype)=0 and not($contains and count(attribute)=0)">
          <fhir:type>
            <fhir:code>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',ahdis:profilefortemplate($ref,$project))"/></xsl:attribute>
            </fhir:code>
            <fhir:profile>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',ahdis:profilefortemplate($ref,$project))"/></xsl:attribute>
            </fhir:profile>
          </fhir:type>
        </xsl:if>

        <xsl:message select="'$contains and count(attribute)=0',$contains and count(attribute)=0"/>

        <xsl:if test="$contains and count(attribute)=0">
          <fhir:type>
            <fhir:code>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/', ahdis:profilefortemplate($contains,$project))"/></xsl:attribute>
            </fhir:code>
            <fhir:profile>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/', ahdis:profilefortemplate($contains,$project))"/></xsl:attribute>
            </fhir:profile>
          </fhir:type>
        </xsl:if>


        <xsl:if test="$referstotemplate">
          <fhir:type>
            <fhir:code>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',$Differentialchildelement)"/></xsl:attribute>
            </fhir:code>
            <xsl:for-each select="$oids">
              <xsl:if test="string-length(ahdis:profilefortemplate(.,$project))>0">
                <fhir:profile>
                  <xsl:attribute name="value"><xsl:value-of select="$canonicalBase"/>/StructureDefinition/<xsl:value-of select="ahdis:profilefortemplate(.,$project)"/></xsl:attribute>
                </fhir:profile>
              </xsl:if>
            </xsl:for-each>
          </fhir:type>
        </xsl:if>

        <xsl:if test="@name='hl7:entryRelationship' and $referstocontainedtemplate">
          <fhir:type>
            <fhir:code>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',$Differentialchildelement)"/></xsl:attribute>
            </fhir:code>
            <xsl:for-each select="$containedoids">
              <xsl:if test="string-length(ahdis:profilefortemplate(.,$project))>0">
                <xsl:variable name="profile" select="concat('ER',ahdis:profilefortemplate(.,$project))"/>
                <fhir:profile>
                  <xsl:attribute name="value"><xsl:value-of select="$canonicalBase"/>/StructureDefinition/<xsl:value-of select="$profile"/></xsl:attribute>
                </fhir:profile>
              </xsl:if>
            </xsl:for-each>
          </fhir:type>
        </xsl:if>

<!-- 
      <xsl:if test="not(ahdis:isBaseModel()) and @name='hl7:value' and string-length(@datatype)>0">
        <fhir:type>
          <fhir:code>
            <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',@datatype)"/></xsl:attribute>
          </fhir:code>
          <fhir:profile>
            <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',@datatype)"/></xsl:attribute>
          </fhir:profile>
        </fhir:type>
      </xsl:if>
 -->

        <xsl:if test="count(choice)>0">
          <xsl:apply-templates select="." mode="choice"/>
        </xsl:if>

        <xsl:if test="count(contains/choice)>0">
          <xsl:apply-templates select="contains" mode="choice"/>
        </xsl:if>
        
      <!--  <vocabulary valueSet="2.16.756.5.30.1.127.3.10.1.5"/>  -->
        <xsl:if test="count(vocabulary/@valueSet)=1">
          <xsl:choose>
            <xsl:when test="string-length(ahdis:valuesetoidtouri(vocabulary/@valueSet))>0">
              <fhir:binding>
                <fhir:strength value="preferred"/> <!-- TODO: can we specific somehow which binding strenght? -->
                <fhir:valueSet>
                  <xsl:attribute name="value"><xsl:value-of select="ahdis:valuesetoidtouri(vocabulary/@valueSet)"/></xsl:attribute>
                </fhir:valueSet>
              </fhir:binding>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="' .. Warning: No corresponding FHIR ValueSet found for ', vocabulary/@valueSet"/>
              <xsl:comment select="' .. Warning: No corresponding FHIR ValueSet found for ', vocabulary/@valueSet"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="count(vocabulary/@valueSet)>1">
          <xsl:message select="' .. Warning: No support yet for multiple ValueSets ', vocabulary/@valueSet"/>
          <xsl:comment select="' .. Warning: No support yet for multiple ValueSets ', vocabulary/@valueSet"/>
        </xsl:if>

      </fhir:element>

<!--    <xsl:if test="not($referstotemplate) and not($referstoelement) and not($contains)"> -->
      <xsl:if test="not($referstotemplate) and not($referstoelement)">

        <xsl:if test="$isHeader">
          <xsl:apply-templates select="attribute" mode="its">
            <xsl:with-param name="parentid" select="$id"/>
            <xsl:with-param name="parentpath" select="$path"/>
            <xsl:with-param name="isSlice" select="false()"/>
            <xsl:with-param name="slicename" select="''"/>
            <xsl:with-param name="isHeader" select="false()"/>
            <xsl:with-param name="force" select="false()"/>
          </xsl:apply-templates>

          <xsl:if test="count(vocabulary/@code)=1">
            <fhir:element>
              <xsl:call-template name="elementIdPath">
                <xsl:with-param name="id" select="ahdis:id($id,false(),'','code')"/>
                <xsl:with-param name="path" select="ahdis:path($path,'code')"/>
              </xsl:call-template>
              <fhir:min value="1"/>
              <fhir:max value="1"/>
              <fhir:fixedString>
                <xsl:attribute name="value"><xsl:value-of select="vocabulary/@code"/></xsl:attribute>
              </fhir:fixedString>
            </fhir:element>
          </xsl:if>
          <xsl:if test="count(vocabulary/@code)>1">
            <xsl:message select="' .. Warning: No support yet for multiple codes ', vocabulary/@code"/>
          </xsl:if>
        </xsl:if>
      </xsl:if>

    </xsl:if>


    <xsl:if test="not($referstoelement)">


      <xsl:for-each-group select="element | choice/element | contains/element | contains/choice/element" group-adjacent="@name">

        <xsl:variable name="siblings" as="xs:integer" select="count(current-group())"/>
        <xsl:message select="'.. ',current-grouping-key(),' count ', $siblings"/>


        <xsl:choose>
          <xsl:when test="$siblings>1 and (current-grouping-key()='hl7:author' or 
                           current-grouping-key()='hl7:effectiveTime' or 
                           current-grouping-key()='hl7:entry' or
                           current-grouping-key()='hl7:code' or
                           current-grouping-key()='hl7:qualifier' or
                           current-grouping-key()='hl7:representedOrganization' or
                           current-grouping-key()='hl7:substanceAdministration' or
                           (current-grouping-key()='hl7:component' and not($iscomponentchoiceslice)))">
              <!-- Todo set min max instead of slice, we have nothing to slice -->
            <xsl:message select="'.. WARNING: slice setup cannot be defined for ', current-grouping-key(), 'in ', $prefix, ' child elements ignored'"/>
            <xsl:comment select="'.. WARNING: slice setup cannot be defined for ', current-grouping-key(), 'in ', $prefix, ' child elements ignored'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="current-group()">
              <xsl:if test="position()=1 and $siblings>1 and not($iscomponentchoiceslice)">
                <xsl:apply-templates select="." mode="slicesetup">
                  <xsl:with-param name="parentid" select="$id"/>
                  <xsl:with-param name="parentpath" select="$path"/>
                  <xsl:with-param name="isSlice" select="false()"/>
                  <xsl:with-param name="isHeader" select="true()"/>
                  <xsl:with-param name="force" select="false"/>
                </xsl:apply-templates>
              </xsl:if>
              <xsl:apply-templates select="." mode="its">
                <xsl:with-param name="parentid" select="$id"/>
                <xsl:with-param name="parentpath" select="$path"/>
                <xsl:with-param name="isSlice" select="$siblings>1"/>
                <xsl:with-param name="isHeader" select="true()"/>
                <xsl:with-param name="force" select="false()"/>
              </xsl:apply-templates>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>


      </xsl:for-each-group>
    </xsl:if>




  </xsl:template>
  
  <!-- slicing -->

  <xsl:template match="element[@name='hl7:templateId']" mode="slicesetup">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:firstLetterUpperCase($differentialchildelement)"/>

    <xsl:variable name="id" as="xs:string" select="ahdis:id($parentid,false(),'',
                                                         if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <xsl:variable name="path" as="xs:string" select="ahdis:path($parentpath,if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <fhir:element>
      <xsl:call-template name="elementIdPathDescSlice">
        <xsl:with-param name="itselement" select="."/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="sliceName" select="''"/>
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
      <fhir:slicing>
        <fhir:discriminator>
          <fhir:type value="value"/>
          <fhir:path value="root"/>
        </fhir:discriminator>
        <rules value="open"/>
      </fhir:slicing>
    </fhir:element>
  </xsl:template>
  
  <!-- 
  <xsl:template match="element[@name='hl7:substanceAdministration']" mode="slicesetup">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:firstLetterUpperCase($differentialchildelement)"/>

    <xsl:variable name="id" as="xs:string" select="ahdis:id($parentid,false(),'',
                                                         if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <xsl:variable name="path" as="xs:string" select="ahdis:path($parentpath,if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <fhir:element>
      <xsl:call-template name="elementIdPathDescSlice">
        <xsl:with-param name="itselement" select="."/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="sliceName" select="''"/>
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
      <fhir:slicing>
        <fhir:discriminator>
          <fhir:type value="value"/>
          <fhir:path value="templateId.root"/>
        </fhir:discriminator>
        <rules value="open"/>
      </fhir:slicing>
    </fhir:element>
  </xsl:template>
  -->

  <xsl:template match="element[@name='hl7:entryRelationship']" mode="slicesetup">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:firstLetterUpperCase($differentialchildelement)"/>

    <xsl:variable name="id" as="xs:string" select="ahdis:id($parentid,false(),'',
                                                         if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <xsl:variable name="path" as="xs:string" select="ahdis:path($parentpath,if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>

    <fhir:element>
      <xsl:call-template name="elementIdPathDescSlice">
        <xsl:with-param name="itselement" select="."/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="sliceName" select="''"/>
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
      <fhir:slicing>
        <fhir:discriminator>
          <fhir:type value="profile"/>
          <fhir:path value="$this"/>
        </fhir:discriminator>
        <rules value="open"/>
      </fhir:slicing>
    </fhir:element>
  </xsl:template>

  <xsl:template match="element[@name='hl7:id']" mode="slicesetup">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:firstLetterUpperCase($differentialchildelement)"/>

    <xsl:variable name="id" as="xs:string" select="ahdis:id($parentid,false(),'',
                                                         if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <xsl:variable name="path" as="xs:string" select="ahdis:path($parentpath,if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <fhir:element>
      <xsl:call-template name="elementIdPathDescSlice">
        <xsl:with-param name="itselement" select="."/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="sliceName" select="''"/>
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
      <fhir:slicing>
        <fhir:discriminator>
          <fhir:type value="value"/>
          <fhir:path value="root"/>
        </fhir:discriminator>
        <fhir:discriminator>
          <fhir:type value="value"/>
          <fhir:path value="extension"/>
        </fhir:discriminator>
        <rules value="open"/>
      </fhir:slicing>
    </fhir:element>
  </xsl:template>

  <xsl:template match="element[@name='hl7:participant']" mode="slicesetup">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:firstLetterUpperCase($differentialchildelement)"/>

    <xsl:variable name="id" as="xs:string" select="ahdis:id($parentid,false(),'',
                                                         if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <xsl:variable name="path" as="xs:string" select="ahdis:path($parentpath,if (string-length($parentid)>0) 
                                                         then ($differentialchildelement)
                                                         else ($Differentialchildelement))"/>
    <fhir:element>
      <xsl:call-template name="elementIdPathDescSlice">
        <xsl:with-param name="itselement" select="."/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="sliceName" select="''"/>
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
      <fhir:slicing>
        <fhir:discriminator>
          <fhir:type value="value"/>
          <fhir:path value="templateId.root"/>
        </fhir:discriminator>
        <rules value="open"/>
      </fhir:slicing>
    </fhir:element>
  </xsl:template>

  <xsl:template match="element" mode="slicesetup">
    <xsl:param name="parentid" as="xs:string" required="yes"/>
    <xsl:param name="parentpath" as="xs:string" required="yes"/>
    <xsl:param name="isSlice" as="xs:boolean" required="yes"/>

    <xsl:message select="'.. ERROR: slice setup needs to be defined for ', @name, 'and id', @id"/>
    <xsl:comment select="'.. ERROR: slice setup needs to be defined for ', @name, 'and id', @id"/>

  </xsl:template>


  <xsl:template match="text()|@*" mode="its">
  </xsl:template>

  <xsl:template match="." mode="choice">
             <!--   <choice minimumMultiplicity="1" maximumMultiplicity="1">  -->
    <xsl:for-each select="choice">
      <fhir:constraint>
        <fhir:key>
          <xsl:attribute name="value"><xsl:value-of select="concat('choice-',position())"/>
                  </xsl:attribute>
        </fhir:key>
        <fhir:severity value="error"/>
        <fhir:human value="Choice of the contained elements"/>
        <xsl:variable name="fhirpathinner">
          <xsl:for-each select="element">
            <xsl:value-of select="ahdis:skipns(@name)"/>
            <xsl:if test="position() != last()">
              <xsl:value-of select="' | '"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <fhir:expression>
          <xsl:attribute name="value"><xsl:value-of select="concat('(',$fhirpathinner,').count()&lt;=',@maximumMultiplicity,' and ','(',$fhirpathinner,').count()&gt;=',@minimumMultiplicity)"/>
                  </xsl:attribute>
        </fhir:expression>
      </fhir:constraint>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="//template/template" mode="logical">
  
     <!-- TODO: basedefinition from first profile it is constrained 
                differentialtype has to be the same as in the basedefintion
                we now when the too easy way for the firstw match :-(   -->

    <xsl:variable name="isHeader" as="xs:boolean" select="count(attribute)>0 or count(element)>1 or count(choice)>0"/>
    
    <!-- isHeader means a template with attributes, element or choice not a toplevel element -->

    <xsl:variable name="head" select="if ($isHeader) then (.) else (element)"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="if ($isHeader) then (ahdis:idFromArtDecorTemplate(@name,$removePrefix)) else (replace(substring(element/@name, 5), '\.', ''))"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:typefortemplate('',ahdis:firstLetterUpperCase($differentialchildelement))"/>

    <xsl:variable name="logicalid" select="ahdis:idFromArtDecorTemplate(@name,$removePrefix)"/> <!-- nees to in sync with filename for ig -->
    <xsl:variable name="type" select="$Differentialchildelement"/>

    <xsl:variable name="itstemplate" select="."/>
    <fhir:StructureDefinition>

      <fhir:meta>
        <fhir:source>
          <xsl:attribute name="value"><xsl:value-of select="concat($decorservice,'/RetrieveTemplate?format=xml&amp;prefix=',../@indent,'&amp;id=',../@id,'&amp;effectiveDate=dynamic')"/></xsl:attribute>
        </fhir:source>
      </fhir:meta>

      <fhir:id>
        <xsl:attribute name="value"><xsl:value-of select="$logicalid"/></xsl:attribute>
      </fhir:id>
      <fhir:extension url="http://hl7.org/fhir/StructureDefinition/elementdefinition-namespace">
        <fhir:valueUri value="urn:hl7-org:v3"/>
      </fhir:extension>
      <fhir:url>
        <xsl:attribute name="value"><xsl:value-of select="$canonicalBase"/>/StructureDefinition/<xsl:value-of select="$logicalid"/>
        </xsl:attribute>
      </fhir:url>
      <fhir:name>
        <xsl:attribute name="value"><xsl:value-of select="$Differentialchildelement"/>
        </xsl:attribute>
      </fhir:name>
      <fhir:title>
        <xsl:attribute name="value"><xsl:value-of select="@displayName"/>
        </xsl:attribute>
      </fhir:title>
      <fhir:status value="active"/>
      <fhir:experimental value="false"/>
      <fhir:publisher value="HL7 Switzerland"/>
      <xsl:if test="desc[@language=$language]">
        <fhir:description>
          <xsl:attribute name="value"><xsl:value-of select="ahdis:cleanwhitespace(desc[@language=$language])"/>
          </xsl:attribute>
        </fhir:description>
      </xsl:if>
      <fhir:kind value="logical"/>
      <fhir:abstract value="false"/>
      <fhir:type>
        <xsl:attribute name="value"><xsl:value-of select="$type"/>
        </xsl:attribute>
      </fhir:type>

      <xsl:if test="ahdis:isBaseModel()">
        <fhir:baseDefinition>
          <xsl:attribute name="value"><xsl:value-of select="'http://fhir.ch/ig/cda-r2/StructureDefinition/LogicalElement'"/></xsl:attribute>
        </fhir:baseDefinition>
        <fhir:derivation value="specialization"/>
      </xsl:if>
      <xsl:if test="not(ahdis:isBaseModel())">
        <fhir:baseDefinition>
          <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',$Differentialchildelement)"/></xsl:attribute>
        </fhir:baseDefinition>
        <fhir:derivation value="constraint"/>
      </xsl:if>

      <fhir:differential>

        <fhir:element>
          <xsl:call-template name="elementIdPathDescSlice">
            <xsl:with-param name="itselement" select="."/>
            <xsl:with-param name="id" select="$Differentialchildelement"/>
            <xsl:with-param name="sliceName" select="''"/>
            <xsl:with-param name="path" select="$Differentialchildelement"/>
          </xsl:call-template>

          <xsl:if test="count(choice)>0">
            <xsl:apply-templates select="." mode="choice"/>
          </xsl:if>
        </fhir:element>


        <xsl:apply-templates select="$head/attribute" mode="its">
          <xsl:with-param name="parentid" select="$Differentialchildelement"/>
          <xsl:with-param name="parentpath" select="$Differentialchildelement"/>
          <xsl:with-param name="isSlice" select="false()"/>
          <xsl:with-param name="slicename" select="''"/>
          <xsl:with-param name="isHeader" select="$isHeader"/>
          <xsl:with-param name="force" select="true()"/>
        </xsl:apply-templates>
            
            
            <!-- The ART-DECOR base model does not contain for all RIM classes realmCode/typeId/tempalteid -->
        <xsl:if test="ahdis:isBaseModel() and $removePrefix='CDA'">


          <xsl:if test="count($head/element[@name='hl7:realmCode'])=0">
            <xsl:message select="' .. Warning: added hl7:realmCode, not in template ',@name,' with id ',@id"/>
            <xsl:comment select="' .. Warning: added hl7:realmCode, not in template ',@name,' with id ',@id"/>
            <fhir:element>
              <xsl:attribute name="id"><xsl:value-of select="concat($Differentialchildelement,'.realmCode')"/>
                  </xsl:attribute>
              <fhir:path>
                <xsl:attribute name="value"><xsl:value-of select="concat($Differentialchildelement,'.realmCode')"/>
                  </xsl:attribute>
              </fhir:path>
              <fhir:min value="0"/>
              <fhir:max value="*"/>
              <fhir:type>
                <fhir:code>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/CD')"/></xsl:attribute>
                </fhir:code>
                <fhir:profile>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/CS')"/></xsl:attribute>
                </fhir:profile>
              </fhir:type>
            </fhir:element>
          </xsl:if>

          <xsl:if test="count($head/element[@name='hl7:typeId'])=0">
            <xsl:message select="' .. Warning: added hl7:typeId, not in template ',@name,' with id ',@id"/>
            <xsl:comment select="' .. Warning: added hl7:typeId, not in template ',@name,' with id ',@id"/>
            <fhir:element>
              <xsl:attribute name="id"><xsl:value-of select="concat($Differentialchildelement,'.typeId')"/>
                  </xsl:attribute>
              <fhir:path>
                <xsl:attribute name="value"><xsl:value-of select="concat($Differentialchildelement,'.typeId')"/>
                  </xsl:attribute>
              </fhir:path>
              <fhir:min value="0"/>
              <fhir:max value="*"/>
              <fhir:type>
                <fhir:code>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/II')"/></xsl:attribute>
                </fhir:code>
                <fhir:profile>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/II')"/></xsl:attribute>
                </fhir:profile>
              </fhir:type>
            </fhir:element>
          </xsl:if>

          <xsl:if test="count($head/element[@name='hl7:templateId'])=0">
            <xsl:message select="' .. Warning: added hl7:templateId, not in template ',@name,' with id ',@id"/>
            <xsl:comment select="' .. Warning: added hl7:templateId, not in template ',@name,' with id ',@id"/>
            <fhir:element>
              <xsl:attribute name="id"><xsl:value-of select="concat($Differentialchildelement,'.templateId')"/>
                  </xsl:attribute>
              <fhir:path>
                <xsl:attribute name="value"><xsl:value-of select="concat($Differentialchildelement,'.templateId')"/>
                  </xsl:attribute>
              </fhir:path>
              <fhir:min value="0"/>
              <fhir:max value="*"/>
              <fhir:type>
                <fhir:code>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/II')"/></xsl:attribute>
                </fhir:code>
                <fhir:profile>
                  <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/II')"/></xsl:attribute>
                </fhir:profile>

              </fhir:type>
            </fhir:element>
          </xsl:if>
        </xsl:if>

<!--  for base model we do not have to slice -->
<!--         <xsl:apply-templates select="$head/element | $head/choice/element" mode="its">  -->
        
        <xsl:apply-templates select="$head" mode="its">
          <xsl:with-param name="parentid" select="if ($isHeader) then ($Differentialchildelement) else ('')"/>
          <xsl:with-param name="parentpath" select="if ($isHeader) then ($Differentialchildelement) else ('')"/>
          <xsl:with-param name="isSlice" select="false()"/>
          <xsl:with-param name="slicename" select="''"/>
          <xsl:with-param name="isHeader" select="$isHeader"/>
          <xsl:with-param name="force" select="false()"/>
        </xsl:apply-templates>

      </fhir:differential>
    </fhir:StructureDefinition>
  </xsl:template>


  <!-- A profile is generated it for specialised contained elements -->
  <xsl:template match="." mode="containsprofile">

    <xsl:variable name="containedtype" as="xs:string" select="ahdis:firstLetterUpperCase(ahdis:skipns(contains/element/@name))"/>
    <xsl:variable name="containedoids" select="contains/element/element[@name='hl7:templateId']/attribute[@name='root']/@value"/>
    <xsl:variable name="containedprofile" select="ahdis:profilefortemplate($containedoids[1],$project)"/>

    <xsl:variable name="logicalid" as="xs:string" select="concat('ER',$containedprofile)"/>

    <xsl:variable name="differentialchildelement" as="xs:string" select="ahdis:skipns(@name)"/>
    <xsl:variable name="Differentialchildelement" as="xs:string" select="ahdis:typefortemplate('',ahdis:firstLetterUpperCase($differentialchildelement))"/>

    <xsl:message select="'containsprofile called for ', $logicalid"/>

    <fhir:StructureDefinition>
      <fhir:id>
        <xsl:attribute name="value"><xsl:value-of select="$logicalid"/>
        </xsl:attribute>
      </fhir:id>
      <fhir:extension url="http://hl7.org/fhir/StructureDefinition/elementdefinition-namespace">
        <fhir:valueUri value="urn:hl7-org:v3"/>
      </fhir:extension>
      <fhir:url>
        <xsl:attribute name="value"><xsl:value-of select="$canonicalBase"/>/StructureDefinition/<xsl:value-of select="$logicalid"/>
        </xsl:attribute>
      </fhir:url>
      <fhir:name>
        <xsl:attribute name="value"><xsl:value-of select="$logicalid"/>
        </xsl:attribute>
      </fhir:name>
      <fhir:title>
        <xsl:attribute name="value"><xsl:value-of select="concat('entryRelationShip profile wich referes to ',$containedprofile)"/>
        </xsl:attribute>
      </fhir:title>
      <fhir:status value="active"/>
      <fhir:experimental value="false"/>
      <fhir:publisher value="autogenerated by artdecor2ig"/>
      <fhir:kind value="logical"/>
      <fhir:abstract value="false"/>
      <fhir:type>
        <xsl:attribute name="value"><xsl:value-of select="$logicalid"/>
        </xsl:attribute>
      </fhir:type>
      <fhir:baseDefinition>
        <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',$Differentialchildelement)"/></xsl:attribute>
      </fhir:baseDefinition>
      <fhir:derivation value="constraint"/>
      <fhir:differential>

        <xsl:apply-templates select="." mode="its">
          <xsl:with-param name="parentid" select="''"/>
          <xsl:with-param name="parentpath" select="''"/>
          <xsl:with-param name="isSlice" select="false()"/>
          <xsl:with-param name="slicename" select="''"/>
          <xsl:with-param name="isHeader" select="false()"/>
          <xsl:with-param name="force" select="false()"/>
        </xsl:apply-templates>


        <xsl:variable name="element" as="xs:string" select="ahdis:skipns(contains/element/@name)"/>
        <xsl:variable name="Element" as="xs:string" select="ahdis:typefortemplate('',ahdis:firstLetterUpperCase($element))"/>

        <fhir:element>
          <xsl:attribute name="id"><xsl:value-of select="concat('EntryRelationship.',$element)"/></xsl:attribute>

          <fhir:path>
            <xsl:attribute name="value"><xsl:value-of select="concat('EntryRelationship.',$element)"/></xsl:attribute>
          </fhir:path>

          <fhir:min value="1"/>
          <fhir:max value="1"/>
          <fhir:type>
            <fhir:code>
              <xsl:attribute name="value"><xsl:value-of select="concat($canonicalCda,'/StructureDefinition/',$Element)"/></xsl:attribute>
            </fhir:code>
            <fhir:profile>
              <xsl:attribute name="value"><xsl:value-of select="$canonicalBase"/>/StructureDefinition/<xsl:value-of select="$containedprofile"/>
               </xsl:attribute>
            </fhir:profile>
          </fhir:type>
        </fhir:element>

      </fhir:differential>
    </fhir:StructureDefinition>

  </xsl:template>


</xsl:stylesheet>