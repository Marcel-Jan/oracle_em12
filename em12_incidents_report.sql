------------------------------------------------------------------------------------------------------------------------------------------------------
--      Get a report on incidents in EM12c
--
--      Script      em12_incidents_report.sql
--      Run as      SYSMAN
--
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     Aug 26 2015 M. Krijgsman   First version, based queries by Peter Hol
--      1.1     Sep 10 2015 M. Krijgsman   Extra reports for specific metrics and incidents
--      1.2     Sep 18 2015 M. Krijgsman   Totals per team added.
--      1.3     Sep 24 2015 M. Krijgsman   Types of incidents sorted on count and severity.
--      1.4     Nov 03 2015 M. Krijgsman   Line of Business columns added and list of criticals, warnings, suppressed
--      1.5     Dec 31 2015 M. Krijgsman   Added total counts of suppressed and acknowledged incidents and non-suppressed and acknowledged incidents.
--      1.6     Apr 25 2016 M. Krijgsman   Added incident count without resolved incidents
--      1.7     Jun 21 2016 M. Krijgsman   Added count unassigned incidents per team
--      1.8     Aug 02 2016 M. Krijgsman   Added info about targets down, unreachable or pending.
--      1.9     Sep 20 2016 M. Krijgsman   Added report about types of incidents that are suppressed.
--      1.10    Nov 09 2016 M. Krijgsman   Changed the Types of incidents report so that error numbers are shown.
--      1.11    Jan 05 2017 M. Krijgsman   Added list of suppressed per line of business
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
prompt =        em12_incidents_report.sql          =
prompt =                                           =
prompt =============================================
prompt


spool em12_incidents_&l_dbname._&datetime..html

prompt  <TITLE>Report on EM12 incidents in &l_dbname</TITLE>
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
prompt <h1>Incidents in EM12c</h1>
prompt <p>This file was created with:
prompt em12_incidents_report.sql
prompt version 1.11 (2017)
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
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#inccount">Count of incidents</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#inccountsar">Count of resolved. suppressed or acknowledged incidents</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#inccountnonsar">Count of non resolved/suppressed/acknowledged incidents</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#inccountteams">Count of incidents per team</a></td>
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#targcount">Count targets down, unreachable or pending/unknown.</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#targetsdown">Targets down</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#targetsunreach">Unreachable targets</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#targetspending">Targets that are pending/unknown</a></td>  
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incsupprlob">Suppressed incidents per line of business.</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incperlob">Count of incidents per Line of Business</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incnonsarperlob">Count of non resolved/suppressed/acknowledged incidents per Line of Business</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incpertarget">Count of incidents per target</a></td>  
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#critpertmlob">Criticals per team and line of business</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#warnpertmlob">Warnings per team and line of business</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#advpertmlob">Advisory incidents per team and line of business</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#clrpertmlob">Cleared incidents per team and line of business</a></td>
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#suppressed">Suppressed incidents per team and line of business</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#inc1day">Incidents that haven&rsquo;t been updated for one day</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incssev">Incidents and severities</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incsteam">Incidents and teams</a></td>  
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incssevxls">Types of incidents and severities (Easier to put in Excel)</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incsupp">Types of suppressed incidents per line of business</a></td>
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#jobsfailed">Job(s) failed incidents</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#jobsbroken">Job(s) broken incidents</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incstatsnotok">db_check_incremental_stats NOK incidents</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#recfileimpsized">Recovery File Destination improperly sized incidents</a></td>  
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#redoswitches">DB_REDOLOG_SWITCHES_PER_HOUR incidents</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#standbybehind">The standby database is behind incidents.</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#accessviol">An access violation has occurred incidents.</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#incall">All incidents</a></td>  
prompt 	</tr>
prompt </table>
prompt </center>  
prompt 


set heading on
set markup HTML ON ENTMAP OFF



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="inccount"></A><h2>Count of incidents.</h2>
set markup HTML ON ENTMAP ON

select sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	union
	select NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE>systimestamp-1
	union
	select NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE<systimestamp-93
);


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="targcount"></A><h2>Count of targets down, unreachable or pending.</h2>
set markup HTML ON ENTMAP ON

select decode(PROPERTY_VALUE, null, 'Unknown', PROPERTY_VALUE) "Line of Business", sum(targdown) "Targets down", sum(targunreach) "Targets unreachable"
     , sum(targpend) "Targets pending/Unknown", sum(metrerr) "Targets with metric errors"
