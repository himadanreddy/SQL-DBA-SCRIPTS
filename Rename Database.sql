USE master;  
GO  
ALTER DATABASE Advatar SET OFFLINE WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE Advatar SET ONLINE
GO
ALTER DATABASE Advatar  
Modify Name = Advatar_OLD ;  
GO

ALTER DATABASE Advatar_DISH SET OFFLINE WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE Advatar_DISH SET ONLINE
GO
ALTER DATABASE Advatar_DISH  
Modify Name = Advatar ;  
GO  
