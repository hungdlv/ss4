create or replace PACKAGE BODY Pkg_Baocaotonghop IS

--***********************************
-- COPPY GIA XE THUONG MAI
--***********************************
PROCEDURE CopyGiaXeCV(
    pKhuVuc in number,      
    pDongXe in number,
    pThangOld in number,
    pNamOld in number,
    pThangNew in number,
    pNamNew in number
) IS 
  vCount number := 0;
BEGIN
     select thang into vCount 
     from GiaXecv gx 
     where gx.thang = pThangNew and gx.nam = pNamNew and iddongxe = pDongxe;
     
     exception
     --if(vCount = 0) then
     when NO_DATA_FOUND then     
      insert into giaxecv(Thang,Nam,idloaixe,truthunglung,giacongbo,giatoithieu,giadaily,h2_dly_tvbh,h2daily,h2tvbh,ghichu,iddongxe)
      select pThangNew,pNamNew,idloaixe,truthunglung,giacongbo,giatoithieu,giadaily,h2_dly_tvbh,h2daily,h2tvbh,ghichu,iddongxe
      from giaxecv where thang=pThangOld and nam=pNamOld and iddongxe=pDongXe;      
      commit;
     --end if;
     
END CopyGiaXeCV;

--***********************************
-- DOC GIA XE THUONG MAI
--***********************************
PROCEDURE LoadGiaXeCV(
    pKhuVuc in number,      
    pDongXe in number,
    pThang in number,
    pNam in number,
    Cur       OUT SYS_REFCURSOR
) IS 
  vCount number := 0;
BEGIN
  select count(*) into vCount 
     from GiaXecv gx 
     --inner join LoaiXe lx on gx.idloaixe = lx.maloaixe
     where gx.thang = pThang and gx.nam = pNam and iddongxe = pDongxe;
     --and lx.dongxebc = pDongXe;
     
     if(vCount > 0) then
      OPEN Cur FOR    
      select lx.maloaixe, lx.tenloaixe
          , NVL(gx.TRUTHUNGLUNG,0) as TRUTHUNGLUNG
          , NVL(gx.GIACONGBO,0) as GIACONGBO, NVL(gx.GIATOITHIEU,0) as GIATOITHIEU, NVL(gx.GIADAILY,0) as GIADAILY
          , NVL(gx.H2_DLY_TVBH,0) as H2_DLY_TVBH, NVL(gx.H2DAILY,0) as H2DAILY, NVL(gx.H2TVBH,0) AS H2TVBH
          ,NVL(gx.GhiChu,'') as GhiChu
          from LoaiXe  lx 
          inner join GiaXeCV gx on lx.maloaixe = gx.idloaixe and gx.iddongxe=pDongXe AND gx.thang=pthang and gx.nam=pnam and gx.iddongxe=pdongxe
          --where lx.dongxebc = pDongXe
          and lx.checkhienthi = 1   
          and nvl(lx.xehetban,0) = 0    
          order by lx.tenloaixe;
     else
       OPEN Cur FOR 
       select lx.maloaixe, lx.tenloaixe
          , 0 as TRUTHUNGLUNG
          , 0 as GIACONGBO, 0 as GIATOITHIEU, 0 as GIADAILY
          , 0 as H2_DLY_TVBH, 0 as H2DAILY, 0 AS H2TVBH
          ,'' as GhiChu
          from LoaiXe  lx 
          --left join GiaXe gx on lx.maloaixe = gx.idloaixe
          inner join dongxe dx on dx.madongxe=lx.dongxebc
          where lx.dongxebc = pDongXe
          and lx.checkhienthi = 1   
          and nvl(lx.xehetban,0) = 0    
          order by lx.tenloaixe;       
     end if;
END LoadGiaXeCV; 

--***********************************
-- CAP NHAT GIA XE THUONG MAI
--***********************************
PROCEDURE updateGiaXeCV
(
   pMaXe in number,
   pTruThungLung in number,
   pGiaCongBo in number,
   pGiaToiThieu in number,
   pGiaDaiLy in number,
   pH2_DLy_TVBH in number,
   pH2_DaiLy in number,
   pH2_TVBH in number,  
   pThang in number,
   pNam in number,
   pGhiChu in nvarchar2,
   pDongxe in number
)
IS 
   vCount number:= 0;
BEGIN
    select count(gx.idloaixe) into vCount
    from GiaXeCV gx
    where gx.idloaixe = pMaXe and gx.thang = pThang and gx.nam = pNam;
    
    if(vCount = 0) then
      insert into GiaXeCV(thang, nam, Idloaixe, truthunglung, giacongbo, giatoithieu, giadaily, h2_dly_tvbh, h2daily, h2tvbh, ghichu, iddongxe)
      values (pThang ,pNam,pMaXe,ptruthunglung, pgiacongbo, pgiatoithieu, pgiadaily, ph2_dly_tvbh, ph2_daily, ph2_tvbh, pghichu, pdongxe);    
    end if;
    if(vCount = 1) then
        update GiaXeCV
        set truthunglung=ptruthunglung, giacongbo=pgiacongbo, giatoithieu=pgiatoithieu, giadaily=pgiadaily, h2_dly_tvbh=ph2_dly_tvbh, h2daily=ph2_daily, h2tvbh=ph2_tvbh, ghichu=pghichu 
        where thang = pThang and nam = pNam and idloaixe = pMaXe;        
    end if;
    commit;
END updateGiaXeCV;


--***********************************
-- DOC VUNG MIEN THEO EMAIL
--***********************************
PROCEDURE Vungmien_GetByEmail
(
    pEmail IN NVARCHAR2,
    CUR OUT SYS_REFCURSOR
)
IS 
BEGIN
open cur for
  select ID, TEN, THUTU, KHUVUC, DBMS_LOB.SUBSTR(DONVIS, 4000, 1) AS DONVI from vungmien
  WHERE KHUVUC IN 
        (
        SELECT * 
        FROM TABLE(
              SELECT SPLIT_CLOB(nd.khuvucs,',') 
              FROM NGUOIDUNG nd 
              WHERE nd.email=pEmail
              )
        ) 
   order by THUTU;
END Vungmien_GetByEmail;

--***********************************
-- DOC DON VI THEO EMAIL
--***********************************
PROCEDURE Donvi_GetByEmail
(
    pEmail IN NVARCHAR2,
    CUR OUT SYS_REFCURSOR
)
IS
BEGIN
  open CUR for
 /* select MADV, TENDV, KHUVUC, DBMS_LOB.SUBSTR(dongxes, 4000, 1) DONGXE from DONVI WHERE KHUVUC IN (SELECT * 
        FROM TABLE(SELECT SPLIT_CLOB(nd.khuvucs,',') 
              FROM NGUOIDUNG nd 
              WHERE nd.email=pEmail
              ) where column_value is not null );*/
    select MADV, TENDV, KHUVUC, DBMS_LOB.SUBSTR(dongxes, 4000, 1) DONGXE 
    from DONVI 
    WHERE MADV IN (SELECT * 
        FROM TABLE(SELECT SPLIT_CLOB(nd.MADVS,',') 
              FROM NGUOIDUNG nd 
              WHERE 
              --nd.email='vuduyanh@thaco.com.vn'
              nd.email=pEmail
              ) where column_value is not null );
              
END Donvi_GetByEmail;


--***********************************
--Doc dong xe by email
--***********************************
PROCEDURE Dongxe_GetByEmail(
pEmail  IN varchar,
Cur     OUT SYS_REFCURSOR
)
IS
l_exst number(1);
BEGIN
select case 
           when exists(select k.madongxe,k.tendongxe from
            (
              select a.*
              from NguoIDung b, table(split_clob(b.dongxes,',')) a
              where COLUMN_VALUE is not null and b.email = pEmail
            ) dxe inner join dongxe k on dxe.column_value = k.madongxe
           ) then 1
           else 0
         end  into l_exst
  from dual;
  
  if l_exst = 1 
  then
    OPEN CUR FOR
    select k.madongxe,k.tendongxe from
            (
              select a.*
              from NguoIDung b, table(split_clob(b.dongxes,',')) a
              where COLUMN_VALUE is not null and b.email = pEmail
            ) dxe inner join dongxe k on dxe.column_value = k.madongxe;
  else
    OPEN CUR FOR
    select k.madongxe,k.tendongxe 
      from
      (
     select distinct c.COLUMN_VALUE as DongXe
     from donvi dv , table(split_clob(dv.dongxes,',')) c
     where COLUMN_VALUE is not null and dv.madv in (
                                                       select distinct a.* 
                                                       from NguoIDung b, table(split_clob(b.madvs,',')) a
                                                       where COLUMN_VALUE is not null and b.email = pEmail)
       )  dxe inner join dongxe k on dxe.dongxe = k.madongxe 
       order by k.tendongxe;
  end if;
           
END Dongxe_GetByEmail;


