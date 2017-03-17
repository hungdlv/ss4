create or replace PACKAGE BODY pkg_hanhx_khtn_cv
IS
    --
    -- To modify this template, edit file PKGBODY.TXT in TEMPLATE
    -- directory of SQL Navigator
    --
    -- Purpose: Briefly explain the functionality of the package body
    --
    -- MODIFICATION HISTORY
    -- Person       Date      Comments
    -- ---------    ------  ------------------------------------------
    -- Enter procedure, function bodies as shown below

/* Lay thong tin thung xe */
    PROCEDURE GetThungByLoaiXe (pLoaiXe IN NUMBER, CUR OUT SYS_REFCURSOR)

    IS
    BEGIN
        OPEN Cur FOR
            SELECT  *
              FROM  dmthung
             WHERE  dmthung.IDLoaiXe = pLoaiXe;
    END GetThungByLoaiXe;

/* Lay dien bien khach hang CV */
    PROCEDURE DIENBIENKHTN_GETBYTUVANBH_CV (cur OUT SYS_REFCURSOR, pMAKHTN IN NUMBER,

    pTUVANBH IN NUMBER)
    AS
    BEGIN
        OPEN cur FOR
              SELECT   d.MADB, d.MAKHTN, d.NOIDUNG, d.NGAYCAPNHAT, d.NGAYTIEP,
                          d.MATHEODOIKHTN, d.TINHTRANGKH,
                          NVL (d.XEQUANTAM, t.xequantam) AS xequantam,
                          GETLOAIXES (NVL (d.xequantam, t.xequantam)) AS tenxequantam,
                          tt.tendm AS TENTINHTRANGKH, d.mamau,
                          (SELECT   mx.tenmau
                              FROM  mauxe mx
                             WHERE  mx.mamau = d.mamau)
                              AS tenmauxe, d.madongco,d.Thung,d.GhiChu_Thung,d.MaOption,

                          (SELECT   hs.tenhopso
                              FROM  hopso hs
                             WHERE  hs.mahopso = d.madongco)
                              AS tendongco
                 FROM         DIENBIENKHTN d

                              INNER JOIN
                                  THEODOIKHTN t

                              ON d.matheodoikhtn = t.matheodoikhtn

                          INNER JOIN
                              dmchung tt

                          ON tt.madm = d.tinhtrangkh

                WHERE   t.MAKHTN = pMAKHTN AND t.TUVANBH = pTUVANBH

            ORDER BY   d.ngaytiep;

    END DIENBIENKHTN_GETBYTUVANBH_CV;


/* Kiem tra tu van ban hanhx co trong nhom nao chua */                                                                                    -- Procedure
PROCEDURE sp_check_tvbh (pMaTVBH IN VARCHAR, Cur OUT SYS_REFCURSOR)
IS
BEGIN
 open Cur for
    SELECT *
      FROM  nhomtvbh tv
     WHERE  tv.nhomtruong = pMaTVBH OR INSTR (tv.dstuvanbh, pMaTVBH) > 0;
    
END sp_check_tvbh;                                                                                    -- Procedure

PROCEDURE GETTVBH_BYMADV_NEW
(
  pMADONVI IN NUMBER,
  pIDNhom in number,
  CUR OUT SYS_REFCURSOR
)
IS
BEGIN    
OPEN CUR FOR 

   select distinct k.manv,k.tennv,k.ngayvao from
   (    
        select p.manhanvien as manv,p.tennhanvien as tennv,p.ngayvaocty as ngayvao
        from nguoidung p 
        where dbms_lob.instr(p.madvs,pMADONVI)>0 and p.machucvu in(1,2,3,4,5) --DucSon 13/2/2014   
        and MaNhanVien not in(select mAnHANvien from
 nguoidung nd
join 
  nhomtvbh ON instr(nhomtvbh.dstuvanbh,nd.MaNhanVien)>0 and (MaNhomTVBH<>pIDNhom or pIDNhom=-1)
where NhomTruong is not null and MaDonVi=pMADONVI)
   )k
    order by k.tennv;               
END GETTVBH_BYMADV_NEW;

PROCEDURE GETPHOPHONG_BYMADV
(
  pMADONVI IN NUMBER,
  CUR OUT SYS_REFCURSOR
)
IS
BEGIN    
OPEN CUR FOR 

   select distinct k.manv,k.tennv,k.ngayvao from
   (    
        select p.manhanvien as manv,p.tennhanvien as tennv,p.ngayvaocty as ngayvao
        from nguoidung p 
        where dbms_lob.instr(p.madvs,pMADONVI)>0 and p.machucvu=3 --DucSon 13/2/2014   
        
   )k
    order by k.tennv;               
END GETPHOPHONG_BYMADV;

PROCEDURE NHOMTVBH_INSERT
(
  pTENNHOMTVBH NVARCHAR2,
  pMADONVI NUMBER,
  pNHOMTRUONG VARCHAR2,
  pNGUOITAO VARCHAR2,
  pNGAYTAO DATE,
  pDSTUVANBH CLOB,
  pDSXEMNHOM CLOB,
  pThiTruong in nvarchar2
)IS
BEGIN
    INSERT INTO NHOMTVBH
    (
      MANHOMTVBH,
      TENNHOMTVBH,
      MADONVI,
      NHOMTRUONG,
      NGUOITAO,
      NGAYTAO,
      DSTUVANBH,DSXEMNHOM,
      ThiTruong
    )
    VALUES
    (
      SEQ_NHOMTVBH.Nextval,
      pTENNHOMTVBH,
      pMADONVI,
      pNHOMTRUONG,
      EMPLOYEE_LOADBYEMAIL(pNGUOITAO),
      pNGAYTAO,
      pDSTUVANBH,
      pDSXEMNHOM,
      pThiTruong
    );
END NHOMTVBH_INSERT;
PROCEDURE NHOMTVBH_UPDATE
  (
    pMANHOMTVBH NUMBER,
    pTENNHOMTVBH NVARCHAR2,
    pMADONVI NUMBER,
    pNHOMTRUONG VARCHAR2,
    pNGUOISUA VARCHAR2,
    pNGAYSUA DATE,
    pDSTUVANBH CLOB,
    pDSXEMNHOM CLOB
  )IS
  BEGIN
    UPDATE NHOMTVBH SET
        TENNHOMTVBH=pTENNHOMTVBH,
        MADONVI=pMADONVI,
        NHOMTRUONG=pNHOMTRUONG,
        NGUOISUA=EMPLOYEE_LOADBYEMAIL(pNGUOISUA),
        NGAYSUA=pNGAYSUA,
        DSTUVANBH=pDSTUVANBH,
        DSXEMNHOM= pDSXEMNHOM
    WHERE MANHOMTVBH=pMANHOMTVBH;
  END NHOMTVBH_UPDATE;
  
  procedure DIENBIENKHTN_INSERT_VDA
(
    pMAKHTN NUMBER,
    PMATHEODOIKHTN NUMBER,
    pNOIDUNG VARCHAR2,
    pNGAYCAPNHAT DATE,
    pNGAYTIEP DATE,
    pTINHTRANGKH NUMBER,
    pXEQUANTAM CLOB,
    pMaMau NUMBER,
    pThung varchar2,
    pGhiChu_Thung varchar2
) is
--poutXEQUANTAMS CLOB;
--poutTINHTRANGKH NUMBER;
begin
  INSERT INTO DIENBIENKHTN
  (
    MADB,    
    MAKHTN ,
    MATHEODOIKHTN ,
    NOIDUNG ,
    NGAYCAPNHAT ,
    NGAYTIEP ,
    TINHTRANGKH ,
    XEQUANTAM,
    MAMAU,
    THUNG,
    GHICHU_THUNG
  )
  VALUES
  (
   SEQ_DIENBIENKHTN.Nextval,
    pMAKHTN ,
    PMATHEODOIKHTN ,
    pNOIDUNG ,
    pNGAYCAPNHAT ,
    pNGAYTIEP ,
    pTINHTRANGKH ,
    pXEQUANTAM,
    pMaMau,pThung,pGhiChu_Thung
  ); 
  

--  SELECT DB.TINHTRANGKH into poutTINHTRANGKH,DB.Xequantam into poutXEQUANTAMS FROM DIENBIENKHTN DB where  DB.Matheodoikhtn=PMATHEODOIKHTN order by DB.Ngaytiep desc;
  
end DIENBIENKHTN_INSERT_VDA;


procedure DIENBIENKHTN_GETBYMAKHTN
(cur OUT SYS_REFCURSOR,pMAKHTN in number, pMATHEODOIKHTN in nvarchar2 default null,
pMADV in number default null)
 is
begin
  open cur for
    SELECT db.*,d.TENDM as TENTINHTRANGKH,
                  substr(noidung, greatest (-20, 1), 10) as  noidung_short
                  , GETLOAIXES(NVL(db.xequantam,TD.XEQUANTAM)) as TENXEQUANTAM
                  , gettenhopso (db.madongco)as tendongco 
                  , gettenmauxe(TO_NUMBER(db.mamau)) as tenmauxe,db.Thung,db.GhiChu_thung
                  , (mx.tenmau || ' - ' || mx.codemau) as tenmau,db.MaOption
    FROM DIENBIENKHTN db LEFT JOIN DMCHUNG d ON db.TINHTRANGKH=d.madm
                      left JOIN THEODOIKHTN TD ON TD.MATHEODOIKHTN=db.Matheodoikhtn
                      left join mauxe mx on mx.mamau = db.mamau
    
    WHERE db.MATHEODOIKHTN=pMATHEODOIKHTN and TD.MaKHTN = pMaKHTN    
    and (pMADV IS NULL OR td.madv=pMADV)
    and db.makhtn=pMaKHTN
    ORDER BY db.ngaytiep asc,MaDB ASC; 
end DIENBIENKHTN_GETBYMAKHTN;


