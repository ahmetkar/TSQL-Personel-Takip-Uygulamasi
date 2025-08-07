Create Database PersonelDb
GO
use PersonelDb
GO
--Personeller,Rütbeler,PersonelIsKayitlari,PersonelMesaiKayitlari,PersonelIzinler,PersonelMaaslar

Create Table Rutbeler (
Id int not null primary key identity(1,1),
RutbeAdi nvarchar(50)
)

Create Table Personeller (
Id int not null primary key identity(1,1),
Isim nvarchar(100) not null,
Soyisim nvarchar(100) not null,
Isegiristarihi datetime not null,
Istencikistarihi datetime,
RutbeId int DEFAULT 1 
)

Create Table PersonelMaaslar (
Id int not null primary key identity(1,1),
PersonelId int not null,
Maas money not null default 0
)

Create Table PersonelIsKayitlari (
Id int not null primary key identity(1,1),
PersonelId int not null,
GirisVeyaCikis bit not null,
Tarih datetime not null
)

Create Table PersonelMesaiKayitlari (
Id int not null primary key identity(1,1),
PersonelId int not null,
MesaiBaslangicTarihi datetime not null,
MesaiBitisTarihi datetime not null,
)

Create Table PersonelIzinler (
Id int not null primary key identity(1,1),
PersonelId int not null,
IzinBaslangicTarihi datetime not null,
IzinBitisTarihi datetime not null,
IzinNedeni nvarchar(300) not null,
)

Create Table PersonelMaasIslemBilgileri (
Id int not null primary key identity(1,1),
KesintiMi bit not null,
NeKadar money not null,
Neden nvarchar(50) not null
)


Alter Table Personeller
Add Constraint RutbeForeign FOREIGN KEY(RutbeId) REFERENCES Rutbeler(Id)
On Delete NO ACTION
On Update NO ACTION

Alter Table PersonelMaaslar
Add Constraint PersonelMaasForeign FOREIGN KEY(PersonelId) REFERENCES Personeller(Id)
On Delete Cascade
On Update Cascade

Alter Table PersonelIsKayitlari
Add Constraint PersonelIsKayitForeign FOREIGN KEY(PersonelId) REFERENCES Personeller(Id)
On Delete Cascade
On Update Cascade

Alter Table PersonelMesaiKayitlari
Add Constraint PersonelMesaiForeign FOREIGN KEY(PersonelId) REFERENCES Personeller(Id)
On Delete Cascade
On Update Cascade

Alter Table PersonelIzinler
Add Constraint PersonelIzinForeign FOREIGN KEY(PersonelId) REFERENCES Personeller(Id)
On Delete Cascade
On Update Cascade

GO

insert into Rutbeler(RutbeAdi) values ('Yonetici')
insert into Rutbeler(RutbeAdi) values ('Isci')
insert into Rutbeler(RutbeAdi) values ('Takim Lideri')
insert into Rutbeler(RutbeAdi) values ('Yardimci Yonetici')

GO
insert into PersonelMaasIslemBilgileri(KesintiMi,NeKadar,Neden) values (0,300,'NormalMesaiSaati')
insert into PersonelMaasIslemBilgileri(KesintiMi,NeKadar,Neden) values (0,100,'EkstraMesaiSaati')
insert into PersonelMaasIslemBilgileri(KesintiMi,NeKadar,Neden) values (1,20,'Izin')

Select * from PersonelMaasIslemBilgileri
GO


Create proc PersonelEkle(
@Isim nvarchar(MAX),
@Soyisim nvarchar(MAX),
@Rutbe nvarchar(50),
@Maas money
)
as
declare @bugun datetime = GETDATE()
declare @RutbeId int = 0
declare @SonEklenenId int = 0
If Exists(Select RutbeAdi from Rutbeler where RutbeAdi = @Rutbe)
begin
	Select @RutbeId = Id from Rutbeler where RutbeAdi = @Rutbe
	insert into Personeller(Isim,Soyisim,Isegiristarihi,Istencikistarihi,RutbeId) values (@Isim,@Soyisim,@bugun,NULL,@RutbeId)
	set @SonEklenenId = IDENT_CURRENT('Personeller')
	insert into PersonelMaaslar(PersonelId,Maas) values(@SonEklenenId,@Maas)
end

go

Create proc PersonelGirisKaydiEkle (
@PersonelId int
)
as
declare @bugun datetime = GETDATE()
insert into PersonelIsKayitlari(PersonelId,GirisVeyaCikis,Tarih) values (@PersonelId,0,@bugun)

GO

