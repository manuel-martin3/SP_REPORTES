USE [bapEmpresa02]
GO
/****** Object:  StoredProcedure [dbo].[gspTb_RptDetalle_ReqProduccion]    Script Date: 16/09/2015 2:02:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*detalle de reporte*/
/*
EXEC  gspTb_RptDetalle_ReqProduccion
 'OP'
,'140Q'		
,'0000000001'
,'B1'
,'DET'
*/

ALTER PROCEDURE [dbo].[gspTb_RptDetalle_ReqProduccion](
--	declare 
	 @tipop char(2)		=NULL--'OP'
	,@serop char(4)		=NULL--'140Q'			
	,@numop char(10)	=NULL--'0000000001'
	,@tallaid CHAR(2)	=NULL
	,@Idx char(3)		=NULL
	)
AS
BEGIN

	SET @tallaid 	=ISNULL(@tallaid,'B1')
	SET @Idx 		='DET'

	IF (@Idx='DET')
	BEGIN 	
	create table #mytabla 
		(item int identity(1,1), colorid varchar(3))
	insert into #mytabla
	select 
	rqd.colorid as colorid  
	from [dbo].[tb_pp_reqproddet] rqd
	inner join [dbo].[tb_pp_reqprodcab] rqc on
		rqd.tipreq =rqc.tipreq 
	and rqd.serreq =rqc.serreq 
	and rqd.numreq =rqc.numreq 
	WHERE
		rqd.tipop=@tipop
	and rqd.serop=@serop
	and rqd.numop=@numop
	group by rqd.colorid

	declare @detalle as Table(
	tipop char(2),	
	serop char(4),	
	numop char(10),
	partepdaname varchar(30),
	productid varchar(13),
	productname varchar(500),
	consumo numeric(14,9),
	panios int,
	prendas int,
	total numeric(14,9)
	)

	DECLARE @prendas int, @panios int, @color char(3)
	declare 
	@d int = (select COUNT(1) from #mytabla), 
	@e int = 1
	while @e<=@d
	begin			
		set @color=(SELECT colorid FROM #mytabla WHERE item =@e)
		--select @color
		(select @prendas= SUM(ISNULL(rqd.totalprendas,0))
		from [dbo].[tb_pp_reqproddet] rqd
		inner join [dbo].[tb_pp_reqprodcab] rqc on
			rqd.tipreq =rqc.tipreq 
		and rqd.serreq =rqc.serreq 
		and rqd.numreq =rqc.numreq 
		where 
			rqd.tipop =@tipop 
		and rqd.serop =@serop 
		and rqd.numop =@numop 
		and rqd.colorid =@color)  

		(select @panios= SUM(ISNULL(rqd.panios,0))
		from [dbo].[tb_pp_reqproddet] rqd
		inner join [dbo].[tb_pp_reqprodcab] rqc on
			rqd.tipreq =rqc.tipreq 
		and rqd.serreq =rqc.serreq 
		and rqd.numreq =rqc.numreq 
		where 
			rqd.tipop =@tipop 
		and rqd.serop =@serop 
		and rqd.numop =@numop 
		and rqd.colorid =@color)	

		insert into @detalle 
		select @tipop, @serop, @numop,		
		partepdaname,pr.productid,pr.productname,isnull(null,0.00)as'consumo',		
		 @panios panios
		,@prendas prendas
		,isnull(null,0.00) as'total' 
		
		from tb_pp_parteprenda p
			inner join tb_pp_ordenprodfase ofa on 
				p.partepdaid=ofa.secuencia
			inner join tb_pp_ordenprodtela ot on
					ot.[tipop]		=ofa.[tipop]
				and ot.[serop]		=ofa.[serop]
				and ot.[numop]		=ofa.[numop]
				and ot.[partepdaid]	=p.[partepdaid]
			inner join tb_ta_productos pr on 
				pr.[productid]=ot.productid
			inner join [tb_pp_reqproddet] rqd on
				ot.[tipop]		=rqd.[tipop]
			and ot.[serop]		=rqd.[serop]
			and ot.[numop]		=rqd.[numop]

		where
				rqd.tipop=@tipop
			and rqd.serop=@serop
			and rqd.numop=@numop
			and rqd.colorid=@color
						   
		set @e=@e+1
	end
	select distinct * from @detalle
	drop table #mytabla
	END
	ELSE
	BEGIN
	RAISERROR (N'[dbo].[gspTb_Rptcabecera_ReqProduccion]: SELECT Batch: 1.....VERIFICAR DATOS DE ENTRADA!', 10, 1) WITH NOWAIT;
	END 			   
END