procedure UPDATE_THEODOIKHTN_NEW_CV
(
    pMATHEODOIKHTN NUMBER,
    pTUVANBH NVARCHAR2,
    pHTTT NUMBER,
    pKENHTXs CLOB,   
    pTGMUADUKIEN NVARCHAR2,
    pTHONGTINKHAC NVARCHAR2     
) is
  pNgayTiepDau date:=sysdate;
  pNgayTiepCuoi date:=sysdate; 
  pTinhTrangKH number;
  
  pTinhTrangShow varchar2(50) := '';
  pXeQuanTamShow varchar(100) := '';
  pXeQuanTam Clob:='';
  pNoiDungTiepCuoi nvarchar2(1000) := '';
  pMaMau number :=0 ;
  pThung varchar2(2000):='';
  pGhiChu_Thung nvarchar2(2000):='';
  pTinhTrangDau number:=0;
  pSoLanDienBien number:=0;
  pNgayKyHD nvarchar2(2000):='';
  pThangKyHD nvarchar2(2000):=''; 
  pLan1 nvarchar2(2000):=''; 
   pLan2 nvarchar2(2000):=''; 
   pLan3 nvarchar2(2000):=''; 
    pLan4 nvarchar2(2000):=''; 
     pLan5 nvarchar2(2000):=''; 
      pLan6 nvarchar2(2000):=''; 
      pLan7 nvarchar2(2000):='';
       pLan8 nvarchar2(2000):='';
        pMaOption varchar2(2000):='';
begin

  --ngay tiep dau
  select ngaytiep into pNgayTiepDau  from 
  (
    select COALESCE( d.ngaytiep , td.ngaytiepxuc) as ngaytiep 
     from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
    where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb asc
  ) where rownum=1;
  
  --ngay tiep cuoi
  select ngaytiep into pNgayTiepCuoi  from 
  (
    select COALESCE( d.ngaytiep , td.ngaytiepxuc) as ngaytiep
    from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
    where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
  
  
  -- ma tinh  trang khach hang
 select tinhtrangkh into pTinhTrangKH  from 
 (
      select nvl(COALESCE(d.tinhtrangkh , to_number(td.tinhtrangkhs)),0) as  tinhtrangkh
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
 ) where rownum=1; 
 
 -- tinh trang khach hang show   
 if(pTinhTrangKH <> 0) then
   select dm.tendm into pTinhTrangShow
   from dmchung dm
   where dm.madm = pTinhTrangKH;
 end if;
 
 
 -- xe quan tam   
 select xequantam into pXeQuanTam  from 
 (
      select COALESCE(d.xequantam, td.xequantam) as xequantam
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
  
  -- xe quan tam show
  select important.Tenxequantam(pXeQuanTam) into pXeQuanTamShow
  from dual;
  
  
 -- noi dung tiep cuoi
 select noidung into pNoiDungTiepCuoi  from 
 (
      select COALESCE(d.noidung ,td.dienbientheodoi) as noidung
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
 ) where rownum=1; 
 
 
  -- xe quan tam   
 select mamau into pMaMau  from 
 (
      select COALESCE(to_number(d.mamau),td.mamau) as mamau
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
    -- xe quan tam   
 select thung into pThung  from 
 (
      select COALESCE(d.THung,td.Thung) as thung
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
   select MAOPTION into pMaOption  from 
 (
      select COALESCE(d.MaOption,td.MaOption) as MAOPTION
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
  BEGIN 
   select TO_CHAR(NgayTiep,'dd'),TO_CHAR(NgayTiep,'mm') into pNgayKyHD, pThangKyHD from 
 (select * from
    
      dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN  and( d.TinhTrangKH=5605) order by d.madb desc
  ) where rownum=1;
   
  EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pNgayKyHD:='';
     pThangKyHD:='';
     
  END;
  
  BEGIN
   select NVL(TinhTrangKH,0) into pTinhTrangDau from 
 (select * from
    
      dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN   order by d.madb asc
  ) where rownum=1;
    EXCEPTION WHEN NO_DATA_FOUND
    THEN
     pTinhTrangDau:=0;
    
  END;
  BEGIN
  select diengiai into pLan1 from 
     (SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 1);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan1:='';
  END;
  BEGIN
  select diengiai into pLan2 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 2);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan2:='';
  END;
   BEGIN
  select diengiai into pLan3 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 3);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan3:='';
  END;
   BEGIN
  select diengiai into pLan4 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 4);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan4:='';
  END;
    BEGIN
  select diengiai into pLan5 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 5);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan5:='';
  END;
    BEGIN
  select diengiai into pLan6 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 6);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan6:='';
  END;
    BEGIN
  select diengiai into pLan7 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 7);
   EXCEPTION WHEN NO_DATA_FOUND
   then
     pLan7:='';
  END;
     BEGIN
  select diengiai into pLan8 from 
 (SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 8);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan8:='';
  END;
  
   select count(*) into pSoLanDienBien from dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN ;
    
    update theodoikhtn td 
    set
          td.TUVANBH=pTUVANBH,
          td.HTTT=pHTTT,
          td.KENHTXs=pKENHTXs,   
          td.TGMUADUKIEN=pTGMUADUKIEN,
          td.THONGTINKHAC=pTHONGTINKHAC,           
          td.ngaytiepxuc=pNgayTiepDau,
          td.tinhtrangkhs=pTinhTrangKH,
          td.xequantam=pXeQuanTam,
          td.ngaytiepcuoi = pNgayTiepCuoi,
          td.tinhtrangkhshow = pTinhTrangShow,
          td.xequantamshow = pXeQuanTamShow,
          td.dienbientheodoi = pNoiDungTiepCuoi,
          td.mamau = pMaMau,
          td.Thung=pThung,
          td.GhiChu_Thung=pGhiChu_Thung,
          td.NgaykyHD=pNgayKyHD,
          td.ThangKyHD=pThangKyHD,
          td.TinhTrangDau=pTinhTrangDau,
          td.Lan1=pLan1,
          td.Lan2=pLan2,
          td.Lan3=pLan3,
          td.Lan4=pLan4,
          td.Lan5=pLan5,
          td.Lan6=pLan6,
          td.Lan7=pLan7,
          td.Lan8=pLan8,
          td.SoLanDienBien=pSoLanDienBien,
          td.MAOPTION=pMAOPTION
    where td.matheodoikhtn=pMATHEODOIKHTN;
    commit;
end UPDATE_THEODOIKHTN_NEW_CV;


PROCEDURE      THEODOIKHTN_LOAD_FORM
(
    Pmadv           NUMBER DEFAULT NULL,
    Ptungay         DATE DEFAULT NULL,
    Pdenngay        DATE DEFAULT NULL,
    Pfromngaytao    DATE DEFAULT NULL,
    Ptongaytao      DATE DEFAULT NULL,
    Pfromngaytxcuoi DATE DEFAULT NULL,
    Ptongaytxcuoi   DATE DEFAULT NULL,
    Ptinhtrangkh    NUMBER DEFAULT NULL,
    Pxequantam      NUMBER DEFAULT NULL,
    Ptinhthanh      NUMBER DEFAULT NULL,
    Pquanhuyen      NUMBER DEFAULT NULL,
    Pnhomtv         NUMBER DEFAULT NULL,
    Ptvbh           VARCHAR2 DEFAULT NULL,
    Ptgdukienmua    VARCHAR2 DEFAULT NULL,
    Psodienthoai    VARCHAR2 DEFAULT NULL,
    Psolandienbien  NUMBER,
    Pkhachhang      NVARCHAR2 DEFAULT NULL,
    pKTX            in number,
    -------------------------
    Cur OUT SYS_REFCURSOR
)IS
   dstuvan CLOB := null;
