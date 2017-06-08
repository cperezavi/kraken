REM
REM ======================================================================
REM hcheck8i.sql	Version 2.00	      Tue Mar  1 11:13:40 CET 2011
REM
REM Purpose:
REM	To provide a single package which looks for common data dictionary
REM	problems. 
REM 	Note that this version has not been checked with locally managed
REM 	tablespaces and may give spurious output if these are in use.
REM 	This script is for use mainly under the guidance of Oracle Support.
REM 
REM Usage:
REM 	set serverout on
REM 	execute hcheck.full;
REM 
REM 	Output is to the hOut package to allow output to be redirected
REM 	as required
REM   
REM     See <Note:101466.1> for details of using this and other h* packages
REM
REM Depends on:
REM	hOut 
REM
REM Notes:
REM 	Must be installed in SYS schema
REM	This package is intended for use in Oracle 8.1 through 11.1
REM      This package will NOT work in 8.0 or earlier.
REM     In all cases any output reporting "problems" should be 
REM      passed by an experienced Oracle Support analyst to confirm
REM      if any action is required.
REM
REM CAUTION
REM   The sample program in this article is provided for educational 
REM   purposes only and is NOT supported by Oracle Support Services.  
REM   It has been tested internally, however, and works as documented.  
REM   We do not guarantee that it will work for you, so be sure to test 
REM   it in your environment before relying on it.
REM 
REM ======================================================================
REM

create or replace package hcheck as
  procedure Full;
end hcheck;
/
show errors
create or replace package body hcheck as
 --
  Ver	VARCHAR2(10)  := '8i-11/2.00';
  Warn  NUMBER  :=0;
  Fatal NUMBER  :=0;
 --
  Function Owner( uid number ) return varchar2 is
    r varchar2(30):=null;
  begin
    select name into r from user$ where user#=uid;
    return(r);
  exception
    when no_data_found then
	return('*UnknownOwnerID='||uid||'*');
  end;
 --
  Function ObjName( objid number ) return varchar2 is
    r varchar2(40):=null;
    own number;
  begin
    select name , owner# into r,own from obj$ where obj#=objid;
    return(owner(own)||'.'||r);
  exception
    when no_data_found then
	return('*UnknownObjID='||objid||'*');
  end;
 --
  procedure OversizedFiles is
   Cursor cBigFile is
        select f.ts# TS, f.relfile# RFILE, f.file# AFILE, v.name NAME, f.blocks
          from ts$ ts, file$ f, v$datafile v
         where ts.ts#                = f.ts#
           and v.file#               = f.file#
           and f.blocks              > 4194303
           and bitand(ts.flags,256) != 256
         order by f.ts#, f.relfile#
        ;
   tag varchar2(80):=chr(10)||
     'Problem: Oversized File - See Note:107591.1 (Bug:568232 , Bug:925105)';
  begin
   For R in cBigFile
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OVERSIZED FILE ('||r.blocks||' blocks) TS='||R.TS||
			' RFILE='||r.RFILE||
			' ABS='||r.AFILE||' Name='||r.NAME);
     Fatal:=Fatal+1;
   End Loop;
  end;
 --
  function ObjectIsTemporary( o number ) return boolean 
  -- Return TRUE if object is a TEMPORARY object
  -- Return NULL if object does not exist
  -- Return FALSE if object is not temporary
  is
    Cursor cIsTemp is
	select bitand(nvl(flags,0), 2) IsTemp from obj$ where obj#=o
    ;
    ret boolean:=NULL;
  begin
    FOR R in cIsTemp LOOP -- For loop just to keep cursor closed
      if R.IsTemp=2 then ret:=TRUE; else ret:=FALSE; end if;
    END LOOP;
    return RET;
  end;
 --
  procedure OrphanedIndex is
  noTable EXCEPTION ;
  PRAGMA EXCEPTION_INIT(noTable, -942) ;
