set pages 1000
set serveroutput on
set lines 500
 
DECLARE 
		
	v_hwm number :=0;
	v_current_size number :=0;
	v_percent_gain number :=0;
	v_total_space_rec number :=0;
	v_total_data_size number :=0;
		
BEGIN
	
	for v_file_info in (select FILE_NAME, FILE_ID, BLOCK_SIZE 
						from dba_tablespaces tbs, dba_data_files df 
						where tbs.tablespace_name = df.tablespace_name)
	loop
		select ceil( (nvl(hwm,1) * v_file_info.block_size)/1024/1024 ) ,
			   ceil( blocks * v_file_info.block_size/1024/1024) into v_hwm,v_current_size
		from dba_data_files a,
		( select file_id, max(block_id+blocks-1) hwm
		  from dba_extents
		  group by file_id ) b
	   where a.file_id = b.file_id(+)
	   and a.file_id = v_file_info.file_id;
	   
	   v_total_space_rec := v_total_space_rec +(v_current_size-v_hwm);
	   v_total_data_size := v_total_data_size +v_current_size;
		  
		dbms_output.put_line(v_file_info.file_name || ':');
		dbms_output.put_line('Current size: ' || v_current_size || 'M' );
		dbms_output.put_line('HWM: ' || v_hwm || 'M' );
		dbms_output.put_line('Percentage reclaimable: ' || round((v_current_size-v_hwm)*100/v_current_size,2) || '%');
		dbms_output.put_line('Use following command to resize: ALTER DATABASE DATAFILE ''' || v_file_info.file_name || ''' RESIZE ' || v_hwm|| 'M;');
		
		dbms_output.put_line('	');
		dbms_output.put_line('	');
	end loop;
	
	dbms_output.put_line('Total datafiles size reclaimable: ' || v_total_space_rec || 'M');
	dbms_output.put_line('Percentage of space reclaimable in the datafiles: ' || round(v_total_space_rec*100/v_total_data_size,2) || '%');
END;