BEGIN
        IF (Pnhomtv IS NOT NULL)
        THEN
            SELECT Ntv.Dstuvanbh
            INTO Dstuvan
            FROM Nhomtvbh Ntv
            WHERE Ntv.Manhomtvbh = Pnhomtv;
        END IF;
        
        if(Ptinhtrangkh is null) then
      IF (Psolandienbien IS NULL)
              THEN
                    OPEN Cur FOR
                        SELECT  Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               e.email,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                     
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                  
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                               td.tinhtrangkhshow as Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                     
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               , (mx.tenmau || ' - ' || mx.codemau) as tenmau ,td.Thung,td.GhiChu_Thung,td.MaOption,
                               decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                        FROM Theodoikhtn Td
                        left JOIN Nguoidung e  ON e.Manhanvien = Td.Tuvanbh
                        left JOIN Khtn k  ON k.Makhtn = Td.Makhtn
                        LEFT  JOIN City c  ON c.Id = k.Tinhthanh
                        LEFT  JOIN Province p ON p.Id = k.Quanhuyen
                        LEFT  JOIN Dmchung Httt ON Httt.Madm = Td.Httt
                        left JOIN Khachhang K1 ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)
                        AND 
                        (
                        ((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND  Pdenngay) OR Pdenngay IS NULL ) 
                         AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL)
                         AND ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN   Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL)
                        )                  
                              
                        AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND (Td.Tuvanbh IN (SELECT *
                                           FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)                                             
                        
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL or Td.Tinhtrangkhs is null) 
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null)        
                       AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')                  
                        
                        ORDER BY 
                        CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                        END DESC;
                
                ELSE
                    OPEN Cur FOR
                        SELECT   Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               e.email,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                  
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                    
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,             
                               td.tinhtrangkhshow AS Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               to_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.Thung,td.GhiChu_Thung,td.MaOption,
                              decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                        FROM Theodoikhtn Td
                        INNER JOIN Nguoidung e
                        ON e.Manhanvien = Td.Tuvanbh
                        INNER JOIN Khtn k
                        ON k.Makhtn = Td.Makhtn
                        LEFT OUTER JOIN City c
                        ON c.Id = k.Tinhthanh
                        LEFT OUTER JOIN Province p
                        ON p.Id = k.Quanhuyen
                        LEFT OUTER JOIN Dmchung Httt
                        ON Httt.Madm = Td.Httt
                        LEFT JOIN Khachhang K1
                        ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)               
                        AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                              Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                              Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                              ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN
                              Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL 
                              ))
                     AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND (Td.Tuvanbh IN (SELECT *
                                           FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL) 
                        --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))    
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)                
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                        AND k.Makhtn IN (SELECT k.Makhtn
                                        FROM Theodoikhtn Td
                                        INNER JOIN Nguoidung e
                                        ON e.Manhanvien = Td.Tuvanbh
                                        INNER JOIN Khtn k
                                        ON k.Makhtn = Td.Makhtn
                                        LEFT OUTER JOIN City c
                                        ON c.Id = k.Tinhthanh
                                        LEFT OUTER JOIN Province p
                                        ON p.Id = k.Quanhuyen
                                        LEFT OUTER JOIN Dmchung Httt
                                        ON Httt.Madm = Td.Httt
                                        LEFT JOIN Dienbienkhtn d
                                        ON k.Makhtn = d.Makhtn
                                        WHERE (Td.Madv = Pmadv)
                                        GROUP BY k.Makhtn,
                                                 k.Tenkhtn
                                        HAVING COUNT(d.Makhtn) = Psolandienbien                                
                                        )
                        AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null) 
                        ORDER BY 
                         CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy')
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                         END DESC;
                END IF;    
        else              
             IF (Psolandienbien IS NULL)
                  THEN
                      OPEN Cur FOR
                          SELECT   Td.Matheodoikhtn,
                                 e.Tennhanvien AS Tvbh,
                                 e.Manhanvien AS Manv,
                                 e.email,
                                 To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                                 upper(k.Tenkhtn) AS Tenkh,
                                 p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                                 k.Dienthoai,
                                 To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                                 Td.Xequantam,                     
                                 td.xequantamshow AS Tenxequantam,
                                 Httt.Tendm AS Httt,
                                 Td.Kenhtxs AS Kenhtx,
                                 Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                  
                                 to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                                 td.tinhtrangkhshow as Tentinhtrangkh,
                                 Td.Dienbientheodoi,
                                 Td.Tgmuadukien,
                                 Td.Thongtinkhac,
                                 Td.Makhtn,                     
                                 Td.Dienbientheodoi AS Dienbien_Short,
                                 Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                                 To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                                 To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                                 k.ngaysua, td.ngaytiepcuoi
                                 , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.Thung,td.GhiChu_Thung,td.MaOption,
                                decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                          FROM Theodoikhtn Td
                          LEFT JOIN Nguoidung e
                          ON e.Manhanvien = Td.Tuvanbh
                          left JOIN Khtn k
                          ON k.Makhtn = Td.Makhtn
                          LEFT OUTER JOIN City c
                          ON c.Id = k.Tinhthanh
                          LEFT OUTER JOIN Province p
                          ON p.Id = k.Quanhuyen
                          LEFT OUTER JOIN Dmchung Httt
                          ON Httt.Madm = Td.Httt
                          LEFT JOIN Khachhang K1
                          ON K1.Makhtn = Td.Makhtn
                          left join mauxe mx on td.mamau = mx.mamau
                          WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)
                          AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                                Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                                ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN                      
                                Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL
                                ))                   
                                
                          AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                                '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                          AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                                REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                          AND (Td.Tuvanbh IN (SELECT *
                                             FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)
                          --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))                      
                          
                          AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                          AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                          AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                          AND (Pxequantam IN
                                (SELECT *
                                 FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                                Pxequantam IS NULL or td.xequantam is null)
                          and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)  
                          and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)              
                          AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')                          
                          ORDER BY 
                          CASE
                               WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                               WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                               WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                          END DESC;
                  
                  ELSE
                      OPEN Cur FOR
                          SELECT  Td.Matheodoikhtn,
                                 e.Tennhanvien AS Tvbh,
                                 e.Manhanvien AS Manv,
                                 e.email,
                                 To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                                 upper(k.Tenkhtn) AS Tenkh,
                                 p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                                 k.Dienthoai,
                                 To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                                 Td.Xequantam,                  
                                 td.xequantamshow AS Tenxequantam,
                                 Httt.Tendm AS Httt,
                                 Td.Kenhtxs AS Kenhtx,
                                 Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                    
                                 to_char(td.tinhtrangkhs) as Tinhtrangkh,             
                                 td.tinhtrangkhshow AS Tentinhtrangkh,
                                 Td.Dienbientheodoi,
                                 Td.Tgmuadukien,
                                 Td.Thongtinkhac,
                                 Td.Makhtn,                
                                 Td.Dienbientheodoi AS Dienbien_Short,
                                 Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                                 to_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                                 To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                                 k.ngaysua, td.ngaytiepcuoi
                                 , (mx.tenmau || ' - ' || mx.codemau) as tenmau ,td.Thung,td.GhiChu_Thung,td.MaOption,
                                 decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                          FROM Theodoikhtn Td
                          INNER JOIN Nguoidung e
                          ON e.Manhanvien = Td.Tuvanbh
                          INNER JOIN Khtn k
                          ON k.Makhtn = Td.Makhtn
                          LEFT OUTER JOIN City c
                          ON c.Id = k.Tinhthanh
                          LEFT OUTER JOIN Province p
                          ON p.Id = k.Quanhuyen
                          LEFT OUTER JOIN Dmchung Httt
                          ON Httt.Madm = Td.Httt
                          LEFT JOIN Khachhang K1
                          ON K1.Makhtn = Td.Makhtn
                          left join mauxe mx on td.mamau = mx.mamau
                          WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)               
                          AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                                Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                                ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL
                                ))
                       AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                                '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                          AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                                REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                          AND (Td.Tuvanbh IN (SELECT *
                                             FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)
                          --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))     
                                            
                          AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                          AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                          AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                          AND (Pxequantam IN
                                (SELECT *
                                 FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                                Pxequantam IS NULL or td.xequantam is null)                
                          and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)
                          and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                          AND k.Makhtn IN (SELECT k.Makhtn
                                          FROM Theodoikhtn Td
                                          INNER JOIN Nguoidung e
                                          ON e.Manhanvien = Td.Tuvanbh
                                          INNER JOIN Khtn k
                                          ON k.Makhtn = Td.Makhtn
                                          LEFT OUTER JOIN City c
                                          ON c.Id = k.Tinhthanh
                                          LEFT OUTER JOIN Province p
                                          ON p.Id = k.Quanhuyen
                                          LEFT OUTER JOIN Dmchung Httt
                                          ON Httt.Madm = Td.Httt
                                          LEFT JOIN Dienbienkhtn d
                                          ON k.Makhtn = d.Makhtn
                                          WHERE (Td.Madv = Pmadv)
                                          GROUP BY k.Makhtn,
                                                   k.Tenkhtn
                                          HAVING COUNT(d.Makhtn) = Psolandienbien                                
                                          )
                          AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')
                          
                          ORDER BY 
                           CASE
                               WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                               WHEN Pfromngaytxcuoi IS NOT NULL THEN To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy')
                               WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                           END DESC;
                
                 END IF;    
       end if;

END THEODOIKHTN_LOAD_FORM;



PROCEDURE THEODOIKHTN_LOAD_FORM_NEW
(
    Pmadv           NUMBER DEFAULT NULL,
    Ptungay         DATE DEFAULT NULL,
    Pdenngay        DATE DEFAULT NULL,
    Pfromngaytao    DATE DEFAULT NULL,
    Ptongaytao      DATE DEFAULT NULL,
    Pfromngaytxcuoi DATE DEFAULT NULL,
    Ptongaytxcuoi   DATE DEFAULT NULL,
    Ptinhtrangkh    NUMBER DEFAULT NULL,
    Pxequantam      NUMBER DEFAULT NULL,
    Ptinhthanh      NUMBER DEFAULT NULL,
    Pquanhuyen      NUMBER DEFAULT NULL,
    Pnhomtv         NUMBER DEFAULT NULL,
    Ptvbh           VARCHAR2 DEFAULT NULL,
    Ptgdukienmua    VARCHAR2 DEFAULT NULL,
    Psodienthoai    VARCHAR2 DEFAULT NULL,
    Psolandienbien  NUMBER,
    Pkhachhang      NVARCHAR2 DEFAULT NULL,
    pKTX            in number,
    pLoaiKH in number,
    -------------------------
    Cur OUT SYS_REFCURSOR
)IS
   dstuvan CLOB := null;
