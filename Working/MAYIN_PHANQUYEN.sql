CREATE TABLE [dbo].[tblMenu](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TenMenu] [nvarchar](500) NOT NULL,
	[ThuTu] [int] NOT NULL,
	[ParentID] [bigint] NULL,
	[IsSeparator] [bit] NULL,
	[IsActive] [bit] NULL,
	[Controller] [nvarchar](500) NULL,
	[Action] [nvarchar](500) NULL,
	[Icon] [nvarchar](500) NULL,
	[Width] [int] NULL,
 CONSTRAINT [PK_tblMenu] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[tblNhomQuyenChiTiet](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[NhomQuyenID] [bigint] NOT NULL,
	[MenuID] [bigint] NOT NULL,
	[Them] [bit] NULL,
	[Xoa] [bit] NULL,
	[Sua] [bit] NULL,
	[Xem] [bit] NULL,
	[In] [bit] NULL,
	[Excel] [bit] NULL,
 CONSTRAINT [PK_tblNhomQuyenChiTiet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

--=============================================

[usp_categorieList] 'ubx_phanquyen', 0, '24372','0', '5298'
alter proc [dbo].[usp_categorieList]  
  @catname varchar(50)='',                  
  @paging bit=0,                  
  @para1 varchar(max)='',                  
  @para2 varchar(max)='',                  
  @para3 varchar(max)='',                  
  @para4 varchar(max)='',                  
  @para5 varchar(max)=''                  
as                  
begin  
	if @catname = 'ubx_phanquyen'  
 begin  
 --para1: nhanvienid  
 declare @tblResult1 table(id bigint, parent bigint, name nvarchar(500), xem bit, them bit, sua bit,xoa bit, [print] bit, excel bit)  
 insert into @tblResult1(id, parent, name, xem, them, sua, xoa, [print], excel) values(0, null, 'Root', 0,0,0,0,0,0)  
 ;WITH CATE_TREE AS  
 (  
  SELECT  id, parentid, tenmenu name FROM ubx_tblMenu where id=201  
  UNION ALL  
  SELECT ch.id, ch.parentid, ch.tenmenu FROM ubx_tblMenu ch INNER JOIN CATE_TREE tr ON ch.[parentid] = tr.id  
 )  
 insert into @tblResult1(id, parent, name, xem, them, sua, xoa, [print], excel)  
 select id, ParentID, name, 0,0,0,0,0,0 FROM CATE_TREE r  
  
 update a  
 set a.them = b.them, a.sua=b.sua, a.xoa=b.xoa, a.xem=b.xem, a.[print]=isnull(b.[in],0), a.excel=isnull(b.Excel,0)  
 from @tblResult1 a,  
 (select* from ubx_tblNhomQuyenChiTiet where nhomquyenid=cast(@para1 as int)  ) b  
 where a.id = b.MenuID  
  
 select* from @tblResult1  
 end  
end