create or replace PACKAGE BODY Pkg_DMCHUNG AS

  PROCEDURE DongXeGetByEmail_CV
(
    pEmail in varchar2,
    Cur       OUT SYS_REFCURSOR
) AS
  BEGIN
    OPEN Cur FOR
select k.madongxe,k.tendongxe 
      from
      (
     select distinct c.COLUMN_VALUE as DongXe
     from donvi dv , table(split_clob(dv.dongxes,',')) c
     where COLUMN_VALUE is not null and dv.madv in (
                                                       select distinct a.* 
                                                       from NguoIDung b, table(split_clob(b.madvs,',')) a
                                                       where COLUMN_VALUE is not null and b.email = pEmail)
       )  dxe inner join dongxe k on dxe.dongxe = k.madongxe and k.madongxe in (5249,5250,5251,5262,5252)
       order by k.tendongxe  ;
  END DongXeGetByEmail_CV;

  PROCEDURE DongXeGetByEmailFast_CV
(
    pEmail in varchar2,
    Cur       OUT SYS_REFCURSOR
) AS
  BEGIN
    OPEN Cur FOR
select k.madongxe,k.tendongxe 
      from
      (
          select a.*
          from NguoIDung b, table(split_clob(b.dongxes,',')) a
          where COLUMN_VALUE is not null and b.email = pEmail
       )  dxe inner join dongxe k on dxe.column_value = k.madongxe and k.madongxe in (5249,5250,5251,5262,5252) 
       order by k.tendongxe  ;
  END DongXeGetByEmailFast_CV;
  
  
  --d?c t?t c? giao d?ch có nhân viên dã ngh?
PROCEDURE GetAllGDByDonvi
(
    pDonvi in int,
    Cur       OUT SYS_REFCURSOR
)AS
  BEGIN
    OPEN Cur FOR
    with CT as (
  select  regexp_substr(aa,'[^,]+', 1, level) as MANV from (
    select listagg(to_char(dstuvanbh),',') 
    Within GROUP(ORDER BY dstuvanbh) aa 
    from NHOMTVBH where madonvi=pDonvi
  ) tresult
   connect by regexp_substr(aa, '[^,]+', 1, level) is not null
)

select gd.magd, kh.tenkh, dv.TENDV, gd.mahopdong, lx.TENLOAIXE, mx.TENMAU, gd.sokhung, gd.somay, to_char(gd.ngaygiaodich,'dd/MM/yyyy') ngaygiaodich,
gd.MANV, nd.TENNHANVIEN
from giaodich gd
inner join DONVI dv on dv.MADV=gd.MADV
inner join loaixe lx on lx.MALOAIXE=gd.maloaixe and lx.checkhienthi=1
inner join mauxe mx on mx.MAMAU=gd.MAMAU
inner join khachhang kh on kh.makh=gd.makh
left join nguoidung nd on nd.MANHANVIEN=gd.MANV
where gd.manv not in (
  select* from CT
 ) and gd.madv=pDonvi and gd.manv != pDonvi
 and gd.ngayhuygiaodich is null;
    
END GetAllGDByDonvi;

--C?p nh?t giao d?ch c?a nhân viên cu v? cho showroom
PROCEDURE CapnhatgdchoSR
(
    pMagd in int,
    pDonvi in int
)AS
BEGIN
  update giaodich set manv=pDonvi where magd=pMagd;
  commit;
END CapnhatgdchoSR;

END Pkg_DMCHUNG;
