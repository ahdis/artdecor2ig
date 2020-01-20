<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:fhir="http://hl7.org/fhir" xmlns:ahdis="http://ahdis.ch" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:java-file="java:java.io.File" xmlns:java-uri="java:java.net.URI">

  <xsl:output method="xml" indent="yes"/>

  <xsl:function name="ahdis:cleanwhitespace" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace($input, '^\s+|\s+$', '')"/>
  </xsl:function>

  <xsl:function name="ahdis:firstLetterUpperCase" as="xs:string*">
    <xsl:param name="input" as="xs:string*"/>
    <xsl:sequence>
      <xsl:for-each select="$input">
        <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
      </xsl:for-each>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="ahdis:camelCaseSpaces" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="string-join(ahdis:firstLetterUpperCase(tokenize($input, '\s+')), '')"/>
  </xsl:function>

  <xsl:function name="ahdis:canonicalFromArtDecorTemplate" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence>
      <xsl:choose>
        <xsl:when test="$input='ad1bbr-'">
          <!-- instead of Art-Decor we are unsing the fhir cda-core-2.0 mdoel -->
          <xsl:value-of select="'http://hl7.org/fhir/cda'"/>
          <!-- <xsl:value-of select="'http://fhir.ch/ig/cda-r2'"/> -->
        </xsl:when>
        <xsl:when test="$input='ch-pcc-'">
          <xsl:value-of select="'http://fhir.ch/ig/cda-ch-pcc'"/>
        </xsl:when>
        <xsl:when test="$input='hl7chcda-'">
          <xsl:value-of select="'http://fhir.ch/ig/cda-ch-v2'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('not found ',$input,'addyourcanonicalto-ahdis:canonicalFromArtDecorTemplate')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="ahdis:idFromArtDecorTemplate" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="removePrefix" as="xs:string"/>
    <xsl:variable name="name" select="if (string-length($removePrefix)>0 and starts-with(lower-case($input),lower-case($removePrefix))) then (ahdis:firstLetterUpperCase(substring($input, string-length($removePrefix)+1))) else ($input)"/>
    <xsl:sequence select="ahdis:camelCaseSpaces(replace($name,'\s+|\.|-|_',' '))"/>
  </xsl:function>

  <xsl:function name="ahdis:cleanwhitespaceshort" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:variable name="idnodot">
      <xsl:value-of select="substring(replace($input, '^\s+|\s+$', ''), 1, 100)"/>
    </xsl:variable>

    <xsl:variable name="shortedtopoint">
      <xsl:value-of select="string-join(tokenize($idnodot, '\.')[position() lt last()], '.')"/>
    </xsl:variable>

    <xsl:sequence select="if (string-length($shortedtopoint)>0) then (concat($shortedtopoint,'.')) else ($idnodot)"/>
  </xsl:function>

  <xsl:function name="ahdis:skipxpath" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="if (string-length(substring-before($input,'['))>0) then (substring-before($input,'[')) else ($input)"/>
  </xsl:function>

  <xsl:function name="ahdis:skipns" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="substring-after($input, ':')"/>
  </xsl:function>

  <xsl:function name="ahdis:profilefortemplate" as="xs:string">
    <xsl:param name="oid" as="xs:string"/>
    <xsl:param name="project"/>
    <xsl:variable name="templates" select="$project//return/template[@id=$oid or @ref=$oid][1]/@name"/>
    <xsl:sequence>
      <xsl:value-of select="if ($templates) then (ahdis:idFromArtDecorTemplate($templates,$removePrefix)) else ('')"/>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="ahdis:canonicalfortemplate" as="xs:string">
    <xsl:param name="oid" as="xs:string"/>
    <xsl:param name="project"/>
    <!-- TODO: art-decor has in project.xml in ident not from which repo the template is from -->
    <!-- <template ref="2.16.840.1.113883.10.12.154" name="CDAinformant" displayName="CDA Informant" url="http://art-decor.org/decor/services/" ident="hl7chcda-"></template> -->
    <xsl:variable name="ident">
      <xsl:choose>
        <xsl:when test="starts-with($oid,'2.16.840.1.113883.10.12.')">
          <xsl:value-of select="'ad1bbr-'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$project//return/template[@id=$oid or @ref=$oid][1]/@ident"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence>
      <xsl:value-of select="ahdis:canonicalFromArtDecorTemplate($ident)"/>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="ahdis:hasoneprofilefortemplate" as="xs:boolean">
    <xsl:param name="oids" as="xs:string*"/>
    <xsl:param name="project"/>
    <xsl:variable name="length" as="xs:integer*">
      <xsl:for-each select="$oids">
        <xsl:value-of select="string-length(ahdis:profilefortemplate(.,$project))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="sum($length)>0"/>
  </xsl:function>

</xsl:stylesheet>