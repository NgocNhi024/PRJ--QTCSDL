												--THAY ĐỔI THIẾT KẾ BẢNG
USE master;  
GO  

IF DB_ID (N'STOREDKT') is not null
DROP DATABASE STOREDKT;  
GO  

CREATE DATABASE STOREDKT
GO

USE STOREDKT
GO

-- Tạo bảng KHÁCH HÀNG
CREATE TABLE CUSTOMER
(
	Cust_ID CHAR (10) PRIMARY KEY not null,
	Cust_name NVARCHAR(100) not null,
	Cust_Ad NVARCHAR(100) not null
)
go
-- Tạo bảng NHÀ CUNG CẤP
CREATE TABLE NHACUNGCAP
(
	NCC_ID CHAR(10) not null PRIMARY KEY,
	NCC_Name NVARCHAR(100) not null,
	NCC_Ad NVARCHAR(100) not null,
	NCC_Phone CHAR(11) not null UNIQUE,
	NCC_Fax CHAR(11) UNIQUE,
	NCC_Web NVARCHAR(100) unique,
	NCC_Email VARCHAR(50) not null UNIQUE
)
go
-- Tạo bảng HÀNG HÓA
CREATE TABLE HANGHOA 
(
    HH_ID CHAR(8) PRIMARY KEY not null,           
    HH_Name NVARCHAR(50) not null,      
    DVT NVARCHAR(10) not null,
	GiaBanMacDinh DECIMAL(10,2) not null
)
go
-- Tạo bảng HÓA ĐƠN BÁN
CREATE TABLE HOADONBAN 
(
    HDB_ID CHAR(10) PRIMARY KEY NOT NULL,
    Cust_ID CHAR(10),
    HDB_Time DATE NOT NULL,               
    HDB_TT NVARCHAR(20) NOT NULL,             
    HDB_Thue TINYINT NOT NULL,
    Cust_AcNo VARCHAR(14),
	Cust_DDName NVARCHAR(50),
    FOREIGN KEY (Cust_ID) REFERENCES CUSTOMER(Cust_ID) ON DELETE CASCADE ON UPDATE CASCADE,
);
go
-- Tạo bảng CHI TIẾT HÓA ĐƠN BÁN
CREATE TABLE CHITIETHOADONBAN 
(
    HDB_ID CHAR(10),                          
    HH_ID CHAR(8),                            
    HDB_Soluong INT not null CHECK (HDB_Soluong >0),   
	DongiaBan DECIMAL(10,2) null CHECK (DongiaBan >0),
    PRIMARY KEY (HDB_ID, HH_ID),              
    FOREIGN KEY (HDB_ID) REFERENCES HOADONBAN(HDB_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (HH_ID) REFERENCES HANGHOA(HH_ID) ON DELETE CASCADE ON UPDATE CASCADE
)

-- Tạo bảng HÓA ĐƠN MUA
CREATE TABLE HOADONMUA 
(
	HDN_ID CHAR(10) PRIMARY KEY not null,
	HDN_Time DATE not null,
	HDN_TT NVARCHAR(20) not null,
	HDN_Thue TINYINT not null,
	NCC_AcNo VARCHAR(14), 
	NCC_Bname NVARCHAR(50), 
	NCC_BRName NVARCHAR(50),
	NCC_ID CHAR(10),
	FOREIGN KEY (NCC_ID) REFERENCES NHACUNGCAP(NCC_ID) ON DELETE CASCADE ON UPDATE CASCADE,
)

-- Tạo bảng CHI TIẾT HÓA ĐƠN MUA
CREATE TABLE CHITIETHOADONMUA 
(	
	HDN_ID CHAR(10),
	HH_ID CHAR(8),
	HDN_SoLuong INT not null CHECK (HDN_SoLuong >0) ,
	DongiaNhap DECIMAL(10,2) not null CHECK (DongiaNhap >0),
	PRIMARY KEY (HDN_ID, HH_ID),
	FOREIGN KEY (HDN_ID) REFERENCES HOADONMUA(HDN_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (HH_ID) REFERENCES HANGHOA(HH_ID) ON DELETE CASCADE ON UPDATE CASCADE
)
--------------------------------------------------------------------------------------------------------------------
														--DUMP DỮ LIỆU

--------------------------------------------------------------------------------------------------------------------

-- DUMP BẢNG NHÀ CUNG CẤP
go
create or alter procedure sp_insertIntoNhaCungCap
as
begin
	declare @NCC_ID CHAR(10),
			@NCC_Name NVARCHAR(100),
			@NCC_Ad NVARCHAR(100),
			@NCC_Phone CHAR(11),
			@NCC_Fax CHAR(11),
			@NCC_Web NVARCHAR(100), 
			@NCC_Email VARCHAR(50),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO NCC_ID
		SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		while exists (select 1 from NHACUNGCAP where NCC_ID = @NCC_ID)
		begin
			-- Nếu trùng thì tạo NCC_ID mới
			SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		end
		-- TẠO NCC_Name
		set @NCC_Name = N'NCC' + CAST(@Count AS NVARCHAR(10))
		-- TẠO NCC_AD
		set @NCC_Ad = N'Địa chỉ ' + CAST(@Count AS NVARCHAR(10))
		-- TẠO NCC_PHONE, NCC_FAX, NCC_EMAIL, NCC_WEB
		set @NCC_Phone = '0' + cast(cast(rand() * 9000000000 + 1000000000 as bigint) as nvarchar(10))
		set @NCC_Fax = '0' + cast(cast(rand() * 9000000000 + 1000000000 as bigint) as nvarchar(10))
		set @NCC_Email = @NCC_Name + '@gmail.com'
		set @NCC_Web = 'www.' + @NCC_Name + '.vn'
		while	exists (select 1 from NHACUNGCAP where	NCC_Phone = @NCC_Phone or NCC_Fax = @NCC_Fax 
														or NCC_Email = @NCC_Email or NCC_Web = @NCC_Web) 
				or @NCC_Fax = @NCC_Phone
		begin
			set @NCC_Phone = '0' + cast(cast(rand() * 9999999999 as bigint) as nvarchar(10))
			set @NCC_Fax = '0' + cast(cast(rand() * 9000000000 + 1000000000 as bigint) as nvarchar(10))
		end
		INSERT INTO NhaCungCap (NCC_ID, NCC_Name, NCC_Ad, NCC_Phone, NCC_Fax,NCC_Web, NCC_Email)
        VALUES (@NCC_ID, @NCC_Name, @NCC_Ad, @NCC_Phone, @NCC_Fax,@NCC_Web, @NCC_Email)
		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG HOADONMUA
go
create or alter procedure sp_insertIntoHoaDonMua
as
begin
	declare @HDN_ID CHAR(10),
			@HDN_Time DATE,
			@HDN_TT NVARCHAR(20),
			@HDN_Thue TINYINT,
			@NCC_AcNo VARCHAR(14), 
			@NCC_Bname NVARCHAR(50),
			@NCC_BRName NVARCHAR(50),
			@NCC_ID CHAR(10),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDN_ID
		set @HDN_ID = 'B' + RIGHT('000000000' + CAST(@count AS VARCHAR(9)), 9)
		-- TẠO HDN_TIME
		DECLARE @StartDate DATE = '2000-01-01'
		DECLARE @EndDate DATE = getdate()
		DECLARE @Days INT = DATEDIFF(DAY, @StartDate, @EndDate);
		SET @HDN_time = DATEADD(DAY, CAST(RAND() * @Days AS INT), @StartDate)
		-- TẠO HDN_TT
		SET @HDN_TT = CASE WHEN RAND() >= 0.5 THEN N'Tiền mặt' ELSE N'Chuyển khoản' END
		-- TẠO HDN_THUE
		SET @HDN_Thue = CASE WHEN RAND() >= 0.5 THEN 10 ELSE 8 END
		--TẠO NCC_ACNO
		if @HDN_TT = N'Tiền mặt'
		begin
			SET @NCC_AcNo = null
			set @NCC_Bname = null
			set @NCC_BRName = null
		end
		else 
		begin
			DECLARE @i int
			DECLARE @RandomNumber VARCHAR(14)
			set @RandomNumber = ''
			set @i = 1
			WHILE @i <= 14
			BEGIN
				SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
				SET @i = @i + 1
			END
			SET @NCC_AcNo = @RandomNumber

			while exists (select 1 from HOADONMUA where NCC_AcNo = @NCC_AcNo)
			begin
				set @RandomNumber = ''
				set @i = 1
				WHILE @i <= 14
				BEGIN
					SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
					SET @i = @i + 1
				END
				SET @NCC_AcNo = @RandomNumber
			end
			set @NCC_Bname = N'Ngân hàng' + cast(@count as varchar(1000))
			set @NCC_BRName = N'Chi nhánh' + cast(@count as varchar(1000))
		end;
		-- NCC_ID
		with CTE_NCC as (select	NCC_ID, ROW_NUMBER() OVER (ORDER BY NCC_ID) AS RowNum from NHACUNGCAP)

		select @NCC_ID = NCC_ID from CTE_NCC where RowNum = @count

		INSERT INTO HOADONMUA (HDN_ID, HDN_Time, HDN_TT, HDN_Thue, NCC_AcNo, NCC_Bname, NCC_BRName, NCC_ID)
        VALUES (@HDN_ID, @HDN_Time, @HDN_TT, @HDN_Thue, @NCC_AcNo, @NCC_Bname, @NCC_BRName, @NCC_ID)
        
		SET @Count = @Count + 1

	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG HANGHOA

go
create or alter procedure sp_insertIntoHangHoa
as
begin
	declare @HH_ID CHAR(8),    
			@HH_Name NVARCHAR(50), 
			@DVT NVARCHAR(10),
			@GiaBanMacDinh DECIMAL(10,2),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HH_ID
		set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
		-- TẠO HH_NAME
		set @HH_Name = N'Hàng hóa ' + CAST(@Count AS NVARCHAR(10))
		-- TẠO DVT
		SET @DVT = CASE WHEN RAND() > 0.5 THEN N'cái' ELSE N'bộ' END
		-- TẠO GIABANMACDINH
		set @GiaBanMacDinh = CAST((RAND() * 1000000) + 200000 AS DECIMAL(10,2))
		INSERT INTO HANGHOA (HH_ID, HH_Name, DVT, GiaBanMacDinh)
        VALUES (@HH_ID, @HH_Name, @DVT, @GiaBanMacDinh)

		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG CHITIETHOADONMUA
go
create or alter procedure sp_insertIntoChiTietHoaDonMua
as
begin
	declare @HDN_ID CHAR(10),
			@HH_ID CHAR(8),
			@HDN_SoLuong INT,
			@DongiaNhap DECIMAL(10,2),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDN_ID
		set @HDN_ID = 'B' + RIGHT('000000000' + CAST(@count AS VARCHAR(9)), 9)
		-- TẠO HH_ID
		set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
		-- TẠO HDN_SOLUONG
		set @HDN_SoLuong = FLOOR(RAND() * 50) + 1
		-- TAO DONGIANHAP
		select @DongiaNhap = GiaBanMacDinh/1.1 from HANGHOA
		where HH_ID = @HH_ID

		INSERT INTO CHITIETHOADONMUA (HDN_ID, HH_ID, HDN_SoLuong, DongiaNhap)
        VALUES (@HDN_ID, @HH_ID, @HDN_Soluong, @DongiaNhap)
		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

-- DUMP BẢNG CUSTOMER

go
create or alter procedure sp_insertIntoCustomer
as
begin
	declare @Cust_ID CHAR (10),
			@Cust_name NVARCHAR(100),
			@Cust_Ad NVARCHAR(100),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		--TẠO CUST_ID
		SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		while exists (select 1 from CUSTOMER where Cust_ID = @Cust_ID)
		begin
			-- Nếu trùng thì tạo CUST_ID mới
			SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
		end
		-- TẠO CUST_NAME
		SET @Cust_name = N'KH' + CAST(@Count AS NVARCHAR(10))
		-- TẠO CUST_AD
		SET @Cust_Ad = N'Địa chỉ ' + CAST(@Count AS NVARCHAR(10))
		INSERT INTO Customer (Cust_ID, Cust_Name, Cust_Ad)
        VALUES (@Cust_ID, @Cust_Name, @Cust_Ad)
		set @count = @count + 1
	end
end

-----------------------------------------------------------------------------------

-- DUMP BẢNG HOADONBAN
go
create or alter procedure sp_insertIntoHoaDonBan
as
begin
	declare @HDB_ID CHAR(10),
			@Cust_ID CHAR(10),
			@HDB_Time DATE,               
			@HDB_TT NVARCHAR(20),             
			@HDB_Thue TINYINT,
			@Cust_AcNo VARCHAR(14),
			@Cust_DDName NVARCHAR(50),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDB_ID
		SET @HDB_ID = 'S' + RIGHT('000000000' + CAST(@Count AS VARCHAR(9)), 9);
		-- TẠO CUST_ID
	
		with CTE_Cust as
		(
			select Cust_ID, ROW_NUMBER() over (order by Cust_ID) as rownum from CUSTOMER
		)
		select @Cust_ID = Cust_ID from CTE_Cust
		where rownum = @count
		-- TẠO HDB_TIME
		DECLARE @StartDate DATE = '2000-01-01'
		DECLARE @EndDate DATE = getdate()
		DECLARE @Days INT = DATEDIFF(DAY, @StartDate, @EndDate)
		SET @HDB_Time= DATEADD(DAY, CAST(RAND() * @Days AS INT), @StartDate);
		-- TẠO HDB_TT
		SET @HDB_TT = CASE WHEN RAND() > 0.5 THEN N'Tiền mặt' ELSE N'Chuyển khoản' END
		-- TẠO HDB_THUE
		SET @HDB_Thue = CASE WHEN RAND() >= 0.5 THEN 10 ELSE 8 END
		-- TẠO CUST_DDNAME (ĐẠI DIỆN CÔNG TY MUA HÀNG)
		SET @Cust_DDName = N'Đại diện' + CAST(@Count AS NVARCHAR(10))
		-- TẠO CUST_ACNO
		if @HDB_TT = N'Tiền mặt'
		begin
			SET @Cust_AcNo = null
		end
		else 
		begin
			DECLARE @i int
			DECLARE @RandomNumber VARCHAR(14)
			set @RandomNumber = ''
			set @i = 1
			WHILE @i <= 14
			BEGIN
				SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
				SET @i = @i + 1
			END
			SET @Cust_AcNo = @RandomNumber

			while exists (select 1 from HOADONMUA where NCC_AcNo = @Cust_AcNo)
			begin
				set @RandomNumber = ''
				set @i = 1
				WHILE @i <= 14
				BEGIN
					SET @RandomNumber = @RandomNumber + CAST(FLOOR(RAND() * 10) AS VARCHAR(1))
					SET @i = @i + 1
				END
				SET @Cust_AcNo = @RandomNumber
			end
		end
		INSERT INTO HOADONBAN (HDB_ID, Cust_ID, HDB_Time, HDB_TT, HDB_Thue, Cust_AcNo,Cust_DDName)
        VALUES (@HDB_ID, @Cust_ID, @HDB_Time, @HDB_TT, @HDB_Thue, @Cust_AcNo,@Cust_DDName)
		set @count = @count + 1
	end
end


-----------------------------------------------------------------------------------

--DUMP BẢNG CHITIETHOADONBAN


go
create or alter procedure sp_insertIntoChiTietHoaDonBan
as
begin
	declare @HDB_ID CHAR(10),                          
			@HH_ID CHAR(8),                            
			@HDB_Soluong INT,   
			@DongiaBan DECIMAL(10,2),
			@count int
	set @count = 1
	while @count <= 1000
	begin
		-- TẠO HDB_ID
		set @HDB_ID = 'S' + RIGHT('000000000' + CAST(@Count AS VARCHAR(9)), 9)
		-- TẠO HH_ID
		set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
		-- TẠO HDB_SOLUONG
		set @HDB_Soluong = FLOOR(RAND() * 50) + 1
		-- TẠO DONGIABAN
		select @DongiaBan = GiaBanMacDinh from HANGHOA
		where HH_ID = @HH_ID
		INSERT INTO CHITIETHOADONBAN (HDB_ID, HH_ID, HDB_Soluong, DonGiaBan)
        VALUES (@HDB_ID, @HH_ID, @HDB_Soluong, @DonGiaBan)
		set @count = @count + 1
	end
end

-------------------------------------------------------------------------------------------------------
go
create or alter proc sp_DumpSTORE
as
begin
	exec sp_insertIntoNhaCungCap
	exec sp_insertIntoHoaDonMua
	exec sp_insertIntoHangHoa
	exec sp_insertIntoChiTietHoaDonMua
	exec sp_insertIntoCustomer
	exec sp_insertIntoHoaDonBan
	exec sp_insertIntoChiTietHoaDonBan
end
go
exec sp_DumpSTORE
------------------------------------------------------------------------------------------------------------
select * from NHACUNGCAP
select * from HOADONMUA
select * from CHITIETHOADONMUA
select * from HANGHOA

select * from CUSTOMER
select * from HOADONBAN
select * from CHITIETHOADONBAN
-------------------------------------------------------------------------------------------------------------------
															--MODULES:
--1.THỦ TỤC THÊM NHÀ CUNG CẤP MỚI VÀO BẢNG NHÀ CUNG CẤP
go
create or alter procedure sp_XuLyNhaCungCap
	@NCC_ID char(10),
	@NCC_Name NVARCHAR(100),
	@NCC_Ad NVARCHAR(100),
	@NCC_Phone CHAR(11),
	@NCC_Fax CHAR(11),
	@NCC_Web NVARCHAR(100),
	@NCC_Email VARCHAR(50),
	@ID char(10) output
as
begin
	declare @count int
	begin try 
		if @NCC_ID = ''	
		begin
			select @count = count(*) + 1 from NHACUNGCAP
			SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			while exists (select 1 from NHACUNGCAP where NCC_ID = @NCC_ID)
			begin
				-- Nếu trùng thì tạo NCC_ID mới
				SET @NCC_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			end
			insert into NHACUNGCAP
			(NCC_ID, NCC_Name, NCC_Ad, NCC_Phone, NCC_Fax, NCC_Web, NCC_Email)
			values
			(@NCC_ID, @NCC_Name, @NCC_Ad, @NCC_Phone, @NCC_Fax, @NCC_Web, @NCC_Email)
			set @ID = @NCC_ID 
		end
		else 
		begin
			set @ID = @NCC_ID 
		end
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu nhà cung cấp: ' + ERROR_MESSAGE()
	end catch
end
------------------------------------------------------------
--2.	THỦ TỤC THÊM THÔNG TIN HÓA ĐƠN MỚI KHI MUA HÀNG VÀO BẢNG HOADONMUA
go
create or alter procedure sp_XuLyHoaDonMua
	@HDN_TT NVARCHAR(20),
	@HDN_Thue TINYINT,
	@NCC_AcNo VARCHAR(14), 
	@NCC_Bname NVARCHAR(50),
	@NCC_BRName NVARCHAR(50),
	@NCC_ID CHAR(10),
	@ID char(10) output
as
begin
	declare @HDN_ID CHAR(10) 
	declare @count int
	declare @HDN_Time DATE
	begin try	
		select @count = count(*) + 1 from HOADONMUA
		set @HDN_ID = 'B' + right('000000000' + cast(@count as varchar(100)),9)
		set @HDN_Time = GETDATE()
		INSERT INTO HOADONMUA (HDN_ID, HDN_Time, HDN_TT, HDN_Thue, NCC_AcNo, NCC_Bname, NCC_BRName, NCC_ID)
        VALUES (@HDN_ID, @HDN_Time, @HDN_TT, @HDN_Thue, @NCC_AcNo, @NCC_Bname, @NCC_BRName, @NCC_ID); 
		set @ID = @HDN_ID 
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu hóa đơn mua: ' + ERROR_MESSAGE()
	end catch
end
------------------------------------------------------------
--3.	THỦ TỤC THỰC HIỆN THÊM HÀNG HÓA VÀO BẢNG HANGHOA
go
create or alter procedure sp_XuLyThemHangHoa
	--HANGHOA
	@HH_ID CHAR(8),           
    @HH_Name NVARCHAR(50),      
    @DVT NVARCHAR(10),
	--CHITIETHOADONMUA
	@HDN_ID CHAR(10),
	@HDN_SoLuong INT,
	@DongiaNhap DECIMAL(10,2),
	@check bit 
as
begin
	begin try
		declare @count int
		declare	@GiaBanMacDinh DECIMAL(10,2)
		if @check = 1
		begin
			select @count = count(*) + 1 from HANGHOA
			set @HH_ID = 'HH' + RIGHT('000000' + CAST(@Count AS VARCHAR(6)), 6)
			set @GiaBanMacDinh = @DongiaNhap * 1.1
			INSERT INTO HANGHOA (HH_ID, HH_Name, DVT, GiaBanMacDinh)
			VALUES (@HH_ID, @HH_Name, @DVT, @GiaBanMacDinh)

			INSERT INTO CHITIETHOADONMUA (HDN_ID, HH_ID, HDN_SoLuong, DongiaNhap)
			VALUES (@HDN_ID, @HH_ID, @HDN_Soluong, @DongiaNhap)
		end
		else 
		begin
			INSERT INTO CHITIETHOADONMUA (HDN_ID, HH_ID, HDN_SoLuong, DongiaNhap)
			VALUES (@HDN_ID, @HH_ID, @HDN_Soluong, @DongiaNhap)
		end
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu: ' + ERROR_MESSAGE()
	end catch
end

------------------------------------------------------------------------
--4.	TRIGGER TỰ ĐỘNG CẬP NHẬT GIÁ MỚI CHO HÀNG HÓA MỚI NHẬP
go
create or alter trigger XuLyCapNhatGiaBanMacDinh
on CHITIETHOADONMUA
after insert, update
as
begin
	declare @giamoi decimal(10,2)
    declare @id char(10)
	select @giamoi = DongiaNhap, @id = HH_ID from CHITIETHOADONMUA
	where HDN_ID in (select HDN_ID inserted)

	update HANGHOA
	set GiaBanMacDinh = @giamoi * 1.1
	where HH_ID = @id
end
go
-----------------------------------------------------------------------
--KIỂM TRA:
declare @ID char(10)

exec sp_XuLyNhaCungCap
	@NCC_ID = '',
	@NCC_Name = N'NCCdemo1',
	@NCC_Ad = N'Địa chỉ demo1',
	@NCC_Phone = '06018265109',
	@NCC_Fax = '06018265999',
	@NCC_Web = 'www.NCCdemo1.vn',
	@NCC_Email = 'NCCdemo1@gmail.com',
	@ID = @ID output
print(@ID)

declare @IDabc char(10)
exec sp_XuLyHoaDonMua
	@HDN_TT = 'Tiền mặt',
	@HDN_Thue = '8',
	@NCC_AcNo = null,
	@NCC_Bname = null,
	@NCC_BRName = null,
	@NCC_ID = @ID,
	@ID = @IDabc output
print(@IDabc)



exec sp_XuLyThemHangHoa
	@HH_ID = 'HH000001', 
    @HH_Name = N'Hàng hóa 1',
    @DVT = 'bộ',
	@HDN_ID = @IDabc,
	@HDN_SoLuong = 10,
	@DongiaNhap = 50000,
	@check = 0
select * from HOADONMUA
select * from NHACUNGCAP
select * from HOADONMUA
select * from CHITIETHOADONMUA
select * from HANGHOA

-- 5.	THỦ TỤC THÊM KHÁCH HÀNG MỚI VÀO BẢNG CUSTOMER

go
create or alter procedure sp_XuLyCustomer
	@Cust_ID CHAR (10),
	@Cust_name NVARCHAR(100),
	@Cust_Ad NVARCHAR(100),
	@ID char(10) output
as
begin select * from CUSTOMER
	declare @count int
	begin try 
		if @Cust_ID = ''
		begin
			select @count = count(*) + 1 from CUSTOMER
			SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			while exists (select 1 from CUSTOMER where Cust_ID = @Cust_ID)
			begin
				-- Nếu trùng thì tạo CUST_ID mới
				SET @Cust_ID = RIGHT('0000000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 10)
			end
			INSERT INTO Customer (Cust_ID, Cust_Name, Cust_Ad)
			VALUES (@Cust_ID, @Cust_Name, @Cust_Ad)
			set @ID = @Cust_ID 
		end
		else 
		begin
			set @ID = @Cust_ID 
		end
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu khách hàng : ' + ERROR_MESSAGE()
	end catch
end
-- 6.	THỦ TỤC XỬ LÝ KHI BÁN HÀNG HÓA TRÊN BẢNG HOADONBAN & CHITIETHOADONBAN
go
create or alter procedure sp_XuLyHoaDonBan
    @Cust_ID CHAR(10),
    @HDB_TT NVARCHAR(20),             
    @HDB_Thue TINYINT,
    @Cust_AcNo VARCHAR(14),
	@ID char(10) output
as
begin
    declare @HDB_Time DATE,              
			@HDB_ID CHAR(10),
			@count int
	begin try	
		select * from HOADONBAN
		select @count = count(*) + 1 from HOADONMUA
		set @HDB_ID = 'S' + right('000000000' + cast(@count as varchar(100)),9) 
		set @HDB_Time = GETDATE()
		INSERT INTO HOADONBAN (HDB_ID, Cust_ID, HDB_Time, HDB_TT, HDB_Thue, Cust_AcNo)
        VALUES (@HDB_ID, @Cust_ID, @HDB_Time, @HDB_TT, @HDB_Thue, @Cust_AcNo)
		set @ID = @HDB_ID
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu hóa đơn bán: ' + ERROR_MESSAGE()
	end catch
end

go
create or alter procedure sp_XuLyBanHang
	@HDB_ID CHAR(10),                          
	@HH_ID CHAR(8),                            
	@HDB_Soluong INT
as
begin
	declare @count int, @DonGiaBan decimal(10,2)
	begin try
		select @DonGiaBan = GiaBanMacDinh from HANGHOA
		where HH_ID = @HH_ID
		INSERT INTO CHITIETHOADONBAN (HDB_ID, HH_ID, HDB_Soluong, DonGiaBan)
        VALUES (@HDB_ID, @HH_ID, @HDB_Soluong, @DonGiaBan)
	end try
	begin catch
		print N'Lỗi trong quá trình thêm dữ liệu vào bảng CHITIETHOADONBAN'
	end catch
end
--------------------------------------------------------------------------------------------
--KIỂM TRA:
declare @ID_test char(10)
exec sp_XuLyCustomer
	@Cust_ID = 'COM0000001',
	@Cust_name = N'KH1',
	@Cust_Ad = N'Địa chỉ 1',
	@ID = @ID_test output
print(@ID_test)
----------------------------------
declare @ID_testabc char(10)
exec sp_XuLyHoaDonBan
	@Cust_ID = @ID_test,
    @HDB_TT = N'Tiền mặt',             
    @HDB_Thue = '8',
    @Cust_AcNo = null,
	@ID = @ID_testabc output
print(@ID_testabc)
---------------------------
exec sp_XuLyBanHang
	@HDB_ID = @ID_testabc,                          
	@HH_ID = 'HH000001',                            
	@HDB_Soluong = 10

select * from CUSTOMER
select * from HOADONBAN
select * from CHITIETHOADONBAN
select * from HANGHOA

-- 7.	THỦ TỤC TÍNH TỔNG THU NHẬP TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH
GO
CREATE OR ALTER PROCEDURE sp_TongThuNhap 
(	
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,
    @TongThuNhap NUMERIC(15,4) OUT
)
AS
BEGIN
    DECLARE @Tong1 NUMERIC(15,4),
			@Tong2 NUMERIC(15,4),
			@count int
	set @TongThuNhap = 0
	SELECT @count = COUNT(*) FROM HOADONBAN
	WHERE HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc
	if @count >= 1
	begin 
		SELECT @Tong1 = SUM(HDB_Soluong * DongiaBan * (1 - 0.08))
		FROM HOADONBAN	JOIN CHITIETHOADONBAN ON HOADONBAN.HDB_ID = CHITIETHOADONBAN.HDB_ID
		WHERE HOADONBAN.HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc AND HDB_Thue = 8;
		
		SELECT @Tong2 = SUM(HDB_Soluong * DongiaBan * (1 - 0.10))
		FROM HOADONBAN	JOIN CHITIETHOADONBAN ON HOADONBAN.HDB_ID = CHITIETHOADONBAN.HDB_ID
		WHERE HOADONBAN.HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc AND HDB_Thue = 10
		
		SET @TongThuNhap = @Tong1 + @Tong2;
	end
END
go
DECLARE @TongThuNhap NUMERIC(15,4);
EXEC sp_TongThuNhap 
    @ThoiGianBatDau = '2023-01-01', 
    @ThoiGianKetThuc = '2023-12-31',
    @TongThuNhap = @TongThuNhap OUTPUT;
    
PRINT N'Tổng thu nhập: ' + CAST(@TongThuNhap AS NVARCHAR(20));
go
--------------------------------------------------------------------

-- 8.  THỦ TỤC TÍNH TỔNG CHI PHÍ NHẬP HÀNG TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH

GO
CREATE OR ALTER PROCEDURE sp_Tongchiphi 
(
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,
    @Tongchiphi NUMERIC(15,4) OUT
)
AS
BEGIN

    SET @Tongchiphi = 0;

    SELECT @Tongchiphi = SUM(HDN_Soluong * DongiaNhap * 
        CASE 
            WHEN HDN_Thue = 8 THEN (1 + 0.08)  
            WHEN HDN_Thue = 10 THEN (1 + 0.10) 
        END)
    FROM HOADONMUA	JOIN CHITIETHOADONMUA ON HOADONMUA.HDN_ID = CHITIETHOADONMUA.HDN_ID
					JOIN HANGHOA ON CHITIETHOADONMUA.HH_ID = HANGHOA.HH_ID
    WHERE HOADONMUA.HDN_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc
END
-------------------------------------------------------------------------------------------------
GO
DECLARE @TongChiPhi NUMERIC(15,4)
EXEC sp_Tongchiphi 
    @ThoiGianBatDau = '2023-01-01', 
    @ThoiGianKetThuc = '2023-12-31',
    @Tongchiphi = @TongChiPhi OUTPUT;

PRINT N'Tổng chi phí: ' + CAST(@TongChiPhi AS NVARCHAR(20))


----------------------------------------------------------------------------------------------
--9. THỦ TỤC TÍNH LỢI NHUẬN TRONG 1 KHOẢNG THỜI GIAN NHẤT ĐỊNH
GO
CREATE OR ALTER PROCEDURE sp_LoiNhuan
(
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,       
    @LoiNhuan NUMERIC(15,4) OUT, 
    @PhanTramLoiNhuan NUMERIC(5,2) OUT, 
    @KetLuan NVARCHAR(100) OUT   
)
AS
BEGIN

    DECLARE @TongThuNhap NUMERIC(15,4) = 0
    DECLARE @TongChiPhi NUMERIC(15,4) = 0

    exec sp_TongThuNhap
		@ThoiGianBatDau = @ThoiGianBatDau,
        @ThoiGianKetThuc = @ThoiGianKetThuc,
        @TongThuNhap = @TongThuNhap OUTPUT

    exec sp_Tongchiphi
		@ThoiGianBatDau = @ThoiGianBatDau,
        @ThoiGianKetThuc = @ThoiGianKetThuc,
        @Tongchiphi = @TongChiPhi OUTPUT

    SET @LoiNhuan = @TongThuNhap - @TongChiPhi

    IF @TongThuNhap > 0
    BEGIN
        SET @PhanTramLoiNhuan = (@LoiNhuan / @TongThuNhap) * 100
    END
    ELSE
    BEGIN
        SET @PhanTramLoiNhuan = 0
    END

    IF @LoiNhuan > 0
    BEGIN
        SET @KetLuan = N'Lời: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(10)) + N'%'
    END
    ELSE
    BEGIN
        SET @KetLuan = N'Lỗ: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(10)) + N'%'
    END
END
-------------------------
go
DECLARE @LoiNhuan NUMERIC(15,4)
DECLARE @PhanTramLoiNhuan NUMERIC(5,2)
DECLARE @KetLuan NVARCHAR(100);

EXEC sp_LoiNhuan 
    @ThoiGianBatDau = '2023-01-01', 
    @ThoiGianKetThuc = '2023-12-31',
    @LoiNhuan = @LoiNhuan OUTPUT,
    @PhanTramLoiNhuan = @PhanTramLoiNhuan OUTPUT,
    @KetLuan = @KetLuan OUTPUT;

-- In kết quả
PRINT N'Tổng lợi nhuận: ' + CAST(@LoiNhuan AS NVARCHAR(20));
PRINT N'Phần trăm lợi nhuận: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + '%'
PRINT N'Kết luận: ' + @KetLuan
-----------------------------------------------------------------------------------
-- 10. THỦ TỤC TÍNH LỢI NHUẬN CỦA 1 LOẠI HÀNG HÓA TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH
GO
CREATE OR ALTER PROCEDURE sp_LoiNhuan1LoaiSp
    @HH_ID CHAR(8),
    @ThoiGianBatDau DATE,        
    @ThoiGianKetThuc DATE,
    @LoiNhuan1Sp NUMERIC(15,4) OUTPUT,
    @Tongchiphi1sp NUMERIC(15,4) OUTPUT,
    @TongThuNhap1sp NUMERIC(15, 4) OUTPUT,
    @PhanTramLoiNhuan NUMERIC(5, 2) OUTPUT,
    @KetLuan NVARCHAR(100) OUTPUT
AS
BEGIN
    SET @TongThuNhap1sp = 0;

    -- Tính tổng thu nhập
    SELECT @TongThuNhap1sp = SUM(HDB_Soluong * DongiaBan * CASE 
                                                                WHEN HDB_Thue = 8 THEN (1 - 0.08)  
                                                                WHEN HDB_Thue = 10 THEN (1 - 0.1) 
                                                            END)
    FROM HOADONBAN
    JOIN CHITIETHOADONBAN ON HOADONBAN.HDB_ID = CHITIETHOADONBAN.HDB_ID
    JOIN HANGHOA ON CHITIETHOADONBAN.HH_ID = HANGHOA.HH_ID
    WHERE HOADONBAN.HDB_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc
          AND CHITIETHOADONBAN.HH_ID = @HH_ID
          AND HDB_Thue IN (8,10)

    -- Tính tổng chi phí
    SET @Tongchiphi1sp = 0;
    SELECT @Tongchiphi1sp = SUM(HDN_Soluong * DongiaNhap * 
                                CASE 
                                    WHEN HDN_Thue = 8 THEN (1 + 0.08)  
                                    WHEN HDN_Thue = 10 THEN (1 + 0.1) 
                                END)
    FROM HOADONMUA
    JOIN CHITIETHOADONMUA ON HOADONMUA.HDN_ID = CHITIETHOADONMUA.HDN_ID
    JOIN HANGHOA ON CHITIETHOADONMUA.HH_ID = HANGHOA.HH_ID
    WHERE CHITIETHOADONMUA.HH_ID = @HH_ID 
          AND HOADONMUA.HDN_Time BETWEEN @ThoiGianBatDau AND @ThoiGianKetThuc

    -- Tính lợi nhuận
    SET @LoiNhuan1Sp = @TongThuNhap1sp - @Tongchiphi1sp

    -- Tính phần trăm lợi nhuận
    IF @TongThuNhap1sp > 0
    BEGIN
        SET @PhanTramLoiNhuan = (@LoiNhuan1Sp / @TongThuNhap1sp) * 100
    END
    ELSE
    BEGIN
        SET @PhanTramLoiNhuan = 0
    END

    -- Đưa ra kết luận
    IF @LoiNhuan1Sp > 0
    BEGIN
        SET @KetLuan = N'Lời: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + N'%'
    END
    ELSE
    BEGIN
        SET @KetLuan = N'Lỗ: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + N'%'
    END
END

----CHECK

GO
DECLARE @LoiNhuan1Sp NUMERIC(15,4)
DECLARE @Tongchiphi1sp NUMERIC(15,4)
DECLARE @TongThuNhap1sp NUMERIC(15,4)
DECLARE @PhanTramLoiNhuan NUMERIC(5,2)
DECLARE @KetLuan NVARCHAR(100)


EXEC sp_LoiNhuan1LoaiSp 'HH000017', '2024-01-01', '2024-6-30', 
    @LoiNhuan1Sp OUTPUT, 
	@Tongchiphi1sp OUTPUT,
	@TongThuNhap1sp OUTPUT,
    @PhanTramLoiNhuan OUTPUT, 
    @KetLuan OUTPUT


-- In kết quả
PRINT N'Tổng lợi nhuận: ' + CAST(@LoiNhuan1Sp AS NVARCHAR(20))
PRINT N'Phần trăm lợi nhuận: ' + CAST(@PhanTramLoiNhuan AS NVARCHAR(20)) + '%'
PRINT N'Kết luận: ' + @KetLuan
select * from CHITIETHOADONBAN
select * from HOADONBAN

















