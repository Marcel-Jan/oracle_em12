------------------------------------------------------------------------------------------------------------------------------------------------------
--      Get a report on security in EM12c
--
--      Script      em12_security_report.sql
--      Run as      SYSMAN
--
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      0.1     Aug 15 2016 M. Krijgsman   First version, based on em12_incidents_report.sql
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
prompt =        em12_security_report.sql           =
prompt =                                           =
prompt =============================================
prompt


spool em12_security_&l_dbname._&datetime..html

prompt  <TITLE>Report on EM12 security in &l_dbname</TITLE>
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
prompt <h1>Security in EM12c</h1>
prompt <p>This file was created with:
prompt em12_security_report.sql
prompt version 0.1 (2016)
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
prompt 	<tr><th colspan="4">Security</th></tr>  
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#users">EM Users</a></td>  
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#roles">EM Roles</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#rolegrnt">Granted roles</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#privgrtrole">Privileges granted to roles</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#privgrtuser">Privileges granted to users</a></td>
prompt 	</tr>
prompt </table>
prompt </center>  
prompt 


set heading on
set markup HTML ON ENTMAP OFF


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="users"></A><h2>EM Users.</h2>
set markup HTML ON ENTMAP ON

col USER_NAME for a30
col USER_DESCRIPTION for a60

select USER_NAME, USER_DESCRIPTION 
from GC_USERS
order by USER_NAME
/



prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="roles"></A><h2>Roles.</h2>
set markup HTML ON ENTMAP ON

col ROLE_NAME for a30
col DESCRIPTION for a60

select * 
from SYSMAN.MGMT_ROLES
order by role_name
;


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="rolegrnt"></A><h2>Granted roles.</h2>
set markup HTML ON ENTMAP ON

col GRANTEE for a30

select * 
from MGMT_ROLE_GRANTS
order by GRANTEE
;


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="privgrtrole"></A><h2>Privileges to roles.</h2>
set markup HTML ON ENTMAP ON

col PRIV_NAME for a40
col APPLY_GRANT for a40

select *
from MGMT_PRIV_GRANTS
where GRANTEE_IS_ROLE=1
order by GRANTEE
/


prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="privgrtuser"></A><h2>Privileges to users.</h2>
set markup HTML ON ENTMAP ON

col PRIV_NAME for a40
col APPLY_GRANT for a40

select *
from MGMT_PRIV_GRANTS
where GRANTEE_IS_ROLE=0
order by GRANTEE
/



-- For future versions:
-- MGMT_USER_CACHE_OBJECTS - named credentials falling under users.
-- Misschien niet hier, maar vallen wel onder users: MGMT_USER_JOBS, MGMT_USER_REPORT_DEFS
-- EM_PRIV_DIRECT_INCLUDES
-- MGMT_AUDIT_LOGS, evt gekoppeld aan MGMT_USER_SESSION

spool off

set markup HTML OFF ENTMAP OFF

set define &

@/tmp/your_sqlplus_env_&datetime..sql