BEGIN
        IF (Pnhomtv IS NOT NULL)
        THEN
            SELECT Ntv.Dstuvanbh
            INTO Dstuvan
            FROM Nhomtvbh Ntv
            WHERE Ntv.Manhomtvbh = Pnhomtv;
        END IF;
        
        if(Ptinhtrangkh is null) then
      IF (Psolandienbien IS NULL)
              THEN
                    OPEN Cur FOR
                        SELECT  Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               e.email,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                     
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                  
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                               td.tinhtrangkhshow as Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                     
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               , (mx.tenmau || ' - ' || mx.codemau) as tenmau ,td.Thung,td.GhiChu_Thung,td.MaOption,
                              decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                        FROM Theodoikhtn Td
                        left JOIN Nguoidung e  ON e.Manhanvien = Td.Tuvanbh
                        left JOIN Khtn k  ON k.Makhtn = Td.Makhtn
                        LEFT  JOIN City c  ON c.Id = k.Tinhthanh
                        LEFT  JOIN Province p ON p.Id = k.Quanhuyen
                        LEFT  JOIN Dmchung Httt ON Httt.Madm = Td.Httt
                        left JOIN Khachhang K1 ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)
                        AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)
                        AND 
                        (
                        ((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND  Pdenngay) OR Pdenngay IS NULL ) 
                         AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL)
                         AND ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN   Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL)
                        )                  
                              
                        AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND (Td.Tuvanbh IN (SELECT *
                                           FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)                                             
                        
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL or Td.Tinhtrangkhs is null) 
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null)        
                       AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')                  
                        
                        ORDER BY 
                        CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                        END DESC;
                
                ELSE
                    OPEN Cur FOR
                        SELECT   Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               e.email,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                  
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                    
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,             
                               td.tinhtrangkhshow AS Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               to_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.Thung,td.GhiChu_Thung,td.MaOption,
                               decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                        FROM Theodoikhtn Td
                        INNER JOIN Nguoidung e
                        ON e.Manhanvien = Td.Tuvanbh
                        INNER JOIN Khtn k
                        ON k.Makhtn = Td.Makhtn
                        LEFT OUTER JOIN City c
                        ON c.Id = k.Tinhthanh
                        LEFT OUTER JOIN Province p
                        ON p.Id = k.Quanhuyen
                        LEFT OUTER JOIN Dmchung Httt
                        ON Httt.Madm = Td.Httt
                        LEFT JOIN Khachhang K1
                        ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)      AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)          
                        AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                              Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                              Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                              ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN
                              Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL 
                              ))
                     AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND (Td.Tuvanbh IN (SELECT *
                                           FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL) 
                        --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))    
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)                
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                        AND k.Makhtn IN (SELECT k.Makhtn
                                        FROM Theodoikhtn Td
                                        INNER JOIN Nguoidung e
                                        ON e.Manhanvien = Td.Tuvanbh
                                        INNER JOIN Khtn k
                                        ON k.Makhtn = Td.Makhtn
                                        LEFT OUTER JOIN City c
                                        ON c.Id = k.Tinhthanh
                                        LEFT OUTER JOIN Province p
                                        ON p.Id = k.Quanhuyen
                                        LEFT OUTER JOIN Dmchung Httt
                                        ON Httt.Madm = Td.Httt
                                        LEFT JOIN Dienbienkhtn d
                                        ON k.Makhtn = d.Makhtn
                                        WHERE (Td.Madv = Pmadv)
                                        GROUP BY k.Makhtn,
                                                 k.Tenkhtn
                                        HAVING COUNT(d.Makhtn) = Psolandienbien                                
                                        )
                        AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null) 
                        ORDER BY 
                         CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy')
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                         END DESC;
                END IF;    
        else              
             IF (Psolandienbien IS NULL)
                  THEN
                      OPEN Cur FOR
                          SELECT   Td.Matheodoikhtn,
                                 e.Tennhanvien AS Tvbh,
                                 e.Manhanvien AS Manv,
                                 e.email,
                                 To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                                 upper(k.Tenkhtn) AS Tenkh,
                                 p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                                 k.Dienthoai,
                                 To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                                 Td.Xequantam,                     
                                 td.xequantamshow AS Tenxequantam,
                                 Httt.Tendm AS Httt,
                                 Td.Kenhtxs AS Kenhtx,
                                 Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                  
                                 to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                                 td.tinhtrangkhshow as Tentinhtrangkh,
                                 Td.Dienbientheodoi,
                                 Td.Tgmuadukien,
                                 Td.Thongtinkhac,
                                 Td.Makhtn,                     
                                 Td.Dienbientheodoi AS Dienbien_Short,
                                 Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                                 To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                                 To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                                 k.ngaysua, td.ngaytiepcuoi
                                 , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.Thung,td.GhiChu_Thung,td.MaOption,
                                decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                          FROM Theodoikhtn Td
                          LEFT JOIN Nguoidung e
                          ON e.Manhanvien = Td.Tuvanbh
                          left JOIN Khtn k
                          ON k.Makhtn = Td.Makhtn
                          LEFT OUTER JOIN City c
                          ON c.Id = k.Tinhthanh
                          LEFT OUTER JOIN Province p
                          ON p.Id = k.Quanhuyen
                          LEFT OUTER JOIN Dmchung Httt
                          ON Httt.Madm = Td.Httt
                          LEFT JOIN Khachhang K1
                          ON K1.Makhtn = Td.Makhtn
                          left join mauxe mx on td.mamau = mx.mamau
                          WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)  AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)
                          AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                                Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                                ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN                      
                                Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL
                                ))                   
                                
                          AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                                '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                          AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                                REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                          AND (Td.Tuvanbh IN (SELECT *
                                             FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)
                          --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))                      
                          
                          AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                          AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                          AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                          AND (Pxequantam IN
                                (SELECT *
                                 FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                                Pxequantam IS NULL or td.xequantam is null)
                          and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)  
                          and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)              
                          AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')                          
                          ORDER BY 
                          CASE
                               WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                               WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                               WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                          END DESC;
                  
                  ELSE
                      OPEN Cur FOR
                          SELECT  Td.Matheodoikhtn,
                                 e.Tennhanvien AS Tvbh,
                                 e.Manhanvien AS Manv,
                                 e.email,
                                 To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                                 upper(k.Tenkhtn) AS Tenkh,
                                 p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                                 k.Dienthoai,
                                 To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                                 Td.Xequantam,                  
                                 td.xequantamshow AS Tenxequantam,
                                 Httt.Tendm AS Httt,
                                 Td.Kenhtxs AS Kenhtx,
                                 Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                    
                                 to_char(td.tinhtrangkhs) as Tinhtrangkh,             
                                 td.tinhtrangkhshow AS Tentinhtrangkh,
                                 Td.Dienbientheodoi,
                                 Td.Tgmuadukien,
                                 Td.Thongtinkhac,
                                 Td.Makhtn,                
                                 Td.Dienbientheodoi AS Dienbien_Short,
                                 Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                                 to_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                                 To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                                 k.ngaysua, td.ngaytiepcuoi
                                 , (mx.tenmau || ' - ' || mx.codemau) as tenmau ,td.Thung,td.GhiChu_Thung,td.MaOption,
                                 decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                          FROM Theodoikhtn Td
                          INNER JOIN Nguoidung e
                          ON e.Manhanvien = Td.Tuvanbh
                          INNER JOIN Khtn k
                          ON k.Makhtn = Td.Makhtn
                          LEFT OUTER JOIN City c
                          ON c.Id = k.Tinhthanh
                          LEFT OUTER JOIN Province p
                          ON p.Id = k.Quanhuyen
                          LEFT OUTER JOIN Dmchung Httt
                          ON Httt.Madm = Td.Httt
                          LEFT JOIN Khachhang K1
                          ON K1.Makhtn = Td.Makhtn
                          left join mauxe mx on td.mamau = mx.mamau
                          WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)        AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)         
                          AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                                Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                                ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL
                                ))
                       AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                                '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                          AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                                REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                          AND (Td.Tuvanbh IN (SELECT *
                                             FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)
                          --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))     
                                            
                          AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                          AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                          AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                          AND (Pxequantam IN
                                (SELECT *
                                 FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                                Pxequantam IS NULL or td.xequantam is null)                
                          and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)
                          and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                          AND k.Makhtn IN (SELECT k.Makhtn
                                          FROM Theodoikhtn Td
                                          INNER JOIN Nguoidung e
                                          ON e.Manhanvien = Td.Tuvanbh
                                          INNER JOIN Khtn k
                                          ON k.Makhtn = Td.Makhtn
                                          LEFT OUTER JOIN City c
                                          ON c.Id = k.Tinhthanh
                                          LEFT OUTER JOIN Province p
                                          ON p.Id = k.Quanhuyen
                                          LEFT OUTER JOIN Dmchung Httt
                                          ON Httt.Madm = Td.Httt
                                          LEFT JOIN Dienbienkhtn d
                                          ON k.Makhtn = d.Makhtn
                                          WHERE (Td.Madv = Pmadv)
                                          GROUP BY k.Makhtn,
                                                   k.Tenkhtn
                                          HAVING COUNT(d.Makhtn) = Psolandienbien                                
                                          )
                          AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')
                          
                          ORDER BY 
                           CASE
                               WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                               WHEN Pfromngaytxcuoi IS NOT NULL THEN To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy')
                               WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                           END DESC;
                
                 END IF;    
       end if;

END THEODOIKHTN_LOAD_FORM_NEW;


PROCEDURE NHOMTVBH_BYNHOMTRUONG
(
  pMADONVI IN NUMBER,
  pMaNhanVien IN VARCHAR2,
  pMaChucVu in number,
  CUR OUT sys_refcursor
)IS
  BEGIN
    OPEN CUR FOR
    select DISTINCT manhomtvbh,tennhomtvbh from (
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMADONVI
         AND  ntv.NhomTruong=pMaNhanVien
    union 
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMADONVI
         AND instr(ntv.DsXemNhom,pMaNhanVien)>0 and pMaChucVu=3
    
     union 
    SELECT  ntv.manhomtvbh,ntv.tennhomtvbh
    FROM NHOMTVBH ntv
    WHERE ntv.madonvi=pMADONVI
       and pMaChucVu<>2 and pMaChucVu<>3 );
            
         
          /*(SELECT e.EMPLOYEE_ID FROM EMPLOYEE@dblink e WHERE e.EMAIL=pEMAIL_NT);*/
  END NHOMTVBH_BYNHOMTRUONG;
  PROCEDURE DSTUVANBH_BYDONVI_NEW
  (
  pMADONVI NUMBER,
  pMaNhanVien IN varchar2,
  pMaChucVu IN varchar2,
  CUR OUT Sys_Refcursor
  )IS
 
  BEGIN
       OPEN CUR FOR
   select DISTINCT MaNV,TENNV from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,pMADONVI)>0
   
    WHERE ntv.madonvi=pMADONVI
         AND  ntv.NhomTruong=pMaNhanVien  
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,pMADONVI)>0
    WHERE ntv.madonvi=pMADONVI
         AND instr(ntv.DsXemNhom,pMaNhanVien)>0 and pMaChucVu=3
    
     union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and instr(nd.MaDVs,pMADONVI)>0
    WHERE ntv.madonvi=pMADONVI
        and pMaChucVu<>2 and pMaChucVu<>3
          );
         
      
      
  END DSTUVANBH_BYDONVI_NEW;
  
  procedure Theodoikhtn_Load_FormExcel
