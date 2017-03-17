create or replace PACKAGE BODY PKG_HANHX_BIEUDOKHTN AS

  PROCEDURE SP_BCKHTN_ByTinhTrang  
   (
     pMaDV IN number,
     pMaNhanVien varchar2,
     pMaChucVu in number,
     pFromDate in varchar2,
     pToDate in varchar2,
     Cur out SYS_REFCURSOR
   ) IS

    v_Tong nvarchar2(100):='Total';
    v_All nvarchar2(100):='zzzz';
    v_p_TD nvarchar2(100):='%TD';
    v_p_OK nvarchar2(100):='%GD';
    v_p_Fail nvarchar2(100):='%TD_Fail';
  BEGIN
    open Cur for 
    with LISTDATA AS
(

SELECT	 dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenDm,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM	
  (
  select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,Pmadv)>0
   
    WHERE ntv.madonvi=Pmadv
         AND  ntv.NhomTruong=pMaNhanVien  
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,Pmadv)>0
    WHERE ntv.madonvi=Pmadv
         AND instr(ntv.DsXemNhom,pMaNhanVien)>0 and pMaChucVu=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,Pmadv)>0
    WHERE ntv.madonvi=Pmadv 
        and pMaChucVu<>2 and pMaChucVu<>3 
          )) dstvbh
  left outer join (select * from theodoikhtn where theodoikhtn.MaDV=pMaDV and  trunc(theodoikhtn.ngaytiepxuc) >=trunc(to_date(pFromDate,'dd/mm/yyyy'))
			AND trunc(theodoikhtn.ngaytiepxuc) <= trunc(to_date(pToDate,'dd/mm/yyyy'))
      ) khtn on dstvbh.MaNV=khtn.TuVanBH
  left outer join 
			(SELECT	 *
				FROM	 dmChung
			  WHERE	 LoaiDm = 'TinhTrangKHTN' AND TinhTrang = 1) chung on  INSTR (khtn.TinhTrangKHS, chung.MaDm) > 0       
 
      

			
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenDm 
)
select * from (

select * from (

    select * from LISTDATA
    
    union 
    select Tennhomtvbh,TenNV,v_Tong TenDm,sum(val) val,1 as TrangThai
    from LISTDATA where TenDm in('Hot','Warm','Cool','Khác')
    group by Tennhomtvbh,TenNV
    
    union 
    select Tennhomtvbh,v_Tong TenNV,TenDm,sum(val) val,2 as TrangThai
    from LISTDATA 
    group by Tennhomtvbh,TenDm
    
      union 
    select  Tennhomtvbh,v_Tong TenNV,v_Tong TenDm,sum(val) val,2 as TrangThai
    from LISTDATA where  TenDm in('Hot','Warm','Cool','Khác')
    group by Tennhomtvbh
    union 
    select v_All Tennhomtvbh,v_Tong TenNV,TenDm,sum(val) val,3 as TrangThai
    from LISTDATA 
    group by TenDm
    union
    select v_All Tennhomtvbh,v_Tong TenNV,v_Tong TenDm,sum(val) val,3 as TrangThai
    from LISTDATA where  TenDm in('Hot','Warm','Cool','Khác')   
    
    union
    select Tennhomtvbh,TenNV,v_p_TD TenDm,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select Tennhomtvbh,TenNV,v_Tong TenDm,sum(val) val
    from LISTDATA where TenDm in('Hot','Warm','Cool','Khác')
    group by Tennhomtvbh,TenNV ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA where  TenDm in('Hot','Warm','Cool','Khác')  
    )  s
    union
    select Tennhomtvbh,v_Tong TenNV,v_p_TD TenDm,sum(val) val,2 TrangThai
    from(
    select Tennhomtvbh,TenNV,v_p_TD TenDm,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select Tennhomtvbh,TenNV,v_Tong TenDm,sum(val) val
    from LISTDATA where TenDm in('Hot','Warm','Cool','Khác')
    group by Tennhomtvbh,TenNV ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA where  TenDm in('Hot','Warm','Cool','Khác')  
    )  s
    ) group by Tennhomtvbh
    
    union
  
    select Tennhomtvbh,v_Tong TenNV,v_p_OK TenDm,decode(sum(valTD),0,0,round(sum(valOK)*100/sum(valTD),1)) val,2 as TrangThai
    from (
      select Tennhomtvbh,sum(val) valOK,0 valTD
    from LISTDATA where TenDm in('OK')
    group by Tennhomtvbh
    union
     select Tennhomtvbh,0 valOK,sum(val) valTD
    from LISTDATA where TenDm in('Hot','Warm','Cool','Khác')
    group by Tennhomtvbh
    )
    group by Tennhomtvbh
    union
   select Tennhomtvbh,TenNV,v_p_Ok TenDm,decode(sum(valTD),0,0,round(sum(valOK)*100/sum(valTD),1)) val,1 as TrangThai
    from (
      select Tennhomtvbh,TenNV,sum(val) valOK,0 valTD
    from LISTDATA where TenDm in('OK')
    group by Tennhomtvbh,TenNV
    union
     select Tennhomtvbh,TenNV,0 valOK,sum(val) valTD
    from LISTDATA where TenDm in('Hot','Warm','Cool','Khác')
    group by Tennhomtvbh,TenNV
    )
    group by Tennhomtvbh,TenNV
    union
    select Tennhomtvbh,v_Tong TenNV,v_p_Fail TenDm,sum(val) val,2 TrangThai
    from(
    select Tennhomtvbh,TenNV,v_p_TD TenDm,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select Tennhomtvbh,TenNV,v_Tong TenDm,sum(val) val
    from LISTDATA where TenDm in('Fail')
    group by Tennhomtvbh,TenNV ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA where  TenDm in('Fail')  
    )  s
    ) group by Tennhomtvbh
    
   
     union
     select Tennhomtvbh,TenNV,v_p_Fail TenDm,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select Tennhomtvbh,TenNV,v_Tong TenDm,sum(val) val
    from LISTDATA where TenDm in('Fail')
    group by Tennhomtvbh,TenNV ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA where  TenDm in('Fail')  
    )  s
    union
    select v_All Tennhomtvbh,v_Tong TenNV,v_p_TD TenDm,100 val,3 as TrangThai
    from dual
     union
   
    
     select v_All Tennhomtvbh,v_Tong TenNV,v_p_OK TenDm,decode(sum(valTD),0,0,round(sum(valOK)*100/sum(valTD),1)) val,3 as TrangThai
    from (
      select sum(val) valOK,0 valTD
    from LISTDATA where TenDm in('OK')
  
    union
     select 0 valOK,sum(val) valTD
    from LISTDATA where TenDm in('Hot','Warm','Cool','Khác')
    )
  
    union
    select v_All Tennhomtvbh,v_Tong TenNV,v_p_Fail TenDm,100 val,3 as TrangThai
    from dual
   
    
  )
  
    
    PIVOT 
    (
      sum(val)
      FOR TenDm
      IN ('Hot','Warm','Cool','Khác','Total','%TD','OK','%GD','Fail','%TD_Fail')
    )
)
order by Tennhomtvbh,TrangThai;
          
          
    
  END SP_BCKHTN_ByTinhTrang;

   PROCEDURE SP_BCKHTN_ByKenhTX  
   (
     pMaDV IN number,
       pMaNhanVien varchar2,
     pMaChucVu in number,
     pFromDate in varchar2,
     pToDate in varchar2,
     Cur out SYS_REFCURSOR
   )
  IS
   
    v_TDA VARCHAR2(100):='_TD';
    v_TCA VARCHAR2(100):='_TC';
    v_TD varchar2(100):='''_TD''';
    v_TC varchar2(100):='''_TC''';
    v_Tong_TD VARCHAR2(100):='''Total_TD''';
    v_Tong_TC VARCHAR2(100):='''Total_TC''';
    v_Tong VARCHAR2(100):='''Total''';
    v_All VARCHAR2(100):='''yyyy''';
     v_All_p VARCHAR2(100):='''zzzz''';
     v_TheoLoaiXe VARCHAR2(1000):='''% GD / Kênh TT''';
     v_list VARCHAR2(4000):='';
    v_Sql varchar2(32767):=null;
  Formatdate VARCHAR(100) := '''dd/MM/yyyy''';
   v_a varchar(100):='';
    v_nhomdongxe VARCHAR2(2000):='';
    v_nhomTD VARCHAR2(2000):='';
    v_nhomTC VARCHAR2(2000):='';

  BEGIN
 SELECT Listagg(''''||TenNhom||'_TD'||'''', ',') Within GROUP(ORDer BY ThuTuHienThi ASC)
   
into v_nhomTD
from (
  SELECT cast(TenDm as varchar(2000)) TenNhom , ThuTuHienTHi
	 FROM   DmChung
	WHERE   LoaiDm = 'KenhTiepXuc' AND TinhTrang = 1
ORDER BY   ThuTuHienTHi
) abc ;

  v_list:=v_nhomTD||','||''''||'Total_TD'||''''||','||REPLACE( v_nhomTD, '_TD','_TC' )||','||''''||'Total_TC'||'''';
  dbms_output.put_line(v_list);
    v_sql:='
    with LISTDATA_TD AS
(

SELECT	 cast(dstvbh.Tennhomtvbh as varchar2(2000)) Tennhomtvbh ,cast(dstvbh.TenNV as varchar2(2000)) TenNV,chung.TenNhom||'||v_TD||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM	
  (
 select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,'||Pmadv||')>0
   
    WHERE ntv.madonvi='||Pmadv||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||' 
        and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 
          )) dstvbh left join
 (select * from TheoDoiKhtn khtn where khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
			AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
    AND INSTR (khtn.TinhTrangKHS,5605)<= 0  
      ) khtn on  dstvbh.MaNV=khtn.TuVanBH
      left join 
						(  SELECT MaDM,cast(TenDm as varchar(2000)) TenNhom , ThuTuHienTHi
     FROM   DmChung
    WHERE   LoaiDm = ''KenhTiepXuc'' AND TinhTrang = 1) chung on INSTR (khtn.KenhTXS,chung.MaDM) > 0       
      
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenNhom 
),LISTDATA_TC AS
(

SELECT	 cast(dstvbh.Tennhomtvbh as varchar2(2000)) Tennhomtvbh ,cast(dstvbh.TenNV as varchar2(2000)) TenNV,chung.TenNhom||'||v_TC||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM	
  (
  select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,'||Pmadv||')>0
   
    WHERE ntv.madonvi='||Pmadv||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||' 
        and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 
          )) dstvbh left join
 (select * from TheoDoiKhtn khtn where khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
			AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
    AND INSTR (khtn.TinhTrangKHS,5605)> 0  
      ) khtn on  dstvbh.MaNV=khtn.TuVanBH
      left join 
						(  SELECT MaDM,cast(TenDm as varchar(2000)) TenNhom , ThuTuHienTHi
     FROM   DmChung
    WHERE   LoaiDm = ''KenhTiepXuc'' AND TinhTrang = 1) chung on INSTR (khtn.KenhTXS,chung.MaDM) > 0       
      
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenNhom 
)
select * from (

select * from (

    select * from LISTDATA_TD
    union 
     select * from LISTDATA_TC
union 
    select Tennhomtvbh,TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TD  
    group by Tennhomtvbh,TenNV
     union 
    select Tennhomtvbh,TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TC  
    group by Tennhomtvbh,TenNV
    
    union 
    select Tennhomtvbh,'||v_Tong||' TenNV,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD 
    group by Tennhomtvbh,TenNhom
 union 
    select Tennhomtvbh  ,'||v_Tong||' TenNV,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC 
    group by Tennhomtvbh,TenNhom
    union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,TenNhom ,sum(val) val,3 as TrangThai
    from LISTDATA_TD 
    group by TenNhom
    union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,TenNhom ,sum(val) val,3 as TrangThai
    from LISTDATA_TC 
    group by TenNhom
    union
    select Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    group by Tennhomtvbh
    union
       select Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
    group by Tennhomtvbh
     union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,3 as TrangThai
    from LISTDATA_TD
  
    union
       select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,3 as TrangThai
    from LISTDATA_TC
   
    union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TC
    group by TenNHom ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TC   
    )  s
    union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TD
    group by TenNHom ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD   
    )  s
     union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||'  TenNV,'||v_Tong_TD||' TenNhom,100 val,4 as TrangThai
    from dual
    union 
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,'||v_Tong_TC||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TC
   ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD   
    )  s
   
    
  )
  
    PIVOT 
    (
      sum(val)
      FOR TenNHom
      IN ('||v_list||')
    )
)
order by Tennhomtvbh,TrangThai';
dbms_output.put_line(v_sql);