Create proc PersonelCikisKaydiEkle (
@PersonelId int,
@cikistarihi datetime = NULL
)
as
declare @bugun datetime = GETDATE()
IF @cikistarihi IS NOT NULL
begin
	insert into PersonelIsKayitlari(PersonelId,GirisVeyaCikis,Tarih) values (@PersonelId,1,@cikistarihi)
end
else 
begin
	insert into PersonelIsKayitlari(PersonelId,GirisVeyaCikis,Tarih) values (@PersonelId,1,@bugun)
end

GO

Create proc PersonelMesaiEkle(
@PersonelId int,
@baslangic datetime,
@bitis datetime
)
as
insert into PersonelMesaiKayitlari(PersonelId,MesaiBaslangicTarihi,MesaiBitisTarihi) values (@PersonelId,@baslangic,@bitis)


go


Create proc PersonelIzinEkle(
@PersonelId int,
@baslangic datetime,
@bitis datetime,
@neden nvarchar(MAX)
)
as
insert into PersonelIzinler(PersonelId,IzinBaslangicTarihi,IzinBitisTarihi,IzinNedeni) values (@PersonelId,@baslangic,@bitis,@neden)

go

Create function BuguneEkle(@Saat int,@Dakika int,@Gun int) returns datetime
as
begin
	declare @bugun datetime = GETDATE()
	if(@Gun != 0)
	begin
	set @bugun = DATEADD(DAY,@Gun,@bugun)
	end
	if(@Saat != 0)
	begin
	set @bugun = DATEADD(HOUR,@Saat,@bugun)
	end
	if(@Dakika != 0)
	begin
	set @bugun = DATEADD(MINUTE,@Dakika,@bugun)
	end

	return @bugun
end

go

--datepart ile verilen a�a��daki fonk.lar
--tarihin haftan�n ka��nc� g�n�,y�l�n ka��nc� ay�,ay�n ka��nc� g�n� oldu�unu hesaplar
--Select DATEPART(DW,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE())

Create Function SaatiHesapla(@baslangic datetime,@bitis datetime) returns int
as
begin
	return DATEDIFF(HOUR,@baslangic,@bitis)
end


go

Create Trigger NormalMesaiUcretiEkle
on PersonelIsKayitlari
after insert
as
IF EXISTS (
	Select 1 from inserted i where i.GirisVeyaCikis = 1
)
begin
	declare @SonEklenenId int = IDENT_CURRENT('PersonelIsKayitlari')
	declare @baslangic datetime
	declare @bitis datetime
	declare @nekadar money
	declare @personelid int

	Select @personelid = PersonelId,@bitis = Tarih from inserted where Id = @SonEklenenId
	Select @baslangic = Tarih from PersonelIsKayitlari where PersonelId = @personelid and GirisVeyaCikis = 0

	Select @nekadar = NeKadar from PersonelMaasIslemBilgileri where Neden = 'NormalMesaiSaati'
	
	declare @kacsaat int = dbo.SaatiHesapla(@baslangic,@bitis)

	declare @toplamzam int = @kacsaat*@nekadar

	print CAST(@personelid as nvarchar(MAX))+' idli kullanici'+CAST(@toplamzam as nvarchar(MAX))+' kadar normal mesai ücreti kazandi. '

	Update PersonelMaaslar SET Maas = Maas+@toplamzam where PersonelId = @personelid
end
go


Create Trigger EkstraMesaiUcretiEkle
on PersonelMesaiKayitlari
after insert
as
declare @SonEklenenId int = IDENT_CURRENT('PersonelMesaiKayitlari')
declare @baslangic datetime
declare @bitis datetime
declare @nekadar money
declare @personelid int

Select @personelid = PersonelId,@baslangic = MesaiBaslangicTarihi,@bitis = MesaiBitisTarihi from PersonelMesaiKayitlari where Id = @SonEklenenId
Select @nekadar = NeKadar from PersonelMaasIslemBilgileri where Neden = 'EkstraMesaiSaati'
declare @kacsaat int = dbo.SaatiHesapla(@baslangic,@bitis)

declare @toplamzam int = @kacsaat*@nekadar

print CAST(@personelid as nvarchar(MAX))+' idli kullanici'+CAST(@toplamzam as nvarchar(MAX))+' kadar mesai zammi kazandi. '

Update PersonelMaaslar SET Maas = Maas+@toplamzam where PersonelId = @personelid

go


Create Trigger IzinKesintisiYap
on PersonelIzinler
after insert
as
declare @SonEklenenId int = IDENT_CURRENT('PersonelIzinler')
declare @baslangic datetime
declare @bitis datetime
declare @nekadar money
declare @personelid int

