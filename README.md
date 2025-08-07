# Uygulama Açıklaması

Bu proje tsql ile tamamen benim tarafımdan yazılmıştır.

Bu veritabanında personel ve onun bilgilerini içeren 8 tablo bulunur.

Rütbeler personel rütbe bilgilerini,Personeller tablosu personel bilgilerini,PersonelMaaslar Personellere ait maaşları,PersonelIsKayitlari personelin işe giriş çıkış tarihlerini 
PersonelIzinler personelin aldığı izinleri, PersonelMaasIslemBilgileri izin veya ek mesai durumunda personelin alacağı ekstra primlerin bilgilerini tutar,PersonelMesaiKayitlari 
personelin mesai bilgilerini tutar.

Personel ekleyen,giriş kaydı,çıkış kaydı ,mesai ,izin ekleyen prosedürler bulunur. 
Şuanki zamana gün,saat,dakika ekleyen ve  iki saat arası dakika farkını hesaplayan fonksiyonlar bulunur.

PersonelIsKayitlarina personelin günlük çıkış kaydı eklendiğinde tetiklenip normal mesai ücretini hesaplayan personel maaşlar tablosuna ekleyen trigger fonksiyonu
PersonelMesaiKayitlarina mesai kaydı girildiğinde tetiklenip mesai saati kadar ücreti personelmaaslar tablosuna ekleyen trigger fonksiyonu
PersonelIzinler tablosuna personel izin bilgisi eklendiğinde personelin izin saati kadar kesinti yapan ve maaş tablosunu güncelleyen trigger fonksiyonu bulunur

Personeller ve diğer tabloları join yapıları ile kombine edip çeşitli personel bilgilerini getiren Viewlerde bulunur.

