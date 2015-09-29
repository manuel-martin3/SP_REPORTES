USE [bapEmpresa02]
GO
/****** Object:  StoredProcedure [dbo].[gspTb_RptMain_ReqProduccion]    Script Date: 15/09/2015 21:28:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC gspTb_RptMain_ReqProduccion
--DECLARE
 'OP'
,'140Q'
,'0000000001'
,'D2'
,'ALL'
  */


ALTER PROCEDURE [dbo].[gspTb_RptMain_ReqProduccion](
--	declare 
	 @tipop char(2)		=NULL--'OP'
	,@serop char(4)		=NULL--'140Q'			
	,@numop char(10)	=NULL--'0000000001'
	,@tallaid CHAR(2)	=NULL
	,@Idx char(3)		=NULL
	)
AS
BEGIN

 	SET @tallaid =ISNULL(@tallaid,'B1')
	SET @Idx  	 ='ALL'


	IF(@Idx='CAB')/*cabecera reporte*/
	BEGIN
		EXEC gspTb_RptCabecera_ReqProduccion		
		 @tipop		
		,@serop		
		,@numop		
		,@tallaid	
		,@Idx		
	END

	IF(@Idx='CPO')/*cuerpo reporte*/
	BEGIN
		EXEC gspTb_RptCuerpo_ReqProduccion			
		 @tipop		
		,@serop		
		,@numop		
		,@tallaid	
		,@Idx		
	END

	IF(@Idx='DET')/*detalle reporte*/
	BEGIN
		EXEC gspTb_RptDetalle_ReqProduccion		
		 @tipop		
		,@serop		
		,@numop		
		,@tallaid	
		,@Idx		
	END

	IF(@Idx='ALL')/*detalle reporte*/
	BEGIN  

		BEGIN
		create table #RptCabecera_ReqProduccion
		(
		serierq		varchar(10),
		numreq		varchar(10),
		tipop		char(2), 
		serop		char(4),
		numop		char(10),
		fechini		datetime,
		fechfin		datetime,
		destino		varchar(70),
		serieop		varchar(10),
		numopr		varchar(10),
		articidold	varchar(7),
		articname	varchar(50)
		)		
		insert into #RptCabecera_ReqProduccion 
			EXEC gspTb_RptCabecera_ReqProduccion	  
			 @tipop		
			,@serop		
			,@numop		
			,@tallaid	
			,'CAB'
		END
		BEGIN
		create table #RptCuerpo_ReqProduccion 
		(
			tipop char(2),
			serop char(4),
			numop char(10),
			colorname varchar(30),	
			[01] int,
			[02] int,
			[03] int,
			[04] int,
			[05] int,
			[06] int,
			[07] int,
			[08] int,
			[09] int,
			[10] int,
			[11] int,
			[12] int,
			panios int,
			totalprend int,
			canalventaname varchar(50),
			cliente varchar(70)
		)			
		
		insert into #RptCuerpo_ReqProduccion 		
			EXEC gspTb_RptCuerpo_ReqProduccion			
			 @tipop		
			,@serop		
			,@numop		
			,@tallaid	
			,'CPO'				
		END

		BEGIN
		create table #RptDetalle_ReqProduccion
		(
			tipop char(2), 
			serop char(4),
			numop char(10),
			partepdaname varchar(30),
			productid	 varchar(13),
			productname	 varchar(500),
			consumo		 numeric(14,9),
			panios		 int,
			prendas		 int,
			total		 numeric(14,9)
		)
		
		insert into #RptDetalle_ReqProduccion
			EXEC gspTb_RptDetalle_ReqProduccion		
			 @tipop		
			,@serop		
			,@numop		
			,@tallaid	
			,'DET' 
		END
			
		--DECLARE @Columna AS TABLE (STR6 VARCHAR(MAX))
		--INSERT INTO @Columna
		--	EXEC gspTb_RptCuerpo_ReqProduccion			
		--	 @tipop		
		--	,@serop		
		--	,@numop		
		--	,@tallaid	
		--	,'COL'

		--DECLARE
		--@STR6 VARCHAR(MAX) = (SELECT STR6 FROM @Columna);

		--/* consulta dinamica */
		--Declare
		--@SQLString nvarchar(max),
		--@ParmDefinition nvarchar(max),
		--@moduloshort char(2);

		--SET @SQLString= N' ' +
		--N' SELECT DISTINCT  ' +
		--N' a.*,  ' +
		--N' b.tipop, ' +
		--N' b.serop, ' +
		--N' b.numop, ' +
		--N' b.colorname, '+@STR6+' '+ 
		----N' ,b.panios, ' +
		----N' b.totalprend, ' +
		--N' ,b.canalventaname, ' +
		--N' b.cliente, ' +
		--N' c.* 	 ' +
		--N' FROM  ' +
		--N' #RptCabecera_ReqProduccion a,  ' +
		--N' #RptCuerpo_ReqProduccion b,  ' +
		--N' #RptDetalle_ReqProduccion c ' 
		--EXEC(@SQLString);

		select 
		 a.serierq		
		,a.numreq		
		,a.tipop		
		,a.serop		
		,a.numop		
		,a.fechini		
		,a.fechfin		
		,a.destino		
		,a.serieop		
		,a.numopr		
		,a.articidold	
		,a.articname	
		,b.colorname
		,b.[01]as 'ta01'
		,b.[02]as 'ta02'
		,b.[03]as 'ta03'
		,b.[04]as 'ta04'
		,b.[05]as 'ta05'
		,b.[06]as 'ta06'
		,b.[07]as 'ta07'
		,b.[08]as 'ta08'
		,b.[09]as 'ta09'
		,b.[10]as 'ta10'
		,b.[11]as 'ta11'
		,b.[12]as 'ta12'
		,b.panios
		,b.totalprend
		,b.canalventaname
		,b.cliente		
		,c.partepdaname
		,c.productid	
		,c.productname	
		,c.consumo		
		,c.panios		
		,c.prendas		
		,c.total			
		from 
		#RptCabecera_ReqProduccion a,
		#RptCuerpo_ReqProduccion b, 
		#RptDetalle_ReqProduccion c
		where 
			a.tipop=c.tipop
		and a.serop=c.serop
		and a.numop=c.numop
		and c.tipop=b.tipop
		and c.serop=b.serop
		and c.numop=b.numop
		

		and c.tipop='OP'
		and c.serop='140Q'
		and c.numop='0000000001'
				
		drop table #RptCabecera_ReqProduccion 
		drop table #RptCuerpo_ReqProduccion 
		drop table #RptDetalle_ReqProduccion 	
	END
END