--
   Cursor cOrphanInd is
        select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
          from seg$ s, ind$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
           -- and not (i.file#=0 and i.block#=0) /* Covered by IF in loop */
           and bitand(i.flags,4096)!=4096  /* Exclude NOSEGMENT index */
           and nvl(s.type#,0)!=6
        ;
--
  def_obj    number   := 0 ;
  def_count  number   := 0 ;
  def_exists number   := 1 ;
  sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
  sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
--
   tag varchar2(80):=chr(10)||
    'Problem: Orphaned IND$ (no SEG$) - See Note:65987.1 (Bug:624613/3655873)';
   ind_flags number ;
  Begin
  Begin
--
    Execute Immediate sqlstr Into def_count ;
    Exception
      When noTable Then
        def_exists := 0 ;
    End ;
--
   For R in cOrphanInd
   Loop
     Begin
       if (ObjectIsTemporary(R.obj#)) then
          null; -- This is ok 
       else
         select o.flags
           into ind_flags
           from obj$ o
           where obj#=R.bo# ;
         if (ind_flags != 2) /* 0x02 -> Global Temp */
         then
           if (def_exists = 0) then
             if (tag is not null) then hout.put_line(tag); tag:=null; end if;
             hout.put_line(' ORPHAN IND$: OBJ='||R.obj#||
                            ' DOBJ='||r.dataobj#||
                            ' TS='||r.TS#||
                            ' RFILE/BLOCK='||r.file#||' '||r.block#||
                            ' BO#='||r.bo#||' SegType='||R.type#);
               if (r.TS#=0 and r.file#=0 and r.block#=0) then
                 hout.put_line(' ^- May be OK. Needs manual check');
               end if ;
             Fatal:=Fatal+1;
           else
              Begin
                Execute Immediate sqlstr1 Into def_obj Using R.obj# ;
              Exception
                When NO_DATA_FOUND Then
                  if (tag is not null) then hout.put_line(tag); tag:=null; end if;
                    hout.put_line(' ORPHAN IND$: OBJ='||R.obj#||
                                   ' DOBJ='||r.dataobj#||
                                   ' TS='||r.TS#||
                                   ' RFILE/BLOCK='||r.file#||' '||r.block#||
                                   ' BO#='||r.bo#||' SegType='||R.type#);
                      if (r.TS#=0 and r.file#=0 and r.block#=0) then
                        hout.put_line(' ^- May be OK. Needs manual check');
                      end if ;
                    Fatal:=Fatal+1;
             End ;
           end if;
         end if;
       end if;
       Exception
         When NO_DATA_FOUND
         then
           hout.put_line(' ORPHAN IND$: OBJ='||R.obj#||
                            ' DOBJ='||r.dataobj#||
                            ' TS='||r.TS#||
                            ' RFILE/BLOCK='||r.file#||' '||r.block#||
                            ' BO#='||r.bo#||' SegType='||R.type#);
           if (r.TS#=0 and r.file#=0 and r.block#=0)
           then
             hout.put_line(' ^- May be OK. Needs manual check');
           end if;
           Fatal:=Fatal+1;
     End ;
   End Loop;
  End;
 --
  function IndexIsNosegment( o number ) return boolean is
   Cursor cX is
	select bitand(flags,4096) noseg from ind$ where obj#=o;
   ret boolean:=null;
  begin
   For C in cX 
   loop
     if C.noseg=4096 then
	ret:=true;
     else
	ret:=false;
     end if;
   end loop;
   return ret;	/* true/false or NULL if not found */
  end;
 --
  procedure OrphanedUndo is
   Cursor cOrphanUndo is
--
     select u.us#            u_us,
            u.name           u_name,
            u.ts#            u_ts,
	    nvl(s.ts#,0)     s_ts,
	    u.file#          u_file,
	    nvl(s.file#,0)   s_file,
	    u.block#         u_block,
	    nvl(s.block#,0)  s_block,
	    u.status$        u_status,
            nvl(s.type#,0)   s_type
     from   undo$            u,
            seg$             s
     where  u.ts#           = s.ts#    (+)
     and    u.file#         = s.file#  (+)
     and    u.block#        = s.block# (+)
     and    u.status$       > 1 
     and    nvl(s.type#,0) != 1
     ;

   tag varchar2(80):=chr(10)||'Problem: Orphaned Undo$ (no SEG$) - See '||
                     'Note:270386.1';

  begin
   For R in cOrphanUndo
   Loop
     If ((R.s_ts    != R.u_ts)   Or
         (R.s_file  != R.u_file) Or
	 (R.s_block != R.u_block))
     Then
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;

       hout.put_line(' ORPHAN UNDO$: US#='||R.u_us||
			' NAME='||R.u_name||
			' RFILE/BLOCK='||R.u_file||' '||R.u_block||
			' STATUS$='||R.u_status);
       Fatal:=Fatal+1;
     End if ;
   End Loop;
  End;
 --
  procedure OrphanedIndexPartition is
--
  noTable EXCEPTION ;
  PRAGMA EXCEPTION_INIT(noTable, -942) ;
--
  def_obj    number   := 0 ;
  def_count  number   := 0 ;
  def_exists number   := 1 ;
--
   Cursor cOrphanInd is
	select i.obj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
          from seg$ s, indpart$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
	   and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
           and nvl(s.type#,0)!=6
        ;
   sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
   sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned Index Partition (no SEG$) - '||
     'See Note:65987.1 (Bug:624613)';
   noseg boolean:=null;
  begin
    Begin
--
    Execute Immediate sqlstr Into def_count ;
    Exception
      When noTable Then
        def_exists := 0 ;
    End ;
--
   For R in cOrphanInd
   Loop
     noseg:=IndexIsNosegment(R.bo#);
     if (def_exists = 0) then
       begin
           if (tag is not null) then hout.put_line(tag); tag:=null; end if;
           hout.put_line(' ORPHAN INDPART$: OBJ='||R.obj#||
			    ' TS='||r.TS#||
			    ' RFILE/BLOCK='||r.file#||' '||r.block#||
			    ' BO#='||r.bo#||' SegType='||R.type#);
           Fatal:=Fatal+1;
       end ;
     else
     if (noseg is null OR noseg = false) then
       begin
         execute immediate sqlstr1 into def_obj Using R.obj# ;
         exception when NO_DATA_FOUND then
           if (tag is not null) then hout.put_line(tag); tag:=null; end if;
           hout.put_line(' ORPHAN INDPART$: OBJ='||R.obj#||
			    ' TS='||r.TS#||
			    ' RFILE/BLOCK='||r.file#||' '||r.block#||
			    ' BO#='||r.bo#||' SegType='||R.type#);
           Fatal:=Fatal+1;
       end ;
     end if;
     end if;
     if noseg is null then
       hout.put_line(' ^- INDPART$ . BO# has no IND$ entry ??');
     end if;
   End Loop;
  End;
 --
  procedure OrphanedIndexSubPartition is
  noTable EXCEPTION ;
  PRAGMA EXCEPTION_INIT(noTable, -942) ;
--
  def_obj    number   := 0 ;
  def_count  number   := 0 ;
  def_exists number   := 1 ;
--
   Cursor cOrphanInd is
    select i.obj#, i.ts#, i.file#, i.block#, i.pobj#, s.type#
          from seg$ s, indsubpart$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
       and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
           and nvl(s.type#,0)!=6
        ;
   sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
   sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned Index SubPartition (no SEG$) - '||
     'See xxxxx';
  Begin
    Begin
      Execute Immediate sqlstr Into def_count ;
      Exception
        When noTable Then
          def_exists := 0 ;
    End ;
--
    For R in cOrphanInd Loop
      Begin
        if (def_exists = 0) then
          if (tag is not null) then hout.put_line(tag); tag:=null; end if;
		  --
          hout.put_line(' ORPHAN INDSUBPART$: OBJ='||R.obj#||
                    ' TS='||r.TS#||
                    ' RFILE/BLOCK='||r.file#||' '||r.block#||
                    ' POBJ#='||r.pobj#||' SegType='||R.type#);
          -- Fatal:=Fatal+1;
        else
		  Begin
            execute immediate sqlstr1 into def_obj Using R.obj# ;
            exception when NO_DATA_FOUND then
              if (tag is not null) then hout.put_line(tag); tag:=null; end if;
                hout.put_line(' ORPHAN INDSUBPART$: OBJ='||R.obj#||
                    ' TS='||r.TS#||
                    ' RFILE/BLOCK='||r.file#||' '||r.block#||
                    ' POBJ#='||r.pobj#||' SegType='||R.type#);
                -- Fatal:=Fatal+1;
          End ;
        End if ;
      End ;
    End Loop;
  End ;
--
  procedure OrphanedTable is
--
  noTable EXCEPTION ;
  PRAGMA EXCEPTION_INIT(noTable, -942) ;
--
  def_obj    number   := 0 ;
  def_count  number   := 0 ;
  def_exists number   := 1 ;
--
  Cursor cOrphanTab is
        select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bobj#, s.type#,
                bitand(i.property,64) iot
          from seg$ s, tab$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
           /* and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
           and nvl(s.type#,0)!=5
           and bitand(i.property,64)!=64 /*(So that we exclude iot's) */
        ;
  sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
  sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;

  tag varchar2(80):=chr(10)||
    'Problem: Orphaned TAB$ (no SEG$)';
--
--
  Begin
--
-- 11gR2 introduces Deferred Segment Creation feature.
-- need to check against sys.deferred_stg$ before reporting segment failure.
--
    Begin
--
    Execute Immediate sqlstr Into def_count ;
    Exception
      When noTable Then
        def_exists := 0 ;
    End ;
--
    For R in cOrphanTab
    Loop
      if (ObjectIsTemporary(R.obj#)) then
        null; -- This is ok
      else
        if (r.iot=64 and r.dataobj#=0 and r.ts#=0 and r.file#=0 and r.block#=0)
        then
          null; -- this is a truncated IOT - see 4701060
        else
          if (def_exists = 0) then
            if (tag is not null) then hout.put_line(tag); tag:=null; end if;
            hout.put_line(' ORPHAN TAB$: OBJ='||R.obj#||
                          ' DOBJ='||r.dataobj#||
                          ' TS='||r.TS#||
                          ' RFILE/BLOCK='||r.file#||' '||r.block#||
                          ' BOBJ#='||r.bobj#||' SegType='||R.type#);
            if (r.TS#=0 and r.file#=0 and r.block#=0) then
              hout.put_line(' ^- May be OK. Needs manual check');
            end if;
            Fatal:=Fatal+1;
          else
            Begin
              Execute Immediate sqlstr1 Into def_obj Using R.obj# ;
            Exception
              When NO_DATA_FOUND Then
                if (tag is not null) then hout.put_line(tag); tag:=null; end if;
                hout.put_line(' ORPHAN TAB$: OBJ='||R.obj#||
                              ' DOBJ='||r.dataobj#||
                              ' TS='||r.TS#||
                              ' RFILE/BLOCK='||r.file#||' '||r.block#||
                              ' BOBJ#='||r.bobj#||' SegType='||R.type#);
                if (r.TS#=0 and r.file#=0 and r.block#=0) then
                  hout.put_line(' ^- May be OK. Needs manual check');
                end if;
                Fatal:=Fatal+1;
            End ;
--
          end if;
        end if;
      end if;
    End Loop;
  End;
 --
  procedure OrphanedTablePartition is
  noTable EXCEPTION ;
  PRAGMA EXCEPTION_INIT(noTable, -942) ;
--
   def_obj    number   := 0 ;
   def_count  number   := 0 ;
   def_exists number   := 1 ;
--
   Cursor cOrphanTabPart is
        select i.obj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
          from seg$ s, tabpart$ i, tab$ t
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
           and i.bo# = t.obj#
           and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
           and nvl(s.type#,0)!=5
           and bitand(t.property,64)!=64 /*(So that we exclude iot's) */
        ;
   sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
   sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned Table Partition (no SEG$) - (Cause unknown)';
  begin
    Begin
--
    Execute Immediate sqlstr Into def_count ;
    Exception
      When noTable Then
        def_exists := 0 ;
    End ;
--
   For R in cOrphanTabPart
   Loop
   begin
   if (def_exists = 0) then
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' ORPHAN TABPART$: OBJ='||R.obj#||
					 ' TS='||r.TS#||
					 ' RFILE/BLOCK='||r.file#||' '||r.block#||
					 ' BO#='||r.bo#||' SegType='||R.type#);
       if (r.TS#=0 and r.file#=0 and r.block#=0) then
         hout.put_line(' ^- May be OK. Needs manual check');
       end if;
       Fatal:=Fatal+1;
   else
     begin
     Execute Immediate sqlstr1 Into def_obj Using R.obj# ;
     Exception
       When NO_DATA_FOUND Then
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' ORPHAN TABPART$: OBJ='||R.obj#||
					 ' TS='||r.TS#||
					 ' RFILE/BLOCK='||r.file#||' '||r.block#||
					 ' BO#='||r.bo#||' SegType='||R.type#);
       if (r.TS#=0 and r.file#=0 and r.block#=0) then
         hout.put_line(' ^- May be OK. Needs manual check');
       end if;
       Fatal:=Fatal+1;
    end;
   end if ;
   end ;
   End Loop;
  End;
 --
  procedure OrphanedTableSubPartition is
  noTable EXCEPTION ;
  PRAGMA EXCEPTION_INIT(noTable, -942) ;
--
  def_obj    number   := 0 ;
  def_count  number   := 0 ;
  def_exists number   := 1 ;
--
   Cursor cOrphanTabSubPart is
        select tsp.obj#, tsp.ts#, tsp.file#, tsp.block#, tsp.pobj#, s.type#
          from obj$ o, tabcompart$ tcp, tabsubpart$ tsp, seg$ s
         where o.obj#     = tcp.obj#
           and tcp.obj#   = tsp.pobj#
           and tsp.ts#    = s.ts#     (+)
           and tsp.file#  = s.file#   (+)
           and tsp.block# = s.block#  (+)
           and s.file# is null
        ;
   sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
   sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned Table SubPartition (no SEG$) - (Cause unknown)';
  begin
    Begin
--
    Execute Immediate sqlstr Into def_count ;
    Exception
      When noTable Then
        def_exists := 0 ;
    End ;
--
   For R in cOrphanTabSubPart
   Loop
   begin
     if (def_exists = 0) then
         if (tag is not null) then hout.put_line(tag); tag:=null; end if;
         hout.put_line(' ORPHAN TABSUBPART$: OBJ='||R.obj#||
			    ' TS='||r.TS#||
			    ' RFILE/BLOCK='||r.file#||' '||r.block#||
			    ' POBJ#='||r.pobj#||' SegType='||R.type#);
         Fatal:=Fatal+1;
     else
       begin
       execute immediate sqlstr1 Into def_obj Using R.obj# ;
       Exception
         When NO_DATA_FOUND Then
           if (tag is not null) then hout.put_line(tag); tag:=null; end if;
           hout.put_line(' ORPHAN TABSUBPART$: OBJ='||R.obj#||
			      ' TS='||r.TS#||
			      ' RFILE/BLOCK='||r.file#||' '||r.block#||
			      ' POBJ#='||r.pobj#||' SegType='||R.type#);
           Fatal:=Fatal+1;
       end ;
     end if ;
   end ;
   End Loop;
  End;
 --
  procedure OrphanedTabComPart is
   Cursor cOrphanTCP is
	select t.obj# , t.bo#, b.name, p.name pname, p.subname, b.owner#
          from tabcompart$ t, obj$ b, obj$ p
         where b.obj#(+)=t.bo# 
           and p.obj#(+)=t.obj# and p.obj#+b.obj# is null
        ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned TabComPart$ from OBJ$ - (see Bug:1528062)';
  begin
   For R in cOrphanTCP
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' ORPHAN TABCOMPART$: OBJ='||R.obj#||
			' OBJ#Name='||r.subname||' ('||r.pname||')'||
			' BO#='||R.bo#||
			' BO#name='||Owner(R.owner#)||'.'||R.name);
     Fatal:=Fatal+1;
   End Loop;
  End;
 --
  procedure ZeroTabSubPart is
   Cursor cZero is
	select sp.obj#, sp.ts#, sp.pobj#, b.name, b.subname, b.owner#
          from indsubpart$ sp, obj$ b
         where sp.file#=0 and sp.block#=0
      	   and b.obj#(+)=sp.pobj#
        ;
   tag varchar2(80):=chr(10)||
     'Problem: IndSubPart$ has File#=0'||
     '(see Bug:1614155 if also Orphan SEG$)';
  begin
   For R in cZero
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' ORPHAN INDSUBPART$: OBJ#='||R.obj#||
			' POBJ#='||R.pobj#||
			' Index='||Owner(R.Owner#)||'.'||R.name||
			' Partn='||R.subname);
     Fatal:=Fatal+1;
   End Loop;
  End;
 --
  procedure MissingPartCol is
-- Drop table will return:
-- ORA-00600: internal error code, arguments: [kkpodDictPcol1], [1403], [0]
   Cursor cOrphanColObj is
        select tp.bo#, tp.obj#, tp.ts#, tp.file#, tp.block#, o.type#
          from tabpart$ tp, partcol$ pc, obj$ o
         where tp.bo# = pc.obj# (+)
           and tp.obj# = o.obj#
           and pc.obj# is null
        ;
   tag varchar2(80):=chr(10)||
     'Problem: Missing TabPart Column (no PARTCOL$ info)';
  begin
   For R in cOrphanColObj
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' MISSING PARTCOL$: OBJ='||R.bo#||
                   ' DOBJ='||R.obj#||
                   ' TS='||R.ts#||
                   ' RFILE/BLOCK='||R.file#||' '||R.block#||
                   ' SegType='||R.type#);
     Fatal:=Fatal+1;
   End Loop;
  End;
 --
  procedure OrphanedSeg$ is
   Cursor cOrphanSeg is
	select 'TYPE2 UNDO' typ, s.ts#, s.file#, s.block#
          from seg$ s, undo$ u
         where s.ts#=u.ts#(+)
           and s.file#=u.file#(+)
           and s.block#=u.block#(+)
           and s.type#=10
	   -- and u.file# is null
	   and decode(u.status$,1,null,u.status$) is null
	UNION ALL
	select 'UNDO' typ, s.ts#, s.file#, s.block#
          from seg$ s, undo$ i
         where s.ts#=i.ts#(+)
           and s.file#=i.file#(+)
           and s.block#=i.block#(+)
           and s.type#=1
	   -- and i.file# is null
	   and decode(i.status$,1,null,i.status$) is null
	UNION ALL
	select 'DATA' typ, s.ts#, s.file#, s.block#
          from seg$ s, 
		(select a.ts#,a.file#,a.block# from tab$ a
		 union all 
		 select b.ts#,b.file#,b.block# from clu$ b
		 union all 
		 select c.ts#,c.file#,c.block# from tabpart$ c
		 union all 
		 select d.ts#,d.file#,d.block# from tabsubpart$ d
		) i
         where s.ts#=i.ts#(+)
           and s.file#=i.file#(+)
           and s.block#=i.block#(+)
           and s.type#=5
	   and i.file# is null
	UNION ALL
	select 'INDEX' typ, s.ts#, s.file#, s.block#
          from seg$ s, 
		(select a.ts#,a.file#,a.block# from ind$ a
		 union all 
		 select b.ts#,b.file#,b.block# from indpart$ b
		 union all 
		 select d.ts#,d.file#,d.block# from indsubpart$ d
		) i
         where s.ts#=i.ts#(+)
           and s.file#=i.file#(+)
           and s.block#=i.block#(+)
           and s.type#=6
	   and i.file# is null
	UNION ALL
        select 'LOB' typ, s.ts#, s.file#, s.block#
          from seg$ s, lob$ i --, sys_objects so
         where s.ts#=i.ts#(+)
           and s.file#=i.file#(+)
           and s.block#=i.block#(+)
           and s.type#=8
           and i.file# is null
        ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned SEG$ Entry';
   so_type number ;
  begin
    For R in cOrphanSeg
    Loop
      If (R.typ = 'LOB')
      then
        Begin
          select so.object_type_id into so_type
            from sys_objects so
           where so.ts_number    = R.ts#
             and so.header_file  = R.file#
             and so.header_block = R.block# ;
          if ( so_type not in (40, 41) )      /* Object Found */
          then
            if (tag is not null) then hout.put_line(tag); tag:=null; end if;
            hout.put_line(' ORPHAN SEG$: SegType='||R.typ||
	 		  ' TS='||r.TS#||
	 		  ' RFILE/BLOCK='||r.file#||' '||r.block#);
            Fatal:=Fatal+1;
          End If ;
        Exception
          When NO_DATA_FOUND                 /* Object *Not Found */
          then 
            if (tag is not null) then hout.put_line(tag); tag:=null; end if;
            hout.put_line(' ORPHAN SEG$: SegType='||R.typ||
	 		  ' TS='||r.TS#||
	 		  ' RFILE/BLOCK='||r.file#||' '||r.block#);
            Fatal:=Fatal+1;
        End ;
      End If ;
    End Loop;
  End;
 --
  procedure DictAt( ts number, fi number, bl number ) is
   Cursor cDictAt is
     select typ, ts#,file#,block#,count('x') CNT
      from (
	select 'UNDO$' typ, u.ts#, u.file#, u.block# from undo$ u
         where decode(u.status$,1,null,u.status$) is null
	UNION ALL
	select 'TAB$', a.ts#,a.file#,a.block# from tab$ a
	UNION ALL
	select 'CLU$', b.ts#,b.file#,b.block# from clu$ b
	UNION ALL
	select 'TABPART$', c.ts#,c.file#,c.block# from tabpart$ c
	UNION ALL
	select 'TABSUBPART$', d.ts#,d.file#,d.block# from tabsubpart$ d
	UNION ALL
	select 'IND$', a.ts#,a.file#,a.block# from ind$ a
	UNION ALL
	select 'INDPART$', b.ts#,b.file#,b.block# from indpart$ b
	UNION ALL
	select 'INDSUBPART$', d.ts#,d.file#,d.block# from indsubpart$ d
	UNION ALL
	select 'LOB$' , i.ts#, i.file#, i.block# from lob$ i
	UNION ALL
	select 'LOBFRAG$' , i.ts#, i.file#, i.block# from lobfrag$ i
--	UNION ALL
--	select 'RECYCLEBIN$' , i.ts#, i.file#, i.block# from recyclebin$ i
       ) 
       where ts#= TS and file# = FI and block#= BL
       group by typ, ts#,file#,block#
      ;
  begin
   For R in cDictAt
   Loop
     hout.put_line('^  '||R.typ||' has '||R.cnt||' rows');
   End Loop;
  End;
 --
  procedure DuplicateBlockUse is
   Cursor cDuplicateBlock is
     select ts#,file#,block#,count('x') CNT, min(typ) mintyp
      from (
	select 'UNDO$' typ, u.ts#, u.file#, u.block# from undo$ u
         where decode(u.status$,1,null,u.status$) is null
	UNION ALL
	select 'TAB$', a.ts#,a.file#,a.block# from tab$ a
	UNION ALL
	select 'CLU$', b.ts#,b.file#,b.block# from clu$ b
	UNION ALL
	select 'TABPART$', c.ts#,c.file#,c.block# from tabpart$ c
	UNION ALL
	select 'TABSUBPART$', d.ts#,d.file#,d.block# from tabsubpart$ d
	UNION ALL
	select 'IND$', a.ts#,a.file#,a.block# from ind$ a
	UNION ALL
	select 'INDPART$', b.ts#,b.file#,b.block# from indpart$ b
	UNION ALL
	select 'INDSUBPART$', d.ts#,d.file#,d.block# from indsubpart$ d
	UNION ALL
	select 'LOB$' , i.ts#, i.file#, i.block# from lob$ i
	UNION ALL
	select 'LOBFRAG$' , i.ts#, i.file#, i.block# from lobfrag$ i
--	UNION ALL
--	select 'RECYCLEBIN$' , i.ts#, i.file#, i.block# from recyclebin$ i
       ) 
       where block#!=0 
       group by ts#,file#,block#
       having count('x') > 1
	  and min(typ)!='CLU$' 	/* CLUSTER can have multiple entries */
      ;
   tag varchar2(80):=chr(10)||
     'Problem: Block has multiple dictionary entries';
  begin
   For R in cDuplicateBlock
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' MULTI DICT REF: TS='||r.TS#||
			' RFILE/BLOCK='||r.file#||' '||r.block#||
			' cnt='||R.cnt);
     DictAt(R.ts#, R.file#, R.block#);
     Fatal:=Fatal+1;
   End Loop;
  End;
 --
  procedure OrphanedIndPartObj# is
   Cursor cOrphanInd is
	select i.obj#, i.ts#, i.file#, i.block#, i.bo#
          from obj$ o, indpart$ i
         where o.obj#(+)=i.obj# and o.obj# is null
        ;
   tag varchar2(80):=chr(10)||
     'Problem: Orphaned Index Partition Obj# (no OBJ$) - '||
     'See Bug:5040222';
   noseg boolean:=null;
  begin
   For R in cOrphanInd
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' ORPHAN INDPART$: OBJ#='||R.obj#||' - no OBJ$ row');
     Fatal:=Fatal+1;
   End Loop;
  End;
 --
  procedure TruncatedCluster is
   Cursor cBadCluster is
   	select /*+ ORDERED */ 
		t.obj#, u.name owner, o.name, t.dataobj# td, c.dataobj# cd
	  from clu$ c, tab$ t, obj$ o, user$ u
	 where t.ts# = c.ts#
	   and   t.file# = c.file#
	   and   t.block# = c.block#
	   and   t.dataobj# != c.dataobj#
	   and   t.obj# = o. obj#
	   and   o.owner# = u.user#
   ;
   tag varchar2(80):=chr(10)||
     'Problem: Clustered Tables with bad DATAOBJ# - '||
     'See Note:109134.1 (Bug:1283521)';
  begin
   For R in cBadCluster
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' Bad TAB$ entry: TAB OBJ='||R.obj#||
			' NAME='||r.owner||'.'||r.name||
			' Tab DOBJ='||r.td||' != '||r.cd
     );
     Fatal:=Fatal+1;
   End Loop;
  End;
 --
  procedure HighObjectIds is
   Cursor cHighObject is
	select max(obj#) maxobj, max(dataobj#) maxdobj from obj$
   ;
   tag varchar2(80):=chr(10)||
     'Problem: High Objects IDS exist - See Note:76746.1 (Bug:970640)';
  begin
   For R in cHighObject
   Loop
     if (r.maxobj>2000000000) or (r.maxdobj>2000000000) then
       hout.put_line(tag); 
       hout.put_line(' HIGH OBJECT NUMBERS EXIST: max(OBJ)='||r.maxobj||
			' max(dataobj#)='||r.maxdobj);
       Fatal:=Fatal+1;
     end if;
   End Loop;
  End;
 --
  procedure PQsequence is
   Cursor cPQ is
	SELECT max_value, cycle_flag, last_number
          FROM DBA_SEQUENCES
         WHERE sequence_owner='SYS' and sequence_name='ORA_TQ_BASE$'
   ;
   tag varchar2(80):=chr(10)||
     'Problem: PQ Sequence needs fixing - See Note:66450.1 (Bug:725220)';
  begin
   For R in cPQ
   Loop
     if (R.cycle_flag!='Y' and R.last_number>1000000) then
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' ORA_TQ_BASE$ is not CYCLIC - '||
			To_char(R.max_value-R.last_number)||' values left');
       Fatal:=Fatal+1;
     end if;
   End Loop;
  End;
 --
  procedure PoorDefaultStorage is
   Cursor cPoorStorage is
	select * from dba_tablespaces
	 where (initial_extent<1024*1024 or contents='TEMPORARY')
	   and next_extent<65536 
	   and min_extlen<65536 
	   and pct_increase<5 
	   and max_extents>3000
	;
   tag varchar2(80):=chr(10)||
		'Warning: Poor Default Storage Clauses (see Note:50380.1)';
  begin
   For R in cPoorStorage
   Loop
     if (tag is not null) then 
	hout.put_line(tag); tag:=null; 
	hout.put_line('  '||rpad('Tablespace',30)||rpad('Init',10)||
		rpad('Next',10)||rpad('Min',10)||rpad('Pct',4)||
		'MaxExtents'
	); tag:=null; 
     end if;
     hout.put_line('  '||rpad(R.tablespace_name,30)
			||rpad(r.initial_extent,10)
			||rpad(r.next_extent,10)
			||rpad(r.min_extlen,10)
			||rpad(r.pct_increase,4)
			||r.max_extents );
     Warn:=Warn+1;
   End Loop;
  End;
 --
  procedure PoorStorage is
   Cursor cPoorStorage is
	select * from dba_segments
	 where (initial_extent<65535
	   and next_extent<65536 
	   and pct_increase<5 
	   and max_extents>3000
	   and extents>500)
	  or extents>3000
	;
   tag varchar2(80):=chr(10)||
	'Warning: Poor Storage Clauses (see Note:50380.1)';
  begin
   For R in cPoorStorage
   Loop
     if (tag is not null) then 
	hout.put_line(tag); 
	tag:=null; 
	hout.put_line('  '||rpad('Segment',50)||rpad('Next',10)||
		rpad('Exts',7)||rpad('Pct',4)||
		'MaxExtents'
	);
     end if;
     hout.put_line('  '||
	rpad(R.segment_type||' '||R.owner||'.'||R.segment_name,50)
			||rpad(r.next_extent,10)
			||rpad(r.extents,7)
			||rpad(r.pct_increase,4)
			||r.max_extents );
     Warn:=Warn+1;
   End Loop;
  End;
 --
  procedure FetUet(ts number, fil number, len number) is
   Cursor cMap(ts number,fil number) is
     select block#,length,'FET$' typ 
	 from fet$ where ts#=TS and file#=FIL
      UNION ALL
     select block#,length,'UET$' typ 
	 from uet$ where ts#=TS and file#=FIL
     order by 1
   ;
   BlkExpected number;
   prev cMap%Rowtype;
   tag varchar2(80):=chr(10)||
     'Problem: Fet/Uet corruption in TS#='||TS||' RFile='||FIL;
  begin
   BlkExpected:=2;
   For R in cMap(TS,FIL)
   Loop
     if (R.block#!=BlkExpected) then 
        if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       	if R.block#<BlkExpected then
          hout.put_line(' OVERLAP: TS#='||TS||' RFILE='||FIL||
			' ('||prev.typ||' '||prev.block#||' '||prev.length||
			') overlaps ('||
			R.typ||' '||R.block#||' '||R.length||')');
	else
           hout.put_line(' GAP:     TS#='||TS||' RFILE='||FIL||
			' ('||prev.typ||' '||prev.block#||' '||prev.length||
			') gap-to ('||
			R.typ||' '||R.block#||' '||R.length||')');
	end if;
        Fatal:=Fatal+1;
     end if;
     prev:=R;
     BlkExpected:=R.block#+R.length;
   End Loop;
   -- hout.put_line(' Check expect='||BlkExpected||' len='||len);
   if ( BlkExpected-1!=len ) then
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     if (BlkExpected-1>len) then
        hout.put_line(' EXTENT past end of file: TS#='||TS||' RFILE='||FIL||
		' ('||prev.typ||' '||prev.block#||' '||prev.length||
		') goes past end of file ('||len||' blocks)');
     else
        hout.put_line(' EXTENT too short: TS#='||TS||' RFILE='||FIL||
		' ('||prev.typ||' '||prev.block#||' '||prev.length||
		') does not reach end of file ('||len||' blocks)');
     end if;
     Fatal:=Fatal+1;
   end if;
  End;
 --
  procedure FetUet(ts number) is
   Cursor cFiles(ts number) is
	select relfile#,blocks from file$ 
	 where ts#=TS and status$!=1 	/*!=invalid*/
   ;
  begin
   For R in cFiles(ts)
   Loop
     FetUet(TS,R.relfile#,R.blocks);
   End Loop;
  End;
 --
 -- Each first extent should have SEGFILE,BLOCK = FILE,BLOCK
 --
  procedure Uet0Check is
   Cursor cUet0OK is  
     Select * from uet$
      where ext# = 0
        and (file# != segfile# or block# != segblock# )
   ;
   tag varchar2(80):=chr(10)||
     'Problem: Uet extent 0 corrupt';
  begin
   For R in cUet0OK 
   Loop
        hout.put_line(' EXTENT 0 not at start of segment: TS#='||R.TS#||
			' '||R.segfile#||','||R.segblock#||' != '||
			R.file#||','||R.block#);
   	Fatal:=Fatal+1;
   End Loop;
  end;
 --
  procedure ExtentlessSeg is
   Cursor cExtentlessSeg is  
       select s.* from seg$ s, uet$ u
	where s.ts#=u.ts#(+)
	  and s.file#=u.segfile#(+)
	  and s.block#=u.segblock#(+)
	  and bitand(NVL(s.spare1,0), 1) = 0 /* Not locally managed */
	  and u.ext#(+)=0
	  and u.ts# IS NULL 		     /* no UET$ entry */
	 order by s.ts#,s.file#,s.block#
	;
   tag varchar2(80):=chr(10)||
     'Problem:  SEG$ entry has no UET$ entries (Dictionary managed)';
   sawType9 boolean:=FALSE;
  begin
   For R in cExtentlessSeg 
   Loop
        hout.put_line(' SEG$ has no UET$ entry: TS#='||R.TS#||' RFILE#='||
			R.file#||' BLK#='||R.block#||' TYPE#='||r.type#);
	if (r.type#=9) then
	  sawType9:=TRUE;
	end if;
   	Fatal:=Fatal+1;
   End Loop;
   if SawType9 then
        hout.put_line(' NB: TYPE#=9 is special and may be OK' );
   end if;
  end;
 --
  procedure SeglessUET is
   Cursor cSeglessUET is  
       select u.ts#, u.segfile#, u.segblock#, count('x') cnt, min(ext#) minext#
	 from seg$ s, uet$ u
	where s.ts#(+)=u.ts#
	  and s.file#(+)=u.segfile#
	  and s.block#(+)=u.segblock#
	  and s.ts# IS NULL 		     /* no SEG$ entry */
	 group by u.ts#,u.segfile#,u.segblock#
	;
   tag varchar2(80):=chr(10)||
     'Problem:  UET$ entry has no SEG$ entries (Dictionary managed)';
  begin
   For R in cSeglessUET 
   Loop
        hout.put_line(' UET$ has no SEG$ entry: TS#='||R.TS#||' SegFILE#='||
			R.segfile#||' SegBLK#='||R.segblock#||' Count='||
			r.cnt||' MinExt#='||R.minext#);
   	Fatal:=Fatal+1;
   End Loop;
  end;
 --
  procedure FetUet is
   Cursor cTS is
	select ts# from ts$ 
	 where online$!=3 	/* !=Invalid*/
	   and bitmapped=0	/* dictionary managed */
   ;
  begin
   For R in cTS
   Loop
     FetUet(R.TS#);
   End Loop;
  End;
 --
  procedure BadInd$ is
   Cursor cBadInd is
       select o.obj# OBJ#, u.name OWNER, o.name NAME 
         from user$ u, obj$ o, ind$ i
	where u.user#=o.owner#
	  and o.type#=1 /* INDEX */
	  and o.obj#=i.obj#(+)
	  and i.obj# is null;
   tag varchar2(80):=chr(10)||
     'Problem:  OBJ$ INDEX entry has no IND$ entry';
  begin
   For R in cBadInd
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     if (R.name='I_OBJAUTH1') then
	tag:=' (Possibly Bug:273956)';
     end if;
     hout.put_line(' INDEX has no IND$ entry: Obj='||R.obj#||' '||
			R.owner||'.'||R.name||tag);
     tag:=null; 
     Fatal:=Fatal+1;
   End Loop; 
  end;
 --
  procedure BadTab$ is
   Cursor cBadTab is
       select o.obj# OBJ#, u.name OWNER, o.name NAME 
         from user$ u, obj$ o, tab$ i
	where u.user#=o.owner#
	  and o.type#=2 /* TABLE */
	  and o.linkname is null
	  and o.obj#=i.obj#(+)
	  and i.obj# is null;
   tag varchar2(80):=chr(10)||
     'Problem:  OBJ$ TABLE entry has no TAB$ entry';
  begin
   For R in cBadTab
   Loop
     if (R.name!='DR$DBO') then
      if (tag is not null) then hout.put_line(tag); tag:=null; end if;
      hout.put_line(' TABLE has no TAB$ entry: Obj='||R.obj#||' '||
			R.owner||'.'||R.name);
     end if;
     Fatal:=Fatal+1;
   End Loop; 
  end;
 --
  procedure OnlineRebuild$ is
   Cursor cBadInd is
       select o.obj# OBJ#, u.name OWNER, o.name NAME, o.dataobj# O_ID,
		i.dataobj# I_ID 
         from user$ u, obj$ o, ind$ i
	where u.user#=o.owner#
	  and o.type#=1 /* INDEX */
	  and o.obj#=i.obj#
   	  and o.dataobj# != i.dataobj#
   ;
   tag varchar2(80):=chr(10)||
     'Problem:  OBJ$.DATAOBJ# != IND.DATAOBJ# (See Note:125149.1)';
  begin
   For R in cBadInd
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' '||R.owner||'.'||R.name||' OBJ$.DATAOBJ#='||R.o_id||
			'IND$.DATAOBJ#='||R.i_id);
     Fatal:=Fatal+1;
   End Loop; 
  end;
 --
  procedure bug1584155 is
   Cursor cbug1584155 is 
	 select u.name owner, o.name name , a.name attr
	  from user$ u, obj$ o, type$ t, attribute$ a, type$ att
	  where u.user#=o.owner#
	  and o.oid$ = t.toid
	  and o.type# <> 10 -- must not be invalid
	  and bitand(t.properties, 2048) = 0 -- not system-generated
	  and t.toid = a.toid
	  and t.version# = a.version#
	  and a.attr_toid = att.toid(+)
	  and a.attr_version# = att.version#(+)
	  and att.toid is null
	;
   tag varchar2(80):=chr(10)||
     'Problem:  Bad ATTRIBUTE$.ATTR_TOID entries Bug:1584155';
  begin
   For R in cbug1584155
   Loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' '||R.owner||'.'||R.name||' ATTR_NAME='||R.attr);
     Fatal:=Fatal+1;
   End Loop;
  end;
 -- 
  Function IsLastPartition( o number ) return boolean is
    n number;
  begin
    select partcnt into n from partobj$ where obj#=o;
    if n>1 then return(false); else return(true); end if;
  end;
 --
  procedure bug1360714_Composite is
   Cursor cbadtab is 
	select o.obj# part_obj#, 
	  	o.owner#, o.name, o.subname, p.subpartcnt, p.bo# table_obj#
	   from obj$ o, tabcompart$ p 
	   where o.type#=19		/* PARTITION */
	     and o.obj#=p.obj#		/* Has subpartitions */
	     and p.subpartcnt=0 	/* Has No entries in tabsubpart$ */
   ;
   Cursor cbadidx is
	  select o.obj# part_obj#, 
	  	o.owner#, o.name, o.subname, p.subpartcnt, p.bo# index_obj#
	   from obj$ o, indcompart$ p 
	   where o.type#=20		/* INDEX PARTITION */
	     and o.obj#=p.obj#		/* Has subpartitions */
	     and p.subpartcnt=0 	/* Has No entries in indsubpart$ */
   ;
   tag varchar2(80):=chr(10)||
     'Problem:  Missing TABSUBPART$ entry/s - possibly Bug:1360714';
   showmsg boolean:=false;
  Begin
   for R in Cbadtab
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' TABLE '||Owner(R.owner#)||'.'||R.name||
		   ' Partition '||R.subname||
		   ' PartObj#='||r.part_obj#||' TabObj#='||R.table_obj#);
     if IsLastPartition( R.table_obj# ) then
     	hout.put_line(' ^^ PARTOBJ$.PARTCNT<=1 - non standard corruption');
     end if;
     Fatal:=Fatal+1;
   end loop;
   for I in Cbadidx
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' INDEX '||Owner(I.owner#)||'.'||I.name||
		   ' Partition '||I.subname||
		   ' PartObj#='||I.part_obj#||' IndObj#='||I.index_obj#);
     if IsLastPartition( I.index_obj# ) then
     	hout.put_line(' ^^ PARTOBJ$.PARTCNT<=1 - non standard corruption');
     end if;
     Fatal:=Fatal+1;
     showmsg:=true;
   end loop;
   if showmsg then
     hout.put_line('There are probably orphaned SEG$ entry/s with this');
   end if;
  End;
--
  procedure bug7509714_Composite is
   Cursor cPartSubpart is
     select po.obj# obj#, u.name owner, o.name name, decode(o.type#, 1, 'INDEX', 'TABLE') type,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST',
       'UNKNOWN') part,
       decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3, 'SYSTEM', 4,
       'LIST', 'UNKNOWN') subpart
     from   partobj$ po, obj$ o, user$ u
     where  po.obj#    = o.obj#
     and    o.owner#   = u.user#
     and    po.spare2 != 0
     and    o.type#    = 1 -- Index
     and    decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST',
       'UNKNOWN') != decode(mod(po.spare2, 256), 0, 'NONE', 2, 'HASH', 3,
       'SYSTEM', 4, 'LIST', 'UNKNOWN') ;
   tag varchar2(80):=chr(10)||
     'Warning:  TABPART/TABSUBPART method mismatch - may hit Bug:7509714';
  Begin
   for R in cPartSubpart
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(
       rpad(' INDEX '||R.owner||'.'||R.name,62,' ') ||
       ' (OBJ '||R.obj#||')'
     ) ;
     Warn:=Warn+1 ;
   End Loop ;
  End ;
 --
  procedure bug1362374_trigger is
   Cursor ctrig is 
	select count('x') cnt from trigger$ 
	 where sys_evts IS NULL
	    or nttrigcol IS NULL
	 having count('x') > 0;
   tag varchar2(80):=chr(10)||
     'Problem:  NULL SYS_EVTS/NTTRIGCOL - Bug:1362374 / Note:131528.1';
  Begin
   for R in CTrig
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' TRIGGER$ has '||R.cnt||' NULL entries');
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure TinyFiles is
   Cursor ctiny is 
	select file#, ts#, blocks from file$
	 where status$=2 and blocks<=1;
   tag varchar2(80):=chr(10)||
     'Problem:  Tiny File size in FILE$ - Bug:1646512 ?';
  Begin
   for R in CTiny
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' FILE$ FILE#='||R.file#||' has BLOCKS='||R.blocks);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure bug1365707_badobj is
   Cursor cBad is 
	select obj#, type#, name from obj$
	 where type#=0 and name!='_NEXT_OBJECT';
   tag varchar2(80):=chr(10)||
     'Problem:  Bad OBJ$ entry with TYPE#=0 - see Bug:1365707';
  Begin
   for R in CBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ$ OBJ#='||R.OBJ#||' TYPE#=0 NAME='||R.name);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure bug1842429_badview is
   Cursor cBad is 
	select o.obj#, owner#, name from obj$ o, view$ v
	 where o.type#=4 
	   and o.oid$ is not null
	   and v.obj#=o.obj#
           and bitand(v.property,1)=0
   ;
   tag varchar2(80):=chr(10)||
     'Problem:  OBJ$.OID$ set for a VIEW - see Note:157540.1 / Bug:1842429';
  Begin
   for R in CBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ$ OBJ#='||R.OBJ#||' Owner='||Owner(R.owner#)||
		    ' NAME='||R.name);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure TabPartCountMismatch is
   Cursor cPartObj is 
	select o.obj#, o.owner#, o.name, 
		t.property, p.partcnt, bitand(p.spare2,255) comp
	  from obj$ o, tab$ t, partobj$ p
	 where o.type#=2 		/* table */
	   and o.dataobj# is null 
	   and o.obj#=t.obj#
	   and bitand(t.property,32)=32	/* partitioned table */
	   and o.obj#=p.obj#(+)
   ;
   tag varchar2(80):=chr(10)||'Problem:  OBJ$-PARTOBJ$-<TABPART$ mismatch';
   cnt number;
  Begin
   for R in cPartObj
   loop
-- no partitions
     if R.partcnt is null then
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' OBJ$ has no PARTOBJ$ OBJ#='||R.OBJ#||' NAME='||R.name);
       Fatal:=Fatal+1;
     else 
       if (R.comp=0 /*not composite*/) then
         select count('x') into cnt from tabpart$ where bo#=R.obj#;
-- partcnt = 1048575 for interval partitioning tables
         if ( R.partcnt != cnt and R.partcnt != 1048575 ) then
           if (tag is not null) then hout.put_line(tag); tag:=null; end if;
           hout.put_line(' PARTOBJ$ PARTCNT!=num TABPART$ rows OBJ#='||R.OBJ#||
		' NAME='||R.name||' PARTCNT='||R.partcnt||' CNT='||cnt);
           Fatal:=Fatal+1;
         end if;
	 -- Check OBJ$ for the tabpart$ rows match up
	 for Pobj in (select o.obj#,o.name,o.subname,o.type# , o.owner#
			from obj$ o, tabpart$ p
		       where o.obj#=p.obj#
			 and p.bo#=R.obj#)
	 loop
           if Pobj.name!=R.name 
		OR Pobj.type#!=19 
		OR Pobj.owner#!=R.owner# 
	   then
             if (tag is not null) then hout.put_line(tag); tag:=null; end if;
             hout.put_line(
		' TABPART$-OBJ$ mismatch (Bug:1273906)'||
		' OBJ#='||Pobj.obj#||
		' #'||Pobj.owner#||'.'||Pobj.name||' '||Pobj.subname);
             if Pobj.name!=R.name then
               hout.put_line(
		'  - Table Name ('||R.name||') != '||
		' Partition Name ('||Pobj.name||')' );
	     end if ;
             if Pobj.owner#!=R.owner# then
               hout.put_line(
		'  - Table Owner# ('||R.owner#||') != '||
		' Partition Onwer# ('||Pobj.owner#||')' );
	     end if ;
             if Pobj.type#!=19 then
               hout.put_line(
		'  - Partition Type# ('||Pobj.type#||')!=19' );
	     end if ;
             Fatal:=Fatal+1;
           end if;
	 end loop;
       elsif (R.comp=2 /*hash composite*/) then
         select count('x') into cnt from tabcompart$ where bo#=R.obj#;
	     if ( R.partcnt != cnt and R.partcnt != 1048575 ) then
--       if R.partcnt!=cnt then
           if (tag is not null) then hout.put_line(tag); tag:=null; end if;
           hout.put_line(' PARTOBJ$ PARTCNT!=num TABCOMPART$ rows OBJ#='||
		R.OBJ#||
		' NAME='||R.name||' PARTCNT='||R.partcnt||' CNT='||cnt);
           Fatal:=Fatal+1;
         end if;
       end if;
     end if;
   end loop;
  End;
 --
  procedure MissingSum$ is
   Cursor cBad is
	select t.obj#,o.owner#,o.name
          from tab$ t, obj$ o, sum$ s
         where bitand(t.flags,262144)=262144 	/* Container table */
   	   and o.obj#=t.obj#
           and s.containerobj#(+)=t.obj#
	   and s.containerobj# is null
	;
   tag varchar2(80):=chr(10)||
	'Problem:  SUM$ entry missing for container table';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' TAB$ OBJ#='||R.OBJ#||' '||Owner(R.owner#)||'.'||R.name);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure MissingDir$ is
   Cursor cBad is
        select o.obj# o_obj, o.owner# o_owner, o.name o_name, d.obj# d_obj,
               oa.grantee# oa_grantee, oa.privilege# oa_priv, u.name u_name
        from   obj$ o, dir$ d, objauth$ oa, user$ u
        where  o.obj# = d.obj# (+)
        and    o.obj# = oa.obj# (+)
        and    o.owner# = u.user#
        and    o.type# = 23
        and    d.obj# is null ;
   tag varchar2(80):=chr(10)||
	'Problem:  DIR$ entry missing for Directory Objects';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ$ OBJ#='||R.o_obj||' Owner='||R.u_name||'.'||
       R.o_name||' - Grantee('||R.oa_grantee||') - Priv ('||
       R.oa_priv||')');
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure BadSegFreelist is
   Cursor cBad is
	select ts#,file#,block#,type#,lists,groups
	  from seg$
         where lists=1 or groups=1;
   tag varchar2(80):=chr(10)||
	'Problem:  SEG$ bad LISTS/GROUPS (==1) - See Tar:2470806.1';
   tag2 varchar2(80):=
	'May be Ok for LOBSEGMENT/SECUREFILE in release 11gR1+' ;
-- select SEGMENT_TYPE, SEGMENT_SUBTYPE
-- from   sys_dba_segs
-- where  tablespace_id = R.TS#
-- and    header_file   = R.RFILE#
-- and    header_block  = R.BLK# ;
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     if (tag2 is not null) then hout.put_line(tag2); tag2:=null; end if;
     hout.put_line(' Bad SEG$ lists/groups : TS#='||R.TS#||' RFILE#='||
			R.file#||' BLK#='||R.block#||' TYPE#='||r.type#||
			' Lists='||R.lists||' Groups='||R.groups);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure Bug1805146DroppedFuncIdx is
    Cursor cBad is
      select distinct u.name owner, o.name tab 
        from user$ u, obj$ o, col$ c
      where o.type#=2
        and c.col#=0
        and bitand(32768,c.property)=32768
        and o.obj#=c.obj#
        and u.user#=o.owner#
        and u.user#!=0;
   tag varchar2(80):=chr(10)||
	'Problem:  Table with Dropped Func Index '|| 
	' - Bug:1805146 / Note:148740.1';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' Table='||R.owner||'.'||R.tab);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure BadPublicObjects is
   Cursor cPub is
	select obj#,name,type# from obj$ 
         where owner#=1 and type# not in (5,10);
   tag varchar2(80):=chr(10)||
	'Problem:  Objects owned by PUBLIC - Bug:1762570';
  Begin
   for R in cPub
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ$ OBJ#='||R.OBJ#||' TYPE='||R.type#||' NAME='||R.name);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure Bug1375026Seq is
   Cursor cSeq is
	 select increment$ from seq$ s , obj$ o
	  where o.name='IDGEN1$' and owner#=0
	    and s.obj#=o.obj#
	    and increment$>50;
   tag varchar2(80):=chr(10)||
	'Problem:  Sequence IDGEN1$ INCREMENT_BY too high - Bug:1375026';
  Begin
   for R in cSeq
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure Bug1359472BadOwner is
   Cursor cBad is
	select obj#, type#, owner#, name from obj$ 
	 where owner# not in (select user# from user$) 
	   and type# != 10; 
   tag varchar2(80):=chr(10)||
	'Problem:  OBJ$.OWNER# not in USER$ - See Note:333181.1 (Bug:1359472)';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ$ OBJ#='||R.OBJ#||' TYPE='||R.type#||' NAME='||R.name
		||' Owner#='||R.OWNER#);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure Bug6310840audit is
   Cursor cBad is
        select decode(aud.user#,
                      0, 'ANY CLIENT',
                      client.name)     username ,
               proxy.name              proxyname,
               prv.name                privilege,
               decode(aud.success,
                      1, 'BY SESSION',
                      2, 'BY ACCESS' ,
                      'NOT SET')       success  ,
               decode(aud.failure,
                      1, 'BY SESSION',
                      2, 'BY ACCESS' ,
                      'NOT SET')       failure
          from sys.user$               client   ,
               sys.user$               proxy    ,
               system_privilege_map    prv      ,
               sys.audit$              aud
         where aud.option# = -prv.privilege
           and aud.user#   = client.user#
           and aud.user#  != 1               /* PUBLIC */
           and aud.proxy#  = proxy.user# (+)
           and aud.proxy# is null
   ;
   tag varchar2(80):=chr(10)||
	'Problem:  INV/CORR audit$ entry - Note:455565.1 (Bug 6351123 / Bug 6310840)';
   variant varchar2(30) ;
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     if (R.username = 'ANY CLIENT')
     then
       variant := 'Corrupted -' ;
     else
       variant := 'Invalid   -' ;
     end if;
     hout.put_line(variant||' USER#='''||R.username||''' OPTION='''||
                   R.privilege||''' SUCCESS='''||R.success||''' FAILURE='''||
                   R.failure||'''');
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure Bug2371453synonym is
   Cursor cBad is
     select distinct o.obj#, o.owner#, o.name 
       from obj$ o , idl_ub1$ i
      where type#=5
        and ctime!=mtime
        and i.obj#=o.obj#	/* Has IDL information */
     ;
   tag varchar2(80):=chr(10)||
	'Warning:  Synonym LAST_DDL_TIME!=CREATED - May hit Bug:2371453';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ#='||R.OBJ#||' Name='||Owner(R.owner#)||'.'||R.name);
     Warn:=Warn+1;
   end loop;
  End;
 --
  procedure ObjSynMissing is
   Cursor cBad is
     select o.obj#, o.owner#, o.name 
       from obj$ o , syn$ s
      where o.type#=5
        and o.obj#=s.obj#(+)	
	and o.linkname is null /* Not a remote object */
	and s.obj# is null
     ;
   tag varchar2(80):=chr(10)||
	'Warning:  SYN$ entry missing for OBJ$ type#=5';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ#='||R.OBJ#||' Name='||Owner(R.owner#)||'.'||R.name);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure CheckDual is
   Cursor cBad is
     select dummy from dual;
   tag varchar2(80):=chr(10)||
	'Fatal:  DUAL is unusual';
   n number:=0;
  Begin
   for R in cBad
   loop
     n:=n+1;
     if (n>1) then
       hout.put_line(chr(10)||'DUAL has more than one row');
       Fatal:=Fatal+1;
       exit;
     end if;
     if (nvl(R.dummy,'Z')!='X') then
       hout.put_line(chr(10)||'DUAL . DUMMY does not contain "X"');
       Fatal:=Fatal+1;
     end if;
   end loop;
  End;
 --
  procedure Bug2728624badOid is
    Cursor cBad is
      select o.obj#, o.type#, o.owner#, o.name, c.col#, c.intcol#, c.name cname, t.property, bitand(t.property,4096) bp4096
      from   obj$ o, col$ c, coltype$ ct, oid$ oi, tab$ t
      where  o.obj#     = ct.obj#
      and    ct.obj#    = c.obj#
      and    ct.col#    = c.col#
      and    ct.intcol# = c.intcol#
      and    oi.oid$(+) = ct.toid
      and    o.obj#     = t.obj#(+)
      and    c.name  like 'SYS_NC%'
      and    oi.oid$ is null ;
    tag varchar2(80):=chr(10)||
    'Problem:  Column type is OBJECT with missing OID$ - Bug:2728624 ?';
  Begin
   for R in cBad
   loop
     if (R.bp4096 is Null or R.bp4096=0)
     then
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' OBJ#='||R.OBJ#||' Name='||Owner(R.owner#)||'.'||R.name||
          ' IntCol#('||R.intcol#||')='||R.cname||' TabProp='||R.property);
       hout.put_line(' ^ May be Ok ('||R.bp4096||')') ;
       Warn:=Warn+1;
     else
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' OBJ#='||R.OBJ#||' Name='||Owner(R.owner#)||'.'||R.name||
          ' IntCol#='||R.intcol#||'='||R.cname||' TabProp='||R.property||' ('||R.bp4096||')');
       Fatal:=Fatal+1;
     end if ;
   end loop;
  End;
 --
  procedure Bug3532977source is
   Cursor cBad is
	select count('x') cnt, count(distinct s.obj#) nobj 
	  from source$ s, obj$ o
	 where s.obj#=o.obj#(+)
	  and o.obj# is null
	 having count('x') > 0
	  ;
   tag varchar2(80):=chr(10)||
	'Problem:  SOURCE$ for OBJ# not in OBJ$ - Bug:3532977 ?';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' SOURCE$ has '||R.cnt||
	' rows for '||R.nobj||' OBJ# values not in OBJ$');
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure Bug2405258lob is
   Cursor cBad is
	select l.obj#, l.lobj#
	  from lob$ l, obj$ o
	 where l.lobj#=o.obj#(+)
	  and o.obj# is null
	 ;
   tag varchar2(80):=chr(10)||
	'Problem:  LOB$ . LOBJ# not in OBJ$ - Bug:2405258 ?';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' LOB$.LOBJ# has no OBJ$ entry for LOBJ#='||R.lobj#||
	' (OBJ#='||R.obj#||')');
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure UpgCheckc0801070 is
   tag varchar2(80):=chr(10)||
    'Problem:  option# in STMT_AUDIT_OPTION_MAP(ON COMMIT REFRESH) - '||
    'Bug:6636804 ';
   bug6636804 number ;
  Begin
   Select count('x') into bug6636804 from STMT_AUDIT_OPTION_MAP
   where  option# = 229
   and    name    = 'ON COMMIT REFRESH';

   if ( bug6636804 > 0 )
   then
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;

     hout.put_line('-- Please run the following:') ;
     hout.put_line('SQL> update STMT_AUDIT_OPTION_MAP set option#=234') ;
     hout.put_line('     where name =''ON COMMIT REFRESH'' ;') ;
     hout.put_line('SQL> commit ;') ;

     Fatal:=Fatal+1;

   end if ;
  End;
 --
  procedure Bug3753873indpname is
   Cursor cBad is
	select io.obj# io, io.name ionam, ipo.obj# ipo, ipo.name iponam
	 from obj$ io , indpart$ ip,  obj$ ipo
	where ipo.type#=20  /* IND PART */
	  and ip.obj#=ipo.obj#
	  and io.obj#(+)=ip.bo#
	  and nvl(io.name,'"')!=ipo.name
	;
   tag varchar2(80):=chr(10)||
    'Problem:  OBJ$.NAME mismatch for INDEX v INDEX PARTITION - Bug:3753873 ?';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' Ind Part OBJ$.OBJ# '||R.ipo||' '||R.iponam||
		'!='||R.ionam||' OBJ#='||R.io);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure BadCboHiLo is
   Cursor cBad is
	select obj#,intcol#,lowval,hival
	 from hist_head$ where lowval>hival
	;
   tag varchar2(80):=chr(10)||'Problem:  HIST_HEAD$.LOWVAL > HIVAL !';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ# '||R.obj#||' INTCOL#='||R.intcol#);
     Warn:=Warn+1;
   end loop;
  End;
 --
  procedure ObjectNames is
   Cursor cBad is
	select username, object_type, 
		substr(owner||'.'||object_name,1,62) Name
  	  from dba_objects, dba_users
         where object_name=username
   	   and (owner=username OR owner='PUBLIC')
	;
   tag varchar2(80):=chr(10)||
	'Warning:  OBJECT name clashes with SCHEMA name - Bug:2894111 etc..';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' Schema='||R.username||' Object='||R.name||' ('||
		R.object_type||')');
     Warn:=Warn+1;
   end loop;
  End;
 --
  procedure BadDepends is
   Cursor cBad is
        select o.obj#          dobj        ,
               p.obj#          pobj        ,
               d.p_timestamp   p_timestamp ,
               p.stime         p_stime     ,
               o.type#         o_type      ,
               p.type#         p_type
          from sys.obj$        o           ,
               sys.dependency$ d           ,
               sys.obj$        p
         where p_obj#   = p.obj# (+)
           and d_obj#   = o.obj#
           and o.status = 1                    /*dependent is valid*/
           and p.status = 1                       /*parent is valid*/
           and p.stime !=d.p_timestamp /*parent timestamp not match*/
          order by 2,1
        ;
   tag varchar2(80):=chr(10)||
	'Problem:  Dependency$ p_timestamp mismatch for VALID objects';
   tag2 varchar2(80):=
	'May be Ok - needs checking, (Warning: [W], Error: [E]).'||chr(10) ;
   to_chk varchar2 (4) ;
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     if (tag2 is not null) then hout.put_line(tag2); tag2:=null; end if;
     if ( (R.o_type = 5) and (R.p_type = 29) )
     then
       to_chk := '[W]'  ;
       Warn   := Warn+1 ;
     else
       to_chk := '[E]' ;
       Fatal  := Fatal+1 ;
     end if ;
     hout.put_line(' '||to_chk||' - P_OBJ#='||R.pobj||' D_OBJ#='||R.dobj);
   end loop;
  End;
 --
  procedure BadCol# is
   Cursor cBad is
	select o.obj# , max(intcol#) maxi, max(col#) maxc
  	  from sys.col$ o
         group by o.obj#
        having max(intcol#)>1000 or max(col#)>999
	;
   tag varchar2(80):=chr(10)||
	'Problem:  COL$ intcol#/col# too high (bug 2212987)';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ#='||R.obj#||' max(intcol#)'||R.maxi||
		' max(col#)='||R.maxc);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure ChkIotTS is
   Cursor cBad is
	select o.owner#, o.obj# , o.name , t.ts#, t.file#, t.block#
  	  from sys.obj$ o, sys.tab$ t
	 where bitand(t.property,64)=64	/* Marked as an IOT */
	   and ts#!=0
	   and o.obj#=t.obj#
	;
   tag varchar2(80):=chr(10)||
	'Problem:  IOT tab$ has TS#!=0 ?? May be OK - needs checking';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(
	' OBJ#='||R.obj#||' ('||Owner(R.owner#)||'.'||r.name||') '||
		' TS#='||R.ts#||' f='||R.file#||' b='||r.block#
     );
     Warn:=Warn+1;
   end loop;
  End;
 --
  procedure DuplicateDataobj is
   Cursor cBad is
        select * from
        (
        select /*+ NO_MERGE */ many.dataobj#, o.obj#, o.owner#,
                o.name, o.subname,
                o.type#, t.property
          from ( select dataobj#
                   from obj$
                  where dataobj# is not null
                  group by dataobj#
                 having count('x')>1) many, obj$ o, tab$ t
         where many.dataobj# = o.dataobj#(+)
           and o.type# (+)  != 3                       /* Not a cluster */
           and t.obj#  (+)   = o.obj#
        )
        where bitand(property, 1024)!=1024      /* Not a cluster table  */
        and   bitand(property, 64)!=64          /* Not an IOT           */
--       or property is null                    /* IOT Part's fall here */
        order by dataobj#, obj#
   ;
   tag1 varchar2(80):=chr(10)||
	'Problem:  Duplicate DATAOBJ#, may be valid under the following:';
   tag2 varchar2(80):=chr(10)||
	'          - Using Transportable Tablespaces' ;
   tag3 varchar2(80):=chr(10)||
	'          - OBJ''s belong to different tablespaces' ;
   sub boolean:=false;
  Begin
   for R in cBad
   loop
     if (tag1 is not null) then
        hout.put_line(tag1);
        hout.put_line(tag2);
        hout.put_line(tag3);
        tag1:=null;
        tag2:=null;
        tag3:=null;
     end if;
     hout.put_line(' DATAOBJ#='||R.DATAOBJ#||' OBJ#='||R.obj#||
	' Name='||Owner(R.owner#)||'.'||R.name||' '||R.subname||
		' Type#='||R.type#);
     if (R.type#=34 /*table subpart*/) then
	sub:=true;
     end if;
     Fatal:=Fatal+1;
   end loop;
   if sub then
     hout.put_line(' Subpartition duplicates could be caused by bug:2597763');
   end if;
  End;
 --
  procedure ObjSeqMissing is
   Cursor cBad is
     select o.obj#, o.owner#, o.name 
       from obj$ o , seq$ s
      where o.type#=6
        and o.obj#=s.obj#(+)	
	and o.linkname is null	/* Not remote */
	and s.obj# is null
     ;
   tag varchar2(80):=chr(10)||
	'Warning:  SEQ$ entry missing for OBJ$ type#=6';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ#='||R.OBJ#||' Name='||Owner(R.owner#)||'.'||R.name);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure badIcolDepCnt is
   Cursor cBad is
	select i.obj# , nvl(i.spare1,i.intcols) expect, ic.cnt got
	  from ind$ i,
	   (select obj#, count('x') cnt from icoldep$ group by obj# ) ic
	 where ic.obj#=i.obj#
	  and ic.cnt!=nvl(i.spare1,i.intcols)
	;
   tag varchar2(80):=chr(10)||
    'Error:  ICOLDEP$ count!=IND$ expected num dependencies - bug 5217913';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' OBJ#='||R.OBJ#||' '||ObjName(R.obj#)||
	' IND$ expects '||R.expect||' ICOLDEP$ has '||R.got);
     Fatal:=Fatal+1;
   end loop;
  End;
 --
  procedure warnIcoldep is
   Cursor cBad is
	select adt.obj#,adt.icobj#, adt.intcol#,adt.name
	from
	( select c.obj#, ic.obj# icobj#, c.intcol#, c.name
	 from col$ c , icoldep$ ic
	 where c.type#=121 /*index on ADT*/
	  and c.obj#=ic.bo#
	  and c.intcol#=ic.intcol#
	) adt,
	(select c.obj#, c.intcol#, c.name , ic.obj# icobj#
	  from col$ c , icoldep$ ic
	  where bitand(c.property,33)=33        /* index on ADT attribute */
	   and c.obj#=ic.bo#
	   and c.intcol#=ic.intcol#
	) adtattr
	where adt.obj#=adtattr.obj#             /* same table */
	  and adt.icobj#=adtattr.icobj#         /* same index */
	  and adt.intcol#+1 = adtattr.intcol#   /* likely same ADT/attr */
	order by 1,2
	;
   tag varchar2(80):=chr(10)||
	'Warning:  ICOLDEP$ may reference ADT and its attributes'||
	' - see bug 5217913';
  Begin
   for R in cBad
   loop
     if (tag is not null) then hout.put_line(tag); tag:=null; end if;
     hout.put_line(' Index OBJ#='||R.ICOBJ#||' '||ObjName(R.icobj#)||
	' intcol#='||R.intcol#||'='||R.name);
     Warn:=Warn+1;
   end loop;
  End;
 --
  procedure NosegmentIndex is
   Cursor cWarn is
	select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
          from seg$ s, ind$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
	   and bitand(i.flags,4096)=4096  /* Exclude NOSEGMENT index */
        ;
   tag varchar2(80):=chr(10)||
    'Warning: NOSEGMENT IND$ exists (these are allowed but care needed)';
   --
   Procedure CheckIndPart( o number ) is
    Cursor Cchk is
	select  i.obj#, i.dataobj#, i.ts#, i.file#, i.block#
          from indpart$ i 
	 where i.bo#=o
	   and (i.file#!=0 OR i.block#!=0);
   begin
    For R in Cchk Loop
     hout.put_line(' ^- PROBLEM: Child INDPART$ with FILE/BLK (bug 4683380)');
     hout.put_line(' ^- ( OBJ='||R.obj#|| ' DOBJ='||r.dataobj#||
		' TS='||r.TS#||
		' RFILE/BLOCK='||r.file#||' '||r.block#||')' );
     Fatal:=Fatal+1;
    end loop;
   end;
  begin
   For R in cWarn
   Loop
       if (tag is not null) then hout.put_line(tag); tag:=null; end if;
       hout.put_line(' NOSEGMENT IND$: OBJ='||R.obj#||
			' DOBJ='||r.dataobj#||
			' TS='||r.TS#||
			' RFILE/BLOCK='||r.file#||' '||r.block#||
			' BO#='||r.bo#||' SegType='||R.type#);
       if (R.type# is not null) then
	hout.put_line(' ^- PROBLEM: NOSEGMENT Index has a segment attached ?');
        Fatal:=Fatal+1;
       else
        Warn:=Warn+1;
       end if;
       if (r.TS#!=0 or r.file#!=0 or r.block#!=0) then
	hout.put_line(' ^- Index has ts#/file#/block# set ???');
       end if;
       CheckIndPart(R.obj#);
   End Loop;
  End;
 --
  procedure Full is
  begin
	Fatal := 0 ;
        Warn  := 0 ;
        hout.put_line('HCheck Version '||Ver);
       --
	OversizedFiles;
	TinyFiles;
  	TabPartCountMismatch;
  	bug1360714_Composite;
    bug7509714_Composite;
    OrphanedTabComPart;
  	ZeroTabSubPart;
  	MissingSum$;
    MissingDir$;
	DuplicateDataobj;
  	ObjSynMissing ;
  	ObjSeqMissing ;
    -- 
	OrphanedIndex;
	OrphanedUndo;
	OrphanedIndexPartition;
	OrphanedIndexSubPartition;
	OrphanedTable;
	OrphanedTablePartition;
	OrphanedTableSubPartition;
	MissingPartCol;
	OrphanedSeg$;
    OrphanedIndPartObj#;
	DuplicateBlockUse;
	HighObjectIds;
	PQsequence;
	TruncatedCluster;
	FetUet;
  	Uet0Check;
	ExtentlessSeg;
	SeglessUET;
  	BadInd$;
  	BadTab$;
	BadIcolDepCnt;
	warnIcolDep;
  	OnlineRebuild$;
	bug1584155;
  	bug1362374_trigger;
  	bug1365707_badobj;
  	bug1842429_badview;
	Bug1375026Seq;
  	Bug1805146DroppedFuncIdx;
  	Bug1359472BadOwner;
  	Bug6310840audit;
	Bug2728624badOid;
	Bug3532977source;
	Bug2405258lob;
	UpgCheckc0801070;
	Bug3753873indpname;
    --
  	BadPublicObjects;
  	BadSegFreelist;
	BadCol#;
	BadDepends;
    --
    CheckDual;
  	Bug2371453synonym;
  	PoorDefaultStorage;
  	PoorStorage;
	ObjectNames;
  	BadCboHiLo;
	ChkIotTs;
	NoSegmentIndex;
    --
    hout.new_line;
    hout.put_line(chr(10)||'Found '||Fatal||' potential problems and '||
	warn||' warnings');
    hout.new_line;
    if (Fatal>0 or Warn>0) then
      hout.put_line('Contact Oracle Support with the output');
      hout.put_line('to check if the above needs attention or not');
   	end if;
  end;
end hcheck;
/
show errors
REM
set serverout on
execute hcheck.full
REM ======================================================================