from (
  select p.PROPERTY_VALUE , count(*) targdown, null targunreach, null targpend, null metrerr
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Target Down'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
	union
  select p.PROPERTY_VALUE, null targdown, count(*) targunreach, null targpend, null metrerr
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Unreachable'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
	union
  select p.PROPERTY_VALUE, null targdown, null targunreach, count(*) targpend, null metrerr
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Pending/Unknown'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, null targdown, null targunreach, null targpend, count(*) metrerr
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Metric Error'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
)
group by PROPERTY_VALUE
order by "Line of Business";


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="targetsdown"></A><h2>Targets down.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE "Line of Business", a.TARGET_NAME, a.TARGET_TYPE, a.TYPE_DISPLAY_NAME
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Target Down'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	order by "Line of Business";


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="targetsunreach"></A><h2>Targets unreachable.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE "Line of Business", a.TARGET_NAME, a.TARGET_TYPE, a.TYPE_DISPLAY_NAME
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Unreachable'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	order by "Line of Business";




prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="targetspending"></A><h2>Targets pending.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE "Line of Business", a.TARGET_NAME, a.TARGET_TYPE, a.TYPE_DISPLAY_NAME
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Pending/Unknown'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	order by "Line of Business";


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="targetsmetric"></A><h2>Targets with metric errors.</h2>
set markup HTML ON ENTMAP ON

select p.PROPERTY_VALUE "Line of Business", a.TARGET_NAME, a.TARGET_TYPE, a.TYPE_DISPLAY_NAME
	from MGMT$AVAILABILITY_CURRENT a, MGMT_TARGET_PROPERTIES p
	where a.AVAILABILITY_STATUS = 'Metric Error'
	and   a.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	order by "Line of Business";


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="inccountsar"></A><h2>Count of suppressed, acknowledged or resolved incidents.</h2>
set markup HTML ON ENTMAP ON

select 'Resolved' status, sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	union
	select NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	and LAST_UPDATED_DATE>systimestamp-1
	union
	select NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	and LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	and LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	and LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	and LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE='Resolved'
	and LAST_UPDATED_DATE<systimestamp-93
)
UNION
select 'Suppressed' status, sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
  and   IS_SUPPRESSED=1
	union
	select NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE>systimestamp-1
  and   IS_SUPPRESSED=1
	union
	select NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
  and   IS_SUPPRESSED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
  and   IS_SUPPRESSED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
  and   IS_SUPPRESSED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
  and   IS_SUPPRESSED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE<systimestamp-93
  and   IS_SUPPRESSED=1
)
UNION
select 'Aknowledged' status, sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
  and   IS_ACKNOWLEDGED=1
	union
	select NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE>systimestamp-1
  and   IS_ACKNOWLEDGED=1
	union
	select NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
  and   IS_ACKNOWLEDGED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
  and   IS_ACKNOWLEDGED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
  and   IS_ACKNOWLEDGED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
  and   IS_ACKNOWLEDGED=1
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and   LAST_UPDATED_DATE<systimestamp-93
  and   IS_ACKNOWLEDGED=1
);




prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="inccountnonsar"></A><h2>Count of incidents (non suppressed, non acknowledged, non resolved).</h2>
set markup HTML ON ENTMAP ON

select sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
	union
	select NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
	and LAST_UPDATED_DATE>systimestamp-1
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
	union
	select NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
	and   LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
	and   LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
	and   LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
	and   LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
	union
	select NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and  RESOLUTION_STATE<>'Resolved'
	and   LAST_UPDATED_DATE<systimestamp-93
  and   IS_SUPPRESSED=0
  and   IS_ACKNOWLEDGED=0
);



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="inccountteams"></A><h2>Count of incidents per team.</h2>
set markup HTML ON ENTMAP ON

COLUMN DUMMY NOPRINT;
COMPUTE SUM OF "Total of Incidents" ON DUMMY;
BREAK ON DUMMY;

select NULL DUMMY, OWNER, sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select OWNER, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	group by OWNER
	union
	select OWNER, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE>systimestamp-1
	group by OWNER
	union
	select OWNER, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	group by OWNER
	union
	select OWNER, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	group by OWNER
	union
	select OWNER, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	group by OWNER
	union
	select OWNER, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	group by OWNER
	union
	select OWNER, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS 
	where RESOLUTION_STATE<>'Closed'
	and LAST_UPDATED_DATE<systimestamp-93
  group by OWNER
)
group by OWNER
order by OWNER;


CLEAR BREAKS
CLEAR COMPUTES






prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incperlob"></A><h2>Incidents per line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	group by p.PROPERTY_VALUE
)
group by PROPERTY_VALUE
order by PROPERTY_VALUE;



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incnonsarperlob"></A><h2>Non resolved/suppressed/acknowledged incidents per line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	group by p.PROPERTY_VALUE
)
group by PROPERTY_VALUE
order by PROPERTY_VALUE;



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incsupprlob"></A><h2>Suppressed incidents per line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=1
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	group by p.PROPERTY_VALUE
)
group by PROPERTY_VALUE
order by PROPERTY_VALUE;





prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incpertmlob"></A><h2>Incidents per team and line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, OWNER, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select i.OWNER, p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	group by i.OWNER, p.PROPERTY_VALUE
)
group by OWNER, PROPERTY_VALUE
order by OWNER, PROPERTY_VALUE;


CLEAR BREAKS
CLEAR COMPUTES


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="critpertmlob"></A><h2>Critical incidents per team and line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, OWNER, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select i.OWNER, p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.SEVERITY='Critical'
	group by i.OWNER, p.PROPERTY_VALUE
)
group by OWNER, PROPERTY_VALUE
order by OWNER, PROPERTY_VALUE;


CLEAR BREAKS
CLEAR COMPUTES



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="opencritperlob"></A><h2>Open critical incidents per line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.SEVERITY='Critical'
	group by p.PROPERTY_VALUE
)
group by PROPERTY_VALUE
order by PROPERTY_VALUE;


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="warnpertmlob"></A><h2>Warning incidents per team and line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, OWNER, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select i.OWNER, p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.SEVERITY='Warning'
	group by i.OWNER, p.PROPERTY_VALUE
)
group by OWNER, PROPERTY_VALUE
order by OWNER, PROPERTY_VALUE;


CLEAR BREAKS
CLEAR COMPUTES


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="warnpertmlob"></A><h2>Open warning incidents per line of business.</h2>
set markup HTML ON ENTMAP ON

select NULL DUMMY, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
	union
	select p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT$TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.RESOLUTION_STATE<>'Resolved'
	and   i.IS_SUPPRESSED=0
  and   i.IS_ACKNOWLEDGED=0
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.SEVERITY='Warning'
	group by p.PROPERTY_VALUE
)
group by PROPERTY_VALUE
order by PROPERTY_VALUE;




prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="advpertmlob"></A><h2>Advisory incidents per team and line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, OWNER, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select i.OWNER, p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.SEVERITY='Advisory'
	group by i.OWNER, p.PROPERTY_VALUE
)
group by OWNER, PROPERTY_VALUE
order by OWNER, PROPERTY_VALUE;


CLEAR BREAKS
CLEAR COMPUTES



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="clrpertmlob"></A><h2>Cleared incidents per team and line of business.</h2>
set markup HTML ON ENTMAP ON


select NULL DUMMY, OWNER, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select i.OWNER, p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.SEVERITY='Clear'
	group by i.OWNER, p.PROPERTY_VALUE
)
group by OWNER, PROPERTY_VALUE
order by OWNER, PROPERTY_VALUE;


CLEAR BREAKS
CLEAR COMPUTES




prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="suppressed"></A><h2>Suppressed incidents per team and line of business.</h2>
set markup HTML ON ENTMAP ON

select NULL DUMMY, OWNER, PROPERTY_VALUE "Line of Business", sum(Total_incidents) "Total of Incidents", sum(Incidents_today) "Incidents today", sum(Incidents_1day_old) "One day old"
     , sum(Incidents_3day_old) "Three days old", sum(Incidents_7days_old) "Week old"
     , sum(Incidents_31days_old) "Month old", sum(Incidents_3months_old) "3 Months old"
from (
	select i.OWNER, p.PROPERTY_VALUE, count(*) Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, count(*) Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE>systimestamp-1
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, count(*) Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-3 and systimestamp-1
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, count(*) Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-7 and systimestamp-3
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, count(*) Incidents_7days_old, NULL Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-31 and systimestamp-7
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, count(*) Incidents_31days_old, NULL Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE between systimestamp-93 and systimestamp-31
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
	union
	select i.OWNER, p.PROPERTY_VALUE, NULL Total_incidents, NULL Incidents_today, NULL Incidents_1day_old, NULL Incidents_3day_old, NULL Incidents_7days_old, NULL Incidents_31days_old, count(*) Incidents_3months_old
	from MGMT$INCIDENTS i, MGMT_TARGET_PROPERTIES p
	where i.RESOLUTION_STATE<>'Closed'
	and   i.TARGET_GUID=p.TARGET_GUID
	and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
	and   i.LAST_UPDATED_DATE<systimestamp-93
	and   i.IS_SUPPRESSED=1
	group by i.OWNER, p.PROPERTY_VALUE
)
group by OWNER, PROPERTY_VALUE
order by OWNER, PROPERTY_VALUE;