(
    Pmadv           NUMBER DEFAULT NULL,
    Ptungay         varchar2 DEFAULT NULL,
    Pdenngay        varchar2 DEFAULT NULL,
    Pfromngaytao    varchar2 DEFAULT NULL,
    Ptongaytao      varchar2 DEFAULT NULL,
    Pfromngaytxcuoi varchar2 DEFAULT NULL,
    Ptongaytxcuoi   varchar2 DEFAULT NULL,
    Ptinhtrangkh    NUMBER DEFAULT NULL,
    Pxequantam      NUMBER DEFAULT NULL,
    Ptinhthanh      NUMBER DEFAULT NULL,
    Pquanhuyen      NUMBER DEFAULT NULL,
    Pnhomtv         NUMBER DEFAULT NULL,
    Ptvbh           VARCHAR2 DEFAULT NULL,
    Ptgdukienmua    VARCHAR2 DEFAULT NULL,
    Psodienthoai    VARCHAR2 DEFAULT NULL,
    Psolandienbien  NUMBER DEFAULT NULL,
    Pkhachhang      NVARCHAR2 DEFAULT NULL,
    pKTX in number,
     pMaNhanVien in  varchar2,
    pMaChucVu in number,
    -------------------------
    Cur OUT SYS_REFCURSOR     
) is
   Dstuvan CLOB := NULL;
   
   
begin

   
  
                    OPEN Cur FOR
                   with CT as (
                        SELECT Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                     
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2)   AS Tenkenhtx,
                                
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                               td.tinhtrangkhshow as Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                     
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               ,GETNHOMCUATVBH(NVL(td.tuvanbh,''),pMADV) as nhomtv
                               , To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') as ngaytxcuoi 
                               ,td.Lan1 as lan1
                               ,td.Lan2 as lan2
                               ,td.Lan3 as lan3
                               ,td.Lan4 as lan4
                               ,td.Lan5 as lan5
                               ,td.Lan6 as lan6
                               ,td.Lan7 as lan7
                               ,td.Lan8 as lan8
                               , to_char(td.NgayTiepCuoi,'dd/mm/yyyy') || ' ' ||  td.DienBienTheoDoi as diengiai,
    td.NGAYKYHD ngaykyhd,
     td.THANGKYHD thangkyhd
                                , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.TinhTrangDau,td.Thung,td.MaOption,
                                decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                                 
                        FROM Theodoikhtn Td
                      
                        LEFT JOIN Nguoidung e
                        ON e.Manhanvien = Td.Tuvanbh
                        left JOIN Khtn k
                        ON k.Makhtn = Td.Makhtn
                        LEFT OUTER JOIN City c
                        ON c.Id = k.Tinhthanh
                        LEFT OUTER JOIN Province p
                        ON p.Id = k.Quanhuyen
                        LEFT OUTER JOIN Dmchung Httt
                        ON Httt.Madm = Td.Httt
                        LEFT JOIN Khachhang K1
                        ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                         
                          
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)
                       -- AND (Psolandienbien is null or td.SOLanDienBien=Psolandienbien)
                        AND ( Td.Ngaytiepxuc BETWEEN to_date(Ptungay,'dd/mm/yyyy') AND to_date(Pdenngay,'dd/mm/yyyy')
                              OR  Pdenngay IS NULL 
                             )
                         AND(k.NgayTao BETWEEN to_date(Pfromngaytao,'dd/mm/yyyy')
                        AND to_date(Ptongaytao,'dd/mm/yyyy') 
                             OR to_date(Ptongaytao,'dd/mm/yyyy')   IS NULL)
                         AND                      
                             ( trunc(td.ngaytiepcuoi) BETWEEN                      
                           trunc(to_date(Pfromngaytxcuoi,'dd/mm/yyyy')) AND trunc(to_date(Ptongaytxcuoi,'dd/mm/yyyy'))   OR Ptongaytxcuoi  IS NULL  
                              )                   
                              
                        AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND Td.Tuvanbh IN ( select DISTINCT MaNV from (
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,MaNhanVien)>0 and    instr(nd.MaDVs,Pmadv)>0
   
    WHERE ntv.madonvi=Pmadv
         AND  ntv.NhomTruong=pMaNhanVien  and (ntv.MaNhomTVBH=Pnhomtv or Pnhomtv is null)
    union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,Pmadv)>0
    WHERE ntv.madonvi=Pmadv
         AND instr(ntv.DsXemNhom,pMaNhanVien)>0 and pMaChucVu=3  and (ntv.MaNhomTVBH=Pnhomtv or Pnhomtv is null)
    
     union 
    SELECT  nd.MaNhanVien MaNV,TenNhanVien TENNV
    FROM NHOMTVBH ntv join NguoiDung nd on instr(ntv.DsTuVanBH,nd.MaNhanVien)>0 and instr(nd.MaDVs,Pmadv)>0
    WHERE ntv.madonvi=Pmadv and (ntv.MaNhomTVBH=Pnhomtv or Pnhomtv is null)
        and pMaChucVu<>2 and pMaChucVu<>3 
          ))
                                          
                        
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL or Td.Tinhtrangkhs is null or pTinhTrangKH=0) 
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null)        
                        AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')   
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)               
                        ORDER BY 
                        CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                        END DESC
                         ) 
                         
                         select * from CT;
                       
                
              
              
               
end Theodoikhtn_Load_FormExcel;
procedure UPDATE_THEODOIKHTN_NEW_CV2
(
    pMATHEODOIKHTN NUMBER

) is
  pNgayTiepDau date:=sysdate;
  pNgayTiepCuoi date:=sysdate; 
  pTinhTrangKH number;
  
  pTinhTrangShow varchar2(50) := '';
  pXeQuanTamShow varchar(100) := '';
  pXeQuanTam Clob:='';
  pNoiDungTiepCuoi nvarchar2(1000) := '';
  pMaMau number :=0 ;
  pThung varchar2(2000):='';
  pGhiChu_Thung nvarchar2(2000):='';
  pTinhTrangDau number:=0;
  pSoLanDienBien number:=0;
  pNgayKyHD nvarchar2(2000):='';
  pThangKyHD nvarchar2(2000):=''; 
  pLan1 nvarchar2(2000):=''; 
   pLan2 nvarchar2(2000):=''; 
   pLan3 nvarchar2(2000):=''; 
    pLan4 nvarchar2(2000):=''; 
     pLan5 nvarchar2(2000):=''; 
      pLan6 nvarchar2(2000):=''; 
      pLan7 nvarchar2(2000):='';
       pLan8 nvarchar2(2000):='';
begin

  
  BEGIN 
   select TO_CHAR(NgayTiep,'dd'),TO_CHAR(NgayTiep,'mm') into pNgayKyHD, pThangKyHD from 
 (select * from
    
      dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN  and( d.TinhTrangKH=5605) order by d.madb desc
  ) where rownum=1;
   
  EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pNgayKyHD:='';
     pThangKyHD:='';
     
  END;
  
  BEGIN
   select NVL(TinhTrangKH,0) into pTinhTrangDau from 
 (select * from
    
      dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN   order by d.madb asc
  ) where rownum=1;
    EXCEPTION WHEN NO_DATA_FOUND
    THEN
     pTinhTrangDau:=0;
    
  END;
  BEGIN
  select diengiai into pLan1 from 
     (SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 1);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan1:='';
  END;
  BEGIN
  select diengiai into pLan2 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 2);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan2:='';
  END;
   BEGIN
  select diengiai into pLan3 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 3);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan3:='';
  END;
   BEGIN
  select diengiai into pLan4 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 4);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan4:='';
  END;
    BEGIN
  select diengiai into pLan5 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 5);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan5:='';
  END;
    BEGIN
  select diengiai into pLan6 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 6);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan6:='';
  END;
    BEGIN
  select diengiai into pLan7 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 7);
   EXCEPTION WHEN NO_DATA_FOUND
   then
     pLan7:='';
  END;
     BEGIN
  select diengiai into pLan8 from 
 (SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 8);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan8:='';
  END;
  
   select count(*) into pSoLanDienBien from dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN ;
    
    update theodoikhtn td 
    set
          
          td.NgaykyHD=pNgayKyHD,
          td.ThangKyHD=pThangKyHD,
          td.TinhTrangDau=pTinhTrangDau,
          td.Lan1=pLan1,
          td.Lan2=pLan2,
          td.Lan3=pLan3,
          td.Lan4=pLan4,
          td.Lan5=pLan5,
          td.Lan6=pLan6,
          td.Lan7=pLan7,
          td.Lan8=pLan8,
          td.SoLanDienBien=pSoLanDienBien
    where td.matheodoikhtn=pMATHEODOIKHTN;
    commit;
end UPDATE_THEODOIKHTN_NEW_CV2;
PROCEDURE DonVi_GetByEmail
(
  pEmail IN NVARCHAR2,
  CUR OUT SYS_REFCURSOR
) IS
Begin
open CUR for
      SELECT dv.madv,dv.tendv,dv.tenbarcode
      FROM DONVI dv
      WHERE dv.madv IN
            (
            SELECT * 
            FROM TABLE(
                  SELECT SPLIT_CLOB(nd.madvs,',') 
                  FROM NGUOIDUNG nd 
                  WHERE nd.email=pEmail
                  )
            ) and dv.LoaiDV=5170
       order by dv.tendv;
End DonVi_GetByEmail;
 
 PROCEDURE khtn_updateInfo --ok