open CUr for v_sql;

  END SP_BCKHTN_ByKenhTX;

  PROCEDURE SP_BCKHTN_BYLoaiXe  
   (
     pMaDV IN number,
       pMaNhanVien varchar2,
     pMaChucVu in number,
     pFromDate in varchar2,
     pToDate in varchar2,
    
     Cur out SYS_REFCURSOR
   )IS

  
    v_TDA VARCHAR2(100):='_TD';
    v_TCA VARCHAR2(100):='_TC';
    v_TD varchar2(100):='''_TD''';
    v_TC varchar2(100):='''_TC''';
    v_Tong_TD VARCHAR2(100):='''Total_TD''';
    v_Tong_TC VARCHAR2(100):='''Total_TC''';
    v_Tong VARCHAR2(100):='''Total''';
    v_All VARCHAR2(100):='''yyyy''';
     v_All_p VARCHAR2(100):='''zzzz''';
     v_TheoLoaiXe VARCHAR2(1000):='''% theo loại xe''';
     v_list VARCHAR2(4000):='';
    v_Sql varchar2(32767):=null;
  Formatdate VARCHAR(100) := '''dd/MM/yyyy''';
   v_a varchar(100):='';
    v_nhomdongxe VARCHAR2(2000):='';
    v_nhomTD nVARCHAR2(2000):='';
    v_nhomTC VARCHAR2(2000):='';

  BEGIN
 SELECT Listagg(''''||TenNhom||'_TD'||'''', ',') Within GROUP(ORDer BY ThuTuHienThi ASC)
into v_nhomTD
from (
select  distinct TenNhom ,nlx.ThuTuHienThi from LoaiXe lx
        join NhomLoaiXe nlx on lx.MaNhom=nlx.MaNhom and lx.CheckHienThi=1 
        join DongXe dx on dx.MaDongXe=nlx.MaDongXe
        join DonVi on donvi.MaDv=pMaDV and instr(donvi.DongXes,dx.MaDongXe)>0
        where (donvi.LoaiDV=5168 and (lx.CKD=0 or lx.CKD=1)) or (donvi.LoaiDV=5170)
) abc ;
--dbms_output.put_line(v_nhomTD);
  v_list:=v_nhomTD||','||''''||'Total_TD'||''''||','||REPLACE( v_nhomTD, '_TD','_TC' )||','||''''||'Total_TC'||'''';
  --v_list:=''AUMAN_TD','AUMARK_TD','CITY BUS_TD','COUNTY_TD','FORLAND BEN_TD','FORLAND TẢI_TD','HYUNDAI BEN_TD','HYUNDAI TẢI CBU_TD','HYUNDAI TẢI_TD','KIA TẢI_TD','OLLIN_TD','TOWNER_TD','TOWN_TD','UNIVER_TD'||'''';
    v_sql:='
    with LISTDATA_TD AS
(

SELECT	 cast(dstvbh.Tennhomtvbh as varchar2(2000)) Tennhomtvbh ,cast(dstvbh.TenNV as varchar2(2000)) TenNV,chung.TenNhom||'||v_TD||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM	
  (
  select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,'||Pmadv||')>0
   
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||' 
        and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 
          )) dstvbh left join 
  (select * from TheoDoiKhtn khtn where khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
			AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
      AND INSTR (khtn.TinhTrangKHS,5605)<= 0     
      ) khtn on dstvbh.MaNV=khtn.TuVanBH
      left join
			(select nlx.TenNhom,lx.MaLoaiXe from LoaiXe lx
        join NhomLoaiXe nlx on lx.MaNhom=nlx.MaNhom and lx.CheckHienThi=1 and (lx.CKD=0 or lx.CKD=1)
        join DongXe dx on dx.MaDongXe=nlx.MaDongXe
        join DonVi on donvi.MaDv='||Pmadv||' and instr(donvi.DongXes,dx.MaDongXe)>0
      ) chung on INSTR (khtn.XeQuanTam,chung.MaLoaiXe) > 0    
      
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenNhom 
),LISTDATA_TC AS
(

SELECT	 cast(dstvbh.Tennhomtvbh as varchar2(2000)) Tennhomtvbh ,cast(dstvbh.TenNV as varchar2(2000)) TenNV,chung.TenNhom||'||v_TC||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM	
  (
  select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,'||Pmadv||')>0
   
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||' 
        and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 
          )) dstvbh left join 
  (select * from TheoDoiKhtn khtn where khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
			AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
      AND INSTR (khtn.TinhTrangKHS,5605)>= 0     
      ) khtn on dstvbh.MaNV=khtn.TuVanBH left join
			(select nlx.TenNhom,lx.MaLoaiXe from LoaiXe lx
        join NhomLoaiXe nlx on lx.MaNhom=nlx.MaNhom and lx.CheckHienThi=1 and (lx.CKD=0 or lx.CKD=1)
        join DongXe dx on dx.MaDongXe=nlx.MaDongXe
        join DonVi on donvi.MaDv='||Pmadv||' and instr(donvi.DongXes,dx.MaDongXe)>0
      ) chung on INSTR (khtn.XeQuanTam,chung.MaLoaiXe) > 0    
      
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenNhom 
)
select * from (

select * from (

    select * from LISTDATA_TD
    union 
     select * from LISTDATA_TC
union 
    select Tennhomtvbh,TenNV TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TD  
    group by Tennhomtvbh,TenNV
     union 
    select Tennhomtvbh,TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TC  
    group by Tennhomtvbh,TenNV
    
    union 
    select Tennhomtvbh,'||v_Tong||' TenNV,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD 
    group by Tennhomtvbh,TenNhom
 union 
    select Tennhomtvbh  ,'||v_Tong||' TenNV,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC 
    group by Tennhomtvbh,TenNhom
    union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,TenNhom ,sum(val) val,3 as TrangThai
    from LISTDATA_TD 
    group by TenNhom
    union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,TenNhom ,sum(val) val,3 as TrangThai
    from LISTDATA_TC 
    group by TenNhom
    union
    select Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    group by Tennhomtvbh
    union
       select Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
    group by Tennhomtvbh
     union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,3 as TrangThai
    from LISTDATA_TD
  
    union
       select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,3 as TrangThai
    from LISTDATA_TC
   
    union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TC
    group by TenNHom ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TC   
    )  s
    union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TD
    group by TenNHom ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD   
    )  s
     union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||'  TenNV,'||v_Tong_TD||' TenNhom,100 val,4 as TrangThai
    from dual
    union 
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,'||v_Tong_TC||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TC
   ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD   
    )  s
   
    
  )
  
    PIVOT 
    (
      sum(val)
      FOR TenNHom
      IN ('||v_list||')
    )
)
order by Tennhomtvbh,TrangThai';
dbms_output.put_line(v_sql);
open CUr for v_sql;

  END SP_BCKHTN_BYLoaiXe;

PROCEDURE SP_BCKHTN_ByHTTT
   (
     pMaDV IN number,
       pMaNhanVien varchar2,
     pMaChucVu in number,
     pFromDate in varchar2,
     pToDate in varchar2,
     Cur out SYS_REFCURSOR
   )IS
 

   
    v_TD varchar2(100):='''_TD''';
    v_TC varchar2(100):='''_TC''';
    v_Tong_TD VARCHAR2(100):='''Total_TD''';
    v_Tong_TC VARCHAR2(100):='''Total_TC''';
    v_Tong VARCHAR2(100):='''Total''';
    v_All VARCHAR2(100):='''YYYY''';
     v_All_p VARCHAR2(100):='''zzzz''';
     v_p_TD VARCHAR2(1000):='''TYLE_TD''';
      v_p_TC VARCHAR2(1000):='''TYLE_TC''';
     v_list VARCHAR2(4000):='';
    v_Sql varchar2(32767):=null;
  Formatdate VARCHAR(100) := '''dd/MM/yyyy''';
   v_a varchar(100):='';
    v_nhomdongxe VARCHAR2(2000):='';
    v_nhomTD VARCHAR2(2000):='';
    v_nhomTC VARCHAR2(2000):='';
 v_nhom VARCHAR2(2000):='';
  BEGIN
  
 SELECT Listagg(''''||TenNhom||'_TD'||'''', ',') Within GROUP(ORDer BY TenNhom ASC)
   
into v_nhomTD
from (
select DISTINCT cast(tennhomtvbh as varchar2(2000)) TenNhom from (
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMaDV
         AND  ntv.NhomTruong=pMaNhanVien
    union 
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMaDV
         AND instr(ntv.DsXemNhom,pMaNhanVien)>0 and pMaChucVu=3
    
     union 
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMaDV
       and pMaChucVu<>2 and pMaChucVu<>3 )
) abc ;

  v_list:=v_nhomTD||','||''''||'Total_TD'||''''||','||v_p_TD||','||REPLACE( v_nhomTD, '_TD','_TC' )||','||''''||'Total_TC'||''''||','||v_p_TC;
  dbms_output.put_line(v_list);
    v_sql:='
    with LISTDATA_TD AS
(

SELECT   cast(dstvbh.TenDm as varchar2(2000)) TenDm,cast(chung.TenNhomTVBH as varchar(2000))||'||v_TD||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM  
  (
  select * from dmChung where LoaiDm=''HTTT''
  ) dstvbh ,
    (select * from TheoDoiKhtn khtn where
 khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
            AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
           AND INSTR (khtn.TinhTrangKHS,5605)<= 0   ) khtn,
         
            ( 
            select manhomtvbh,tennhomtvbh,dsTuVanBH from (
        SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3
    
     union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
       and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 

            )) chung   

      
      where  dstvbh.Madm=khtn.HTTT (+)
      and INSTR (chung.DsTuVanBH,khtn.TuvanBH) > 0  
   group by dstvbh.TenDm,chung.TenNhomTVBH
),LISTDATA_TC AS
(

SELECT   cast(dstvbh.TenDm as varchar2(2000)) TenDm,cast(chung.TenNhomTVBH as varchar(2000))||'||v_TC||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
   FROM  
  (
  select * from dmChung where LoaiDm=''HTTT''
  ) dstvbh ,
    (select * from TheoDoiKhtn khtn where
 khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
            AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
           AND INSTR (khtn.TinhTrangKHS,5605)>0   ) khtn,
         
            ( 
            select manhomtvbh,tennhomtvbh,dsTuVanBH from (
        SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3
    
     union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
       and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 

            )) chung   

      
      where  dstvbh.Madm=khtn.HTTT(+)
      and INSTR (chung.DsTuVanBH,khtn.TuvanBH) > 0  
   group by dstvbh.TenDm,chung.TenNhomTVBH
)
select * from (

select * from (

    select * from LISTDATA_TD
    union 
     select * from LISTDATA_TC
  
        union
    select TenDm,'||v_Tong_TD||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TD
    group by TenDm
     union
    select TenDm,'||v_Tong_TC||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TC
    group by TenDm
    union
      select '||v_Tong||' TenDm, TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    group by TenNhom
     union
    select '||v_Tong||' TenDm,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
    group by TenNhom
    
    union
      select '||v_Tong||' TenDm,'||v_Tong_TD||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    
     union
    select '||v_Tong||' TenDm,'||v_Tong_TC ||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
   
    union
    select TenDm, '||v_p_TD ||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select TenDm,sum(val) val
    from LISTDATA_TD 
    group by TenDm ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD 
    )  s
    union
    select TenDm, '||v_p_TC ||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select TenDm,sum(val) val
    from LISTDATA_TC 
    group by TenDm ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TC 
    )  s
     union
    select '||v_Tong||' TenDm,'||v_p_TD ||' TenNhom,100 val,2 as TrangThai
    from dual
    union
     select '||v_Tong||' TenDm,'||v_p_TC ||' TenNhom,100 val,2 as TrangThai
    from dual
  )
  
    PIVOT 
    (
      sum(val)
      FOR TenNHom
      IN ('||v_list||')
    )
)
order by TenDm,TrangThai';

dbms_output.put_line(v_sql);
open CUr for v_sql;
  END SP_BCKHTN_ByHTTT;

  PROCEDURE SP_BCKHTN_ByThiTruong
   (
     pMaDV IN number,
       pMaNhanVien varchar2,
     pMaChucVu in number,
     pFromDate in varchar2,
     pToDate in varchar2,
     Cur out SYS_REFCURSOR
   ) IS
    v_TD varchar2(100):='''_TD''';
    v_TC varchar2(100):='''_TC''';
    v_Tong_TD VARCHAR2(100):='''Total_TD''';
    v_Tong_TC VARCHAR2(100):='''Total_TC''';
    v_Tong VARCHAR2(100):='''Total''';
    v_All VARCHAR2(100):='''YYYY''';
     v_All_p VARCHAR2(100):='''zzzz''';
     v_p_TD VARCHAR2(1000):='''TYLE_TD''';
      v_p_TC VARCHAR2(1000):='''TYLE_TC''';
     v_list VARCHAR2(4000):='';
    v_Sql varchar2(32767):=null;
  Formatdate VARCHAR(100) := '''dd/MM/yyyy''';
   v_a varchar(100):='';
    v_nhomdongxe VARCHAR2(2000):='';
    v_nhomTD VARCHAR2(2000):='';
    v_nhomTC VARCHAR2(2000):='';
 v_nhom VARCHAR2(2000):='';
  BEGIN
  
 SELECT Listagg(''''||TenNhom||'_TD'||'''', ',') Within GROUP(ORDer BY TenNhom ASC)
   
into v_nhomTD
from (
select DISTINCT cast(tennhomtvbh as varchar2(2000)) TenNhom from (
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMaDV
         AND  ntv.NhomTruong=pMaNhanVien
    union 
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMaDV
         AND instr(ntv.DsXemNhom,pMaNhanVien)>0 and pMaChucVu=3
    
     union 
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMaDV
       and pMaChucVu<>2 and pMaChucVu<>3 )
) abc ;

  v_list:=v_nhomTD||','||''''||'Total_TD'||''''||','||v_p_TD||','||REPLACE( v_nhomTD, '_TD','_TC' )||','||''''||'Total_TC'||''''||','||v_p_TC;
  dbms_output.put_line(v_list);
    v_sql:='
    with LISTDATA_TD AS
(

SELECT  IsTinh,TenDm,cast(TenNhomTVBH as varchar(2000))||'||v_TD||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM  (
  select cast(decode(c.isbig,1,p.vn_name,c.vn_name) as varchar2(2000)) as TenDm,
  khtn.MaTheoDoiKHTN,chung.TenNhomTVBH,decode(c.isbig,1,0,1) IsTinh
  from 
  TheoDoiKhtn khtn,KHTN k,PROVINCE p,CITY c,
            ( 
            select manhomtvbh,tennhomtvbh,dsTuVanBH from (
        SELECT ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3
    
     union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
       and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 

            )
            ) chung
 WHERE khtn.makhtn= k.makhtn(+)
 and k.quanhuyen=p.id(+)
 and k.tinhthanh=c.id(+)
and
 khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
            AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
      
      AND INSTR (chung.DsTuVanBH,khtn.TuvanBH) > 0    
            AND INSTR (khtn.TinhTrangKHS,5605)<= 0      
      )
   group by TenDm,TenNhomTVBH,IsTinh
   order by IsTinh
),LISTDATA_TC AS
(

SELECT   IsTinh,TenDm,cast(TenNhomTVBH as varchar(2000))||'||v_TC||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM  (
  select cast(decode(c.isbig,1,p.vn_name,c.vn_name) as varchar2(2000)) as TenDm,
  khtn.MaTheoDoiKHTN,chung.TenNhomTVBH,decode(c.isbig,1,0,1) IsTinh
  from 
  TheoDoiKhtn khtn,KHTN k,PROVINCE p,CITY c,
            ( 
            select manhomtvbh,tennhomtvbh,dsTuVanBH from (
        SELECT ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3
    
     union 
      SELECT  ntv.manhomtvbh,ntv.tennhomtvbh,dbms_lob.substr(dsTuVanBH,4000,1) dsTuVanBH
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi='||pMaDV||'
       and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 

            )
            ) chung
 WHERE k.makhtn=khtn.makhtn
 and k.quanhuyen=p.id(+)
 and k.tinhthanh=c.id(+)
and
 khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
            AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||'))
      
      AND INSTR (chung.DsTuVanBH,khtn.TuvanBH) > 0    
            AND INSTR (khtn.TinhTrangKHS,5605)> 0      
      )
   group by TenDm,TenNhomTVBH,IsTinh
   order by IsTinh
)
select * from (

select * from (

    select * from LISTDATA_TD
    union 
     select * from LISTDATA_TC
     
      
        union
    select IsTinh,TenDm,'||v_Tong_TD||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TD
    group by TenDm,IsTinh
     union
    select IsTinh,TenDm,'||v_Tong_TC||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TC
    group by TenDm,IsTinh
    union
      select 2 isTinh,'||v_Tong||' TenDm, TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    group by TenNhom
     union
    select 2 isTinh,'||v_Tong||' TenDm,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
    group by TenNhom
    
    union
      select 2 isTinh,'||v_Tong||' TenDm,'||v_Tong_TD||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    
     union
    select 2 isTinh,'||v_Tong||' TenDm,'||v_Tong_TC ||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
   
    union
    select IsTinh,TenDm, '||v_p_TD ||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select IsTinh,TenDm,sum(val) val
    from LISTDATA_TD 
    group by TenDm,IsTinh ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD 
    )  s
    union
    select IsTinh,TenDm, '||v_p_TC ||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,1 as TrangThai
    from (
      select IsTinh,TenDm,sum(val) val
    from LISTDATA_TC 
    group by TenDm,IsTinh ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TC 
    )  s
     union
    select 2 as IsTinh,'||v_Tong||' TenDm,'||v_p_TD ||' TenNhom,100 val,2 as TrangThai
    from dual
    union
     select 2 as IsTinh, '||v_Tong||' TenDm,'||v_p_TC ||' TenNhom,100 val,2 as TrangThai
    from dual
  )
  
    PIVOT 
    (
      sum(val)
      FOR TenNHom
      IN ('||v_list||')
    )
)
order by IsTinh,TrangThai';
dbms_output.put_line(v_sql);

open CUr for v_sql;
  END SP_BCKHTN_ByThiTruong;
  
  
 PROCEDURE SP_BCKHTN_ByHTTT_CV  
   (
     pMaDV IN number,
       pMaNhanVien varchar2,
     pMaChucVu in number,
     pFromDate in varchar2,
     pToDate in varchar2,
     Cur out SYS_REFCURSOR
   )
  IS
   
    v_TDA VARCHAR2(100):='_TD';
    v_TCA VARCHAR2(100):='_TC';
    v_TD varchar2(100):='''_TD''';
    v_TC varchar2(100):='''_TC''';
    v_Tong_TD VARCHAR2(100):='''Total_TD''';
    v_Tong_TC VARCHAR2(100):='''Total_TC''';
    v_Tong VARCHAR2(100):='''Total''';
    v_All VARCHAR2(100):='''yyyy''';
     v_All_p VARCHAR2(100):='''zzzz''';
     v_TheoLoaiXe VARCHAR2(1000):='''% theo hình thức''';
     v_list VARCHAR2(4000):='';
    v_Sql varchar2(32767):=null;
  Formatdate VARCHAR(100) := '''dd/MM/yyyy''';
   v_a varchar(100):='';
    v_nhomdongxe VARCHAR2(2000):='';
    v_nhomTD VARCHAR2(2000):='';
    v_nhomTC VARCHAR2(2000):='';

  BEGIN
 SELECT Listagg(''''||TenNhom||'_TD'||'''', ',') Within GROUP(ORDer BY ThuTuHienThi ASC)
   
into v_nhomTD
from (
  SELECT cast(TenDm as varchar(2000)) TenNhom , ThuTuHienTHi
	 FROM   DmChung
	WHERE   LoaiDm = 'HTTT' 
ORDER BY   ThuTuHienTHi
) abc ;

  v_list:=v_nhomTD||','||''''||'Total_TD'||''''||','||REPLACE( v_nhomTD, '_TD','_TC' )||','||''''||'Total_TC'||'''';
  dbms_output.put_line(v_list);
    v_sql:='
    with LISTDATA_TD AS
(

SELECT	 cast(dstvbh.Tennhomtvbh as varchar2(2000)) Tennhomtvbh ,cast(dstvbh.TenNV as varchar2(2000)) TenNV,chung.TenNhom||'||v_TD||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
  FROM	
  (
  select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,'||Pmadv||')>0
   
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||' 
        and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 
          )) dstvbh 
          left join 
  (select * from TheoDoiKhtn khtn where khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
			AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||')) AND INSTR (khtn.TinhTrangKHS,5605)<= 0      
      ) khtn on dstvbh.MaNV=khtn.TuVanBH
      left join 
			(  SELECT MaDM,cast(TenDm as varchar(2000)) TenNhom , ThuTuHienTHi
     FROM   DmChung
    WHERE   LoaiDm = ''HTTT'' ) chung on  khtn.HTTT=chung.MaDM
 
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenNhom 
),LISTDATA_TC AS
(

SELECT	 cast(dstvbh.Tennhomtvbh as varchar2(2000)) Tennhomtvbh ,cast(dstvbh.TenNV as varchar2(2000)) TenNV,chung.TenNhom||'||v_TC||' TenNhom,count(MaTheoDoiKHTN) val,1 as TrangThai
   FROM	
  (
  select  MaNV,TENNV,Tennhomtvbh from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,'||Pmadv||')>0
   
    WHERE ntv.madonvi='||pMaDV||'
         AND  ntv.NhomTruong='''||pMaNhanVien||'''
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||'
         AND instr(ntv.DsXemNhom,'''||pMaNhanVien||''')>0 and '||pMaChucVu||'=3 
    
     union 
    SELECT nd.MaNhanVien MaNV,TenNhanVien TENNV,ntv.Tennhomtvbh
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,'||Pmadv||')>0
    WHERE ntv.madonvi='||Pmadv||' 
        and '||pMaChucVu||'<>2 and '||pMaChucVu||'<>3 
          )) dstvbh 
          left join 
 ( select * from TheoDoiKhtn khtn where khtn.MaDV='||Pmadv||' and trunc(khtn.ngaytiepxuc) >=trunc(to_date('''||pFromDate||''','||Formatdate||'))
			AND trunc(khtn.ngaytiepxuc) <= trunc(to_date('''||pToDate||''','||Formatdate||')) AND INSTR (khtn.TinhTrangKHS,5605)<= 0      
      ) khtn on dstvbh.MaNV=khtn.TuVanBH
      left join 
			(  SELECT MaDM,cast(TenDm as varchar(2000)) TenNhom , ThuTuHienTHi
     FROM   DmChung
    WHERE   LoaiDm = ''HTTT'' ) chung on khtn.HTTT=chung.MaDM
 
   group by dstvbh.Tennhomtvbh,dstvbh.TenNV,chung.TenNhom 
)
select * from (

select * from (

    select * from LISTDATA_TD
    union 
     select * from LISTDATA_TC
union 
    select Tennhomtvbh,TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TD  
    group by Tennhomtvbh,TenNV
     union 
    select Tennhomtvbh,TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,1 as TrangThai
    from LISTDATA_TC  
    group by Tennhomtvbh,TenNV
    
    union 
    select Tennhomtvbh,'||v_Tong||' TenNV,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD 
    group by Tennhomtvbh,TenNhom
 union 
    select Tennhomtvbh  ,'||v_Tong||' TenNV,TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC 
    group by Tennhomtvbh,TenNhom
    union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,TenNhom ,sum(val) val,3 as TrangThai
    from LISTDATA_TD 
    group by TenNhom
    union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,TenNhom ,sum(val) val,3 as TrangThai
    from LISTDATA_TC 
    group by TenNhom
    union
    select Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TD
    group by Tennhomtvbh
    union
       select Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,2 as TrangThai
    from LISTDATA_TC
    group by Tennhomtvbh
     union
    select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TD||' TenNhom,sum(val) val,3 as TrangThai
    from LISTDATA_TD
  
    union
       select '||v_All||' Tennhomtvbh,'||v_Tong||' TenNV,'||v_Tong_TC||' TenNhom,sum(val) val,3 as TrangThai
    from LISTDATA_TC
   
    union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TC
    group by TenNHom ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TC   
    )  s
    union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TD
    group by TenNHom ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD   
    )  s
     union
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||'  TenNV,'||v_Tong_TD||' TenNhom,100 val,4 as TrangThai
    from dual
    union 
    select '||v_All_p||' Tennhomtvbh,'||v_TheoLoaiXe||' TenNV,'||v_Tong_TC||' TenNhom,decode(s.sumTotal,0,0,round(val*100/s.sumTotal,1)) val,4 as TrangThai
    from (
      select TenNHom,sum(val) val
    from LISTDATA_TC
   ) abc,
   (
     select sum(val) sumTotal
    from LISTDATA_TD   
    )  s
   
    
  )
  
    PIVOT 
    (
      sum(val)
      FOR TenNHom
      IN ('||v_list||')
    )
)
order by Tennhomtvbh,TrangThai';
dbms_output.put_line(v_sql);

open CUr for v_sql;

  END SP_BCKHTN_ByHTTT_CV;
END PKG_HANHX_BIEUDOKHTN;