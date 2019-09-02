<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://hl7.org/fhir" xmlns:fhir="http://hl7.org/fhir" xmlns:ahdis="http://ahdis.ch" xmlns:xs="http://www.w3.org/2001/XMLSchema"   xmlns:java-file="java:java.io.File"
  xmlns:java-uri="java:java.net.URI">

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

  <xsl:function name="ahdis:idFromArtDecorTemplate" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="ahdis:camelCaseSpaces(replace($input,'\s+|\.|-|_',' '))"/>
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
    <xsl:param name="project" />
    <xsl:variable name="templates" select="$project//return/template[@id=$oid or @ref=$oid][1]/@name"/>
    <xsl:sequence>
      <xsl:value-of select="if ($templates) then (ahdis:idFromArtDecorTemplate($templates)) else ('')"/>
    </xsl:sequence>
  </xsl:function>

  <xsl:function name="ahdis:hasoneprofilefortemplate" as="xs:boolean">
    <xsl:param name="oids" as="xs:string*"/>
    <xsl:param name="project" />
    <xsl:variable name="length" as="xs:integer*">
      <xsl:for-each select="$oids">
        <xsl:value-of select="string-length(ahdis:profilefortemplate(.,$project))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="sum($length)>0"/>
  </xsl:function>
    
</xsl:stylesheet>