(
   pMaKHTN in number,
   pMaTheoDoiKHTN in number,
   pNgheNghiep in nvarchar2,
   pXeSoHuu in nvarchar2,
   pLoaiKH in number,
   pLoaiNgheNghiep in number,
   pSLMuaDuKien in number
) 
IS BEGIN  
     update KHTN
     set NgheNghiep = pNgheNghiep,
         XEDANGSOHUU = pXeSoHuu,
         LoaiKH=pLoaiKH,
         NganhngheKD=pLoaiNgheNghiep
     where MAKHTN = pMaKHTN;
     commit;
     Update theodoikhtn
     set SLMuaDuKien=pSLMuaDuKien
     where MaTheoDoiKHTN=pMaTheoDoiKHTN;
End khtn_updateInfo;
PROCEDURE GetAllNganhNghe
(

  CUR OUT SYS_REFCURSOR
)
IS
begin
 open Cur for
 select * from dmchung where LoaiDm='NganhNgheKD';
end GetAllNganhNghe;


PROCEDURE LOAIXE_GETBYMADV
(
  pMADV IN NUMBER default null,
  CUR OUT SYS_REFCURSOR
) 
IS
dongxes CLOB :=null;
Begin
  SELECT dv.dongxes INTO dongxes
  FROM DONVI dv
  WHERE  dv.madv=nvl(pMADV,0);
OPEN CUR FOR
  SELECT * 
  FROM LoaiXe lx
       INNER JOIN Nhomloaixe nlx ON lx.manhom=nlx.manhom
  WHERE nlx.madongxe IN
        (
            SELECT * 
            FROM TABLE(split_clob(dongxes,','))
        )
      
        
        AND nvl(LX.Checkhienthi,0) = 1
        AND nvl(LX.Xehetban,0) = 0
        order by lx.tenloaixe
        ;
End LOAIXE_GETBYMADV;

  procedure DIENBIENKHTN_INSERT_VDA_new
(
    pMAKHTN NUMBER,
    PMATHEODOIKHTN NUMBER,
    pNOIDUNG VARCHAR2,
    pNGAYCAPNHAT DATE,
    pNGAYTIEP DATE,
    pTINHTRANGKH NUMBER,
    pXEQUANTAM CLOB,
    pMaMau NUMBER,
    pThung varchar2,
    pGhiChu_Thung varchar2,
    pOption varchar2
) is
--poutXEQUANTAMS CLOB;
--poutTINHTRANGKH NUMBER;
begin
  INSERT INTO DIENBIENKHTN
  (
    MADB,    
    MAKHTN ,
    MATHEODOIKHTN ,
    NOIDUNG ,
    NGAYCAPNHAT ,
    NGAYTIEP ,
    TINHTRANGKH ,
    XEQUANTAM,
    MAMAU,
    THUNG,
    GHICHU_THUNG,
    MAOPTION
  )
  VALUES
  (
   SEQ_DIENBIENKHTN.Nextval,
    pMAKHTN ,
    PMATHEODOIKHTN ,
    pNOIDUNG ,
    pNGAYCAPNHAT ,
    pNGAYTIEP ,
    pTINHTRANGKH ,
    pXEQUANTAM,
    pMaMau,pThung,pGhiChu_Thung,pOption
  ); 
  

--  SELECT DB.TINHTRANGKH into poutTINHTRANGKH,DB.Xequantam into poutXEQUANTAMS FROM DIENBIENKHTN DB where  DB.Matheodoikhtn=PMATHEODOIKHTN order by DB.Ngaytiep desc;
  
end DIENBIENKHTN_INSERT_VDA_new;

PROCEDURE NHOMXE_GETBYDONVI--chi lay nhom xe co loaixe CKD hoac CBU
(
   pMADV NUMBER,
   CUR OUT SYS_REFCURSOR
)IS
   dem number :=0;
   dongxes clob := null;
   BEGIN
     SELECT COUNT(*) INTO dem FROM DONVI dv WHERE dv.madv=pMADV;
     IF(dem>0)THEN
       SELECT dv.dongxes INTO dongxes FROM DONVI dv WHERE dv.madv=pMADV AND ROWNUM = 1;
     END IF;
     OPEN CUR FOR
         --SELECT manhom,tennhom
         --FROM
         --(
             SELECT nlx.manhom,nlx.tennhom,nlx.thutuhienthi
             FROM NHOMLOAIXE nlx
                  INNER JOIN LOAIXE lx ON lx.manhom=nlx.manhom
             WHERE --nlx.madongxe IN dongxes
             Instr(dongxes, nlx.madongxe) > 0 
             /*(
              SELECT * FROM TABLE(split_clob(dongxes,','))
             )*/
             --AND (lx.ckd=0 OR lx.ckd=1)
             GROUP BY nlx.manhom,nlx.tennhom,nlx.thutuhienthi
         --)
         ORDER BY thutuhienthi;
END NHOMXE_GETBYDONVI;
PROCEDURE GetInfoKHTN--chi lay nhom xe co loaixe CKD hoac CBU
(
   pMaKHTN NUMBER,
   CUR OUT SYS_REFCURSOR
)
IS
begin
open cur for
select td.MaKHTN,td.MaTheoDOiKHTN,td.SLMuaDuKien,kh.LOAIKH,kh.NganhNgheKD from TheoDoiKHTN td
join KHTN kh on td.MaKHTN=kh.MaKHTN
where kh.MaKHTN=pMaKHTN;
end;

procedure UPDATE_THEODOIKHTN_NEW_CV_1
(
    pMATHEODOIKHTN NUMBER,
    pTUVANBH NVARCHAR2,
    pHTTT NUMBER,
    pKENHTXs CLOB,   
    pDuKienTuNgay varchar2,
    pDuKienDenNgay varchar2,
    pTHONGTINKHAC NVARCHAR2     
) is
  pNgayTiepDau date:=sysdate;
  pNgayTiepCuoi date:=sysdate; 
  pTinhTrangKH number;
  
  pTinhTrangShow varchar2(50) := '';
  pXeQuanTamShow varchar(100) := '';
  pXeQuanTam Clob:='';
  pNoiDungTiepCuoi nvarchar2(1000) := '';
  pMaMau number :=0 ;
  pThung varchar2(2000):='';
  pGhiChu_Thung nvarchar2(2000):='';
  pTinhTrangDau number:=0;
  pSoLanDienBien number:=0;
  pNgayKyHD nvarchar2(2000):='';
  pThangKyHD nvarchar2(2000):=''; 
  pLan1 nvarchar2(2000):=''; 
  pLan2 nvarchar2(2000):=''; 
  pLan3 nvarchar2(2000):=''; 
  pLan4 nvarchar2(2000):=''; 
  pLan5 nvarchar2(2000):=''; 
  pLan6 nvarchar2(2000):=''; 
  pLan7 nvarchar2(2000):='';
  pLan8 nvarchar2(2000):='';
  pMaOption varchar2(2000):='';
begin

  --ngay tiep dau
  select ngaytiep into pNgayTiepDau  from 
  (
    select COALESCE( d.ngaytiep , td.ngaytiepxuc) as ngaytiep 
     from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
    where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb asc
  ) where rownum=1;
  
  --ngay tiep cuoi
  select ngaytiep into pNgayTiepCuoi  from 
  (
    select COALESCE( d.ngaytiep , td.ngaytiepxuc) as ngaytiep
    from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
    where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
  
  
  -- ma tinh  trang khach hang
 select tinhtrangkh into pTinhTrangKH  from 
 (
      select nvl(COALESCE(d.tinhtrangkh , to_number(td.tinhtrangkhs)),0) as  tinhtrangkh
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
 ) where rownum=1; 
 
 -- tinh trang khach hang show   
 if(pTinhTrangKH <> 0) then
   select dm.tendm into pTinhTrangShow
   from dmchung dm
   where dm.madm = pTinhTrangKH;
 end if;
 
 
 -- xe quan tam   
 select xequantam into pXeQuanTam  from 
 (
      select COALESCE(d.xequantam, td.xequantam) as xequantam
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
  
  -- xe quan tam show
  select important.Tenxequantam(pXeQuanTam) into pXeQuanTamShow
  from dual;
  
  
 -- noi dung tiep cuoi
 select noidung into pNoiDungTiepCuoi  from 
 (
      select COALESCE(d.noidung ,td.dienbientheodoi) as noidung
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
 ) where rownum=1; 
 
 
  -- xe quan tam   
 select mamau into pMaMau  from 
 (
      select COALESCE(to_number(d.mamau),td.mamau) as mamau
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
    -- xe quan tam   
 select thung into pThung  from 
 (
      select COALESCE(d.THung,td.Thung) as thung
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
   select MAOPTION into pMaOption  from 
 (
      select COALESCE(d.MaOption,td.MaOption) as MAOPTION
      from theodoikhtn td  left join dienbienkhtn d on td.matheodoikhtn=d.matheodoikhtn
      where td.matheodoikhtn=pMATHEODOIKHTN order by d.madb desc
  ) where rownum=1;
  BEGIN 
   select TO_CHAR(NgayTiep,'dd'),TO_CHAR(NgayTiep,'mm') into pNgayKyHD, pThangKyHD from 
 (select * from
    
      dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN  and( d.TinhTrangKH=5605) order by d.madb desc
  ) where rownum=1;
   
  EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pNgayKyHD:='';
     pThangKyHD:='';
     
  END;
  
  BEGIN
   select NVL(TinhTrangKH,0) into pTinhTrangDau from 
 (select * from
    
      dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN   order by d.madb asc
  ) where rownum=1;
    EXCEPTION WHEN NO_DATA_FOUND
    THEN
     pTinhTrangDau:=0;
    
  END;
  BEGIN
  select diengiai into pLan1 from 
     (SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 1);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan1:='';
  END;
  BEGIN
  select diengiai into pLan2 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 2);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan2:='';
  END;
   BEGIN
  select diengiai into pLan3 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 3);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan3:='';
  END;
   BEGIN
  select diengiai into pLan4 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 4);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan4:='';
  END;
    BEGIN
  select diengiai into pLan5 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 5);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan5:='';
  END;
    BEGIN
  select diengiai into pLan6 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 6);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan6:='';
  END;
    BEGIN
  select diengiai into pLan7 from 
(SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 7);
   EXCEPTION WHEN NO_DATA_FOUND
   then
     pLan7:='';
  END;
     BEGIN
  select diengiai into pLan8 from 
 (SELECT  *
                FROM     (SELECT   ROWNUM nb, e.*
                             FROM   (  SELECT     TO_CHAR (d.NgayTiep, 'dd/mm/yyyy')
                                                      || ' '
                                                      || noidung
                                                          AS diengiai
                                             FROM   dienbienkhtn d where  d.matheodoikhtn=pMATHEODOIKHTN 
                                        ORDER BY   d.madb ASC) e) f

              WHERE  nb = 8);
   EXCEPTION WHEN NO_DATA_FOUND
   THEN
     pLan8:='';
  END;
  
   select count(*) into pSoLanDienBien from dienbienkhtn d 
      where d.matheodoikhtn=pMATHEODOIKHTN ;
    
    update theodoikhtn td 
    set
          td.TUVANBH=pTUVANBH,
          td.HTTT=pHTTT,
          td.KENHTXs=pKENHTXs,   
          td.tgdukienmuatungay=to_date(pDuKienTuNgay,'dd/MM/yyyy'),
          td.tgdukienmuadenngay=to_date(pDuKienDenNgay,'dd/MM/yyyy'),
          td.THONGTINKHAC=pTHONGTINKHAC,           
          td.ngaytiepxuc=pNgayTiepDau,
          td.tinhtrangkhs=pTinhTrangKH,
          td.xequantam=pXeQuanTam,
          td.ngaytiepcuoi = pNgayTiepCuoi,
          td.tinhtrangkhshow = pTinhTrangShow,
          td.xequantamshow = pXeQuanTamShow,
          td.dienbientheodoi = pNoiDungTiepCuoi,
          td.mamau = pMaMau,
          td.Thung=pThung,
          td.GhiChu_Thung=pGhiChu_Thung,
          td.NgaykyHD=pNgayKyHD,
          td.ThangKyHD=pThangKyHD,
          td.TinhTrangDau=pTinhTrangDau,
          td.Lan1=pLan1,
          td.Lan2=pLan2,
          td.Lan3=pLan3,
          td.Lan4=pLan4,
          td.Lan5=pLan5,
          td.Lan6=pLan6,
          td.Lan7=pLan7,
          td.Lan8=pLan8,
          td.SoLanDienBien=pSoLanDienBien,
          td.MAOPTION=pMAOPTION
    where td.matheodoikhtn=pMATHEODOIKHTN;
    commit;
end UPDATE_THEODOIKHTN_NEW_CV_1;

PROCEDURE THEODOIKHTN_LOAD_FORM_NEW_1
(
    Pmadv           NUMBER DEFAULT NULL,
    Ptungay         DATE DEFAULT NULL,
    Pdenngay        DATE DEFAULT NULL,
    Pfromngaytao    DATE DEFAULT NULL,
    Ptongaytao      DATE DEFAULT NULL,
    Pfromngaytxcuoi DATE DEFAULT NULL,
    Ptongaytxcuoi   DATE DEFAULT NULL,
    Ptinhtrangkh    NUMBER DEFAULT NULL,
    Pxequantam      NUMBER DEFAULT NULL,
    Ptinhthanh      NUMBER DEFAULT NULL,
    Pquanhuyen      NUMBER DEFAULT NULL,
    Pnhomtv         NUMBER DEFAULT NULL,
    Ptvbh           VARCHAR2 DEFAULT NULL,
    --Ptgdukienmua    VARCHAR2 DEFAULT NULL,
    Psodienthoai    VARCHAR2 DEFAULT NULL,
    Psolandienbien  NUMBER,
    Pkhachhang      NVARCHAR2 DEFAULT NULL,
    pKTX            in number,
    pLoaiKH in number,
    Ptungay_dukien  DATE DEFAULT NULL,
    Pdenngay_dukien DATE DEFAULT NULL,
    -------------------------
    Cur OUT SYS_REFCURSOR
)IS
   dstuvan CLOB := null;
