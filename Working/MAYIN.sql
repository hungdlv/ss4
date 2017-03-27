USE [THACO_JIRA]
GO
/****** Object:  Table [dbo].[BH_DMChung]    Script Date: 3/27/2017 1:40:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BH_DMChung](
	[id] [int] NOT NULL,
	[loaiID] [int] NULL,
	[maso] [varchar](50) NULL,
	[ten] [nvarchar](50) NULL,
	[ghichu] [nvarchar](50) NULL,
	[para1] [varchar](50) NULL,
	[para2] [varchar](50) NULL,
	[para3] [varchar](50) NULL,
	[para4] [varchar](50) NULL,
	[para5] [varchar](50) NULL,
	[parentid] [int] NULL,
 CONSTRAINT [PK_BH_DMChung] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BH_DongiaCV]    Script Date: 3/27/2017 1:40:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BH_DongiaCV](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[maso] [varchar](50) NULL,
	[tencv] [nvarchar](50) NULL,
	[dongia] [numeric](18, 2) NULL,
 CONSTRAINT [PK_BH_DongiaCV] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BH_Khachhang]    Script Date: 3/27/2017 1:40:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BH_Khachhang](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[makh] [varchar](50) NULL,
	[tenkh] [nvarchar](50) NULL,
 CONSTRAINT [PK_BH_Khachhang] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BH_NhanVien]    Script Date: 3/27/2017 1:40:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BH_NhanVien](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[msnv] [varchar](50) NULL,
	[mathe] [varchar](50) NULL,
	[hoten] [nvarchar](50) NULL,
	[bophanID] [int] NULL,
	[ghichu] [nvarchar](50) NULL,
 CONSTRAINT [PK_BH_NhanVien] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BH_NhapMay]    Script Date: 3/27/2017 1:40:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BH_NhapMay](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ngaynhap] [datetime] NULL,
	[nhanvienID] [int] NULL,
	[DongiaCVID] [int] NULL,
	[dongia] [numeric](18, 2) NULL,
	[khachhangID] [int] NULL,
	[quycachID] [int] NULL,
	[khochinh] [varchar](50) NULL,
	[soluong] [int] NULL,
	[tu] [varchar](50) NULL,
	[den] [varchar](50) NULL,
	[khochinhcalc] [varchar](50) NULL,
	[slchitiet] [numeric](18, 2) NULL,
	[tongmay] [numeric](18, 2) NULL,
	[tienmay] [numeric](18, 2) NULL,
	[may] [int] NULL,
	[koin] [int] NULL,
	[TongCVPhuMay] [numeric](18, 0) NULL,
	[TienPhuMay] [numeric](18, 0) NULL,
	[BB] [numeric](18, 0) NULL,
	[BQ] [numeric](18, 0) NULL,
	[MQ] [numeric](18, 0) NULL,
	[MND] [numeric](18, 0) NULL,
	[CB] [numeric](18, 0) NULL,
	[CK] [numeric](18, 0) NULL,
	[CX] [numeric](18, 0) NULL,
	[LB] [numeric](18, 0) NULL,
	[LBI] [numeric](18, 0) NULL,
	[PHE] [numeric](18, 0) NULL,
	[Gia] [numeric](18, 2) NULL,
	[Thanhtien] [numeric](18, 2) NULL,
 CONSTRAINT [PK_BH_NhapMay] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
