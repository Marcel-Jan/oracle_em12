------------------------------------------------------------------------------------------------------------------------------------------------------
--      Get a report on targets in EM12c
--
--      Script      em12_targets_report.sql
--      Run as      SYSMAN
--
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     Apr 28 2016 M. Krijgsman   First version
--      1.1     May 23 2016 M. Krijgsman   Query for new targets
--
------------------------------------------------------------------------------------------------------------------------------------------------------

column v_datetime    new_value datetime       noprint
select to_char(sysdate, 'YYYYMMDDHH24MISS') v_datetime from dual;

store set /tmp/your_sqlplus_env_&datetime..sql REPLACE

set linesize 3000
set feedback off
set verify off
set pause off
set timing off
set echo off
set heading on
set pages 999
set trimspool on
set newpage none
set define on

column vl_dbname     new_value l_dbname       noprint

select lower(name) vl_dbname from v$database;

prompt =============================================
prompt =                                           =
prompt =         em12_targets_report.sql           =
prompt =                                           =
prompt =============================================
prompt


spool em12_targets_&l_dbname._&datetime..html

prompt  <TITLE>Report on EM12 targets in &l_dbname</TITLE>
prompt  <STYLE TYPE="text/css">
prompt    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    tr,td             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    table             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    th                {font:bold 9pt  Arial,Helvetica,sans-serif; color:#314299; background:#befdfd;}
prompt    h1                {font:bold 12pt Arial,Helvetica,sans-serif; color:#003399; background-color:White;}
prompt    h2                {font:bold 10pt Arial,Helvetica,sans-serif; color:#FF9933; background-color:White;}
prompt    h4                {font:bold 9pt Arial,Helvetica,sans-serif; color:Grey; background-color:White;}
prompt    a                 {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt  </STYLE>

set markup html on spool on preformat off entmap on

--body   'BGCOLOR="#C5CDC5"' table 'WIDTH="90%" BORDER="1"' 


set    markup html on entmap off
set    head off

set markup HTML ON ENTMAP OFF
prompt <h1>Targets in EM12c</h1>
prompt <p>This file was created with:
prompt em12_targets_report.sql
prompt version 1.1 (2016)
prompt 
prompt dbname: &l_dbname
prompt date:   &datetime
prompt </p>
set markup HTML OFF ENTMAP OFF


SET DEFINE ~

prompt <center>
prompt 	<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#314299"><b>Report Index</b></font>
prompt 	<hr align="center" width="250">
prompt
prompt
prompt <table width="90%" border="1">  
prompt 	<tr><th colspan="4">Incidents</th></tr>  
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tarcount">Number of targets</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tartypcount">Target types</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tarperlob">Target types per Line of Business</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tarperowner">Target types per Owner</a></td>
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#ownnotsysman">Targets not owned by EM users</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#brokentar">Broken targets</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#newtargets">New targets</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#asmtargets">ASM targets</a></td>
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#alltargets">All targets</a></td>
prompt 	</tr>
prompt </table>
prompt </center>  
prompt 


set heading on
set markup HTML ON ENTMAP OFF


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="tarcount"></A><h2>Target types.</h2>
set markup HTML ON ENTMAP ON

select 
	(select count(*)
	 from MGMT_TARGETS) "Number of targets",
	(select count(*)
	 from MGMT_TARGETS
	 where BROKEN_REASON!=0) "Broken targets",
	(select count(*)
   from MGMT_TARGETS
   where IS_PROPAGATING!=1) "Not propagating",
	(select count(*)
   from MGMT_TARGETS
   where PROMOTE_STATUS!=3) "Not promoted",
  (select count(*)
   from MGMT_TARGETS
   where IS_ACTIVE!=1) "Not active",
  (select count(*)
   from MGMT_TARGETS
   where IS_READY!=1) "Not ready",
  (select count(*)
   from MGMT_TARGETS
   where IS_READY_FOR_JOB!=1) "Not ready for job"
from dual
/



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="tartypcount"></A><h2>Target types.</h2>
set markup HTML ON ENTMAP ON

select TARGET_TYPE, count(*)
from MGMT_TARGETS
group by TARGET_TYPE
order by TARGET_TYPE
/


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="tarperlob"></A><h2>Target types per Line of Business.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE, t.TARGET_TYPE, count(*)
from MGMT_TARGET_PROPERTIES p
, MGMT_TARGETS t
where t.TARGET_GUID=p.TARGET_GUID
and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
group by p.PROPERTY_VALUE, t.TARGET_TYPE
order by p.PROPERTY_VALUE, t.TARGET_TYPE
/



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="tarperowner"></A><h2>Target types per Owner.</h2>
set markup HTML ON ENTMAP ON

select OWNER, TARGET_TYPE, count(*)
from MGMT_TARGETS
group by OWNER, TARGET_TYPE
order by OWNER, TARGET_TYPE
/


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="brokentar"></A><h2>Broken targets.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE, t.TARGET_NAME, t.BROKEN_REASON, t.BROKEN_STR
from MGMT_TARGETS t
,    MGMT_TARGET_PROPERTIES p
where t.BROKEN_REASON!='0'
and   t.TARGET_GUID=p.TARGET_GUID
and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by p.PROPERTY_VALUE, t.BROKEN_REASON, t.BROKEN_STR
;


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="ownnotsysman"></A><h2>Targets not owned by SYSMAN or EMAAS_MG_TOW_USER.</h2>
set markup HTML ON ENTMAP ON

select t.OWNER, t.TARGET_NAME, t.TARGET_TYPE, p.PROPERTY_VALUE, t.LOAD_TIMESTAMP
from MGMT_TARGETS t
,    MGMT_TARGET_PROPERTIES p
where t.TARGET_GUID=p.TARGET_GUID
and   t.OWNER not in ('SYSMAN', 'EMAAS_MG_TOW_USER')
and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by OWNER, TARGET_NAME
/


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="newtargets"></A><h2>Newest targets (last load time: one month and newer).</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE, t.TARGET_TYPE, t.TARGET_NAME, to_char(t.LOAD_TIMESTAMP, 'DD-MON-YYYY HH24:MI:SS') LOAD_TIMESTAMP
from MGMT_TARGET_PROPERTIES p
, MGMT_TARGETS t
where t.TARGET_GUID=p.TARGET_GUID
and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
and   t.LOAD_TIMESTAMP>systimestamp-31
order by t.LOAD_TIMESTAMP desc 
/



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="asmtargets"></A><h2>ASM targets.</h2>
set markup HTML ON ENTMAP ON

select p1.PROPERTY_VALUE, p2.PROPERTY_VALUE, t.TARGET_NAME, t.TARGET_TYPE, t.DISPLAY_NAME, t.LOAD_TIMESTAMP
from  MGMT_TARGET_PROPERTIES p1
,     MGMT_TARGET_PROPERTIES p2
,     MGMT_TARGETS t
where t.TARGET_GUID=p1.TARGET_GUID
and   t.TARGET_GUID=p2.TARGET_GUID
and   p1.PROPERTY_NAME='orcl_gtp_line_of_bus'
and   p2.PROPERTY_NAME='orcl_gtp_location'
and   t.TARGET_NAME like '+ASM%'
order by p1.PROPERTY_VALUE, p2.PROPERTY_VALUE, t.TARGET_TYPE
/



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="alltargets"></A><h2>All targets.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE, t.TARGET_TYPE, t.TARGET_NAME, t.OWNER, t.BROKEN_REASON, t.LOAD_TIMESTAMP
from MGMT_TARGET_PROPERTIES p
, MGMT_TARGETS t
where t.TARGET_GUID=p.TARGET_GUID
and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by p.PROPERTY_VALUE, t.TARGET_TYPE
/




spool off

set markup HTML OFF ENTMAP OFF

set define &

@/tmp/your_sqlplus_env_&datetime..sql
