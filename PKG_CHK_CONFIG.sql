create or replace package PKG_CHK_CONFIG is

  PROCEDURE P_A0001(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0002(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0003(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0006(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0007(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0004(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0005(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0008(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_A0009(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2);

  PROCEDURE P_SCONFIG(I_STARTDATE IN VARCHAR2,
                      I_ENDDATE   IN VARCHAR2,
                      V_CKCODE    IN VARCHAR2,
                      O_ERRCODE   OUT INTEGER,
                      O_ERRMSG    OUT VARCHAR2);

  --D�ꣿ��1y3�� --������D�䣿����1y3��
  PROCEDURE P_CHECK_ALL(I_STARTDATE IN VARCHAR2,
                        I_ENDDATE   IN VARCHAR2,
    --V_CKCODE    IN VARCHAR2,
                        O_ERRCODE   OUT INTEGER,
                        O_ERRMSG    OUT VARCHAR2);

  --D�ꣿ��1y3�� --D�ꣿ���̣�����D�ꣿ��1������
  PROCEDURE P_CHECK_UNIT(I_STARTDATE IN VARCHAR2,
                         I_ENDDATE   IN VARCHAR2,
                         VC_CKCODE    IN VARCHAR2,
                         O_ERRCODE   OUT INTEGER,
                         O_ERRMSG    OUT VARCHAR2);

  --D�ꣿ��1y3�� --���������̡£��������䣿
  PROCEDURE P_CHECK_TWICE(I_STARTDATE IN VARCHAR2,
                          I_ENDDATE   IN VARCHAR2,
    --V_CKCODE    IN VARCHAR2,
                          O_ERRCODE   OUT INTEGER,
                          O_ERRMSG    OUT VARCHAR2);



  --D�ꣿ������D����aGZ�̣�D�ꣿ��
  PROCEDURE P_CHECK_GZ(
    O_ERRCODE   OUT INTEGER,
    O_ERRMSG    OUT VARCHAR2
  );

end PKG_CHK_CONFIG;
/




CREATE OR REPLACE PACKAGE BODY PKG_CHK_CONFIG IS

  PROCEDURE P_A0001 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢���������ֶηǿռ���
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condt    varchar (2000);
    vc_condtsql varchar (2000);
    --vc_condtA   varchar (2000);--A0002 A0003
    --vc_condtAsql   varchar (2000);--A0002 A0003
    --vc_ywd      varchar (200);
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0001'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname := cur.vc_table_name;
      vc_showcol := replace(cur.vc_show_key,'#',',');--չʾ�ֶ�
--û�в���
      if cur.vc_is_parameter = '0' then
        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');

        vc_condt := cur.vc_desc;--��ѯ����
        vc_condtsql := replace(vc_condt,'''','''''');
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condt; --У������������

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn; --У������������

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 :=  'select '||vc_showcol||' from '||vc_tabname||' where '||cur.vc_col||' is null '||vc_condtsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||ls_sql2||''' from '||vc_tabname
              ||' where 1 = 1 '||vc_condt||' and '||cur.vc_col||' is null '
              ;--2017-10-09

              EXECUTE IMMEDIATE ls_sql1;
              commit;
           END IF;
            --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;


--�в��� ����Ϊnumber
           elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then

            N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop

           vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');--չʾ�ֶ�
           vc_condt := replace(cur.vc_desc,'@d',N_loopdate);--��ѯ����
           vc_condtsql := replace(vc_condt,'''','''''');
           --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condt;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn; --�ж��Ƿ�ͨ���˲�

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 :=  'select '||vc_showcol||' from '||vc_tabname||' where '||cur.vc_col||' is null '||vc_condtsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname
              ||' where 1 = 1 '||vc_condt||' and '||cur.vc_col||' is null '
              ;--2017-10-09

              EXECUTE IMMEDIATE ls_sql1;
              commit;


           end if;
            --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           --N_loopdate := N_loopdate + 1;
          end loop;

--�в��� ����Ϊdate

      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then

          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');--չʾ�ֶ�
                  vc_condt := replace(cur.vc_desc,'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');--��ѯ����
                  vc_condtsql := replace(vc_condt,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condt;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 :=  'select '||vc_showcol||' from '||vc_tabname||' where '||cur.vc_col||' is null '||vc_condtsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2||''' from '||vc_tabname
              ||' where 1 = 1 '||vc_condt||' and '||cur.vc_col||' is null '
              ;--2017-10-09

              EXECUTE IMMEDIATE ls_sql1;
              commit;


           end if;


          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           D_loopdate := D_loopdate + 1;
           end loop;

 --�в��� ����Ϊvarchar
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then

            N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop

             --����log��־
             d_logdate := sysdate;
             INSERT into chk_result_loginfo t
             (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
             values
             (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
             commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');--չʾ�ֶ�
                  vc_condt := replace(cur.vc_desc,'@d',' to_char('||N_loopdate||')');--��ѯ����
                  vc_condtsql := replace(vc_condt,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where '||cur.vc_col||' is null '||vc_condt;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condt;


          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 :=  'select '||vc_showcol||' from '||vc_tabname||' where '||cur.vc_col||' is null '||vc_condtsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname
              ||' where 1 = 1 '||vc_condt||' and '||cur.vc_col||' is null '
              ;--2017-10-09

              EXECUTE IMMEDIATE ls_sql1;
              commit;


           end if;


          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;



      end if;
      commit;

--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and */a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
           and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0001;



  PROCEDURE P_A0002 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condtAsql   varchar (2000);--A0002 A0003
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0002'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname := cur.vc_table_name;
      vc_showcol := replace(cur.vc_show_key,'#',',');--չʾ�ֶ�



--û�в���
      if cur.vc_is_parameter = '0' then

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(cur.vc_desc,'#',')');--A0002 A0003--��ѯ����
        vc_condtAsql := replace(vc_condtA,'''','''''');


          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||ls_sql2||''' from '||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtA;--2017-9-18

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;

--�в��� ����Ϊnumber
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then

            N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop


                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
                  vc_condtA := replace(replace(cur.vc_desc,'#',')'),'@d',N_loopdate);--A0002 A0003--��ѯ����
                  vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1);

           --������ϸ��
            ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '
              ||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtA;--2017-9-18

            EXECUTE IMMEDIATE ls_sql1;
            commit;

           end if;


          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;



--�в��� ����Ϊdate
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then

          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
                  vc_condtA := replace(replace(cur.vc_desc,'#',')'),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');--A0002 A0003--��ѯ����
                  vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1);

           --������ϸ��
            ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2||''' from '
              ||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtA;--2017-9-18

           EXECUTE IMMEDIATE ls_sql1;
           commit;
         end if;
      --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           D_loopdate := D_loopdate + 1;
           end loop;

--�в��� ����Ϊvarchar
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then

          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop
                 --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
                  vc_condtA := replace(replace(cur.vc_desc,'#',')'),'@d',' to_char('||N_loopdate||')');--A0002 A0003--��ѯ����
                  vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '
                ||cur.vc_col||' and a.vc_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1);

           --������ϸ��
            ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '
              ||vc_tabname||' where not exists (select 1 from dim_dictionary_convert a where a.vc_code = '||cur.vc_col||' and a.vc_type='||
              vc_condtA;--2017-9-18

           EXECUTE IMMEDIATE ls_sql1;
           commit;
         end if;
      --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;


       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and*/ a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0002;



  PROCEDURE P_A0003 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condtAsql   varchar (2000);--A0002 A0003
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0003'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname := cur.vc_table_name;
      vc_showcol := replace(cur.vc_show_key,'#',',');--չʾ�ֶ�



--û�в���
      if cur.vc_is_parameter = '0' then

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(cur.vc_desc,'#',')');--A0002 A0003--��ѯ����
        vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;--ȱʧnot

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||ls_sql2||''' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;

--�в��� ����Ϊnumber
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then

          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop


                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
                  vc_condtA := replace(replace(cur.vc_desc,'#',')'),'@d',N_loopdate);--A0002 A0003--��ѯ����
                  vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��
            ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtA;

           EXECUTE IMMEDIATE ls_sql1;
           commit;
         end if;
      --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;


--�в��� ����Ϊdate
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then

          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
                  vc_condtA := replace(replace(cur.vc_desc,'#',')'),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');--A0002 A0003--��ѯ����
                  vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,f_chk_cn);

           --������ϸ��
            ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtA;

           EXECUTE IMMEDIATE ls_sql1;
           commit;
         end if;
      --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           D_loopdate := D_loopdate + 1;
           end loop;


--�в��� ����Ϊvarchar
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then

          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop


                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

                  vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
                  vc_condtA := replace(replace(cur.vc_desc,'#',')'),'@d',' to_char('||N_loopdate||')');--A0002 A0003--��ѯ����
                  vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where not exists (select 1 from e_dim where dim_cde = '
                ||cur.vc_col||' and dim_type='|| vc_condtA ;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '|| substr(vc_condtA,instr(vc_condtA,')') + 1) ;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��
            ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where not exists (select 1 from e_dim where dim_cde = '||cur.vc_col||' and dim_type='||
              vc_condtA;

           EXECUTE IMMEDIATE ls_sql1;
           commit;
         end if;
      --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;




       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and*/ a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0003;

  PROCEDURE P_A0006 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condtAsql   varchar (2000);--A0002 A0003
    vc_condition varchar (2000);
    f_count     number;
    F_CHK_CN    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0006'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname := cur.vc_table_name;
      vc_showcol := replace(cur.vc_show_key,'#',',');--չʾ�ֶ�



--û�в���
      if cur.vc_is_parameter = '0' then

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col);
        vc_condition := replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col);
        vc_condtAsql := replace(vc_condtA,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into F_CHK_CN;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,F_CHK_CN);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,F_CHK_CN);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;

--�в��� ����Ϊnumber
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then
          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',N_loopdate);
        vc_condition := replace(replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col),'@d',N_loopdate);
        vc_condtAsql := replace(vc_condtA,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into F_CHK_CN;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,F_CHK_CN);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,F_CHK_CN);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;

--�в��� ����Ϊdate
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then
          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condition := replace(replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select COUNT(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into F_CHK_CN;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,F_CHK_CN);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,F_CHK_CN);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           D_loopdate := D_loopdate + 1;
           end loop;

--�в��� ����Ϊvarchar
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then
          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop


             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',' to_char('||N_loopdate||')');
        vc_condition := replace(replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col),'@d',' to_char('||N_loopdate||')');
        vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into F_CHK_CN;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,F_CHK_CN);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,F_CHK_CN);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;



       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and*/ a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0006;

  PROCEDURE P_A0007 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condtAsql   varchar (2000);--A0002 A0003
    vc_condition varchar (2000);
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0007'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname := cur.vc_table_name;
      vc_showcol := replace(cur.vc_show_key,'#',',');--չʾ�ֶ�



--û�в���
      if cur.vc_is_parameter = '0' then

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col);
        vc_condition := replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col);
        vc_condtAsql := replace(vc_condtA,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;

--�в��� ����Ϊnumber
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then
          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',N_loopdate);
        vc_condition := replace(replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col),'@d',N_loopdate);
        vc_condtAsql := replace(vc_condtA,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;

--�в��� ����Ϊdate
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then
          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condition := replace(replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           D_loopdate := D_loopdate + 1;
           end loop;

--�в��� ����Ϊvarchar
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then
          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop


             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

        vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');
        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',' to_char('||N_loopdate||')');
        vc_condition := replace(replace(SUBSTR(cur.vc_desc,INSTR(cur.vc_desc,'#') + 1),'@p',cur.vc_col),'@d',' to_char('||N_loopdate||')');
        vc_condtAsql := replace(vc_condtA,'''','''''');

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||''' from '||vc_tabname||' where 1 = 1 '||
              vc_condtA;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;



       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and */a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0007;

  PROCEDURE P_A0004 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname1  varchar (200);--����
    vc_tabname2  varchar (200);--������
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);--չʾ�ֶ�
    vc_showcol2  varchar (2000);--����չʾ�ֶ�ֵ
    vc_condtA   varchar (2000);--��������
    vc_condtAsql   varchar (2000);--������������sql
    vc_condtB   varchar (2000);--where����
    vc_condtBsql   varchar (2000);--where��������sql
    vc_glcol      varchar (2000);--�����ֶ�
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0004'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname1 := substr2(cur.vc_table_name,1,instr(cur.vc_table_name,'#')-1);
      vc_tabname2 := substr2(cur.vc_table_name,instr(cur.vc_table_name,'#')+1);
      vc_showcol := replace(replace(replace(cur.vc_show_key,'#',','),'@tab1',vc_tabname1),'@tab2',vc_tabname2);--չʾ�ֶ�
      vc_showcol2 := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1',vc_tabname1),'@tab2',vc_tabname2);--����չʾ�ֶ�ֵ
      vc_glcol := replace(substr2(cur.vc_desc,instr(cur.vc_desc,'#',1,2)+1),'@tab2',vc_tabname2);--�����ֶ�
      vc_showname := replace(replace(cur.vc_show_key,'@tab1',vc_tabname1),'@tab2',vc_tabname2);


--û�в���
      if cur.vc_is_parameter = '0' then

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;


        vc_condtA := replace(replace(substr2(cur.vc_desc,1,instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2);
        vc_condtAsql := replace(vc_condtA,'''','''''');
        vc_condtB := replace(replace(substr2(cur.vc_desc,instr(cur.vc_desc,'#')+1,instr(cur.vc_desc,'#',1,2)-instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2);
        vc_condtBsql := replace(vc_condtB,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;--

          ls_sql1 := 'select '||vc_showcol||' from '||vc_tabname1||
                     ' left join '||vc_tabname2||' on '||vc_condtA||
                     ' where '||vc_glcol||' is null '||vc_condtB;

          ls_sql2 := 'select count(1) from '||vc_tabname1||
                     ' left join '||vc_tabname2||' on '||vc_condtA||
                     ' where 1 = 1 '||vc_condtB;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtAsql||
                    ' where '||vc_glcol||' is null '||vc_condtBsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||vc_showname||''','||vc_showcol2||','''||ls_sql2
              ||''' from '||vc_tabname1||
              ' left join '||vc_tabname2||' on '||vc_condtA||
              ' where '||vc_glcol||' is null '||vc_condtB;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;

--�в��� ����Ϊnumber
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then
          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;


        vc_condtA := replace(replace(replace(substr2(cur.vc_desc,1,instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2),'@d',N_loopdate);
        vc_condtAsql := replace(vc_condtA,'''','''''');
        vc_condtB := replace(replace(replace(substr2(cur.vc_desc,instr(cur.vc_desc,'#')+1,instr(cur.vc_desc,'#',1,2)-instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2),'@d',N_loopdate);
        vc_condtBsql := replace(vc_condtB,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;--

          ls_sql1 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;

          ls_sql2 := 'select count(1) from '||vc_tabname1||
                     ' left join '||vc_tabname2||' on '||vc_condtA||
                     ' where 1 = 1 '||vc_condtB;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtAsql||
                    ' where '||vc_glcol||' is null '||vc_condtBsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||vc_showname||''','||vc_showcol2||','''||N_loopdate||''','''||ls_sql2
              ||''' from '||vc_tabname1||
              ' left join '||vc_tabname2||' on '||vc_condtA||
              ' where '||vc_glcol||' is null '||vc_condtB;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;


--�в��� ����Ϊdate
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then
          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;


        vc_condtA := replace(replace(replace(substr2(cur.vc_desc,1,instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtAsql := replace(vc_condtA,'''','''''');
        vc_condtB := replace(replace(replace(substr2(cur.vc_desc,instr(cur.vc_desc,'#')+1,instr(cur.vc_desc,'#',1,2)-instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtBsql := replace(vc_condtB,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;--

          ls_sql1 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;

          ls_sql2 := 'select count(1) from '||vc_tabname1||
                     ' left join '||vc_tabname2||' on '||vc_condtA||
                     ' where 1 = 1 '||vc_condtB;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtAsql||
                    ' where '||vc_glcol||' is null '||vc_condtBsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||vc_showname||''','||vc_showcol2||','''||v_loopdate||''','''||ls_sql2
              ||''' from '||vc_tabname1||
              ' left join '||vc_tabname2||' on '||vc_condtA||
              ' where '||vc_glcol||' is null '||vc_condtB;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           D_loopdate := D_loopdate + 1;
           end loop;


--�в��� ����Ϊvarchar
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then
          N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop


             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;


        vc_condtA := replace(replace(replace(substr2(cur.vc_desc,1,instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2),'@d',' to_char('||N_loopdate||')');
        vc_condtAsql := replace(vc_condtA,'''','''''');
        vc_condtB := replace(replace(replace(substr2(cur.vc_desc,instr(cur.vc_desc,'#')+1,instr(cur.vc_desc,'#',1,2)-instr(cur.vc_desc,'#')-1),'@tab1',vc_tabname1),'@tab2',vc_tabname2),'@d',' to_char('||N_loopdate||')');
        vc_condtBsql := replace(vc_condtB,'''','''''');
        --vc_condtAsql := vc_condtA;

          ls_sql := 'select count(1) from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;--

          ls_sql1 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtA||
                    ' where '||vc_glcol||' is null '||vc_condtB;

          ls_sql2 := 'select count(1) from '||vc_tabname1||
                     ' left join '||vc_tabname2||' on '||vc_condtA||
                     ' where 1 = 1 '||vc_condtB;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname1||
                    ' left join '||vc_tabname2||' on '||vc_condtAsql||
                    ' where '||vc_glcol||' is null '||vc_condtBsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||vc_showname||''','||vc_showcol2||','''||N_loopdate||''','''||ls_sql2
              ||''' from '||vc_tabname1||
              ' left join '||vc_tabname2||' on '||vc_condtA||
              ' where '||vc_glcol||' is null '||vc_condtB;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;


       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and*/ a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0004;

  PROCEDURE P_A0005 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condtAsql   varchar (2000);--A0002 A0003
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0005'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;
      vc_tabname := cur.vc_table_name;
      vc_showcol := replace(cur.vc_show_key,'#',',');--չʾ�ֶ�
      vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');--����չʾ�ֶ�ֵ


--û�в���
      if cur.vc_is_parameter = '0' then

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;


        vc_condtA := replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col);--where����������
        vc_condtAsql := replace(vc_condtA,'''','''''');


          ls_sql := 'select count(1) from (select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                    ||' group by '||cur.vc_col||' having count(1) > 1)';

          ls_sql1 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                     ||' AND F_CN  > 1)';

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',f_count,ls_sql1,f_chk_cn);

           --������ϸ��

             /* ls_sql2 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||
              vc_condtAsql||' group by '||cur.vc_col||' having count(1) > 1)';
              */
               ls_sql2 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                     ||' AND F_CN  > 1)';

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||ls_sql2||
              ''' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
              ||' group by '||cur.vc_col||' having count(1) > 1)';

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;

--�в��� ����Ϊnumber
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then
           N_loopdate := to_number(I_STARTDATE);

            while N_loopdate <= to_number(I_ENDDATE) loop


             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;


        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',N_loopdate);--where����������
        vc_condtAsql := replace(vc_condtA,'''','''''');


          ls_sql := 'select count(1) from (select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                    ||' group by '||cur.vc_col||' having count(1) > 1)';

          /*ls_sql1 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                     ||' group by '||cur.vc_col||' having count(1) > 1)';*/

          ls_sql1 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                     ||' AND F_CN  > 1)';

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              /*ls_sql2 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||
              vc_condtAsql||' group by '||cur.vc_col||' having count(1) > 1)';*/
              ls_sql2 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtAsql||' AND F_CN  > 1)';

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||
              ''' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
              ||' group by '||cur.vc_col||' having count(1) > 1)';

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;


--�в��� ����Ϊdate
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then
          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;


        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');--where����������
        vc_condtAsql := replace(vc_condtA,'''','''''');


          ls_sql := 'select count(1) from (select count(1)  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                    ||' group by '||cur.vc_col||' having count(1) > 1)';

          /*ls_sql1 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                     ||' group by '||cur.vc_col||' having count(1) > 1)';*/
         ls_sql1 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA||' AND F_CN  > 1)';

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,f_chk_cn);

           --������ϸ��

             /* ls_sql2 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||
              vc_condtAsql||' group by '||cur.vc_col||' having count(1) > 1)';*/
              ls_sql2 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtAsql||' AND F_CN  > 1)';

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2||
              ''' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
              ||' group by '||cur.vc_col||' having count(1) > 1)';

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           D_loopdate := D_loopdate + 1;
           end loop;


--�в��� ����Ϊvarchar
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then
           N_loopdate := to_number(I_STARTDATE);

            while N_loopdate <= to_number(I_ENDDATE) loop


             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;


        vc_condtA := replace(replace(replace(cur.vc_desc,'#',''),'@p',cur.vc_col),'@d',' to_char('||N_loopdate||')');--where����������
        vc_condtAsql := replace(vc_condtA,'''','''''');


          ls_sql := 'select count(1) from (select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                    ||' group by '||cur.vc_col||' having count(1) > 1)';

          /*ls_sql1 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
                     ||' group by '||cur.vc_col||' having count(1) > 1)';*/

          ls_sql1 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA||' AND F_CN  > 1)';


          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

             /* ls_sql2 := 'select '||vc_showcol||' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||
              vc_condtAsql||' group by '||cur.vc_col||' having count(1) > 1)';*/

             ls_sql2 := 'select '||vc_showcol||' from (select '||vc_showcol||' ,  COUNT(1) OVER(PARTITION BY '||cur.vc_col||' order by null ) F_CN  from '||cur.vc_table_name||' where 1 = 1 '||vc_condtAsql||' AND F_CN  > 1)';


              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||ls_sql2||
              ''' from (select count(1),'||vc_showcol||' from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA
              ||' group by '||cur.vc_col||' having count(1) > 1)';

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;



       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and */a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0005;

  PROCEDURE P_A0008 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condition varchar (2000);
    vc_condtAsql   varchar (2000);--A0002 A0003
    f_count     number;
    f_chk_cn    number;
    v_id        varchar (200);
    N_loopdate  number (20);
    N_loopdate1  number (20);
    D_loopdate  date;
    D_loopdate1  date;
    v_loopdate  varchar (20);
    v_loopdate1  varchar (20);
    d_logdate   date;
    v_prevdate  varchar (20);--��һ��


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,a.vc_is_tradedate,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0008'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;--У������ C****
      vc_tabname := cur.vc_table_name;--���� tpa_******
      vc_showcol := replace(replace(replace(cur.vc_show_key,'#',','),'@tab1','a'),'@tab2','a1');--չʾ�ֶ�



--û�в���

--�в��� ����Ϊdate
       if cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then
          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');


           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

            --������һ��
                  if lower(cur.vc_is_tradedate) = 'date'  then
                     v_prevdate := to_char(D_loopdate - 1,'yyyymmdd');--��Ȼ��
                     d_loopdate1 := d_loopdate;

                    elsif lower(cur.vc_is_tradedate) = 'trade' then
                           select case when a.f_hols_day=1 then a.d_date
                                  else null--a.d_prev_date
                                  end
                             into d_loopdate1 from dim_sys_time a
                           where a.d_date=D_loopdate;--У�������ж�

                          if d_loopdate1 is not null then
                               select to_char(a.d_prev_date,'yyyymmdd') into v_prevdate from dim_sys_time a
                               where a.d_date=d_loopdate1;--������
                          end if;

                    elsif lower(cur.vc_is_tradedate) = 'work' then
                           select case when a.f_hols_day_bank = 1 then a.d_date
                                   else null--a.d_prev_date
                                   end
                              into d_loopdate1 from dim_sys_time a
                           where a.d_date=D_loopdate;

                           if d_loopdate1 is not null then
                                select to_char(a.d_prev_date,'yyyymmdd') into v_prevdate from dim_sys_time a
                                where a.d_date=d_loopdate1;--������
                           end if;

                   end if;
              v_loopdate := to_char(d_loopdate1);--У������
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

        vc_showname := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1','a'),'@tab2','a1');--����չʾ�ֶ�
        vc_condtA := replace(cur.vc_desc,'#','');
        vc_condition := replace(substr(cur.vc_desc,instr(cur.vc_desc,'#') + 1),'#',''); --ѡȡ��һ��#�������ݲ���ȥ������#
        vc_condition := replace(replace(vc_condition,'@tab1','a'),'@tab2','a1');--�滻��@tab1��@tab1
        vc_condition := replace(replace(vc_condition,'@dprev',' to_date('''||v_prevdate||''',''yyyymmdd'')'),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');--�滻����
        vc_condtA := replace(replace(vc_condtA,'@tab1','a'),'@tab2','a1');--�滻��@tab1��@tab1
        --vc_condtA := replace(vc_condtA,'@p','(a.'||cur.vc_col||'/'||'a1.'||cur.vc_col||' - 1)');--@p�滻Ϊ �����ֶεı�ֵ
        vc_condtA := replace(replace(vc_condtA,'@dprev',' to_date('''||v_prevdate||''',''yyyymmdd'')'),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');--�滻����
        --vc_condtA := replace(replace(replace(substr(cur.vc_desc,instr(cur.vc_desc,'#')+1),'#',''),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtAsql := replace(vc_condtA,'''','''''');--����sql

          ls_sql := 'select count(1) from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condition;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;

          if f_count = 0 and d_loopdate1 is not null then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate1,f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 and d_loopdate1 is not null then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||ls_sql2
              ||''' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA
              ;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           D_loopdate := D_loopdate + 1;
           end loop;


--�в��� ����Ϊnumber
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then
          N_loopdate := to_number(I_STARTDATE);


           while N_loopdate <= to_number(I_ENDDATE) loop
            --     v_loopdate := to_char(d_loopdate);
            --������һ��
                  if lower(cur.vc_is_tradedate) = 'date'  then
                     v_prevdate := to_char(to_date(N_loopdate,'yyyymmdd') - 1,'yyyymmdd');--��Ȼ��
                     N_loopdate1 := N_loopdate;

                    elsif lower(cur.vc_is_tradedate) = 'trade' then
                          select case when a.f_hols_day=1 then to_number(to_char(a.d_date,'yyyymmdd'))
                                 else null--to_number(to_char(a.d_prev_date,'yyyymmdd'))
                                 end
                           into N_loopdate1 from dim_sys_time a
                         where a.d_date=to_date(to_char(N_loopdate),'yyyymmdd');--У�������ж�

                         if N_loopdate1 is not null then
                             select to_char(a.d_prev_date,'yyyymmdd') into v_prevdate from dim_sys_time a
                             where a.d_date=to_date(to_char(N_loopdate1),'yyyymmdd');--������
                         end if;

                    elsif lower(cur.vc_is_tradedate) = 'work' then
                          select case when a.f_hols_day_bank = 1 then to_number(to_char(a.d_date,'yyyymmdd'))
                                 else null--to_number(to_char(a.d_prev_date,'yyyymmdd'))
                                 end
                            into N_loopdate1 from dim_sys_time a
                         where a.d_date=to_date(to_char(N_loopdate),'yyyymmdd');

                         if N_loopdate1 is not null then
                              select to_char(a.d_prev_date,'yyyymmdd') into v_prevdate from dim_sys_time a
                              where a.d_date=to_date(to_char(N_loopdate1),'yyyymmdd');--������
                         end if;

                   end if;

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

        vc_showname := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1','a'),'@tab2','a1');--����չʾ�ֶ�
        vc_condtA := replace(cur.vc_desc,'#','');--ѡȡ��һ��#�������ݲ���ȥ������#
        vc_condtA := replace(replace(vc_condtA,'@tab1','a'),'@tab2','a1');--�滻��@tab1��@tab1
        --vc_condtA := replace(vc_condtA,'@p','(a.'||cur.vc_col||'/'||'a1.'||cur.vc_col||' - 1)');--@p�滻Ϊ �����ֶεı�ֵ
        vc_condtA := replace(replace(vc_condtA,'@dprev',' to_number('||v_prevdate||')'),'@d',N_loopdate1);--�滻����

        vc_condition := replace(substr(cur.vc_desc,instr(cur.vc_desc,'#') + 1),'#',''); --ѡȡ��һ��#�������ݲ���ȥ������#
        vc_condition := replace(replace(vc_condition,'@tab1','a'),'@tab2','a1');--�滻��@tab1��@tab1
        vc_condition := replace(replace(vc_condition,'@dprev',' to_number('||v_prevdate||')'),'@d',N_loopdate1);

        --vc_condtA := replace(replace(replace(substr(cur.vc_desc,instr(cur.vc_desc,'#')+1),'#',''),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtAsql := replace(vc_condtA,'''','''''');--����sql

          ls_sql := 'select count(1) from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condition;

          if N_loopdate1 is not null then
             EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
             EXECUTE IMMEDIATE ls_sql2 into f_chk_cn; --�ж��Ƿ�ͨ���˲�
          end if;

          if f_count = 0 and N_loopdate1 is not null then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate1,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0 and N_loopdate1 is not null then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate1||''','''||ls_sql2
              ||''' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA
              ;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           --N_loopdate := N_loopdate + 1;
           end loop;



--�в��� ����Ϊvarchar
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then
         N_loopdate := to_number(I_STARTDATE);


           while N_loopdate <= to_number(I_ENDDATE) loop
                 --v_loopdate := to_char(d_loopdate);
            --������һ��
                  if lower(cur.vc_is_tradedate) = 'date'  then
                     v_prevdate := to_char(N_loopdate - 1);--��Ȼ��
                     N_loopdate1 := N_loopdate;

                    elsif lower(cur.vc_is_tradedate) = 'trade' then
                         select case when a.f_hols_day=1 then to_number(to_char(a.d_date,'yyyymmdd'))
                                else null--to_number(to_char(a.d_prev_date,'yyyymmdd'))
                                end
                           into N_loopdate1 from dim_sys_time a
                         where a.d_date=to_date(to_char(N_loopdate),'yyyymmdd');--У�������ж�

                         if N_loopdate1 is not null then
                             select to_char(a.d_prev_date,'yyyymmdd')
                                    into v_prevdate
                             from dim_sys_time a
                             where a.d_date=to_date(N_loopdate1,'yyyymmdd');--������
                         end if;

                    elsif lower(cur.vc_is_tradedate) = 'work' then
                          select case when a.f_hols_day_bank = 1 then to_number(to_char(a.d_date,'yyyymmdd'))
                                 else null--to_number(to_char(a.d_prev_date,'yyyymmdd'))
                                 end
                            into N_loopdate1 from dim_sys_time a
                         where a.d_date=to_date(to_char(N_loopdate),'yyyymmdd');

                          if N_loopdate1 is not null then
                              select to_char(a.d_prev_date,'yyyymmdd')
                                     into v_prevdate
                              from dim_sys_time a
                              where a.d_date=to_date(to_char(N_loopdate1),'yyyymmdd');--������
                          end if;

                   end if;

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

        vc_showname := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1','a'),'@tab2','a1');--����չʾ�ֶ�
        vc_condtA := replace(cur.vc_desc,'#','');--ѡȡ��һ��#�������ݲ���ȥ������#
        vc_condtA := replace(replace(vc_condtA,'@tab1','a'),'@tab2','a1');--�滻��@tab1��@tab1

        vc_condition := replace(substr(cur.vc_desc,instr(cur.vc_desc,'#') + 1),'#',''); --ѡȡ��һ��#�������ݲ���ȥ������#
        vc_condition := replace(replace(vc_condition,'@tab1','a'),'@tab2','a1');--�滻��@tab1��@tab1
        vc_condition := replace(replace(vc_condition,'@dprev',v_prevdate),'@d',' to_char('||N_loopdate1||')');--�滻����

        --vc_condtA := replace(vc_condtA,'@p','(a.'||cur.vc_col||'/'||'a1.'||cur.vc_col||' - 1)');--@p�滻Ϊ �����ֶεı�ֵ
        vc_condtA := replace(replace(vc_condtA,'@dprev',v_prevdate),'@d',' to_char('||N_loopdate1||')');--�滻����
        --vc_condtA := replace(replace(replace(substr(cur.vc_desc,instr(cur.vc_desc,'#')+1),'#',''),'@p',cur.vc_col),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
        vc_condtAsql := replace(vc_condtA,'''','''''');--����sql

          ls_sql := 'select count(1) from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select '||vc_showcol||' from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA;

          ls_sql2 := 'select count(1) from '||cur.vc_table_name||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condition;

          if N_loopdate1 is not null then
             EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
             EXECUTE IMMEDIATE ls_sql2 into f_chk_cn;
          end if;

          if f_count = 0  and N_loopdate1 is not null then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);


          elsif f_count <> 0  and N_loopdate1 is not null then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,ls_sql1,f_chk_cn);

           --������ϸ��

              ls_sql2 := 'select '||vc_showcol||' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate1||''','''||ls_sql2
              ||''' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA
              ;

              EXECUTE IMMEDIATE ls_sql1;
              commit;

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;




       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and*/ a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0008;


  PROCEDURE P_A0009 (I_STARTDATE IN VARCHAR2,
                     I_ENDDATE   IN VARCHAR2,
                     V_CKCODE    IN VARCHAR2,
                     O_ERRCODE   OUT INTEGER,
                     O_ERRMSG    OUT VARCHAR2) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-10-10
    * �� �� �ţ�  1.1.1
    *
    * ��    ���� ����->�������ݵĿ�ʼ����-��������-У������
                 ����-> ���������ʹ�������
    *
    * �������̣�  STEP1. �ж��Ƿ��в���
                  STEP2. �ж��Ƿ��д�������
    *             STEP3. ��־������
    *             STEP4.
    *             STEP5.
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

    ls_sql      varchar (4000);
    ls_sql1     varchar (4000);
    ls_sql2     varchar (4000);
    vc_chkcode  varchar (200);
    vc_tabname  varchar (200);
    vc_showname varchar (2000);
    vc_showcol  varchar (2000);
    vc_condtA   varchar (2000);--A0002 A0003
    vc_condtAsql   varchar (2000);--A0002 A0003
    f_count     number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate   date;
    --d_cktradedate date;--�ж������Ƿ�Ҫִ�н�����
    --d_ckworkdate date;--�ж������Ƿ�Ҫִ�й�����
    v_datetype  varchar (20);--У������


  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_table_name,
                   a.vc_check_content vc_col,
                   a.vc_cehck_condt vc_desc,
                   a.vc_show_key,a.vc_is_parameter,a.vc_parameter_type,a.VC_CHECK_REMARK,a.vc_is_tradedate
            from chk_config_info a
            where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
            and a.vc_rule_code='A0009'
            and sysdate between a.d_begindate and a.d_enddate
            )

    loop
      vc_chkcode := cur.vc_check_code;--У������ C****
      vc_tabname := cur.vc_table_name;--���� tpa_******
      vc_showcol := replace(replace(replace(cur.vc_show_key,'#',','),'@tab1','a'),'@tab2','a1');--չʾ�ֶ�



--û�в���

--�в��� ����Ϊdate
       if cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then
          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');


           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop
                 v_loopdate := to_char(d_loopdate);

            --����У������
                  if lower(cur.vc_is_tradedate) = 'date'  then
                     v_datetype := to_char(D_loopdate,'yyyymmdd');--��Ȼ��

                    elsif lower(cur.vc_is_tradedate) = 'trade' then

                     select case when a.f_hols_day=1 then to_char(a.d_date,'yyyymmdd')
                            else null--to_char(a.d_prev_date,'yyyymmdd')
                            end
                       into v_datetype from dim_sys_time a
                     where a.d_date=D_loopdate;--������

                    elsif lower(cur.vc_is_tradedate) = 'work' then
                      select case when a.f_hols_day_bank = 1 then to_char(a.d_date,'yyyymmdd')
                             else null--to_char(a.d_prev_date,'yyyymmdd')
                             end
                        into v_datetype from dim_sys_time a
                     where a.d_date=D_loopdate;--������

                   end if;

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  --(cur.vc_check_code,d_logdate,to_date(v_datetype,'yyyymmdd'),2);
                  (cur.vc_check_code,d_logdate,nvl(to_date(v_datetype,'yyyymmdd'),D_loopdate),2);
                  commit;

        vc_showname := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1','a'),'@tab2','a1');--����չʾ�ֶ�
        vc_condtA := replace(cur.vc_desc,'@d',' to_date('''||v_datetype||''',''yyyymmdd'')');--�滻����
        vc_condtAsql := replace(vc_condtA,'''','''''');--����sql

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select * from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�

          if f_count > 0 and v_datetype is not null then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(v_datetype,'yyyymmdd'),f_count,ls_sql1);


          elsif f_count = 0 and v_datetype is not null then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(v_datetype,'yyyymmdd'),f_count,ls_sql1);

 /*          --������ϸ��

              ls_sql2 := 'select * from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_datetype||''','''||ls_sql2
              ||''' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA
              ;

              EXECUTE IMMEDIATE ls_sql1;
              commit;*/

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           D_loopdate := D_loopdate + 1;
           end loop;


--�в��� ����Ϊnumber
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then
          N_loopdate := to_number(I_STARTDATE);


           while N_loopdate <= to_number(I_ENDDATE) loop
                 --v_loopdate := to_char(d_loopdate);
            --����У������
                  if lower(cur.vc_is_tradedate) = 'date'  then
                     v_datetype := to_char(N_loopdate,'yyyymmdd');--��Ȼ��

                    elsif lower(cur.vc_is_tradedate) = 'trade' then
                     select case when a.f_hols_day=1 then to_char(a.d_date,'yyyymmdd')
                            else null--to_char(a.d_prev_date,'yyyymmdd')
                            end
                       into v_datetype from dim_sys_time a
                     where a.d_date=to_date(N_loopdate,'yyyymmdd');--������

                    elsif lower(cur.vc_is_tradedate) = 'work' then
                      select case when a.f_hols_day_bank = 1 then to_char(a.d_date,'yyyymmdd')
                             else null--to_char(a.d_prev_date,'yyyymmdd')
                             end
                        into v_datetype from dim_sys_time a
                     where a.d_date=to_date(N_loopdate,'yyyymmdd');--������

                   end if;

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,nvl(to_date(v_datetype,'yyyymmdd'),to_date(N_loopdate,'yyyymmdd')),2);
                  commit;

        vc_showname := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1','a'),'@tab2','a1');--����չʾ�ֶ�
        vc_condtA := replace(cur.vc_desc,'@d',' to_date('''||v_datetype||''',''yyyymmdd'')');--�滻����
        vc_condtAsql := replace(vc_condtA,'''','''''');--����sql

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select * from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          if v_datetype is not null then
            EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
          end if;

          if f_count > 0 and v_datetype is not null then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(v_datetype,'yyyymmdd'),f_count,ls_sql1);


          elsif f_count = 0 and v_datetype is not null then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(v_datetype,'yyyymmdd'),f_count,ls_sql1);

 /*          --������ϸ��

              ls_sql2 := 'select * from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_datetype||''','''||ls_sql2
              ||''' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA
              ;

              EXECUTE IMMEDIATE ls_sql1;
              commit;*/

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;




--�в��� ����Ϊvarchar
       elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then
          N_loopdate := to_number(I_STARTDATE);


           while N_loopdate <= to_number(I_ENDDATE) loop
                 --v_loopdate := to_char(d_loopdate);
            --����У������
                  if lower(cur.vc_is_tradedate) = 'date'  then
                     v_datetype := to_char(N_loopdate,'yyyymmdd');--��Ȼ��

                    elsif lower(cur.vc_is_tradedate) = 'trade' then
                     select case when a.f_hols_day=1 then to_char(a.d_date,'yyyymmdd')
                            else null--to_char(a.d_prev_date,'yyyymmdd')
                            end
                       into v_datetype from dim_sys_time a
                     where a.d_date=to_date(N_loopdate,'yyyymmdd');--������

                    elsif lower(cur.vc_is_tradedate) = 'work' then
                      select case when a.f_hols_day_bank = 1 then to_char(a.d_date,'yyyymmdd')
                             else null--to_char(a.d_prev_date,'yyyymmdd')
                             end
                        into v_datetype from dim_sys_time a
                     where a.d_date=to_date(N_loopdate,'yyyymmdd');--������

                   end if;

             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,nvl(to_date(v_datetype,'yyyymmdd'),to_date(N_loopdate,'yyyymmdd')),2);
                  commit;

        vc_showname := replace(replace(replace(cur.vc_show_key,'#','||'' ; ''||'),'@tab1','a'),'@tab2','a1');--����չʾ�ֶ�
        vc_condtA := replace(cur.vc_desc,'@d',v_datetype);--�滻����
        vc_condtAsql := replace(vc_condtA,'''','''''');--����sql

          ls_sql := 'select count(1) from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          ls_sql1 := 'select * from '||cur.vc_table_name||' where 1 = 1 '||vc_condtA;

          if v_datetype is not null then
            EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
          end if;
          if f_count > 0 and v_datetype is not null then ----�˲�ͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

            INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'1',to_date(v_datetype,'yyyymmdd'),f_count,ls_sql1);


          elsif f_count = 0 and v_datetype is not null then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(v_datetype,'yyyymmdd'),f_count,ls_sql1);

 /*          --������ϸ��

              ls_sql2 := 'select * from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||
              vc_condtAsql;

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_datetype||''','''||ls_sql2
              ||''' from '||vc_tabname||' a,'||cur.vc_table_name||' a1 where 1 = 1 '||vc_condtA
              ;

              EXECUTE IMMEDIATE ls_sql1;
              commit;*/

             end if;
              --����log��־��¼
              update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
              where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                    and t.f_result = 2
              ;
              commit;
           --N_loopdate := N_loopdate + 1;
           N_loopdate := to_number(to_char(to_date(N_loopdate,'yyyymmdd')+1,'yyyymmdd'));
           end loop;




       END IF;
--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_DATE,A.D_CHECK_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where /*trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and*/ a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;
--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_table_name vc_table_name,cur.vc_col vc_check_content from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET --t.vc_status = '1',
        t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.vc_status,t.d_exectime)
                VALUES
                (t1.vc_check_code,'1',sysdate);
    commit;

    end loop;


    EXCEPTION
    WHEN OTHERS THEN

    rollback;
    --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;

      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_A0009;


PROCEDURE P_SCONFIG(I_STARTDATE IN VARCHAR2,
                    I_ENDDATE   IN VARCHAR2,
                    V_CKCODE    IN VARCHAR2,
                    O_ERRCODE   OUT INTEGER,
                    O_ERRMSG    OUT VARCHAR2) IS


    ls_sql      clob;
    ls_execsql  clob;--�в���ʱ��
    ls_sql1     clob;
    vc_chkcode  varchar (200);
    vc_tabsql   clob;--����sql����
    vc_showname varchar (2000);--չʾ�ֶ�
    f_count     number;
    F_COUNTALL  number;
    v_id        varchar (200);
    N_loopdate  number (20);
    D_loopdate  date;
    v_loopdate  varchar (20);
    d_logdate  date;--��־��ʼ����

  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    for cur in (select a.vc_check_code,a.vc_rule_code,a.vc_check_remark,a.vc_sql_config,
              a.vc_show_key ,a.vc_is_parameter,a.vc_parameter_type,a.VC_VERIFY_CONDITION
              from chk_special_config a
              --inner join fact_chk_info b on a.vc_check_code = b.vc_check_code and b.vc_status = '1'
              where case when V_CKCODE is not null then V_CKCODE else a.vc_check_code end like '%'||a.vc_check_code||'%'
              and sysdate between a.d_begindate and a.d_enddate
              )
    loop

      vc_chkcode := cur.vc_check_code;
      vc_showname := replace(cur.vc_show_key,'#','||'' ; ''||');

      --û��ʱ������
         if cur.vc_is_parameter = '0' then
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,2);
                  commit;

             ls_sql := 'select count(*) FROM ('||'SELECT *  '||to_char(substr(cur.vc_sql_config,instr(UPPER(cur.vc_sql_config),'FROM'))) || ') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
             vc_tabsql := replace(cur.vc_sql_config,'''','''''');

             --��֤������

             ls_sql1 := 'SELECT count(*) '||to_char(substr(cur.vc_sql_config,instr(UPPER(cur.vc_sql_config),'FROM')));


             EXECUTE IMMEDIATE ls_sql into f_count;
             EXECUTE IMMEDIATE ls_sql1 into F_COUNTALL;

              --�ж��Ƿ�ͨ���˲�

              if f_count = 0 then ----�˲�ͨ��
                select sys_guid() into v_id from dual; --��ȡΨһ vc_id
                 --�������ܱ�
                INSERT into fact_chk_result_gather t
                (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.VC_SQL,T.F_CHECK_AMOUNT)
                values
                (v_id,cur.vc_check_code,sysdate,'1',f_count,'SELECT * FROM ('||cur.vc_sql_config||') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION,F_COUNTALL);

              elsif f_count <> 0 then ----�˲�δͨ��
                select sys_guid() into v_id from dual; --��ȡΨһ vc_id
                 --�������ܱ�
                INSERT into fact_chk_result_gather t
                (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,t.f_count,t.VC_SQL,T.F_CHECK_AMOUNT)
                values
                (v_id,cur.vc_check_code,sysdate,'1',f_count,'SELECT * FROM ('||cur.vc_sql_config||') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION,F_COUNTALL);
              --������ϸ��
                ls_sql1 :=
                  'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.vc_sql)
                  select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||vc_tabsql||''''||to_char(substr(cur.vc_sql_config,instr(UPPER(cur.vc_sql_config),'FROM')))|| ' WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;


                  EXECUTE IMMEDIATE ls_sql1 ;
                  commit;


              end if;
          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;


      --�в��� ����Ϊnumber
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'number' then

            N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop
             --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
                  commit;

                  --ls_execsql := replace(cur.vc_sql_config,'@d','');
                  --ls_sql := 'select count(*) '||to_char(substr(ls_execsql,instr(ls_execsql,'from')))||N_loopdate;
                  --vc_tabsql := replace(ls_execsql,'''','''''')||N_loopdate;

                  ls_execsql := replace(cur.vc_sql_config,'@d',N_loopdate);
                  ls_sql := 'select count(*) FROM ('||'SELECT * '||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')))|| ') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
                  ls_sql1 := 'select count(*) '||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')));
                  vc_tabsql := 'SELECT * FROM ('||ls_execsql||') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
                  vc_tabsql := replace(vc_tabsql,'''','''''');

           EXECUTE IMMEDIATE ls_sql into f_count;
           EXECUTE IMMEDIATE ls_sql1 into f_countall;
           --�ж��Ƿ�ͨ���˲�
           if f_count = 0 then ----�˲�ͨ��

               select sys_guid() into v_id from dual; --��ȡΨһ vc_id

               INSERT into fact_chk_result_gather t
              (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,t.F_CHECK_AMOUNT)
              values
              (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,vc_tabsql,f_countall);

          elsif f_count <> 0 then ----�˲�δͨ��

               select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,t.F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,vc_tabsql,f_countall);

           --������ϸ��
           ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||vc_tabsql||''''
              ||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')))|| ' WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION
              ;

              EXECUTE IMMEDIATE ls_sql1;

          END IF;

          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           N_loopdate := N_loopdate + 1;
          end loop;


      --�в��� ����Ϊdate
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'date' then

          D_loopdate := to_date(I_STARTDATE,'yyyymmdd');

           while D_loopdate <= to_date(I_ENDDATE,'yyyymmdd') loop

                  v_loopdate := to_char(d_loopdate);
                  --����log��־
                  d_logdate := sysdate;
                  INSERT into chk_result_loginfo t
                  (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
                  values
                  (cur.vc_check_code,d_logdate,d_loopdate,2);
                  commit;

                  --ls_execsql := replace(cur.vc_sql_config,'@d','');
                  --ls_sql := 'select count(*) '||to_char(substr(ls_execsql,instr(ls_execsql,'from')))||' to_date('''||v_loopdate||''',''yyyymmdd'')';
                  --vc_tabsql := replace(ls_execsql,'''','''''')||' to_date(to_char('||D_loopdate||'),''''yyyymmdd'''')';

                  ls_execsql := replace(trim(both '"' from cur.vc_sql_config),'@d',' to_date('''||v_loopdate||''',''yyyymmdd'')');
                  ls_sql := 'select count(*) FROM ('||'SELECT * '||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')))|| ') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
                  ls_sql1 := 'select count(*) '||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')));
                  --vc_tabsql := replace(ls_execsql,'''','''''');
                  vc_tabsql := 'SELECT * FROM ('||ls_execsql||') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
                  vc_tabsql := replace(vc_tabsql,'''','''''');

           EXECUTE IMMEDIATE ls_sql into f_count; --�ж��Ƿ�ͨ���˲�
           EXECUTE IMMEDIATE ls_sql1 into f_countall;

           if f_count = 0 then ----�˲�ͨ��

           select sys_guid() into v_id from dual; --��ȡΨһ vc_id

             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,t.F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'1',D_loopdate,f_count,vc_tabsql,f_countall);
            /*
            --������ϸ��
                INSERT into FACT_CHK_RESULT_DETAIL t
                (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE)
                values
                (v_id,cur.vc_check_code,sysdate,cur.vc_check_remark || '�˲�ͨ��',D_loopdate);*/


          elsif f_count <> 0 then ----�˲�δͨ��

            select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,t.F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',D_loopdate,f_count,vc_tabsql,f_countall);

           --������ϸ��

              ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||v_loopdate||''','''||vc_tabsql||''''
              ||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')))|| ' WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION
              ;
              EXECUTE IMMEDIATE ls_sql1;

          END IF;

          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           D_loopdate := D_loopdate + 1;
           end loop;

      --�в��� ����Ϊvarchar
      elsif cur.vc_is_parameter = '1' and lower(cur.vc_parameter_type) = 'varchar' then

            N_loopdate := to_number(I_STARTDATE);

           while N_loopdate <= to_number(I_ENDDATE) loop

             --����log��־
             d_logdate := sysdate;
             INSERT into chk_result_loginfo t
             (t.vc_check_code,t.d_check_starttime,t.d_date,t.f_result)
             values
             (cur.vc_check_code,d_logdate,to_date(to_char(N_loopdate),'yyyymmdd'),2);
             commit;

             --ls_execsql := replace(cur.vc_sql_config,'@d','');
             --ls_sql := 'select count(*) '||to_char(substr(ls_execsql,instr(ls_execsql,'from')))||' to_char('||N_loopdate||')';
             --vc_tabsql := replace(ls_execsql,'''','''''')||' to_char('||N_loopdate||')';


             ls_execsql := replace(cur.vc_sql_config,'@d',' to_char('||N_loopdate||')');
             ls_sql := 'select count(*)  FROM ('||'SELECT * '||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')))|| ') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
             ls_sql1 := 'select count(*) '||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')));
             vc_tabsql := 'SELECT * FROM ('||ls_execsql||') WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION;
             vc_tabsql := replace(vc_tabsql,'''','''''');

           EXECUTE IMMEDIATE ls_sql into f_count;
           EXECUTE IMMEDIATE ls_sql1 into f_countall;
           --�ж��Ƿ�ͨ���˲�
           if f_count = 0 then ----�˲�ͨ��

               select sys_guid() into v_id from dual; --��ȡΨһ vc_id

               INSERT into fact_chk_result_gather t
              (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
              values
              (v_id,cur.vc_check_code,sysdate,'1',to_date(N_loopdate,'yyyymmdd'),f_count,vc_tabsql,f_countall);

          elsif f_count <> 0 then ----�˲�δͨ��

               select sys_guid() into v_id from dual; --��ȡΨһ vc_id

           --�������ܱ�
             INSERT into fact_chk_result_gather t
            (VC_ID,VC_CHECK_CODE,D_CHECK_DATE,VC_RESULT,D_DATE,t.f_count,t.vc_sql,F_CHECK_AMOUNT)
            values
            (v_id,cur.vc_check_code,sysdate,'2',to_date(N_loopdate,'yyyymmdd'),f_count,vc_tabsql,f_countall);

           --������ϸ��
           ls_sql1 :=
              'INSERT into FACT_CHK_RESULT_DETAIL t (t.vc_id,t.vc_check_code,t.D_CHECK_DATE,t.vc_result,t.vc_show_key,t.vc_show_detail,t.d_date,t.vc_sql)
              select '''||v_id||''','''||vc_chkcode||''',sysdate,'''||cur.vc_check_remark||' �˲�δͨ��'','''||cur.vc_show_key||''','||vc_showname||','''||N_loopdate||''','''||vc_tabsql||''''
              ||to_char(substr(ls_execsql,instr(UPPER(ls_execsql),'FROM')))|| ' WHERE 1 = 1 '||cur.VC_VERIFY_CONDITION
              ;

              EXECUTE IMMEDIATE ls_sql1;

          END IF;
          --����log��־��¼
          update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 1
          where t.vc_check_code=cur.vc_check_code and t.d_check_starttime = d_logdate
                and t.f_result = 2
          ;
          commit;

           N_loopdate := N_loopdate + 1;
          end loop;




       end if;

--fact_chk_result_gather ���µ����� F_RK
    merge into fact_chk_result_gather t
    using (select A.VC_CHECK_CODE,A.D_CHECK_DATE,A.D_DATE,
                  ROW_NUMBER()OVER(PARTITION BY A.VC_CHECK_CODE,A.D_DATE ORDER BY A.D_CHECK_DATE desc) f_rk
          from fact_chk_result_gather A
          where trunc(a.d_check_date,'dd') = trunc(sysdate,'dd') and a.vc_check_code = cur.vc_check_code
          ) t1
    on (t.vc_check_code=t1.vc_check_code and t.D_CHECK_DATE=t1.D_CHECK_DATE
        and nvl(t.d_date,date'2099-12-31') = nvl(t1.d_date,date'2099-12-31')
       )
    when MATCHED THEN
      UPDATE
    SET t.f_rk = t1.f_rk;
    commit;

--fact_chk_info
    merge into fact_chk_info t
    using (select cur.vc_check_code vc_check_code,cur.vc_rule_code vc_rule_code,cur.vc_check_remark,cur.vc_show_key from dual) t1
    on (t.vc_check_code=t1.vc_check_code)
    when MATCHED THEN
      UPDATE
    SET t.d_exectime = sysdate
     when not matched then
         INSERT (t.vc_check_code,t.d_exectime)
                VALUES
                (t1.vc_check_code,sysdate);
    commit;
    end loop;


    EXCEPTION
    WHEN OTHERS THEN
      rollback;
      --����log��־��¼
      update chk_result_loginfo t set t.d_check_endtime = sysdate,t.f_result = 0
      where t.vc_check_code = vc_chkcode and t.d_check_starttime = d_logdate
            and t.f_result = 2
      ;
      commit;
      /*dbms_output.put_line(sqlerrm);
      dbms_output.put_line(ls_sql);
      dbms_output.put_line(ls_sql1);
      dbms_output.put_line(ls_execsql);*/
      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);
  END P_SCONFIG;

  --У������ --���д洢����
  PROCEDURE P_CHECK_ALL(I_STARTDATE IN VARCHAR2,
                        I_ENDDATE   IN VARCHAR2,
                        --V_CKCODE    IN VARCHAR2,
                        O_ERRCODE   OUT INTEGER,
                        O_ERRMSG    OUT VARCHAR2) IS

  V_CKCODE    varchar(200);
  V_RULECODE  varchar(200);
  V_STARTDATE1 DATE := TO_DATE(I_STARTDATE,'YYYY-MM-DD');
  V_STARTDATE  VARCHAR2(10) := TO_CHAR(V_STARTDATE1,'YYYYMMDD');
  V_ENDDATE1 DATE := TO_DATE(I_ENDDATE,'YYYY-MM-DD');
  V_ENDDATE  VARCHAR2(10) := TO_CHAR(V_ENDDATE1,'YYYYMMDD');

  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD''';
    o_errcode := 0;
    o_errmsg  := '���гɹ�';


   -- ����P_CHECK_***ȷ��ִ�е�У������
    /*for cur in (select a.vc_rule_code,a.vc_check_code,A.D_BEGINDATE,A.D_ENDDATE from CHK_TYPE_SYSTEM a
               where a.vc_status = '1' AND (V_STARTDATE1 <=  A.D_ENDDATE  OR V_ENDDATE1>= A.D_BEGINDATE)
               )*/
    for cur in (select a.vc_rule_code,a.vc_check_code,A.D_BEGINDATE,A.D_ENDDATE from
                  (select ci.vc_rule_code,ci.vc_check_code,ci.D_BEGINDATE,ci.D_ENDDATE from CHK_CONFIG_INFO ci
                     union all
                   select cc.vc_rule_code,cc.vc_check_code,cc.D_BEGINDATE,cc.D_ENDDATE from CHK_SPECIAL_CONFIG cc
                  ) a where V_STARTDATE1 <= A.D_ENDDATE and V_ENDDATE1 >= A.D_BEGINDATE
               )
    loop
    V_CKCODE := cur.vc_check_code;
    V_RULECODE := cur.vc_rule_code;
    V_STARTDATE := TO_CHAR(V_STARTDATE1,'YYYYMMDD');
    V_ENDDATE := TO_CHAR(V_ENDDATE1,'YYYYMMDD');
    IF cur.D_BEGINDATE >= V_STARTDATE1 THEN
       V_STARTDATE  := TO_CHAR(cur.D_BEGINDATE,'YYYYMMDD');
    END IF;

    IF cur.D_ENDDATE <= V_ENDDATE1 THEN
       V_ENDDATE  := TO_CHAR(cur.D_ENDDATE,'YYYYMMDD');
    END IF;

    if V_CKCODE like 'S%' then

      P_SCONFIG(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0002' then

      P_A0002(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0003' then

      P_A0003(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0006' then

      P_A0006(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0007' then

      P_A0007(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0004' then

      P_A0004(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0005' then

      P_A0005(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0008' then

      P_A0008(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0009' then

      P_A0009(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0001' then

      P_A0001(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    end if;

   end loop;

  exception
    when others then
      o_errcode := sqlcode;
      o_errmsg  := substr('δ�����쳣:' || sqlerrm || '��' ||
                          dbms_utility.format_error_backtrace,
                          1,
                          1000);
  end P_CHECK_ALL;

  --У������ --У�鵥��У������
  PROCEDURE P_CHECK_UNIT(I_STARTDATE IN VARCHAR2,
                        I_ENDDATE   IN VARCHAR2,
                        VC_CKCODE    IN VARCHAR2,
                        O_ERRCODE   OUT INTEGER,
                        O_ERRMSG    OUT VARCHAR2) IS

  V_CKCODE    varchar(200);
  V_RULECODE  varchar(200);
  V_STARTDATE1 DATE := TO_DATE(I_STARTDATE,'YYYY-MM-DD');
  V_STARTDATE  VARCHAR2(10) := TO_CHAR(V_STARTDATE1,'YYYYMMDD');
  V_ENDDATE1 DATE := TO_DATE(I_ENDDATE,'YYYY-MM-DD');
  V_ENDDATE  VARCHAR2(10) := TO_CHAR(V_ENDDATE1,'YYYYMMDD');
  v_run_flag  integer;

  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD''';
    o_errcode := 0;
    o_errmsg  := '���гɹ�';
    v_run_flag := 0;

    --��ȡ����ִ���жϱ�־
--�ж��Ƿ�������������ִ��
/*    select count(*)
     into v_run_flag
      from tpa_etl.etl_exec_main_log t
     where t.vc_run_status in ('UNDO', 'RUNNING')
       and t.vc_code in (select mis_cde
               from tpa_etl.etl_dim_mis_grp_rel a
              where a.grp_cde in ('CHECK_ALL',

                              'CHECK_CHK_CONFIG'));*/
    v_run_flag :=0;
    if  v_run_flag = 0 then
        select count(*)
        into v_run_flag
        from chk_result_loginfo t
        where t.f_result=2;
      /*-----------------------------------------------
       stpep3�������ڳ�ͻ����ʱ�����ýӿڽ���������ϴ�����ڳ�ͻ����ʱ��ֱ���˳�
       -----------------------------------------------*/
          if  v_run_flag=0 then


   -- ����P_CHECK_***ȷ��ִ�е�У������
    /*for cur in (select a.vc_rule_code,a.vc_check_code,A.D_BEGINDATE,A.D_ENDDATE from CHK_TYPE_SYSTEM a
               where a.vc_status = '1' AND (V_STARTDATE1 <=  A.D_ENDDATE  OR V_ENDDATE1>= A.D_BEGINDATE)
               and a.vc_check_code = VC_CKCODE
               )*/
    for cur in (select a.vc_rule_code,a.vc_check_code,A.D_BEGINDATE,A.D_ENDDATE from
                  (select ci.vc_rule_code,ci.vc_check_code,ci.D_BEGINDATE,ci.D_ENDDATE from CHK_CONFIG_INFO ci
                     union all
                   select cc.vc_rule_code,cc.vc_check_code,cc.D_BEGINDATE,cc.D_ENDDATE from CHK_SPECIAL_CONFIG cc
                  ) a where V_STARTDATE1 <= A.D_ENDDATE and V_ENDDATE1 >= A.D_BEGINDATE and A.vc_check_code = VC_CKCODE
               )
    loop
    V_CKCODE := cur.vc_check_code;
    V_RULECODE := cur.vc_rule_code;
    V_STARTDATE := TO_CHAR(V_STARTDATE1,'YYYYMMDD');
    V_ENDDATE := TO_CHAR(V_ENDDATE1,'YYYYMMDD');
    IF cur.D_BEGINDATE >= V_STARTDATE1 THEN
       V_STARTDATE  := TO_CHAR(cur.D_BEGINDATE,'YYYYMMDD');
    END IF;

    IF cur.D_ENDDATE <= V_ENDDATE1 THEN
       V_ENDDATE  := TO_CHAR(cur.D_ENDDATE,'YYYYMMDD');
    END IF;

    if V_CKCODE like 'S%' then

      P_SCONFIG(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0002' then

      P_A0002(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0003' then

      P_A0003(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0006' then

      P_A0006(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0007' then

      P_A0007(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0004' then

      P_A0004(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0005' then

      P_A0005(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0008' then

      P_A0008(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0009' then

      P_A0009(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0001' then

      P_A0001(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    end if;

   end loop;


      else
    --��ǰ�г�ͻ������ִ�У���������ϴ��������ʾ
      o_errcode := 1;
      O_ERRMSG := '����:��ǰ�����������������У����Ժ����ԣ�';

      end if;

else
    --��ǰ�г�ͻ������ִ�У���������ϴ��������ʾ
    O_ERRCODE := 1;
    O_ERRMSG := '����:��ǰ�����������������У����Ժ����ԣ�';
end if;



  exception
    when others then
      o_errcode := sqlcode;
      o_errmsg  := substr('δ�����쳣:' || sqlerrm || '��' ||
                          dbms_utility.format_error_backtrace,
                          1,
                          1000);
  end P_CHECK_UNIT;


  --У������ --ÿ����������
  PROCEDURE P_CHECK_TWICE(I_STARTDATE IN VARCHAR2,
                        I_ENDDATE   IN VARCHAR2,
                        --V_CKCODE    IN VARCHAR2,
                        O_ERRCODE   OUT INTEGER,
                        O_ERRMSG    OUT VARCHAR2) IS

  V_CKCODE    varchar(200);
  V_RULECODE  varchar(200);
  V_STARTDATE1 DATE := TO_DATE(I_STARTDATE,'YYYY-MM-DD');
  V_STARTDATE  VARCHAR2(10) := TO_CHAR(V_STARTDATE1,'YYYYMMDD');
  V_ENDDATE1 DATE := TO_DATE(I_ENDDATE,'YYYY-MM-DD');
  V_ENDDATE  VARCHAR2(10) := TO_CHAR(V_ENDDATE1,'YYYYMMDD');

  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD''';
    o_errcode := 0;
    o_errmsg  := '���гɹ�';


   -- ����P_CHECK_***ȷ��ִ�е�У������
    for cur in (select a.vc_rule_code,a.vc_check_code,A.D_BEGINDATE,A.D_ENDDATE from CHK_TYPE_SYSTEM a
               where a.vc_status = '1' AND (V_STARTDATE1 <=  A.D_ENDDATE  OR V_ENDDATE1>= A.D_BEGINDATE)
               and to_number(a.vc_desc) >= 2
               )
    loop
    V_CKCODE := cur.vc_check_code;
    V_RULECODE := cur.vc_rule_code;
    V_STARTDATE := TO_CHAR(V_STARTDATE1,'YYYYMMDD');
    V_ENDDATE := TO_CHAR(V_ENDDATE1,'YYYYMMDD');
    IF cur.D_BEGINDATE >= V_STARTDATE1 THEN
       V_STARTDATE  := TO_CHAR(cur.D_BEGINDATE,'YYYYMMDD');
    END IF;

    IF cur.D_ENDDATE <= V_ENDDATE1 THEN
       V_ENDDATE  := TO_CHAR(cur.D_ENDDATE,'YYYYMMDD');
    END IF;

    if V_CKCODE like 'S%' then

      P_SCONFIG(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0002' then

      P_A0002(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0003' then

      P_A0003(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0006' then

      P_A0006(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0007' then

      P_A0007(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0004' then

      P_A0004(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0005' then

      P_A0005(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0008' then

      P_A0008(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0009' then

      P_A0009(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    elsif V_RULECODE = 'A0001' then

      P_A0001(V_STARTDATE,V_ENDDATE,V_CKCODE,O_ERRCODE,O_ERRMSG);

    end if;

   end loop;

  exception
    when others then
      o_errcode := sqlcode;
      o_errmsg  := substr('δ�����쳣:' || sqlerrm || '��' ||
                          dbms_utility.format_error_backtrace,
                          1,
                          1000);
  end P_CHECK_TWICE;




  PROCEDURE P_CHECK_GZ (
                       O_ERRCODE   OUT INTEGER,
                       O_ERRMSG    OUT VARCHAR2
                       ) IS
    /*****************************************************************************\
    *                           ̫ƽ�ʲ���������
    *           COPYRIGHT (C) 2013, ׿����Ϣ����(�Ϻ�)���޹�˾
    * ===========================================================================
    *
    * �洢��������У������GZ
    * ��     �ߣ� Xu Caojun
    * �������ڣ�  2017-11-9
    * �� �� �ţ�  1.1.1
    *
    * ��    ����
    *
    * �������̣�
    * �޸���ʷ��  �޸�ʱ��        �޸���         �޸ĵ��ĸ�����     �޸�ԭ��
    *
    *
    \*****************************************************************************/

  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYYMMDD''';

    O_ERRCODE   := 0;
    O_ERRMSG    := '���гɹ�';

    --��������ΪGZ��״̬
    update CHK_TYPE_SYSTEM a
    set a.vc_status= case when a.vc_class='GZ' then '1' else '0' end
    ;

      commit;


      O_ERRCODE := SQLCODE;
      O_ERRMSG  := SUBSTR('δ�����쳣:' || SQLERRM || '��' ||
                          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                          1,
                          1000);

  END P_CHECK_GZ;




END PKG_CHK_CONFIG;
/