--***********************************
-- DOC DANH MUC CHUNG
--***********************************
procedure usp_getDMChung(
Cur1       OUT SYS_REFCURSOR,
Cur2       OUT SYS_REFCURSOR,
Cur3       OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN Cur1 FOR
  select* from dongxe where chungloai=5202;
  
  OPEN cur2 for
  select* from NhomLoaiXe where madongxe in(5249,5250,5251,5262,5252);
  
  open cur3 for
  select a.* from LOAIXE a
  inner join
  (
  select a.manhom from NhomLoaiXe a
  inner join dongxe b on b.chungloai=5202 and b.madongxe = a.madongxe
  ) b on b.manhom=a.manhom and a.checkhienthi=1;

END usp_getDMChung;

--***********************************
--
--***********************************
PROCEDURE usp_test(
Cur1       OUT SYS_REFCURSOR,
Cur2       OUT SYS_REFCURSOR,
Cur3       OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN Cur1 FOR
  select a.MALOAIXE, a.TENLOAIXE, a.MANHOM 
  from loaixe a
  inner join (
    select a.* 
    from nhomloaixe a
    inner join dongxe b on b.madongxe=a.madongxe and b.chungloai=5202
  ) b on b.manhom = a.manhom;
  
  OPEN Cur2 FOR
  select a.MANHOM, a.TENNHOM, a.MADONGXE 
  from nhomloaixe a
  inner join dongxe b on b.madongxe=a.madongxe and b.chungloai=5202;
  
  OPEN Cur3 FOR
  select MADONGXE, TENDONGXE, CHUNGLOAI from dongxe where chungloai=5202;
END usp_test;



--***********************************
--TONG HOP THUC HIEN BAN HANG
--***********************************
PROCEDURE sp_THBH_theodongxe(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Dongxes     VARCHAR2(100)   := NULL;
BEGIN
  --SELECT Listagg(Dongxes, ',') Within GROUP(ORDER BY Dongxes) INTO Dongxes FROM Donvi where madv=Pmadv;
        
  OPEN cur FOR
 WITH Result_Table AS
  (SELECT 
Dx.TenDongXe as Nhomlx,
    decode(Dx.Thutuhienthi,'',1,Dx.Thutuhienthi) Thutuhienthi,
      Nlx.Tennhom AS MaLoaiXe,
    Lx.Ckd,
    NVL(SUM(result_ctbhdv.vresult),0) slctbhdv,--, --CHI TIEU BAN HANG
    NVL(SUM(result_gdlk.vresult),0) slgdlk,     --GIAO DICH DANG KY THANG
    NVL(SUM(result_pcxhd.vresult),0) slpcxhd,   --PC OR CV XUAT HOA DON
    NVL(SUM(result_dvxhd.vresult),0) sldvxhd,   --DONVI XUAT HOA DON
    NVL(SUM(result_sldn_nhs.vresult),0) sldnnhs,--DE NGHI NHAN HOSO
    NVL(SUM(result_slgdtd.vresult),0) slgdtd,   --GIAO DICH THEO DOI
    NVL(SUM(result_slth.vresult),0) slth,       --KE HOACH THUC HIEN
    NVL(SUM(result_slthlk.vresult),0) slthlk,   --KE HOACH THUC HIEN LUY KE
     NVL(SUM(result_hston.vresult),0) hston   --HO SO TON*/
  FROM Dongxe Dx
  INNER JOIN Nhomloaixe Nlx
  ON Nlx.Madongxe = Dx.Madongxe
  INNER JOIN Loaixe Lx
  ON Lx.Manhom = Nlx.Manhom
    --CHI TIEU BAN HANG [MADV, MADONGXE, MANHOM]
  LEFT JOIN
    (SELECT Ctbhdv.Madv--, Dx.Madongxe, Nlx.Manhom, SUM(Sldangky) AS Sl
      ,
      lx.maloaixe,
      SUM(Sldangky) AS vresult
    FROM Chitieubanhangdonvi Ctbhdv
    INNER JOIN Loaixe Lx
    ON Lx.Maloaixe = Ctbhdv.Maloaixe
    INNER JOIN Nhomloaixe Nlx
    ON Nlx.Manhom = Lx.Manhom
    INNER JOIN Dongxe Dx
    ON Dx.Madongxe    = Nlx.Madongxe
    AND Instr(Pmadv, Ctbhdv.MaDV) > 0
    WHERE 
    EXTRACT (YEAR FROM TO_DATE (pTo, 'dd/MM/yyyy'))=Ctbhdv.Nam
 and EXTRACT (MONTH FROM TO_DATE (pTo, 'dd/MM/yyyy'))=Ctbhdv.Thang

    AND Lx.Checkhienthi           = 1
    AND Instr(Pmadv, Ctbhdv.MaDV) > 0
      --GROUP BY Ctbhdv.Madv, Dx.Madongxe, Nlx.Manhom
    GROUP BY Ctbhdv.Madv,
      lx.maloaixe
    HAVING COUNT(*) > 0
      --ORDER BY Dx.Madongxe, Nlx.Manhom
    ) result_ctbhdv ON/* Instr(Pmadv, result_ctbhdv.madv)>0
  AND */ 
  lx.MALOAIXE =result_ctbhdv.Maloaixe
    --SOLUONG KE HOACH THUC HIEN
  LEFT JOIN
    (SELECT Madv,
      DBMS_LOB.SUBSTR(XeQuanTam, 4000, 1) AS Xequantam,
      COUNT(*)                            AS vresult
    FROM Theodoikhtn
    WHERE Madv                        <> 0
    AND Instr(Pmadv, Madv) > 0
    AND Ngaytiepxuc BETWEEN TO_DATE(Pto, FORMATDATE) AND TO_DATE(Pto,FORMATDATE)
    AND Tuvanbh                                      IS NOT NULL
    AND Instr('5605, 5602, 5603, 5604', Tinhtrangkhs) > 0
    GROUP BY Madv,
      DBMS_LOB.SUBSTR(XeQuanTam, 4000, 1)
    ) result_slth
  ON  Instr((
    CASE
      WHEN Instr(result_slth.Xequantam, ',') = 0
      THEN result_slth.Xequantam
      ELSE SUBSTR(result_slth.Xequantam, 0, Instr(result_slth.Xequantam, ',') - 1)
    END), Lx.MALOAIXE) > 0
    --SOLUONG KE HOACH THUC HIEN LUY KE
  LEFT JOIN
    (SELECT Madv,
      DBMS_LOB.SUBSTR(XeQuanTam, 4000, 1) AS Xequantam,
      COUNT(*)                            AS vresult
    FROM Theodoikhtn
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv) > 0
    AND Ngaytiepxuc BETWEEN TO_DATE(Pfrom, FORMATDATE) AND TO_DATE(Pto,FORMATDATE)
    AND Tuvanbh   IS NOT NULL
    AND Instr('5605, 5602, 5603, 5604', Tinhtrangkhs) > 0
    GROUP BY Madv,
      DBMS_LOB.SUBSTR(XeQuanTam, 4000, 1)
    ) result_slthlk
  ON   /* Instr(Pmadv, result_slthlk.madv)>0
  AND*/ Instr((
    CASE
      WHEN Instr(result_slthlk.Xequantam, ',') = 0
      THEN result_slthlk.Xequantam
      ELSE SUBSTR(result_slthlk.Xequantam, 0, Instr(result_slthlk.Xequantam, ',') - 1)
    END), Lx.MALOAIXE) > 0
    --SOLUONG GIAO DICH THEO DOI
  LEFT JOIN
    (SELECT Madv,
      Maloaixe,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv) > 0
    AND (Ngaydenghihoso   IS NULL
    OR (Ngaydenghihoso    IS NOT NULL
    AND Ngaydenghihoso     > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaychuyendoitt  IS NULL
    OR (Ngaychuyendoitt   IS NOT NULL
    AND Ngaychuyendoitt    > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaydkgdtheodoi  IS NOT NULL
    AND ((Ngaytheodoilai  IS NULL
    AND Ngaydkgdtheodoi   <= TO_DATE(Pto, FORMATDATE))
    OR (Ngaytheodoilai    IS NOT NULL
    AND Ngaytheodoilai    <= TO_DATE(Pto, FORMATDATE))))
    AND (Ngayhuygiaodich  IS NULL
    OR (Ngayhuygiaodich   IS NOT NULL
    AND Ngayhuygiaodich    > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaycvpcxuathd   IS NULL
    OR (Ngaycvpcxuathd    IS NOT NULL
    AND Ngaycvpcxuathd    >= TO_DATE(Pto, FORMATDATE)))
    AND (Ngayktxuathoadon IS NULL
    OR (Ngayktxuathoadon  IS NOT NULL
    AND Ngayktxuathoadon  >= TO_DATE(Pto, FORMATDATE)))
    GROUP BY Madv,
      Maloaixe
    ) result_slgdtd
  ON/* Instr(Pmadv, result_slgdtd.madv)>0
  AND */Lx.MALOAIXE      =result_slgdtd.Maloaixe
    --SOLUONG GIAO DICH DE NGHI NHAN HOSO
  LEFT JOIN
    (SELECT Madv,
      Maloaixe,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv) > 0
    AND ((Ngaydenghihoso  IS NOT NULL
    AND Ngaydenghihoso    <= TO_DATE(Pto, FORMATDATE))
    OR (Ngaydenghihoso    IS NULL
    AND Ngaychuyendoitt   IS NOT NULL
    AND Ngaychuyendoitt   <= TO_DATE(Pto,FORMATDATE)))
    AND (Ngayhuygiaodich  IS NULL
    OR (Ngayhuygiaodich   IS NOT NULL
    AND Ngayhuygiaodich    > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaycvpcxuathd   IS NULL
    OR (Ngaycvpcxuathd    IS NOT NULL
    AND Ngaycvpcxuathd    >= TO_DATE(Pto, FORMATDATE)))
    AND (Ngayktxuathoadon IS NULL
    OR (Ngayktxuathoadon  IS NOT NULL
    AND Ngayktxuathoadon  >= TO_DATE(Pto, FORMATDATE)))
    GROUP BY Madv,
      Maloaixe
    ) result_sldn_nhs
  ON /*Instr(Pmadv, result_sldn_nhs.madv)>0
  AND*/ lx.MALOAIXE        =result_sldn_nhs.Maloaixe
    --SOLUONG DONVI XUAT HOA DON
  LEFT JOIN
    (SELECT Madv,
      Maloaixe,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv             <> 0
    AND Instr(Pmadv, Madv)  > 0
    AND ((Ngayktxuathoadon IS NOT NULL
    AND TRUNC(Ngayktxuathoadon) BETWEEN TO_DATE(Pfrom, FORMATDATE) AND TO_DATE(Pto,FORMATDATE))
    OR (Ngayktxuathoadon IS NULL
    AND TRUNC(Ngayxuathoadon) BETWEEN TO_DATE(Pfrom,FORMATDATE) AND TO_DATE(Pto,FORMATDATE)))
    GROUP BY Madv,
      Maloaixe
    ) result_dvxhd
  ON /*Instr(Pmadv, result_dvxhd.madv)>0
  AND */lx.MALOAIXE     =result_dvxhd.Maloaixe
    --SOLUONG PC XUAT HOA DON
  LEFT JOIN
    (SELECT Madv,
      Maloaixe,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv <> 0
    AND Instr(Pmadv,MaDV) > 0
    AND to_date(Ngaycvpcxuathd) BETWEEN to_date(Pfrom, Formatdate) AND to_date(Pto,Formatdate)
    AND Ngayhuygiaodich IS NULL
    GROUP BY Madv,
      Maloaixe
    ) result_pcxhd
  ON /*Instr(Pmadv, result_pcxhd.madv)>0
  AND */lx.MALOAIXE     =result_pcxhd.Maloaixe
    --GIAO DICH dang kY THANG
  LEFT JOIN
    (SELECT Madv,
      Maloaixe,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv)>0
   -- AND Madv               = Pmadv
    AND ((Ngaydkgdtheodoi IS NOT NULL
    AND TRUNC(Ngaydkgdtheodoi) BETWEEN TO_DATE(Pfrom,FORMATDATE) AND TO_DATE(Pto,FORMATDATE))
    OR (Ngaydkgdtheodoi IS NULL
    AND Ngaydenghihoso  IS NOT NULL
    AND TRUNC(Ngaydenghihoso) BETWEEN TO_DATE(Pfrom, FORMATDATE) AND TO_DATE(Pto,FORMATDATE)))
    AND Ngayhuygiaodich              IS NULL
    AND NVL(Tinhchitieuthangtruoc, 0) = 0
    GROUP BY MADV,
      MALOAIXE
    ) result_gdlk
  ON /*Instr(Pmadv, result_gdlk.madv)>0
  AND*/ lx.MALOAIXE =result_gdlk.Maloaixe
  left join (
   SELECT gd.Madv,
      Maloaixe,
      COUNT(Magd) vresult
            FROM Giaodich Gd
            LEFT JOIN Khachhang Kh
            ON Kh.Makh = Gd.Makh
            
            LEFT JOIN Hopdong Hd
            ON Hd.Mahopdong = Gd.Mahopdong
            LEFT JOIN Dmchung Dm
            ON Dm.Madm = Gd.Hinhthuctt
            WHERE Gd.Madv <> 0
           AND Instr(Pmadv, Gd.Madv)>0
            AND Ngaycvpcxuathd <= TO_DATE(Pto, FORMATDATE)
            AND Ngayktxuathoadon IS NULL
            AND Ngayhuygiaodich IS NULL
      
            AND Dm.Loaidm = 'HTTT'
            group by gd.Madv, Maloaixe
   
   ) result_hston on lx.MALOAIXE=result_hston.Maloaixe
  WHERE Instr(Pdongxe, Dx.Madongxe) > 0
  AND Nlx.Manhom                   <> 5288
  
  AND Lx.Checkhienthi               = 1
  GROUP BY
  Dx.TenDongXe,
    Dx.Thutuhienthi,
      Nlx.Tennhom,
    Lx.Ckd

    --ORDER BY Nlx.Thutuhienthi
  )

  
SELECT*
FROM
  ( SELECT a.*,
  decode(slctbhdv,0,0,round(slgdlk*100/slctbhdv)) slgdlk_p,  --Phan Tram  DK THANG
  decode(slctbhdv,0,0,round(slpcxhd*100/slctbhdv)) slpcxhd_p,-- Phan Tram PC XHD
  decode(slctbhdv,0,0,round(sldvxhd*100/slctbhdv)) sldvxhd_p--Phan Tram DON VI XHD
  FROM Result_Table a
  UNION ALL
  SELECT '' AS NhomLx ,
    Thutuhienthi,
    'Tổng '||NhomLx         AS MaLoaiXe,
    0             AS Ckd,
    SUM(slctbhdv) AS slctbhdv,--CHI TIEU BAN HANG
    SUM(slgdlk)   AS slgdlk,  --GIAO DICH DK THANG
    SUM(slpcxhd)  AS slpcxhd, --PC OR CV XUAT HOA DON
    SUM(sldvxhd)  AS sldvxhd, --DONVI XUAT HOA DON
    SUM(sldnnhs)  AS sldnnhs, --DE NGHI NHAN HOSO
    SUM(slgdtd)   AS slgdtd,  --GIAO DICH THEO DOI
    SUM(slth)     AS slth,    --KH theo d?i
    SUM(slthlk)   AS slthlk, --KH theo d?i LUY KE
     SUM(hston)   AS hston, -- HO SO TON
     decode(SUM(slctbhdv),0,0,round( SUM(slgdlk)*100/SUM(slctbhdv))) slgdlk_p,--Phan Tram PC XHD
    decode(SUM(slctbhdv),0,0,round( SUM(slpcxhd)*100/SUM(slctbhdv))) slpcxhd_p,--Phan Tram PC XHD
  decode(SUM(slctbhdv),0,0,round(SUM(sldvxhd)*100/SUM(slctbhdv))) sldvxhd_p--Phan Tram DON VI XHD
    
  FROM Result_Table
  GROUP BY Thutuhienthi,NhomLx
  UNION ALL
  SELECT '' AS NhomLx ,
    100000000 Thutuhienthi,
    'Tổng cộng'            AS MaLoaiXe,
    0             AS Ckd,
    SUM(slctbhdv) AS slctbhdv,--CHI TIEU BAN HANG
    SUM(slgdlk)   AS slgdlk,  --GIAO DICH DK THANG
    SUM(slpcxhd)  AS slpcxhd, --PC OR CV XUAT HOA DON
    SUM(sldvxhd)  AS sldvxhd, --DONVI XUAT HOA DON
    SUM(sldnnhs)  AS sldnnhs, --DE NGHI NHAN HOSO
    SUM(slgdtd)   AS slgdtd,  --GIAO DICH THEO DOI
    SUM(slth)     AS slth,    --KH theo d?i
    SUM(slthlk)   AS slthlk,   --KH theo d?i LUY KE
     SUM(hston)   AS hston, -- HO SO TON
       decode(SUM(slctbhdv),0,0,round( SUM(slgdlk)*100/SUM(slctbhdv))) slgdlk_p,--Phan Tram PC XHD
      decode(SUM(slctbhdv),0,0,round( SUM(slpcxhd)*100/SUM(slctbhdv))) slpcxhd_p,--Phan Tram PC XHD
  decode(SUM(slctbhdv),0,0,round(SUM(sldvxhd)*100/SUM(slctbhdv))) sldvxhd_p--Phan Tram DON VI XHD
  FROM Result_Table
  ) aa
ORDER BY Thutuhienthi,
  NhomLx;
           
END sp_THBH_theodongxe;

PROCEDURE sp_THBH_theodongxe_byNV(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Dongxes     VARCHAR2(100)   := NULL;
  v_Null  nvarchar2(100):='';
BEGIN

        
  OPEN cur FOR
 WITH Result_Table AS
  (SELECT 
dv.TenDV as TenDonVi,
    tvbh.tennhomtvbh as TenNhom,
      nd.TenNhanVien AS TenNhanVien,
      nd.MaNhanVien as MaNhanVien,
    NVL(SUM(result_ctbhdv.vresult),0) slctbhdv, --CHI TIEU BAN HANG
    NVL(SUM(result_gdlk.vresult),0) slgdlk,     --GIAO DICH DANG KY THANG
    NVL(SUM(result_pcxhd.vresult),0) slpcxhd,   --PC OR CV XUAT HOA DON
    NVL(SUM(result_dvxhd.vresult),0) sldvxhd,   --DONVI XUAT HOA DON
    NVL(SUM(result_sldn_nhs.vresult),0) sldnnhs,--DE NGHI NHAN HOSO
    NVL(SUM(result_slgdtd.vresult),0) slgdtd,   --GIAO DICH THEO DOI
    NVL(SUM(result_slth.vresult),0) slth,       --KE HOACH THUC HIEN
    NVL(SUM(result_slthlk.vresult),0) slthlk,   --KE HOACH THUC HIEN LUY KE
     NVL(SUM(result_hston.vresult),0) hston   --HO SO TON
  FROM (
  SELECT  MaDonVi, nhomtvbh.tennhomtvbh,
                  nhomtvbh.nhomtruong
                || ','
                || DBMS_LOB.SUBSTR (DSTUVANBH, 4000, 1)
                  AS DanhSachTuVanBH
            FROM  nhomtvbh
           WHERE  INSTR(Pmadv,nhomtvbh.MaDonVi)>0 ) tvbh
  INNER JOIN NguoiDung nd ON INSTR (DanhSachTuVanBH, nd.manhanvien) > 0 and instr(nd.MaDVS,Pmadv)>0
  inner Join DonVi dv  on tvbh.MaDonVi=dv.MaDV
    --CHI TIEU BAN HANG [MADV, MADONGXE, MANHOM]
  LEFT JOIN
    (SELECT Ctbhdv.MaDonVi as MaDV--, Dx.Madongxe, Nlx.Manhom, SUM(Sldangky) AS Sl
      ,
      Ctbhdv.MaNV,
      SUM(SoLuong) AS vresult
    FROM chitieubanhangnhanvien Ctbhdv
    --INNER JOIN Dongxe Dx
    --ON Ctbhdv.Madongxe= Dx.Madongxe and instr(pDongXe,Dx.MaDongXe)>0
    --AND Instr(Pmadv, Ctbhdv.MaDonVi) > 0
    WHERE 
    EXTRACT (YEAR FROM TO_DATE (pTo, 'dd/MM/yyyy'))=Ctbhdv.Nam
 and EXTRACT (MONTH FROM TO_DATE (pTo, 'dd/MM/yyyy'))=Ctbhdv.Thang

  
    --AND Instr(Pmadv, Ctbhdv.MaDonVi) > 0
      --GROUP BY Ctbhdv.Madv, Dx.Madongxe, Nlx.Manhom
    GROUP BY Ctbhdv.MaDonVi,
       Ctbhdv.MaNV
    HAVING COUNT(*) > 0
      --ORDER BY Dx.Madongxe, Nlx.Manhom
    ) result_ctbhdv ON
  nd.MaNhanVien  =result_ctbhdv.MaNV
    --SOLUONG KE HOACH THUC HIEN
  LEFT JOIN
  ( select result_slth.Madv,result_slth.TUVANBH as MaNV,count(MaTheoDoiKHTN) as vresult from
    DongXe dx
    join NhomLoaiXe nlx on nlx.MaDongXe=dx.MaDongXe and instr(pDongXe,dx.MaDongXe)>0  
    join LoaiXe lx on lx.MaNhom=nlx.MaNhom
    join
    (
    SELECT Madv,
      DBMS_LOB.SUBSTR(XeQuanTam, 4000, 1) AS Xequantam,TUVANBH,Theodoikhtn.MaTheoDoiKHTN
    FROM Theodoikhtn 
    WHERE Madv                        <> 0
    AND Instr(Pmadv, Madv) > 0 
    AND Ngaytiepxuc BETWEEN TO_DATE(Pto, FORMATDATE) AND TO_DATE(Pto,FORMATDATE)
    AND Tuvanbh                                      IS NOT NULL
    AND Instr('5605, 5602, 5603, 5604', Tinhtrangkhs) > 0
    ) result_slth   
  ON Instr((
    CASE
      WHEN Instr(result_slth.Xequantam, ',') = 0
      THEN result_slth.Xequantam
      ELSE SUBSTR(result_slth.Xequantam, 0, Instr(result_slth.Xequantam, ',') - 1)
    END), Lx.MALOAIXE) > 0 
    group by result_slth.Madv,result_slth.TUVANBH
    ) result_slth on result_slth.MaNV=nd.MaNhanVien
    --SOLUONG KE HOACH THUC HIEN LUY KE
  LEFT JOIN
    ( select result_slth.Madv,result_slth.TUVANBH as MaNV,count(MaTheoDoiKHTN) as vresult from
    DongXe dx
    join NhomLoaiXe nlx on nlx.MaDongXe=dx.MaDongXe and instr(pDongXe,dx.MaDongXe)>0  
    join LoaiXe lx on lx.MaNhom=nlx.MaNhom
    join
    (
    SELECT Madv,
      DBMS_LOB.SUBSTR(XeQuanTam, 4000, 1) AS Xequantam,TUVANBH,Theodoikhtn.MaTheoDoiKHTN
    FROM Theodoikhtn 
    WHERE Madv                        <> 0
    AND Instr(Pmadv, Madv) > 0 
    AND Ngaytiepxuc BETWEEN TO_DATE(pFrom, FORMATDATE) AND TO_DATE(Pto,FORMATDATE)
    AND Tuvanbh                                      IS NOT NULL
    AND Instr('5605, 5602, 5603, 5604', Tinhtrangkhs) > 0
    ) result_slth   
  ON/* Instr(Pmadv, result_slth.Madv)>0
  AND */Instr((
    CASE
      WHEN Instr(result_slth.Xequantam, ',') = 0
      THEN result_slth.Xequantam
      ELSE SUBSTR(result_slth.Xequantam, 0, Instr(result_slth.Xequantam, ',') - 1)
    END), Lx.MALOAIXE) > 0 
    group by result_slth.Madv,result_slth.TUVANBH
    ) result_slthlk on result_slthlk.MaNV=nd.MaNhanVien
  LEFT JOIN
    (SELECT Madv,
      MaNV,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv) > 0
    AND (Ngaydenghihoso   IS NULL
    OR (Ngaydenghihoso    IS NOT NULL
    AND Ngaydenghihoso     > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaychuyendoitt  IS NULL
    OR (Ngaychuyendoitt   IS NOT NULL
    AND Ngaychuyendoitt    > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaydkgdtheodoi  IS NOT NULL
    AND ((Ngaytheodoilai  IS NULL
    AND Ngaydkgdtheodoi   <= TO_DATE(Pto, FORMATDATE))
    OR (Ngaytheodoilai    IS NOT NULL
    AND Ngaytheodoilai    <= TO_DATE(Pto, FORMATDATE))))
    AND (Ngayhuygiaodich  IS NULL
    OR (Ngayhuygiaodich   IS NOT NULL
    AND Ngayhuygiaodich    > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaycvpcxuathd   IS NULL
    OR (Ngaycvpcxuathd    IS NOT NULL
    AND Ngaycvpcxuathd    >= TO_DATE(Pto, FORMATDATE)))
    AND (Ngayktxuathoadon IS NULL
    OR (Ngayktxuathoadon  IS NOT NULL
    AND Ngayktxuathoadon  >= TO_DATE(Pto, FORMATDATE)))
    GROUP BY Madv,
      MaNV
    ) result_slgdtd
  ON/* Instr(Pmadv, result_slgdtd.madv)>0
  AND */nd.MaNhanVien=result_slgdtd.MaNV
    --SOLUONG GIAO DICH DE NGHI NHAN HOSO
  LEFT JOIN
    (SELECT Madv,
      MaNV,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv) > 0
    AND ((Ngaydenghihoso  IS NOT NULL
    AND Ngaydenghihoso    <= TO_DATE(Pto, FORMATDATE))
    OR (Ngaydenghihoso    IS NULL
    AND Ngaychuyendoitt   IS NOT NULL
    AND Ngaychuyendoitt   <= TO_DATE(Pto,FORMATDATE)))
    AND (Ngayhuygiaodich  IS NULL
    OR (Ngayhuygiaodich   IS NOT NULL
    AND Ngayhuygiaodich    > TO_DATE(Pto, FORMATDATE)))
    AND (Ngaycvpcxuathd   IS NULL
    OR (Ngaycvpcxuathd    IS NOT NULL
    AND Ngaycvpcxuathd    >= TO_DATE(Pto, FORMATDATE)))
    AND (Ngayktxuathoadon IS NULL
    OR (Ngayktxuathoadon  IS NOT NULL
    AND Ngayktxuathoadon  >= TO_DATE(Pto, FORMATDATE)))
    GROUP BY Madv,
      MaNV
    ) result_sldn_nhs
  ON /*Instr(Pmadv, result_sldn_nhs.madv)>0
  AND*/ nd.MaNhanVien        =result_sldn_nhs.MaNV
    --SOLUONG DONVI XUAT HOA DON
  LEFT JOIN
    (SELECT Madv,
      MaNV,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv             <> 0
    AND Instr(Pmadv, Madv)  > 0
    AND ((Ngayktxuathoadon IS NOT NULL
    AND TRUNC(Ngayktxuathoadon) BETWEEN TO_DATE(Pfrom, FORMATDATE) AND TO_DATE(Pto,FORMATDATE))
    OR (Ngayktxuathoadon IS NULL
    AND TRUNC(Ngayxuathoadon) BETWEEN TO_DATE(Pfrom,FORMATDATE) AND TO_DATE(Pto,FORMATDATE)))
    GROUP BY Madv,
      MaNV
    ) result_dvxhd
  ON /*Instr(Pmadv, result_dvxhd.madv)>0
  AND */nd.MaNhanVien     =result_dvxhd.MaNV
    --SOLUONG PC XUAT HOA DON
  LEFT JOIN
    (SELECT Madv,
      MaNV,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv <> 0
    AND Instr(Pmadv,MaDV) > 0
    AND to_date(Ngaycvpcxuathd) BETWEEN to_date(Pfrom, Formatdate) AND to_date(Pto,Formatdate)
    AND Ngayhuygiaodich IS NULL
    GROUP BY Madv,
      MaNV
    ) result_pcxhd
  ON /*Instr(Pmadv, result_pcxhd.madv)>0
  AND */nd.MaNhanVien  =result_pcxhd.MaNV
    --GIAO DICH dang kY THANG
  LEFT JOIN
    (SELECT Madv,
      MaNV,
      COUNT(Magd) vresult
    FROM Giaodich
    WHERE Madv            <> 0
    AND Instr(Pmadv, Madv)>0
   -- AND Madv               = Pmadv
    AND ((Ngaydkgdtheodoi IS NOT NULL
    AND TRUNC(Ngaydkgdtheodoi) BETWEEN TO_DATE(Pfrom,FORMATDATE) AND TO_DATE(Pto,FORMATDATE))
    OR (Ngaydkgdtheodoi IS NULL
    AND Ngaydenghihoso  IS NOT NULL
    AND TRUNC(Ngaydenghihoso) BETWEEN TO_DATE(Pfrom, FORMATDATE) AND TO_DATE(Pto,FORMATDATE)))
    AND Ngayhuygiaodich              IS NULL
    AND NVL(Tinhchitieuthangtruoc, 0) = 0
    GROUP BY MADV,
      MaNV
    ) result_gdlk
  ON /*Instr(Pmadv, result_gdlk.madv)>0
  AND*/ nd.MaNhanVien                   =result_gdlk.MaNV
  left join (
   SELECT gd.Madv,
      gd.MaNV,
      COUNT(Magd) vresult
            FROM Giaodich Gd
            LEFT JOIN Khachhang Kh
            ON Kh.Makh = Gd.Makh
            
            LEFT JOIN Hopdong Hd
            ON Hd.Mahopdong = Gd.Mahopdong
            LEFT JOIN Dmchung Dm
            ON Dm.Madm = Gd.Hinhthuctt
            WHERE Gd.Madv <> 0
           AND Instr(Pmadv, Gd.Madv)>0
            AND Ngaycvpcxuathd <= TO_DATE(Pto, FORMATDATE)
            AND Ngayktxuathoadon IS NULL
            AND Ngayhuygiaodich IS NULL
          
            
            AND Dm.Loaidm = 'HTTT'
            group by gd.Madv,gd.MaNV
   
   ) result_hston on nd.MaNhanVien=result_hston.MaNV
   group by
   dv.TenDV,
    tvbh.tennhomtvbh,
      nd.TenNhanVien,
      nd.MaNhanVien
  --WHERE Instr(Pdongxe, Dx.Madongxe) > 0
  )

SELECT *
FROM
  (
  SELECT a.*,1 as ThuTuHienThi,
  decode(slctbhdv,0,0,round(slgdlk*100/slctbhdv)) slgdlk_p,
  decode(slctbhdv,0,0,round(slpcxhd*100/slctbhdv)) slpcxhd_p, -- Phan Tram PC XHD
  decode(slctbhdv,0,0,round(sldvxhd*100/slctbhdv)) sldvxhd_p --Phan Tram DON VI XHD
  FROM Result_Table a
  UNION ALL
  SELECT TenDonVi, TenNhom,
  'Tổng' || ' '||   TenNhom          as TenNhanVien,
    v_Null        as  MaNhanVien,
    SUM(slctbhdv) AS slctbhdv,--CHI TIEU BAN HANG
    SUM(slgdlk)   AS slgdlk,  --GIAO DICH DK THANG
    SUM(slpcxhd)  AS slpcxhd, --PC OR CV XUAT HOA DON
    SUM(sldvxhd)  AS sldvxhd, --DONVI XUAT HOA DON
    SUM(sldnnhs)  AS sldnnhs, --DE NGHI NHAN HOSO
    SUM(slgdtd)   AS slgdtd,  --GIAO DICH THEO DOI
    SUM(slth)     AS slth,    --KH theo d?i
    SUM(slthlk)   AS slthlk, --KH theo d?i LUY KE
     SUM(hston)   AS hston, -- HO SO TON
     2 as ThuTuHienThi,
     decode(SUM(slctbhdv),0,0,round( SUM(slgdlk)*100/SUM(slctbhdv))) slgdlk_p,--GIAO DICH DK THANG
    decode(SUM(slctbhdv),0,0,round( SUM(slpcxhd)*100/SUM(slctbhdv))) slpcxhd_p,--Phan Tram PC XHD
  decode(SUM(slctbhdv),0,0,round(SUM(sldvxhd)*100/SUM(slctbhdv))) sldvxhd_p--Phan Tram DON VI XHD
    
  FROM Result_Table
  GROUP BY TenDonVi,TenNhom
 
  UNION ALL
  SELECT TenDonVi,
   v_Null AS TenNhom,
 'Tổng '||v_Null|| TenDonVi            as TenNhanVien,
   v_Null           as  MaNhanVien,
    SUM(slctbhdv) AS slctbhdv,--CHI TIEU BAN HANG
    SUM(slgdlk)   AS slgdlk,  --GIAO DICH DK THANG
    SUM(slpcxhd)  AS slpcxhd, --PC OR CV XUAT HOA DON
    SUM(sldvxhd)  AS sldvxhd, --DONVI XUAT HOA DON
    SUM(sldnnhs)  AS sldnnhs, --DE NGHI NHAN HOSO
    SUM(slgdtd)   AS slgdtd,  --GIAO DICH THEO DOI
    SUM(slth)     AS slth,    --KH theo d?i
    SUM(slthlk)   AS slthlk, --KH theo d?i LUY KE
     SUM(hston)   AS hston, -- HO SO TON
      3 as ThuTuHienThi,
       decode(SUM(slctbhdv),0,0,round( SUM(slgdlk)*100/SUM(slctbhdv))) slgdlk_p,--GIAO DICH DK THANG
    decode(SUM(slctbhdv),0,0,round( SUM(slpcxhd)*100/SUM(slctbhdv))) slpcxhd_p,--Phan Tram PC XHD
  decode(SUM(slctbhdv),0,0,round(SUM(sldvxhd)*100/SUM(slctbhdv))) sldvxhd_p--Phan Tram DON VI XHD
   
  FROM Result_Table group by TenDonVi
  ) 
  
ORDER BY TenDonVi,TenNhom,ThuTuHienThi;
            
END sp_THBH_theodongxe_byNV;


PROCEDURE sp_DangkyThang_byMaNV
(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Loaixes     VARCHAR2(32767)   := NULL;
 v_pFrom date :=null;
  v_pTo date :=null;
  v_Sql varchar2(32767):=null;
  v_separate varchar2(100):='''_''';
  v_dongxe varchar2(1000):=''''||Pdongxe||'''';
  v_MaDv varchar2(1000):=''''||Pmadv||'''';
  v_a varchar(100):='';
   v_sp2 varchar(100):=''',''';
    v_SR varchar(100):='''SHOWROOM''';
    v_total varchar(100):='''TOTAL''';
  BEGIN

  v_pFrom:=TO_DATE(pFrom,Formatdate);
  v_pTo:=TO_DATE(pTo,Formatdate);
 
    -- SELECT Listagg(''''||Nlx.MaDongXe||'_'||Nlx.MaNhom||'_'||MaLoaiXe||'''', ',') Within GROUP(ORDER BY Ckd DESC, Nlx.Thutuhienthi ASC)
      SELECT RTRIM(XMLAGG(XMLELEMENT(E,v_a||MaDongXe||'_'||MaNhom||'_'||MaLoaiXe||v_a,',').EXTRACT('//text()') ORDER BY MaDongXe).GetClobVal(),',') AS LIST
        INTO Loaixes
        from (
        select distinct dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
        FROM LoaiXe lx
        Join NhomLoaiXe nlx
        ON Nlx.Manhom = Lx.Manhom
        INNER JOIN Dongxe dx on Nlx.MaDongXe=dx.MaDongXe and Instr(Pdongxe, dx.MaDongXe) > 0
        WHERE Lx.Checkhienthi = 1
        order by  dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe) abc;
        
        Loaixes := ''''||Loaixes ||'''';
        Loaixes:=replace(Loaixes,',',''''||','||'''');
        Loaixes := Loaixes || ',' || '''TOTAL''';
    
        -- base SQL statement
        v_Sql := '
              WITH CTE AS (
              
              select abc.MaNV,abc.TenNV,Tennhomtvbh,abc.MaDV,abc.TenDonVi,abc.ThuTu,list.MaLoaiXe,list.MaGD from (
               SELECT cast(nd.MaNhanVien as varchar(2000)) MaNV,cast(TenNhanVien as varchar(2000)) TENNV,cast(ntv.Tennhomtvbh as varchar(2000)) Tennhomtvbh,dv.MaDV,cast(dv.TenDV as varchar(2000)) TenDonVi ,1 ThuTu
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,ntv.MaDonVi)>0
    join Donvi dv on ntv.MaDonvi=dv.MaDv
    WHERE instr('||v_MaDv||',ntv.MaDonVi)>0
    union 
             select to_char(donvi.MaDV) AS Manv,
'||v_SR||' AS Tennv,'''||'yyyy'||''' TENNHOMTVBH,donvi.MaDV,cast(donvi.TenDV as varchar(2000)) TenDonVi,3 as ThuTu from donvi where instr('||v_MaDv||',donvi.Madv)>0
 
       
              ) ABC
  left join 
                
                (
              
              SELECT Gd.Manv,
                       dx.MaDongXe||'||v_separate||'||nlx.MaNhom||'||v_separate||'||lx.MaLoaiXe as MaLoaiXe,count(Gd.MaGD) as MaGD
                FROM Giaodich Gd
                join LoaiXe lx on lx.MaLoaiXe=gd.MaLoaiXe AND Lx.Checkhienthi = 1
                join NhomLoaiXe nlx on nlx.MaNhom=lx.MaNhom
                join DongXe dx on nlx.MaDongXe=dx.MaDongXe and instr('||v_dongxe||',dx.MaDongXe)>0
                WHERE Gd.Madv <> 0
                AND instr('||v_MaDv||',Gd.Madv)>0
                AND ((Ngaydenghihoso IS NULL AND To_Date(Ngaydkgdtheodoi) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo ||
                 ''') OR
                  (Ngaydenghihoso IS NOT NULL AND To_Date(Ngaydenghihoso) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo || '''))
                AND Ngayhuygiaodich IS NULL
                and nvl(TinhChiTieuThangTruoc,0) = 0
                group by
                Gd.Manv,
                dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
                ) list
                on ABC.Manv=list.MaNV)
                
                select * from(
                select * from (
                select * from CTE
                union
                select '''' MaNV,'''||'Tổng'||''' TenNV, Tennhomtvbh,MaDV,TenDonVi,2 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu=1
                
                group by Tennhomtvbh,MaDV,TenDonVi,MaLoaiXe
                union
                 select '''' MaNV,'''||'Tổng'||''' TenNV,'''||'zzzz'||''' Tennhomtvbh,MaDV,TenDonVi,4 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu in(1,3)
                
                group by MaDV,TenDonVi,MaLoaiXe
                )
                
                 pivot (sum(MaGD) for (MaLoaiXe) in('||Loaixes||'))
                 )
               
                order by MaDV,Tennhomtvbh,ThuTu
            
               ';
                  
              
              
              
              

              
                dbms_output.put_line(v_Sql);
    
        -- execute query 
        OPEN Cur FOR v_Sql;
    
END sp_DangkyThang_byMaNV;

PROCEDURE sp_SrXHD_byMaNV
(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Loaixes     VARCHAR2(32767)   := NULL;
 v_pFrom date :=null;
  v_pTo date :=null;
  v_Sql varchar2(32767):=null;
  v_separate varchar2(100):='''_''';
  v_dongxe varchar2(1000):=''''||Pdongxe||'''';
  v_MaDv varchar2(1000):=''''||Pmadv||'''';
  v_a varchar(100):='';
   v_sp2 varchar(100):=''',''';
    v_SR varchar(100):='''SHOWROOM''';
    v_total varchar(100):='''TOTAL''';
  BEGIN

  v_pFrom:=TO_DATE(pFrom,Formatdate);
  v_pTo:=TO_DATE(pTo,Formatdate);
 
    -- SELECT Listagg(''''||Nlx.MaDongXe||'_'||Nlx.MaNhom||'_'||MaLoaiXe||'''', ',') Within GROUP(ORDER BY Ckd DESC, Nlx.Thutuhienthi ASC)
      SELECT RTRIM(XMLAGG(XMLELEMENT(E,v_a||MaDongXe||'_'||MaNhom||'_'||MaLoaiXe||v_a,',').EXTRACT('//text()') ORDER BY MaDongXe).GetClobVal(),',') AS LIST
        INTO Loaixes
        from (
        select distinct dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
        FROM LoaiXe lx
        Join NhomLoaiXe nlx
        ON Nlx.Manhom = Lx.Manhom
        INNER JOIN Dongxe dx on Nlx.MaDongXe=dx.MaDongXe and Instr(Pdongxe, dx.MaDongXe) > 0
        WHERE  Lx.Checkhienthi = 1
        order by  dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe) abc;
        
        Loaixes := ''''||Loaixes ||'''';
        Loaixes:=replace(Loaixes,',',''''||','||'''');
          Loaixes := Loaixes || ',' || '''TOTAL''';
    
        -- base SQL statement
        
               
              
               v_Sql := '
              WITH CTE AS (
              
              select abc.MaNV,abc.TenNV,Tennhomtvbh,abc.MaDV,abc.TenDonVi,abc.ThuTu,list.MaLoaiXe,list.MaGD from (
               SELECT cast(nd.MaNhanVien as varchar(2000)) MaNV,cast(TenNhanVien as varchar(2000)) TENNV,cast(ntv.Tennhomtvbh as varchar(2000)) Tennhomtvbh,dv.MaDV,cast(dv.TenDV as varchar(2000)) TenDonVi ,1 ThuTu
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,ntv.MaDonVi)>0
    join Donvi dv on ntv.MaDonvi=dv.MaDv
    WHERE instr('||v_MaDv||',ntv.MaDonVi)>0
    union 
             select to_char(donvi.MaDV) AS Manv,
'||v_SR||' AS Tennv,'''||'yyyy'||''' TENNHOMTVBH,donvi.MaDV,cast(donvi.TenDV as varchar(2000)) TenDonVi,3 as ThuTu from donvi where instr('||v_MaDv||',donvi.Madv)>0
 
       
              ) ABC
  left join 
                
                (
              
              SELECT Gd.Manv,
                       dx.MaDongXe||'||v_separate||'||nlx.MaNhom||'||v_separate||'||lx.MaLoaiXe as MaLoaiXe,count(Gd.MaGD) as MaGD
                FROM Giaodich Gd
                join LoaiXe lx on lx.MaLoaiXe=gd.MaLoaiXe AND Lx.Checkhienthi = 1
                join NhomLoaiXe nlx on nlx.MaNhom=lx.MaNhom
                join DongXe dx on nlx.MaDongXe=dx.MaDongXe and instr('||v_dongxe||',dx.MaDongXe)>0
                WHERE Gd.Madv <> 0
                AND instr('||v_MaDv||',Gd.Madv)>0
                 AND (
                 Ngayktxuathoadon IS NOT NULL AND To_Date(Ngayktxuathoadon) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo ||
                 ''')
                group by
                Gd.Manv,
                dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
                ) list
                on ABC.Manv=list.MaNV)
                
                select * from(
                select * from (
                select * from CTE
                union
                select '''' MaNV,'''||'Tổng'||''' TenNV, Tennhomtvbh,MaDV,TenDonVi,2 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu=1
                
                group by Tennhomtvbh,MaDV,TenDonVi,MaLoaiXe
                union
                 select '''' MaNV,'''||'Tổng'||''' TenNV,'''||'zzzz'||''' Tennhomtvbh,MaDV,TenDonVi,4 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu in(1,3)
                
                group by MaDV,TenDonVi,MaLoaiXe
                )
                
                 pivot (sum(MaGD) for (MaLoaiXe) in('||Loaixes||'))
                 )
               
                order by MaDV,Tennhomtvbh,ThuTu
            
               ';
                dbms_output.put_line(v_Sql);
    
        -- execute query 
        OPEN Cur FOR v_Sql;
    
END sp_SrXHD_byMaNV;

PROCEDURE sp_CV_XHD_byMaNV
(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Loaixes     VARCHAR2(32767)   := NULL;
 v_pFrom date :=null;
  v_pTo date :=null;
  v_Sql varchar2(32767):=null;
  v_separate varchar2(100):='''_''';
  v_dongxe varchar2(1000):=''''||Pdongxe||'''';
  v_MaDv varchar2(1000):=''''||Pmadv||'''';
  v_a varchar(100):='';
   v_sp2 varchar(100):=''',''';
    v_SR varchar(100):='''SHOWROOM''';
    v_total varchar(100):='''TOTAL''';
  BEGIN

  v_pFrom:=TO_DATE(pFrom,Formatdate);
  v_pTo:=TO_DATE(pTo,Formatdate);
 
    -- SELECT Listagg(''''||Nlx.MaDongXe||'_'||Nlx.MaNhom||'_'||MaLoaiXe||'''', ',') Within GROUP(ORDER BY Ckd DESC, Nlx.Thutuhienthi ASC)
      SELECT RTRIM(XMLAGG(XMLELEMENT(E,MaDongXe||'_'||MaNhom||'_'||MaLoaiXe,',').EXTRACT('//text()') ORDER BY MaDongXe,MaNhom,MaLoaiXe).GetClobVal(),',') AS LIST
        INTO Loaixes
        from (
        select distinct dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
        FROM LoaiXe lx
        Join NhomLoaiXe nlx
        ON Nlx.Manhom = Lx.Manhom
        INNER JOIN Dongxe dx on Nlx.MaDongXe=dx.MaDongXe and Instr(Pdongxe, dx.MaDongXe) > 0
        WHERE  Lx.Checkhienthi = 1
        order by dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe) abc;
        
        Loaixes := ''''||Loaixes ||'''';
        Loaixes:=replace(Loaixes,',',''''||','||'''');
          Loaixes := Loaixes || ',' || '''TOTAL''';
    dbms_output.put_line(Loaixes);
        -- base SQL statement
       
               
              
               v_Sql := '
              WITH CTE AS (
              
              select abc.MaNV,abc.TenNV,Tennhomtvbh,abc.MaDV,abc.TenDonVi,abc.ThuTu,list.MaLoaiXe,list.MaGD from (
               SELECT cast(nd.MaNhanVien as varchar(2000)) MaNV,cast(TenNhanVien as varchar(2000)) TENNV,cast(ntv.Tennhomtvbh as varchar(2000)) Tennhomtvbh,dv.MaDV,cast(dv.TenDV as varchar(2000)) TenDonVi ,1 ThuTu
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,ntv.MaDonVi)>0
    join Donvi dv on ntv.MaDonvi=dv.MaDv
    WHERE instr('||v_MaDv||',ntv.MaDonVi)>0
    union 
             select to_char(donvi.MaDV) AS Manv,
'||v_SR||' AS Tennv,'''||'yyyy'||''' TENNHOMTVBH,donvi.MaDV,cast(donvi.TenDV as varchar(2000)) TenDonVi,3 as ThuTu from donvi where instr('||v_MaDv||',donvi.Madv)>0
 
       
              ) ABC
  left join 
                
                (
              
              SELECT Gd.Manv,
                       dx.MaDongXe||'||v_separate||'||nlx.MaNhom||'||v_separate||'||lx.MaLoaiXe as MaLoaiXe,count(Gd.MaGD) as MaGD
                FROM Giaodich Gd
                join LoaiXe lx on lx.MaLoaiXe=gd.MaLoaiXe AND Lx.Checkhienthi = 1
                join NhomLoaiXe nlx on nlx.MaNhom=lx.MaNhom
                join DongXe dx on nlx.MaDongXe=dx.MaDongXe and instr('||v_dongxe||',dx.MaDongXe)>0
                WHERE Gd.Madv <> 0
                AND instr('||v_MaDv||',Gd.Madv)>0
                 AND To_Date(Ngaycvpcxuathd) BETWEEN ''' || v_pFrom || ''' AND ''' || v_pTo || '''
                group by
                Gd.Manv,
                dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
                ) list
                on ABC.Manv=list.MaNV)
                
                select * from(
                select * from (
                select * from CTE
                union
                select '''' MaNV,'''||'Tổng'||''' TenNV, Tennhomtvbh,MaDV,TenDonVi,2 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu=1
                
                group by Tennhomtvbh,MaDV,TenDonVi,MaLoaiXe
                union
                 select '''' MaNV,'''||'Tổng'||''' TenNV,'''||'zzzz'||''' Tennhomtvbh,MaDV,TenDonVi,4 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu in(1,3)
                
                group by MaDV,TenDonVi,MaLoaiXe
                )
                
                 pivot (sum(MaGD) for (MaLoaiXe) in('||Loaixes||'))
                 )
               
                order by MaDV,Tennhomtvbh,ThuTu
            
               ';
                  
              
              
                dbms_output.put_line(v_Sql);
    
        -- execute query 
        OPEN Cur FOR v_Sql;
    
END sp_CV_XHD_byMaNV;

PROCEDURE sp_GiaoDich_TonDong
(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Loaixes     VARCHAR2(32767)   := NULL;
 v_pFrom date :=null;
  v_pTo date :=null;
  v_Sql varchar2(32767):=null;
  v_separate varchar2(100):='''_''';
  v_dongxe varchar2(1000):=''''||Pdongxe||'''';
  v_MaDv varchar2(1000):=''''||Pmadv||'''';
  v_a varchar(100):='';
   v_sp2 varchar(100):=''',''';
    v_SR varchar(100):='''SHOWROOM''';
    v_total varchar(100):='''TOTAL''';
  BEGIN

  v_pFrom:=TO_DATE(pFrom,Formatdate);
  v_pTo:=TO_DATE(pTo,Formatdate);
 
    -- SELECT Listagg(''''||Nlx.MaDongXe||'_'||Nlx.MaNhom||'_'||MaLoaiXe||'''', ',') Within GROUP(ORDER BY Ckd DESC, Nlx.Thutuhienthi ASC)
      SELECT RTRIM(XMLAGG(XMLELEMENT(E,MaDongXe||'_'||MaNhom||'_'||MaLoaiXe,',').EXTRACT('//text()') ORDER BY MaDongXe,MaNhom,MaLoaiXe).GetClobVal(),',') AS LIST
        INTO Loaixes
        from (
        select distinct dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
        FROM LoaiXe lx
        Join NhomLoaiXe nlx
        ON Nlx.Manhom = Lx.Manhom
        INNER JOIN Dongxe dx on Nlx.MaDongXe=dx.MaDongXe and Instr(Pdongxe, dx.MaDongXe) > 0
        WHERE  Lx.Checkhienthi = 1
        order by dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe) abc;
        
        Loaixes := ''''||Loaixes ||'''';
        Loaixes:=replace(Loaixes,',',''''||','||'''');
          Loaixes := Loaixes || ',' || '''TOTAL''';
    dbms_output.put_line(Loaixes);
        -- base SQL statement
       

              
             v_Sql := '
              WITH CTE AS (
              
              select abc.MaNV,abc.TenNV,Tennhomtvbh,abc.MaDV,abc.TenDonVi,abc.ThuTu,list.MaLoaiXe,list.MaGD from (
               SELECT cast(nd.MaNhanVien as varchar(2000)) MaNV,cast(TenNhanVien as varchar(2000)) TENNV,cast(ntv.Tennhomtvbh as varchar(2000)) Tennhomtvbh,dv.MaDV,cast(dv.TenDV as varchar(2000)) TenDonVi ,1 ThuTu
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,ntv.MaDonVi)>0
    join Donvi dv on ntv.MaDonvi=dv.MaDv
    WHERE instr('||v_MaDv||',ntv.MaDonVi)>0
    union 
             select to_char(donvi.MaDV) AS Manv,
'||v_SR||' AS Tennv,'''||'yyyy'||''' TENNHOMTVBH,donvi.MaDV,cast(donvi.TenDV as varchar(2000)) TenDonVi,3 as ThuTu from donvi where instr('||v_MaDv||',donvi.Madv)>0
 
       
              ) ABC
  left join 
                
                (
              
              SELECT Gd.Manv,
                       dx.MaDongXe||'||v_separate||'||nlx.MaNhom||'||v_separate||'||lx.MaLoaiXe as MaLoaiXe,count(Gd.MaGD) as MaGD
                FROM Giaodich Gd
                join LoaiXe lx on lx.MaLoaiXe=gd.MaLoaiXe AND Lx.Checkhienthi = 1
                join NhomLoaiXe nlx on nlx.MaNhom=lx.MaNhom
                join DongXe dx on nlx.MaDongXe=dx.MaDongXe and instr('||v_dongxe||',dx.MaDongXe)>0
                WHERE Gd.Madv <> 0
                AND instr('||v_MaDv||',Gd.Madv)>0
                 AND
                  (
                  ((Ngaydenghihoso IS NOT NULL AND Ngaydenghihoso <= '''||v_pto||''') OR
                  (Ngaydenghihoso IS NULL AND Ngaychuyendoitt IS NOT NULL AND Ngaychuyendoitt <='''||v_pto||'''))
            AND (Ngayhuygiaodich IS NULL OR (Ngayhuygiaodich IS NOT NULL AND Ngayhuygiaodich > '''||v_pto||'''))
            AND (Ngaycvpcxuathd IS NULL OR (Ngaycvpcxuathd IS NOT NULL AND Ngaycvpcxuathd >= '''||v_pto||'''))
            AND (Ngayktxuathoadon IS NULL OR (Ngayktxuathoadon IS NOT NULL AND Ngayktxuathoadon >= '''||v_pto||'''))
                  ) or(
                    (Ngaydenghihoso IS NULL OR (Ngaydenghihoso IS NOT NULL AND Ngaydenghihoso > '''||v_pto||'''))
            AND (Ngaychuyendoitt IS NULL OR (Ngaychuyendoitt IS NOT NULL AND Ngaychuyendoitt > '''||v_pto||'''))
            AND (Ngaydkgdtheodoi IS NOT NULL AND ((Ngaytheodoilai IS NULL AND Ngaydkgdtheodoi <= '''||v_pto||''') OR
                  (Ngaytheodoilai IS NOT NULL AND Ngaytheodoilai <= '''||v_pto||''')))
            AND (Ngayhuygiaodich IS NULL OR (Ngayhuygiaodich IS NOT NULL AND Ngayhuygiaodich > '''||v_pto||'''))
            AND (Ngaycvpcxuathd IS NULL OR (Ngaycvpcxuathd IS NOT NULL AND Ngaycvpcxuathd >= '''||v_pto||'''))
            AND (Ngayktxuathoadon IS NULL OR (Ngayktxuathoadon IS NOT NULL AND Ngayktxuathoadon >= '''||v_pto||'''))
   
                  )
                group by
                Gd.Manv,
                dx.MaDongXe,nlx.MaNhom,lx.MaLoaiXe
                ) list
                on ABC.Manv=list.MaNV)
                
                select * from(
                select * from (
                select * from CTE
                union
                select '''' MaNV,'''||'Tổng'||''' TenNV, Tennhomtvbh,MaDV,TenDonVi,2 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu=1
                
                group by Tennhomtvbh,MaDV,TenDonVi,MaLoaiXe
                union
                 select '''' MaNV,'''||'Tổng'||''' TenNV,'''||'zzzz'||''' Tennhomtvbh,MaDV,TenDonVi,4 ThuTu,MaLoaiXe,sum(MaGD) MaGD
                from CTE where ThuTu in(1,3)
                
                group by MaDV,TenDonVi,MaLoaiXe
                )
                
                 pivot (sum(MaGD) for (MaLoaiXe) in('||Loaixes||'))
                 )
               
                order by MaDV,Tennhomtvbh,ThuTu
            
               ';
                
                
                
    
        -- execute query 
        OPEN Cur FOR v_Sql;
    
END sp_GiaoDich_TonDong;
PROCEDURE sp_HSTON_byMaNV(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Dongxes     VARCHAR2(100)   := NULL;
BEGIN
   OPEN Cur FOR
  SELECT To_Char(Hd.Ngayky,'dd/MM/yyyy') AS Ngayky,dx.TenDongXe as TenDongXe,
                   Lx.Tenloaixe AS Tenloaixe,
                   1 AS Soluong,
                   Mx.Codemau,
                   Mx.Tenmau,
                   Gd.Sokhung,
                   Gd.Somay,
                   Gd.Thung,
                   Gd.AC, -- May Lanh
                   Gd.CACD, -- CA/CD,
                   Gd.Giaban AS Giaban,
                   Kh.Tenkh AS Tenkh,
                   Dm.Tendm AS Httt,
                   (CASE
                       WHEN instr(pMaDV,gd.MaDV)>0 THEN
                        (SELECT 'SR'
                         FROM Dual)
                       ELSE
                        (SELECT To_Char(Tennhanvien)
                         FROM Nguoidung Nd
                         WHERE Nd.Manhanvien = Gd.Manv)
                   END) AS Tennv,
                   Gd.Ghichu,
                   kh.DiaChi as DiaChi,
                   kh.DienThoai as DienThoai,
                    gd.ngaynhanxe,gd.ngaynhanhs,gd.ngaydenghihoso 
                   
            FROM Giaodich Gd
            LEFT JOIN Khachhang Kh
            ON Kh.Makh = Gd.Makh
            LEFT JOIN Loaixe Lx
            ON Lx.Maloaixe = Gd.Maloaixe
            LEFT JOIN NhomLoaiXe nlx
            on lx.MaNhom=nlx.MaNhom
            Left JOIN DongXe dx
            on nlx.MaDongXe=dx.MaDongXe and instr(Pdongxe,dx.MaDongXe)>0
            LEFT JOIN Mauxe Mx
            ON Mx.Mamau = Gd.Mamau
            LEFT JOIN Hopdong Hd
            ON Hd.Mahopdong = Gd.Mahopdong
            LEFT JOIN Dmchung Dm
            ON Dm.Madm = Gd.Hinhthuctt
            WHERE Gd.Madv <> 0
           and instr(Pmadv,Gd.Madv)>0
            AND Ngaycvpcxuathd <= TO_DATE(pTo,'dd/mm/yyyy')
            AND Ngayktxuathoadon IS NULL
            AND Ngayhuygiaodich IS NULL
           
            AND Lx.Checkhienthi = 1
            AND Dm.Loaidm = 'HTTT'
            ORDER BY Hd.Ngayky ASC;
end sp_HSTON_byMaNV; 

PROCEDURE sp_GDTON_CHI_TIET(
  Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
  Cur   OUT SYS_REFCURSOR
)
IS
  Formatdate  VARCHAR(10)     := 'dd/MM/yyyy';
  Dongxes     VARCHAR2(100)   := NULL;
BEGIN
   OPEN Cur FOR
  select * from (
   SELECT To_Char(Gd.Ngaytao, Formatdate) AS Ngayky,dx.TenDongXe,
                   Lx.Tenloaixe AS Tenloaixe,hd.SoHopDong,
                   1 AS Soluong,
                   Mx.Codemau,
                   Mx.Tenmau,
                   Gd.Sokhung,
                   Gd.Somay,
                   thung.TenThung Thung,
                   Gd.AC, -- May Lanh
                   Gd.CACD, -- CA/CD,
                   Gd.Giaban AS Giaban,
                   Kh.Tenkh AS Tenkh,
                   Dm.Tendm AS Httt,
                   (CASE
                       WHEN instr(pMaDV,gd.Manv)>0 THEN
                        (SELECT 'SR'
                         FROM Dual)
                       ELSE
                        (SELECT To_Char(Tennhanvien)
                         FROM Nguoidung Nd
                         WHERE Nd.Manhanvien = Gd.Manv)
                   END) AS Tennv,
                  DBMS_LOB.SUBSTR (gd.Ghichu, 4000, 1)as GhiChu,
                kh.DiaChi as DiaChi,
                   kh.DienThoai as DienThoai,
               To_Char( gd.ngaydkgdtheodoi, Formatdate) ngaydkgdtheodoi   ,
                To_Char( gd.Ngaychuyendoitt, Formatdate) Ngaychuyendoitt,
                    gd.DatCoc
                  
                  
            FROM Giaodich Gd
            LEFT JOIN Khachhang Kh
            ON Kh.Makh = Gd.Makh
            LEFT JOIN Loaixe Lx
            ON Lx.Maloaixe = Gd.Maloaixe
              LEFT JOIN NhomLoaiXe nlx
            on lx.MaNhom=nlx.MaNhom
            Left JOIN DongXe dx
            on nlx.MaDongXe=dx.MaDongXe and instr(Pdongxe,dx.MaDongXe)>0
            LEFT JOIN Mauxe Mx
            ON Mx.Mamau = Gd.Mamau
            LEFT JOIN Hopdong Hd
            ON Hd.Mahopdong = Gd.Mahopdong
            LEFT JOIN Dmchung Dm
            ON Dm.Madm = Gd.Hinhthuctt
            Left join DmThung thung on gd.Thung=thung.MaThung
            WHERE Gd.Madv <> 0
            and instr(Pmadv,Gd.Madv)>0
            AND ((Ngaydenghihoso IS NOT NULL AND Ngaydenghihoso <= to_Date(Pto,formatDate)) OR
                  (Ngaydenghihoso IS NULL AND Ngaychuyendoitt IS NOT NULL AND Ngaychuyendoitt <= to_Date(Pto,formatDate)))
            AND (Ngayhuygiaodich IS NULL OR (Ngayhuygiaodich IS NOT NULL AND Ngayhuygiaodich > to_Date(Pto,formatDate)))
            AND (Ngaycvpcxuathd IS NULL OR (Ngaycvpcxuathd IS NOT NULL AND Ngaycvpcxuathd >= to_Date(Pto,formatDate)))
            AND (Ngayktxuathoadon IS NULL OR (Ngayktxuathoadon IS NOT NULL AND Ngayktxuathoadon >= to_Date(Pto,formatDate)))
         
            AND Lx.Checkhienthi = 1
            AND Dm.Loaidm = 'HTTT'
          
            
       UNION 
        SELECT To_Char(Hd.Ngayky, Formatdate) AS Ngayky,dx.TenDongXe,
                   Lx.Tenloaixe AS Tenloaixe,hd.SoHopDong,
                   1 AS Soluong,
                   Mx.Codemau,
                   Mx.Tenmau,
                   Gd.Sokhung,
                   Gd.Somay,
                    thung.TenThung Thung,
                   Gd.AC, -- May Lanh
                   Gd.CACD, -- CA/CD,
                   Gd.Giaban AS Giaban,
                   Kh.Tenkh AS Tenkh,
                   Dm.Tendm AS Httt,
                   (CASE
                       WHEN instr(pMaDV,gd.Manv)>0 THEN
                        (SELECT 'SR'
                         FROM Dual)
                       ELSE
                        (SELECT To_Char(Tennhanvien)
                         FROM Nguoidung Nd
                         WHERE Nd.Manhanvien = Gd.Manv)
                   END) AS Tennv,
                  DBMS_LOB.SUBSTR (gd.Ghichu, 4000, 1)as GhiChu,
                kh.DiaChi as DiaChi,
                   kh.DienThoai as DienThoai,
                   To_Char( gd.ngaydkgdtheodoi, Formatdate) ngaydkgdtheodoi   ,
                To_Char( gd.Ngaychuyendoitt, Formatdate) Ngaychuyendoitt,
                    gd.DatCoc
                  
            FROM Giaodich Gd
            LEFT JOIN Khachhang Kh
            ON Kh.Makh = Gd.Makh
            LEFT JOIN Loaixe Lx
            ON Lx.Maloaixe = Gd.Maloaixe
              LEFT JOIN NhomLoaiXe nlx
            on lx.MaNhom=nlx.MaNhom
            Left JOIN DongXe dx
            on nlx.MaDongXe=dx.MaDongXe and instr(Pdongxe,dx.MaDongXe)>0
            LEFT JOIN Mauxe Mx
            ON Mx.Mamau = Gd.Mamau
            LEFT JOIN Hopdong Hd
            ON Hd.Mahopdong = Gd.Mahopdong
            LEFT JOIN Dmchung Dm
            ON Dm.Madm = Gd.Hinhthuctt
            Left join DmThung thung on gd.Thung=thung.MaThung
            WHERE Gd.Madv <> 0
            and instr(Pmadv,Gd.Madv)>0
            AND (Ngaydenghihoso IS NULL OR (Ngaydenghihoso IS NOT NULL AND Ngaydenghihoso > to_Date(Pto,formatDate)))
            AND (Ngaychuyendoitt IS NULL OR (Ngaychuyendoitt IS NOT NULL AND Ngaychuyendoitt > to_Date(Pto,formatDate)))
            AND (Ngaydkgdtheodoi IS NOT NULL AND ((Ngaytheodoilai IS NULL AND Ngaydkgdtheodoi <= to_Date(Pto,formatDate)) OR
                  (Ngaytheodoilai IS NOT NULL AND Ngaytheodoilai <= to_Date(Pto,formatDate))))
            AND (Ngayhuygiaodich IS NULL OR (Ngayhuygiaodich IS NOT NULL AND Ngayhuygiaodich > to_Date(Pto,formatDate)))
            AND (Ngaycvpcxuathd IS NULL OR (Ngaycvpcxuathd IS NOT NULL AND Ngaycvpcxuathd >= to_Date(Pto,formatDate)))
            AND (Ngayktxuathoadon IS NULL OR (Ngayktxuathoadon IS NOT NULL AND Ngayktxuathoadon >= to_Date(Pto,formatDate)))
           
            AND Lx.Checkhienthi = 1
            AND Dm.Loaidm = 'HTTT')
            order by NgayKy;
end sp_GDTON_CHI_TIET; 

PROCEDURE sp_TheoDoi_TVBH(
     Pmadv IN VARCHAR,
    /* Danh sach Ma don vi */
    Pdongxe IN VARCHAR,
    /* Danh sach  Dong Xe */
    pFrom IN VARCHAR,
    pTo   IN VARCHAR,
    pList in nVARCHAR2,
    Cur OUT SYS_REFCURSOR )

IS
  Formatdate VARCHAR(10) := 'dd/MM/yyyy';
  v_space nvarchar2(100):='''''';
  v_space2 varchar(200):='''_''';
  v_sql varchar(32000):='';
  v_pFrom date :=null;
  v_pTo date :=null;
  v_CT varchar(100) :='''_CT''';
  v_KHTN varchar(100) :='''_KHTN''';
  v_listHoSo varchar(2000):='''5605, 5602, 5603, 5604''';
 v_SR varchar(100):='''SHOWROOM''';
 v_total varchar(100):='''_total''';
  v_percent varchar(100):='''_percent''';

  
BEGIN
 v_pFrom:=TO_DATE(pFrom,Formatdate);
  v_pTo:=TO_DATE(pTo,Formatdate);
 
 -- OPEN Cur FOR
 v_sql:='
 WITH Result_Table AS
  (
  select * from (
select  1 as TrangThai,MaNV ,Nam,Thang, To_CHAR(nam)||'||v_space2||'||To_CHAR(Thang)||'||v_space2||'||To_CHAR(MaDongXe) as keyword,count(MaGD) as SL from (
SELECT  cast(MaNV as VARCHAR2(1000)) as MaNV, dx.MaDongXe,EXTRACT(YEAR FROM Gd.NgayGiaoDich) nam, EXTRACT(Month FROM Gd.NgayGiaoDich) thang,Gd.MaGD 
                FROM Giaodich Gd
                join LoaiXe lx on gd.MaLoaiXe=lx.MaLoaiXe
                join NhomLoaiXe nlx on nlx.MaNhom=lx.MaNhom
                join DongXe dx on dx.MaDongXe=nlx.MaDongXe and instr('''||Pdongxe||''',dx.MaDongXe)>0
                WHERE Madv <> 0
                AND instr('''||Pmadv||''',Gd.Madv)>0
               AND ((Ngaydenghihoso IS NULL AND To_Date(Ngaydkgdtheodoi) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo ||
                 ''') OR
                  (Ngaydenghihoso IS NOT NULL AND To_Date(Ngaydenghihoso) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo || '''))
                AND Ngayhuygiaodich IS NULL
                and nvl(TinhChiTieuThangTruoc,0) = 0)
                
              group by Manv,MaDongXe,nam,Thang
        
              
             
             
   union all
          select 2 as TrangThai,cast(MaNV as VARCHAR2(1000)) as MaNV,Nam,Thang, To_CHAR(Nam)||'||v_space2||'||To_CHAR(Thang)||'||v_CT||' as keyword,soluong as SL
          from chitieubanhangnhanvien where   instr('''||Pmadv||''',MaDonVi)>0
      union all
           select 3 as TrangThai,MaNV,nam,thang,To_CHAR(Nam)||'||v_space2||'||To_CHAR(Thang)||'||v_KHTN||' as keyword,count(MaTheoDoiKHTN) as SL from (
           select  cast(TUVANBH as VARCHAR2(1000)) as MaNV,EXTRACT(YEAR FROM Theodoikhtn.NgayTiepXuc) nam, EXTRACT(Month FROM NgayTiepXuc) thang,MaTheoDoiKHTN
          from Theodoikhtn          
          where   Tuvanbh IS NOT NULL AND Instr('||v_listHoSo||', Tinhtrangkhs) > 0
             ) group by MaNV,nam,thang
         union all    
          
select  4 as TrangThai,MaNV ,Nam, -1 Thang, To_CHAR(nam)||'||v_space2||'||To_CHAR(MaDongXe) as keyword,count(MaGD) as SL from (
SELECT  cast(MaNV as VARCHAR2(1000)) as MaNV, dx.MaDongXe,EXTRACT(YEAR FROM Gd.NgayGiaoDich) nam, -1 thang,Gd.MaGD 
                FROM Giaodich Gd
                join LoaiXe lx on gd.MaLoaiXe=lx.MaLoaiXe
                join NhomLoaiXe nlx on nlx.MaNhom=lx.MaNhom
                join DongXe dx on dx.MaDongXe=nlx.MaDongXe and instr('''||Pdongxe||''',dx.MaDongXe)>0
                WHERE Madv <> 0
                AND instr('''||Pmadv||''',Gd.Madv)>0
               AND ((Ngaydenghihoso IS NULL AND To_Date(Ngaydkgdtheodoi) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo ||
                 ''') OR
                  (Ngaydenghihoso IS NOT NULL AND To_Date(Ngaydenghihoso) BETWEEN ''' ||
                 v_pFrom || ''' AND ''' || v_pTo || '''))
                AND Ngayhuygiaodich IS NULL
                and nvl(TinhChiTieuThangTruoc,0) = 0)
                
              group by Manv,MaDongXe,nam

                      
          ) order by Nam,Thang,KeyWord
        
    
              )
             
              select * from (
             select * from (
                select ABC.ThuTu,ABC.Manv,ABC.Tennv,list.keyword,list.SL
               from (
               select * from (
             select to_char(Manhanvien) AS Manv,
 To_Char(Tennhanvien) AS Tennv,donvi.MaDV,1 as ThuTu from donvi
join nguoidung on instr(nguoidung.madvs,donvi.MaDV)>0 and nguoidung.MaChucVu in(1,2)
and   instr('''||Pmadv||''',donvi.Madv)>0
UNION ALL 
select to_char(donvi.MaDV) AS Manv,
'||v_SR||' AS Tennv,donvi.MaDV,2 as ThuTu from donvi where instr('''||Pmadv||''',donvi.Madv)>0
            ) r1 order by ThuTu ) ABC
  left join 
                 (
                   select MaNV,keyword, SL
                      from Result_Table 
                  union 
                  select MaNV, To_CHAR(Nam)||'||v_space2||'||To_CHAR(Thang)||'||v_total||' as keyword, sum(SL) as SL
                      from Result_Table where TrangThai=1
                      group by MaNV,Thang,Nam
                  
                  union
                   select MaNV,To_CHAR(Nam)||'||v_space2||'||To_CHAR(Thang)||'||v_percent||' as keyword,
                        decode(Sum(ChiTieu),0,0,round(100*sum(SL)/Sum(ChiTieu))) as SL from 
                        (
                        select MaNV, Thang,Nam, sum(SL) as SL,0 as ChiTieu
                      from Result_Table where TrangThai=1
                      group by MaNV,Thang,Nam
                      union
                       select MaNV, Thang,Nam,0 SL,SL as ChiTieu
                      from Result_Table where TrangThai=2
                      )
                          group by  MaNV,Thang,Nam
                      union
                   select MaNV,To_CHAR(nam)||'||v_CT||' as keyword,sum(SL) as SL
                      from Result_Table where TrangThai=2 and Nam=EXTRACT(YEAR from TO_DATE('''||v_pTo||'''))
                      
                         group by MaNV,nam
                         union
                         select MaNV,To_CHAR(nam)||'||v_KHTN||' as keyword,sum(SL) as SL
                      from Result_Table where TrangThai=3 and Nam=EXTRACT(YEAR from TO_DATE('''||v_pTo||'''))
                      
                         group by MaNV,nam
                         
                      union all
                  select MaNV, To_CHAR(Nam)||'||v_total||' as keyword, sum(SL) as SL
                      from Result_Table where TrangThai=4
                      group by MaNV,Nam
                  union all
                     (
                        select MaNV,To_CHAR(Nam)||'||v_percent||' as keyword,decode(Sum(ChiTieu),0,0,round(100*sum(SL)/Sum(ChiTieu))) as SL from (
                        select MaNV,Nam, sum(SL) as SL,0 as ChiTieu
                      from Result_Table where TrangThai=4
                      group by MaNV,Nam
                      union
                       select MaNV,Nam,0 SL,SL as ChiTieu
                      from Result_Table where TrangThai=2 AND Nam=EXTRACT(YEAR from TO_DATE('''||v_pTo||''')))
                         group by  MaNV,Nam
                     )
                  ) list on ABC.Manv=list.MaNV
                )
                pivot (sum(SL) for (keyword) in('||pList||'))
                
                ) order by ThuTu ';
               
        
       
         dbms_output.put_line(v_sql);
         OPEN Cur FOR v_sql;
         END sp_TheoDoi_TVBH;
END Pkg_Baocaotonghop;