BEGIN
        IF (Pnhomtv IS NOT NULL)
        THEN
            SELECT Ntv.Dstuvanbh
            INTO Dstuvan
            FROM Nhomtvbh Ntv
            WHERE Ntv.Manhomtvbh = Pnhomtv;
        END IF;
        
        if(Ptinhtrangkh is null) then
      IF (Psolandienbien IS NULL)
              THEN
                    OPEN Cur FOR
                        SELECT  Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               e.email,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                     
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                  
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                               td.tinhtrangkhshow as Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                     
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               , (mx.tenmau || ' - ' || mx.codemau) as tenmau ,td.Thung,td.GhiChu_Thung
                               ,(case td.MaOption when '0' then '' else td.MaOption end ) as MaOption
                               ,decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                        FROM Theodoikhtn Td
                        left JOIN Nguoidung e  ON e.Manhanvien = Td.Tuvanbh
                        left JOIN Khtn k  ON k.Makhtn = Td.Makhtn
                        LEFT  JOIN City c  ON c.Id = k.Tinhthanh
                        LEFT  JOIN Province p ON p.Id = k.Quanhuyen
                        LEFT  JOIN Dmchung Httt ON Httt.Madm = Td.Httt
                        left JOIN Khachhang K1 ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)
                        AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)
                        AND 
                        (
                        ((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND  Pdenngay) OR Pdenngay IS NULL ) 
                         AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL)
                         AND ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN   Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL)
                        )                  
                        and 
                        ( 
                             td.tgdukienmuatungay between Ptungay_dukien and Pdenngay_dukien or
                             td.tgdukienmuadenngay between Ptungay_dukien and Pdenngay_dukien or 
                             Ptungay_dukien is null or Pdenngay_dukien is null
                        )      
                        /*AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)*/                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND (Td.Tuvanbh IN (SELECT *
                                           FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)                                             
                        
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL or Td.Tinhtrangkhs is null) 
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null)        
                        AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')                  
                        
                        ORDER BY 
                        CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                        END DESC;
                
                ELSE
                    OPEN Cur FOR
                        SELECT   Td.Matheodoikhtn,
                               e.Tennhanvien AS Tvbh,
                               e.Manhanvien AS Manv,
                               e.email,
                               To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                               upper(k.Tenkhtn) AS Tenkh,
                               p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                               k.Dienthoai,
                               To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                               Td.Xequantam,                  
                               td.xequantamshow AS Tenxequantam,
                               Httt.Tendm AS Httt,
                               Td.Kenhtxs AS Kenhtx,
                               Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                    
                               to_char(td.tinhtrangkhs) as Tinhtrangkh,             
                               td.tinhtrangkhshow AS Tentinhtrangkh,
                               Td.Dienbientheodoi,
                               Td.Tgmuadukien,
                               Td.Thongtinkhac,
                               Td.Makhtn,                
                               Td.Dienbientheodoi AS Dienbien_Short,
                               Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                               to_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                               To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                               k.ngaysua, td.ngaytiepcuoi
                               , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.Thung,td.GhiChu_Thung
                               ,(case td.MaOption when '0' then '' else td.MaOption end ) as MaOption
                               ,decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                        FROM Theodoikhtn Td
                        INNER JOIN Nguoidung e
                        ON e.Manhanvien = Td.Tuvanbh
                        INNER JOIN Khtn k
                        ON k.Makhtn = Td.Makhtn
                        LEFT OUTER JOIN City c
                        ON c.Id = k.Tinhthanh
                        LEFT OUTER JOIN Province p
                        ON p.Id = k.Quanhuyen
                        LEFT OUTER JOIN Dmchung Httt
                        ON Httt.Madm = Td.Httt
                        LEFT JOIN Khachhang K1
                        ON K1.Makhtn = Td.Makhtn
                        left join mauxe mx on td.mamau = mx.mamau
                        WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)      AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)          
                        AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                              Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                              Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                              ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN
                              Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL 
                              ))
                        and 
                        ( 
                             td.tgdukienmuatungay between Ptungay_dukien and Pdenngay_dukien or
                             td.tgdukienmuadenngay between Ptungay_dukien and Pdenngay_dukien or 
                             Ptungay_dukien is null or Pdenngay_dukien is null
                        )
                        /*AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                              '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)*/                     
                        AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                              REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                              REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                        AND (Td.Tuvanbh IN (SELECT *
                                           FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL) 
                        --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))    
                        AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                        AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                        AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                        AND (Pxequantam IN
                              (SELECT *
                               FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                              Pxequantam IS NULL or td.xequantam is null)                
                        and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)
                        and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                        AND k.Makhtn IN (SELECT k.Makhtn
                                        FROM Theodoikhtn Td
                                        INNER JOIN Nguoidung e
                                        ON e.Manhanvien = Td.Tuvanbh
                                        INNER JOIN Khtn k
                                        ON k.Makhtn = Td.Makhtn
                                        LEFT OUTER JOIN City c
                                        ON c.Id = k.Tinhthanh
                                        LEFT OUTER JOIN Province p
                                        ON p.Id = k.Quanhuyen
                                        LEFT OUTER JOIN Dmchung Httt
                                        ON Httt.Madm = Td.Httt
                                        LEFT JOIN Dienbienkhtn d
                                        ON k.Makhtn = d.Makhtn
                                        WHERE (Td.Madv = Pmadv)
                                        GROUP BY k.Makhtn,
                                                 k.Tenkhtn
                                        HAVING COUNT(d.Makhtn) = Psolandienbien                                
                                        )
                        AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')
                        and (td.tinhtrangkhshow <> 'Close' or td.tinhtrangkhshow is null) 
                        and (td.tinhtrangkhshow <> 'Fail' or td.tinhtrangkhshow is null) 
                        ORDER BY 
                         CASE
                             WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                             WHEN Pfromngaytxcuoi IS NOT NULL THEN To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy')
                             WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                         END DESC;
                END IF;    
        else              
             IF (Psolandienbien IS NULL)
                  THEN
                      OPEN Cur FOR
                          SELECT   Td.Matheodoikhtn,
                                 e.Tennhanvien AS Tvbh,
                                 e.Manhanvien AS Manv,
                                 e.email,
                                 To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                                 upper(k.Tenkhtn) AS Tenkh,
                                 p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                                 k.Dienthoai,
                                 To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                                 Td.Xequantam,                     
                                 td.xequantamshow AS Tenxequantam,
                                 Httt.Tendm AS Httt,
                                 Td.Kenhtxs AS Kenhtx,
                                 Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                  
                                 to_char(td.tinhtrangkhs) as Tinhtrangkh,                   
                                 td.tinhtrangkhshow as Tentinhtrangkh,
                                 Td.Dienbientheodoi,
                                 Td.Tgmuadukien,
                                 Td.Thongtinkhac,
                                 Td.Makhtn,                     
                                 Td.Dienbientheodoi AS Dienbien_Short,
                                 Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                                 To_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                                 To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                                 k.ngaysua, td.ngaytiepcuoi
                                 , (mx.tenmau || ' - ' || mx.codemau) as tenmau,td.Thung,td.GhiChu_Thung
                                 ,(case td.MaOption when '0' then '' else td.MaOption end ) as MaOption
                                 ,decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                          FROM Theodoikhtn Td
                          LEFT JOIN Nguoidung e
                          ON e.Manhanvien = Td.Tuvanbh
                          left JOIN Khtn k
                          ON k.Makhtn = Td.Makhtn
                          LEFT OUTER JOIN City c
                          ON c.Id = k.Tinhthanh
                          LEFT OUTER JOIN Province p
                          ON p.Id = k.Quanhuyen
                          LEFT OUTER JOIN Dmchung Httt
                          ON Httt.Madm = Td.Httt
                          LEFT JOIN Khachhang K1
                          ON K1.Makhtn = Td.Makhtn
                          left join mauxe mx on td.mamau = mx.mamau
                          WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)  AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)
                          AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                                Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                                ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN                      
                                Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL
                                ))                   
                          and 
                          ( 
                               td.tgdukienmuatungay between Ptungay_dukien and Pdenngay_dukien or
                               td.tgdukienmuadenngay between Ptungay_dukien and Pdenngay_dukien or 
                               Ptungay_dukien is null or Pdenngay_dukien is null
                          )      
                          /*AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                                '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)*/                     
                          AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                                REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                          AND (Td.Tuvanbh IN (SELECT *
                                             FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)
                          --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))                      
                          
                          AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                          AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                          AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                          AND (Pxequantam IN
                                (SELECT *
                                 FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                                Pxequantam IS NULL or td.xequantam is null)
                          and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)  
                          and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)              
                          AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')                          
                          ORDER BY 
                          CASE
                               WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                               WHEN Pfromngaytxcuoi IS NOT NULL THEN td.ngaytiepcuoi                         
                               WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                          END DESC;
                  
                  ELSE
                      OPEN Cur FOR
                          SELECT  Td.Matheodoikhtn,
                                 e.Tennhanvien AS Tvbh,
                                 e.Manhanvien AS Manv,
                                 e.email,
                                 To_Char(Td.Ngaytiepxuc, 'dd/MM/yyyy') AS Ngaytiepxuc,
                                 upper(k.Tenkhtn) AS Tenkh,
                                 p.Vn_Name || '-' || c.Vn_Name AS Diachi,
                                 k.Dienthoai,
                                 To_Char(k.Ngaytao, 'dd/mm/yyyy') AS Ngaytao,
                                 Td.Xequantam,                  
                                 td.xequantamshow AS Tenxequantam,
                                 Httt.Tendm AS Httt,
                                 Td.Kenhtxs AS Kenhtx,
                                 Substr(Pkg_Khtn_Tran.Tendmchung(Td.Kenhtxs), 2) AS Tenkenhtx,                    
                                 to_char(td.tinhtrangkhs) as Tinhtrangkh,             
                                 td.tinhtrangkhshow AS Tentinhtrangkh,
                                 Td.Dienbientheodoi,
                                 Td.Tgmuadukien,
                                 Td.Thongtinkhac,
                                 Td.Makhtn,                
                                 Td.Dienbientheodoi AS Dienbien_Short,
                                 Nvl(K1.Makhtn, 0) AS Makhtnchuyen,                       
                                 to_Char(td.ngaytiepcuoi,'dd/MM/yyyy') AS Ngaytiepxuccuoi,
                                 To_Char(k.Ngaytao, 'dd/MM/yyyy HH24:MI') AS Ngaytaoshow,
                                 k.ngaysua, td.ngaytiepcuoi
                                 , (mx.tenmau || ' - ' || mx.codemau) as tenmau ,td.Thung,td.GhiChu_Thung
                                 ,(case td.MaOption when '0' then '' else td.MaOption end ) as MaOption
                                 ,decode(k.LoaiKH,0,'Cá nhân',1,'Doanh nghi?p','') LoaiKH_Text
                          FROM Theodoikhtn Td
                          INNER JOIN Nguoidung e
                          ON e.Manhanvien = Td.Tuvanbh
                          INNER JOIN Khtn k
                          ON k.Makhtn = Td.Makhtn
                          LEFT OUTER JOIN City c
                          ON c.Id = k.Tinhthanh
                          LEFT OUTER JOIN Province p
                          ON p.Id = k.Quanhuyen
                          LEFT OUTER JOIN Dmchung Httt
                          ON Httt.Madm = Td.Httt
                          LEFT JOIN Khachhang K1
                          ON K1.Makhtn = Td.Makhtn
                          left join mauxe mx on td.mamau = mx.mamau
                          WHERE (Td.Madv = Pmadv OR Pmadv IS NULL)        AND (pLoaiKH=-1 or k.LoaiKH=pLoaiKH)         
                          AND (((To_Date(To_Char(Td.Ngaytiepxuc, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN Ptungay AND
                                Pdenngay) OR Pdenngay IS NULL) AND ((To_Date(To_Char(k.Ngaytao, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytao AND Ptongaytao) OR Ptongaytao IS NULL) AND                      
                                ((To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy') BETWEEN
                                Pfromngaytxcuoi AND Ptongaytxcuoi) OR Ptongaytxcuoi IS NULL
                                ))
                          /*AND (Decode(Upper(Td.Tgmuadukien), NULL, 'zero', Td.Tgmuadukien) LIKE
                                '%' || Upper(Ptgdukienmua) || '%' OR Ptgdukienmua IS NULL)*/                     
                          and 
                          ( 
                               td.tgdukienmuatungay between Ptungay_dukien and Pdenngay_dukien or
                               td.tgdukienmuadenngay between Ptungay_dukien and Pdenngay_dukien or 
                               Ptungay_dukien is null or Pdenngay_dukien is null
                          )
                          AND (REPLACE(Translate(k.Dienthoai, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR
                                REPLACE(Translate(k.Dienthoai2, '.()-_', ' '), ' ', '') =
                                REPLACE(Translate(Psodienthoai, '.()-_', ' '), ' ', '') OR Psodienthoai IS NULL)
                          AND (Td.Tuvanbh IN (SELECT *
                                             FROM TABLE(Split_Clob(Dstuvan, ','))) OR Pnhomtv IS NULL)
                          --and (case when Pnhomtv is not null  then Td.Tuvanbh else null end )  IN (SELECT * FROM TABLE(Split_Clob(Dstuvan, ',')))     
                                            
                          AND (Td.Tuvanbh = Ptvbh OR Ptvbh IS NULL)
                          AND (k.Quanhuyen = Pquanhuyen OR Pquanhuyen IS NULL)
                          AND (k.Tinhthanh = Ptinhthanh OR Ptinhthanh IS NULL)
                          AND (Pxequantam IN
                                (SELECT *
                                 FROM TABLE(Split_Clob(Pkg_Khtn_Tran.Nhomxequantam(Td.Xequantam), ','))) OR
                                Pxequantam IS NULL or td.xequantam is null)                
                          and (Instr(Ptinhtrangkh, Td.Tinhtrangkhs) > 0 OR Ptinhtrangkh IS NULL)
                          and (instr(pKTX,Td.Kenhtxs) > 0 or pKTX = 0)
                          AND k.Makhtn IN (SELECT k.Makhtn
                                          FROM Theodoikhtn Td
                                          INNER JOIN Nguoidung e
                                          ON e.Manhanvien = Td.Tuvanbh
                                          INNER JOIN Khtn k
                                          ON k.Makhtn = Td.Makhtn
                                          LEFT OUTER JOIN City c
                                          ON c.Id = k.Tinhthanh
                                          LEFT OUTER JOIN Province p
                                          ON p.Id = k.Quanhuyen
                                          LEFT OUTER JOIN Dmchung Httt
                                          ON Httt.Madm = Td.Httt
                                          LEFT JOIN Dienbienkhtn d
                                          ON k.Makhtn = d.Makhtn
                                          WHERE (Td.Madv = Pmadv)
                                          GROUP BY k.Makhtn,
                                                   k.Tenkhtn
                                          HAVING COUNT(d.Makhtn) = Psolandienbien                                
                                          )
                          AND (Pkhachhang IS NULL OR Upper(k.Tenkhtn) LIKE u'%' || Upper(Pkhachhang) || '%')
                          
                          ORDER BY 
                           CASE
                               WHEN Ptungay IS NOT NULL THEN Td.Ngaytiepxuc
                               WHEN Pfromngaytxcuoi IS NOT NULL THEN To_Date(To_Char(td.ngaytiepcuoi, 'dd/MM/yyyy'), 'dd/mm/yyyy')
                               WHEN Pfromngaytao IS NOT NULL THEN k.Ngaytao
                           END DESC;
                
                 END IF;    
       end if;

END THEODOIKHTN_LOAD_FORM_NEW_1;


END;