CLEAR BREAKS
CLEAR COMPUTES



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incpertarget"></A><h2>Incidents per target.</h2>
set markup HTML ON ENTMAP ON

select TARGET_NAME, Total_incidents
from (
	select t.TARGET_NAME TARGET_NAME, count(i.INCIDENT_ID) Total_incidents
		from MGMT$INCIDENTS i, MGMT$TARGET t
		where i.RESOLUTION_STATE<>'Closed'
		and i.TARGET_GUID=t.TARGET_GUID	
		group by t.TARGET_NAME
    )
where Total_incidents>2
order by Total_incidents desc
/



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incperday"></A><h2>Incidents per day.</h2>
set markup HTML ON ENTMAP ON

select to_char(LAST_UPDATED_DATE, 'YYYYMMDD') DATUM, count_per_day "Incidents per day"
from (
	select trunc(LAST_UPDATED_DATE) LAST_UPDATED_DATE, count(*) count_per_day
	from MGMT$INCIDENTS
	where RESOLUTION_STATE<>'Closed'
	and IS_SUPPRESSED=0
	group by trunc(LAST_UPDATED_DATE)
	)
order by to_char(LAST_UPDATED_DATE, 'YYYYMMDD') desc
;


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="inc1day"></A><h2>Incidents that haven't been updated for one day.</h2>
-- '
set markup HTML ON ENTMAP ON

col SEVERITY for a8
col "Line of Business" for a30
col PRIORITY for a8
col OWNER for a20
select inc.OWNER, prop.PROPERTY_VALUE "Line of Business", inc.SEVERITY, PRIORITY,count(*) 
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop
where inc.RESOLUTION_STATE<>'Closed' 
and inc.LAST_UPDATED_DATE<systimestamp-1
and   inc.TARGET_GUID=prop.TARGET_GUID
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
group by inc.OWNER, prop.PROPERTY_VALUE, inc.SEVERITY, inc.PRIORITY 
order by 1,2,3,4;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incssev"></A><h2>Types of incidents and severities.</h2>
set markup HTML ON ENTMAP ON



set lines 1500
col SEVERITY for a8
col SUMMARY_MSG for a100
col TARGET_NAME for a39
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
col "Incident Message (short)" for a100


select 
  case 
  when sevnr=1 then 'Critical'
  when sevnr=2 then 'Warning'
  when sevnr=3 then 'Advisory'
  end severity
, inc_msg "Incident Message (short)", inc_count
from (
	select case  
         when i.SEVERITY='Critical' THEN 1
         when i.SEVERITY='Warning' THEN 2
         when i.SEVERITY='Advisory' THEN 3
         end sevnr
	, substr(i.SUMMARY_MSG,1,20)||REGEXP_REPLACE(substr(i.SUMMARY_MSG,21,70), '[0-9]', '*') inc_msg, count(*) inc_count
	from MGMT$INCIDENTS i, MGMT$TARGET t
	where i.TARGET_GUID=t.TARGET_GUID
	and i.RESOLUTION_STATE<>'Closed' 
	group by i.SEVERITY, substr(i.SUMMARY_MSG,1,20)||REGEXP_REPLACE(substr(i.SUMMARY_MSG,21,70), '[0-9]', '*')
	   )
order by sevnr, inc_count desc
;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incssevxls"></A><h2>Types of incidents and severities (Easier to put in Excel).</h2>
set markup HTML ON ENTMAP ON


select 
  case 
  when sevnr=1 then 'Critical'
  when sevnr=2 then 'Warning'
  end severity
, inc_msg "Incident Message (short)"
, inc_count
from (
	select case  
         when i.SEVERITY='Critical' THEN 1
         when i.SEVERITY='Warning' THEN 2
         end sevnr
	, substr(i.SUMMARY_MSG,1,20)||REGEXP_REPLACE(substr(i.SUMMARY_MSG,21,40), '[0-9]', '*') inc_msg, count(*) inc_count
	from MGMT$INCIDENTS i, MGMT$TARGET t
	where i.TARGET_GUID=t.TARGET_GUID
	and i.RESOLUTION_STATE<>'Closed'
	and i.SEVERITY<>'Advisory'
	group by i.SEVERITY, substr(i.SUMMARY_MSG,1,20)||REGEXP_REPLACE(substr(i.SUMMARY_MSG,21,40), '[0-9]', '*')
	   )
