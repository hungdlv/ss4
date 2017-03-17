create or replace procedure usp_baocaotheodoidondathang
(
    pThang varchar,--10
    pNam varchar,--2016
    pDonvi varchar,--5725,5726
    Cur       OUT SYS_REFCURSOR
)
is
  v_sql VARCHAR2(32767)   := NULL;
  v_space nvarchar2(100):='''''';
begin
v_sql := 'WITH Result_Table AS (
    select maloaixe, tenloaixe, IDMAUXE, CODEMAU, TENMAU, (-1) * count(tendv) soluong, iddonvi from (
        select lx.maloaixe, lx.tenloaixe, a.IDMAUXE, mx.CODEMAU, mx.TENMAU, a.iddonvi, dv.tendv
        from ycgx_detail a
        right join donvi dv on dv.madv= a.iddonvi
        join (SELECT c.maloaixe, c.tenloaixe 
                  FROM NHOMLOAIXE a 
                  join DONGXE b on b.madongxe = a.madongxe 
                  join LOAIXE c on c.manhom = a.manhom) lx on lx.maloaixe=a.idloaixe 
        join MAUXE mx on mx.MAMAU=a.IDMAUXE 
        where a.iddonvi in ('|| pDonvi  ||') and a.namdh='|| pNam ||' and a.dhthang='|| pThang ||'
    )  a
    group by maloaixe, tenloaixe, IDMAUXE, CODEMAU, TENMAU, iddonvi
    
    union all
    
    select maloaixe, tenloaixe, IDMAUXE, CODEMAU, TENMAU, sum(soluong) soluong, iddonvi from (
    select lx.maloaixe, lx.tenloaixe, d.IDMAUXE, mx.CODEMAU, mx.TENMAU, m.iddonvi, dv.tendv, d.soluong
    from DonDatHangSR m
    join DonDatHangSR_ChiTiet d on d.DONDATHANGSRID=m.id
    right join donvi dv on dv.madv= m.iddonvi
    join (SELECT c.maloaixe, c.tenloaixe 
              FROM NHOMLOAIXE a 
              join DONGXE b on b.madongxe = a.madongxe 
              join LOAIXE c on c.manhom = a.manhom) lx on lx.maloaixe=d.idloaixe 
    join MAUXE mx on mx.MAMAU=d.IDMAUXE 
    where m.IDDONVI in ('|| pDonvi  ||') and extract(month from m.NGAYDUYETPC)='|| pThang ||' and EXTRACT(year FROM m.ngayduyetpc)='|| pNam ||'
  ) a
  group by maloaixe, tenloaixe, IDMAUXE, CODEMAU, TENMAU, iddonvi
)

SELECT * FROM Result_Table 
  PIVOT 
      ( 
        sum(soluong)
        FOR iddonvi 
        IN ('|| pDonvi  ||')  
      ) order by maloaixe, idmauxe';
      OPEN Cur FOR v_sql;    

end usp_baocaotheodoidondathang;