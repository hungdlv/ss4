create or replace PACKAGE BODY pkg_Baocaokho AS 

PROCEDURE getNhap_Xuat_Kho
(
    pLoaikho in varchar2,
    pKCL in varchar2,
    Cur       OUT SYS_REFCURSOR
) IS
 v_sql VARCHAR2(32767)   := NULL;
  v_NOI_NHAN_NK VARCHAR2(32767)   := NULL;
  v_loaikho varchar2(100) := pLoaikho; --'KIA';--PEUGEOT or  MAZDA or KIA : TEN KHO
  v_dongxe varchar(10) := NULL;-- dong xe --kia: 5142, mazda: 5166, peugeot: 5302
  v_space nvarchar2(100):='''''';
BEGIN
  IF v_loaikho = 'MAZDA' THEN
    SELECT RTRIM(XMLAGG(XMLELEMENT(E, UPPER(TRIM(a.NOI_NHAN_NK)), ',').EXTRACT('//text()') ORDER BY a.NOI_NHAN_NK).GetClobVal(),',') AS LIST
        INTO v_NOI_NHAN_NK
        from (select MAKHO AS NOI_NHAN_NK from khoxekhuvucmazda where UPPER(tenkho) not like '%PEUGEOT%') a;
        v_dongxe := '5166';

  ELSIF  v_loaikho = 'PEUGEOT' THEN
    SELECT RTRIM(XMLAGG(XMLELEMENT(E, UPPER(TRIM(a.NOI_NHAN_NK)), ',').EXTRACT('//text()') ORDER BY a.NOI_NHAN_NK).GetClobVal(),',') AS LIST
        INTO v_NOI_NHAN_NK
        from (select MAKHO AS NOI_NHAN_NK from khoxekhuvucmazda where UPPER(tenkho) not like '%MAZDA%') a;
        v_dongxe := '5302';
  ELSIF  v_loaikho = 'KIA' THEN   
    SELECT RTRIM(XMLAGG(XMLELEMENT(E, UPPER(TRIM(a.NOI_NHAN_NK)), ',').EXTRACT('//text()') ORDER BY a.NOI_NHAN_NK).GetClobVal(),',') AS LIST
        INTO v_NOI_NHAN_NK
        from (select MAKHO AS NOI_NHAN_NK from khoxekhuvuc) a;
        v_dongxe := '5142';
  END IF;
        
        v_NOI_NHAN_NK := ''''||v_NOI_NHAN_NK ||'''';
        v_NOI_NHAN_NK :=  replace(v_NOI_NHAN_NK,',',''''||','||'''');    
        
        if pKCL = 'KCL' then
          v_NOI_NHAN_NK := v_NOI_NHAN_NK || ',''KCL''';
        end if;
          
          v_sql := 'WITH Result_Table AS ( ' ||
          'SELECT* FROM (select lx.maloaixe, lx.tenloaixe, a.IDMAUXE, mx.CODEMAU, mx.TENMAU, a.NOI_NHAN_NK as NK from nhap_xuat_kho a ' ||
        --'SELECT A.maloaixe, A.tenloaixe, A.IDMAUXE, mx.CODEMAU, mx.TENMAU,  A.NK FROM (select lx.maloaixe, lx.tenloaixe, a.IDMAUXE, a.NOI_NHAN_NK as NK from nhap_xuat_kho a ' ||
        'right join ( SELECT c.maloaixe, c.tenloaixe ' ||
          'FROM NHOMLOAIXE a ' ||
          'join DONGXE b on b.madongxe = a.madongxe ' ||
          'join LOAIXE c on c.manhom = a.manhom ' ||
          'where b.madongxe = '|| v_dongxe ||') lx on lx.maloaixe=a.idloaixe ' ||          
           'join MAUXE mx on mx.MAMAU=a.IDMAUXE ) ' ||
          ')' || 
          'SELECT * FROM Result_Table ' ||
  'PIVOT ' ||
      '( ' ||
        'count(NK) ' ||
        'FOR NK ' ||
        'IN ( '|| v_NOI_NHAN_NK ||')  ' ||
      ') ' ||
     
      'union all ' ||
      'select * from (  SELECT 99999 maloaixe, '|| v_space  ||' as tenloaixe,  99999 IDMAUXE,  '|| v_space  ||' as CODEMAU,  '|| v_space  ||' as TENMAU, NK FROM Result_Table ) a ' ||
      'PIVOT ' ||
      '( ' ||
        'count(NK) ' ||
        'FOR NK ' ||
        'IN ( '|| v_NOI_NHAN_NK ||')  ' ||
      ') ';          
          
        /*   
      v_sql := 'SELECT * FROM ' ||
      '( ' ||
        'select lx.maloaixe, lx.tenloaixe, a.IDMAUXE, mx.CODEMAU, mx.TENMAU, a.NOI_NHAN_NK as NK from nhap_xuat_kho a ' ||
       -- 'right join MAUXE mx on mx.CODEMAU=a.ma_mau ' ||
        'right join ( SELECT c.maloaixe, c.tenloaixe ' ||
          'FROM NHOMLOAIXE a ' ||
          'join DONGXE b on b.madongxe = a.madongxe ' ||
          'join LOAIXE c on c.manhom = a.manhom ' ||
          'where b.madongxe = '|| v_dongxe ||') lx on lx.maloaixe=a.idloaixe ' ||          
           'join MAUXE mx on mx.MAMAU=a.IDMAUXE ' ||
          
      ') ' ||
      'PIVOT ' ||
      '( ' ||
        'count(NK) ' ||
        'FOR NK ' ||
        'IN ( '|| v_NOI_NHAN_NK ||')  ' ||
      ') ' ||
      'ORDER BY maloaixe ASC' ;
      */
     DBMS_OUTPUT.PUT_LINE(v_sql);
     OPEN Cur FOR v_sql;     
END getNhap_Xuat_Kho;

PROCEDURE getYeucaugiaoxe(
    pLoaikho in varchar2,
    Cur       OUT SYS_REFCURSOR
) IS
  v_sql VARCHAR2(32767)   := NULL;
  v_NOI_NHAN_NK VARCHAR2(32767)   := NULL;
  v_loaikho varchar2(100) := pLoaikho; --'KIA';--PEUGEOT or  MAZDA or KIA : TEN KHO
  v_dongxe varchar(10) := NULL;-- dong xe --kia: 5142, mazda: 5166, peugeot: 5302
  v_space nvarchar2(100):='''''';
BEGIN
  IF v_loaikho = 'MAZDA' THEN
    SELECT RTRIM(XMLAGG(XMLELEMENT(E, UPPER(TRIM(a.NOI_NHAN_NK)), ',').EXTRACT('//text()') ORDER BY a.NOI_NHAN_NK).GetClobVal(),',') AS LIST
        INTO v_NOI_NHAN_NK
        from (select MAKHO AS NOI_NHAN_NK from khoxekhuvucmazda where UPPER(tenkho) not like '%PEUGEOT%') a;
        v_dongxe := '5166';

  ELSIF  v_loaikho = 'PEUGEOT' THEN
    SELECT RTRIM(XMLAGG(XMLELEMENT(E, UPPER(TRIM(a.NOI_NHAN_NK)), ',').EXTRACT('//text()') ORDER BY a.NOI_NHAN_NK).GetClobVal(),',') AS LIST
        INTO v_NOI_NHAN_NK
        from (select MAKHO AS NOI_NHAN_NK from khoxekhuvucmazda where UPPER(tenkho) not like '%MAZDA%') a;
        v_dongxe := '5302';
  ELSIF  v_loaikho = 'KIA' THEN   
    SELECT RTRIM(XMLAGG(XMLELEMENT(E, UPPER(TRIM(a.NOI_NHAN_NK)), ',').EXTRACT('//text()') ORDER BY a.NOI_NHAN_NK).GetClobVal(),',') AS LIST
        INTO v_NOI_NHAN_NK
        from (select MAKHO AS NOI_NHAN_NK from khoxekhuvuc) a;
        v_dongxe := '5142';
  END IF;
        
        v_NOI_NHAN_NK := ''''||v_NOI_NHAN_NK ||'''';
        v_NOI_NHAN_NK :=  replace(v_NOI_NHAN_NK,',',''''||','||'''');        
        --dbms_output.put_line(v_NOI_NHAN_NK);
        
        
        v_sql := 'WITH Result_Table AS
  (' ||
    'select lx.maloaixe, lx.tenloaixe, a.IDMAUXE, mx.CODEMAU, mx.TENMAU, a.MANOIDEN as NK from ycgx_detail a ' ||
        'right join ( SELECT c.maloaixe, c.tenloaixe ' ||
          'FROM NHOMLOAIXE a ' ||
          'join DONGXE b on b.madongxe = a.madongxe ' ||
          'join LOAIXE c on c.manhom = a.manhom ' ||
          'where b.madongxe = '|| v_dongxe ||') lx on lx.maloaixe=a.idloaixe ' ||
          'join MAUXE mx on mx.MAMAU=a.IDMAUXE ' ||  
  ') ' ||
   'SELECT * FROM Result_Table ' ||
  'PIVOT ' ||
      '( ' ||
        'count(NK) ' ||
        'FOR NK ' ||
        'IN ( '|| v_NOI_NHAN_NK ||')  ' ||
      ') ' ||
     
      'union all ' ||
      'select * from (  SELECT 99999 maloaixe, '|| v_space  ||' as tenloaixe,  99999 IDMAUXE,  '|| v_space  ||' as CODEMAU,  '|| v_space  ||' as TENMAU, NK FROM Result_Table ) a ' ||
      'PIVOT ' ||
      '( ' ||
        'count(NK) ' ||
        'FOR NK ' ||
        'IN ( '|| v_NOI_NHAN_NK ||')  ' ||
      ') ';
	  
     DBMS_OUTPUT.PUT_LINE(v_sql);
     OPEN Cur FOR v_sql;
END getYeucaugiaoxe;


PROCEDURE getChitiet_Nhap_Xuat_Kho
(
  pLoaikho in varchar2,
  pidloaixe in number,
  pidmauxe in number,
  Cur       OUT SYS_REFCURSOR
) IS
BEGIN
 open Cur for
  select c.maloaixe, c.tenloaixe, a.IDMAUXE, mx.CODEMAU, mx.TENMAU, a.NOI_NHAN_NK as NK, a.SO_KHUNG, a.SO_MAY, a.MAU, TO_CHAR(a.NGAY_NHAN_NK, 'dd/mm/yyyy') NGAYNHAP
  from nhap_xuat_kho a 
  join LOAIXE c on c.maloaixe = a.idloaixe
  join MAUXE mx on mx.MAMAU=a.IDMAUXE
  where a.idloaixe = pidloaixe and a.idmauxe=pidmauxe and a.NOI_NHAN_NK=pLoaikho;
END getChitiet_Nhap_Xuat_Kho;

PROCEDURE getChitiet_Yeucaugiaoxe
(
  pLoaikho in varchar2,
  pidloaixe in number,
  pidmauxe in number,
  Cur       OUT SYS_REFCURSOR
) IS
BEGIN
    open Cur for
    select lx.maloaixe, lx.tenloaixe, a.IDMAUXE, mx.CODEMAU, mx.TENMAU, a.MANOIDEN as NK, a.SOKHUNG, a.SOMAY from ycgx_detail a 
    join LOAIXE lx on lx.maloaixe=a.idloaixe 
    join MAUXE mx on mx.MAMAU=a.IDMAUXE
    where a.IDLOAIXE=pidloaixe and a.IDMAUXE=pidmauxe and a.MANOIDEN=pLoaikho;
END getChitiet_Yeucaugiaoxe;


END pkg_Baocaokho;