where inc_count>5
order by "Incident Message (short)" asc
/






prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incsupp"></A><h2>Types of suppressed incidents per Line of Business.</h2>
set markup HTML ON ENTMAP ON


select p.PROPERTY_VALUE "Line of Business",
       substr(i.SUMMARY_MSG,1,60) inc_msg, 
       count(*) inc_count
from MGMT_TARGET_PROPERTIES p, MGMT$INCIDENTS i
where i.TARGET_GUID=p.TARGET_GUID
and   i.IS_SUPPRESSED=1
and   p.PROPERTY_NAME='orcl_gtp_line_of_bus'
group by p.PROPERTY_VALUE, substr(i.SUMMARY_MSG,1,60)
order by p.PROPERTY_VALUE, inc_count desc 
/

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="jobsfailed"></A><h2>Job(s) failed incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE, 
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like '%job(s) have failed%'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;



prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="jobsbroken"></A><h2>job(s) are broken incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE,
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like '%job(s) are broken.'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incstatsnotok"></A><h2>The value of db_check_incremental_stats is NOK incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE,
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like 'The value of db_check_incremental_stats is NOK%'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="recfileimpsized"></A><h2>Recovery File Destination improperly sized incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE,
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like 'Recovery File Destination of database%'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;




prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="redoswitches"></A><h2>The value of DB_REDOLOG_SWITCHES_PER_HOUR incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE,
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like 'The value of DB_REDOLOG_SWITCHES_PER_HOUR%'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="standbybehind"></A><h2>The standby database is behind incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE,
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like 'The standby database is approximately%'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;



prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="accessviol"></A><h2>Access violation incidents.</h2>
set markup HTML ON ENTMAP ON


set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a50
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10
select tgt.TARGET_NAME, prop.PROPERTY_VALUE "Line of Business", inc.SUMMARY_MSG, inc.PRIORITY, inc.RESOLUTION_STATE,
       to_char(inc.LAST_UPDATED_DATE, 'DD-MM-YYYY') LAST_UPDATED_DATE, inc.OWNER
       ,DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED"
       ,DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
       ,inc.INCIDENT_NUM
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   inc.SUMMARY_MSG like 'An access violation detected in%'
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by tgt.TARGET_NAME;



prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incsteam"></A><h2>Types of incidents per team.</h2>
set markup HTML ON ENTMAP ON


select i.OWNER, substr(i.SUMMARY_MSG,1,60) "Incident Message (short)", count(*)
from MGMT$INCIDENTS i, MGMT$TARGET t
where i.TARGET_GUID=t.TARGET_GUID
and i.RESOLUTION_STATE<>'Closed' 
group by i.OWNER, substr(i.SUMMARY_MSG,1,60)
order by i.OWNER, substr(i.SUMMARY_MSG,1,60);


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="incall"></A><h2>All incidents.</h2>
set markup HTML ON ENTMAP ON

set lines 400
col SEVERITY for a8
col SUMMARY_MSG for a150
col TARGET_NAME for a60
col PRIORITY for a8
col RESOLUTION_STATE for a16
col OWNER for a20
col ACKNOWLEDGED for a12
col ESCALATED for a9
col SUPPRESSED for a10

select inc.SEVERITY, inc.INCIDENT_NUM "INCIDENT", inc.SUMMARY_MSG, tgt.TARGET_NAME, inc.PRIORITY, inc.RESOLUTION_STATE, inc.LAST_UPDATED_DATE, inc.OWNER, 
       prop.PROPERTY_VALUE "Line of Business",
       DECODE(inc.IS_ACKNOWLEDGED,
              0, 'No',
              1, 'Yes') "ACKNOWLEDGED",
       DECODE(inc.IS_ESCALATED,
              0, 'No',
              1, 'Yes') "ESCALATED",
       DECODE(inc.IS_SUPPRESSED,
              0, 'No',
              1, 'Yes') "SUPPRESSED"
from MGMT$INCIDENTS inc, MGMT_TARGET_PROPERTIES prop, MGMT$TARGET tgt
where inc.TARGET_GUID=tgt.TARGET_GUID
and   inc.TARGET_GUID=prop.TARGET_GUID
and   inc.RESOLUTION_STATE<>'Closed' 
and   prop.PROPERTY_NAME='orcl_gtp_line_of_bus'
order by inc.INCIDENT_NUM desc;


spool off

set markup HTML OFF ENTMAP OFF

set define &

@/tmp/your_sqlplus_env_&datetime..sql