Select @personelid = PersonelId,@baslangic = IzinBaslangicTarihi,@bitis = IzinBitisTarihi from PersonelIzinler where Id = @SonEklenenId
Select @nekadar = NeKadar from PersonelMaasIslemBilgileri where Neden = 'Izin'
declare @kacsaat int = dbo.SaatiHesapla(@baslangic,@bitis)

declare @toplamkesinti int = @kacsaat*@nekadar

print CAST(@personelid as nvarchar(MAX))+' idli kullanici'+CAST(@toplamkesinti as nvarchar(MAX))+' kadar izin kesintisi aldı. '

Update PersonelMaaslar SET Maas = Maas-@toplamkesinti where PersonelId = @personelid

go


exec PersonelEkle 'Ahmet','Kar','Yonetici',180.000
exec PersonelEkle 'Mehmet','Oz','Isci',40.000
exec PersonelEkle 'Hatice','Haktangelen','Yardimci Yonetici',90.000
exec PersonelEkle 'Busenur','Demir','Takim Lideri',70.000

Select * from Personeller

Select * from PersonelMaaslar

GO

Create View PersonellerveMaaslari
as
Select p.Id,p.Isim,p.Soyisim,p.Isegiristarihi,p.Istencikistarihi,m.Maas from Personeller p inner join PersonelMaaslar m on p.Id = m.PersonelId
GO

Create View PersonellerveRutbeleri
as
Select p.Id,p.Isim,p.Soyisim,p.Isegiristarihi,p.Istencikistarihi,r.RutbeAdi from Personeller p inner join Rutbeler r on p.RutbeId = r.Id
go


Create View PersonellerveIsKayitlari
as
Select p.Id,p.Isim,p.Soyisim,pik.GirisVeyaCikis,pik.Tarih as 'IslemTarihi' from Personeller p inner join PersonelIsKayitlari pik on p.Id = pik.PersonelId
go

Create View PersonellerveEkstraMesaileri
as
Select p.Id,p.Isim,p.Soyisim,dbo.SaatiHesapla(pm.MesaiBaslangicTarihi,pm.MesaiBitisTarihi) as 'ToplamMesaiSaati',pm.MesaiBaslangicTarihi,
pm.MesaiBitisTarihi
from Personeller p inner join PersonelMesaiKayitlari pm on p.Id = pm.PersonelId
go

Create View PersonellerveIzinleri
as
Select p.Id,p.Isim,p.Soyisim,dbo.SaatiHesapla(piz.IzinBaslangicTarihi,piz.IzinBitisTarihi)  as 'ToplamIzinSaati'
,piz.IzinBaslangicTarihi,piz.IzinBitisTarihi,piz.IzinNedeni from Personeller p inner join PersonelIzinler piz on p.Id = piz.PersonelId
go

Create View PersonelTumBilgiler
as
Select p.Id,p.Isim,p.Soyisim,p.Isegiristarihi,p.Istencikistarihi,
r.RutbeAdi,pm.Maas
from Personeller p join Rutbeler r on p.Id = r.Id join PersonelMaaslar pm on pm.Id = p.Id
go


Select * from PersonellerveMaaslari

Select * from PersonellerveRutbeleri

Select * from PersonellerveIsKayitlari

Select * from PersonellerveEkstraMesaileri

Select * from PersonellerveIzinleri

Select * from PersonelTumBilgiler

go


exec PersonelGirisKaydiEkle 1
exec PersonelGirisKaydiEkle 2
exec PersonelGirisKaydiEkle 3
exec PersonelGirisKaydiEkle 4

go

declare @bitis datetime = dbo.BuguneEkle(2,0,0)

exec PersonelCikisKaydiEkle 1,@bitis
exec PersonelCikisKaydiEkle 2,@bitis
exec PersonelCikisKaydiEkle 3,@bitis
exec PersonelCikisKaydiEkle 4,@bitis


Select * from PersonelIsKayitlari
Select * from PersonelMaaslar

go

declare @bugun datetime = GETDATE()
declare @bitis datetime = dbo.BuguneEkle(2,0,0)

exec PersonelMesaiEkle 1,@bugun,@bitis
go
Select * from PersonelMesaiKayitlari
Select * from PersonelMaaslar

declare @bugun datetime = GETDATE()
declare @bitis datetime = dbo.BuguneEkle(1,65,1)

exec PersonelIzinEkle 1,@bugun,@bitis,'Tatil'

Select * from PersonelIzinler
Select * from PersonelMaaslar



