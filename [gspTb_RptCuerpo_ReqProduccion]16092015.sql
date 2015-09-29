USE [bapEmpresa02]
GO
/****** Object:  StoredProcedure [dbo].[gspTb_RptCuerpo_ReqProduccion]    Script Date: 16/09/2015 2:01:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*cuerpo de reporte*/
/*
EXEC gspTb_RptCuerpo_ReqProduccion
 'OP'
,'140Q'		
,'0000000001'
,'D2'
,'CPO'
*/

ALTER PROCEDURE [dbo].[gspTb_RptCuerpo_ReqProduccion](
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
	SET @Idx	 ='CPO'

	IF (@Idx IN('CPO','COL'))
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

		create table #RptDetalle
		(
					tipop char(2), 
					serop char(4),
					numop char(10),
					colorid varchar(3),
					colorname varchar(30),
					coltalla char(2),
					panios		 int,
					totalprendas int,			
					total		int,
					canalventaname varchar(50),
					ctactename varchar(70) 
					)
		insert into #RptDetalle
		select 
		op.tipop, op.serop, op.numop,co.colorid, co.colorname,rqd.coltalla,
		rqd.panios,rqd.totalprendas,rqd.totalprendas total
		,cv.canalventaname,cl.ctactename 
		from [dbo].[tb_pp_reqproddet] rqd 
		inner join [dbo].[tb_pp_reqprodcab] rqc on 
			rqd.tipreq =rqc.tipreq  
		and rqd.serreq =rqc.serreq  
		and rqd.numreq =rqc.numreq 	
		inner join [dbo].[tb_pp_ordenprodcab] op on 
			op.tipop =rqd.tipop 
		and op.serop =rqd.serop 
		and op.numop =rqd.numop 
		inner join [dbo].[tb_pt_articulo] ar on
			ar.articid = op.articid 
		inner join [dbo].[tb_cliente]cl on 
			cl.ctacte=op.ctacte
		inner join [dbo].[tb_cp_canalventa]cv on 
			cv.canalventaid=op.canalventaid 
		inner join [dbo].[tb_pt_color]co on 
			co.colorid=rqd.colorid			
		where 								
				op.tipop = @tipop
			and op.serop = @serop
			and op.numop = @numop

		declare 
		@y int =(select count(1) from #mytabla),
		@x int =1,
		@colorid char(3)  
		while @x<=@y
		begin 
			set @colorid = (select colorid from #mytabla where item = @x)
			update	#RptDetalle
			set panios = (select sum(panios) from #RptDetalle where colorid IN (@colorid)),	
			totalprendas =(select sum(totalprendas) from #RptDetalle where colorid IN (@colorid))
			where 
			colorid = @colorid	
			set @x=@x+1
		end 
		

		SELECT tipop, serop, numop, colorname, 
			SUM(ISNULL([01],0)) AS [ta01], SUM(ISNULL([02],0)) AS [ta02], SUM(ISNULL([03],0)) AS [ta03], 
			SUM(ISNULL([04],0)) AS [ta04], SUM(ISNULL([05],0)) AS [ta05], SUM(ISNULL([06],0)) AS [ta06], 
			SUM(ISNULL([07],0)) AS [ta07], SUM(ISNULL([08],0)) AS [ta08], SUM(ISNULL([09],0)) AS [ta09], 
			SUM(ISNULL([10],0)) AS [ta10], SUM(ISNULL([11],0)) AS [ta11], SUM(ISNULL([12],0)) AS [ta12]
		,panios,totalprendas,canalventaname, ctactename cliente 
		FROM  
		( 	  
			select 
			tipop, serop, numop,colorid, colorname,coltalla,
			panios,totalprendas,total
			,canalventaname,ctactename  
			from #RptDetalle 
		) as Points  
			PIVOT 	
		(AVG(total)   
					FOR coltalla in ( 
		[01], [02], [03], [04], [05], [06], [07], [08], [09], [10], [11], [12]			
					) 
		)AS PivotTable 
		GROUP BY tipop, serop, numop,colorname,panios,canalventaname,ctactename,totalprendas;  
		drop table #mytabla
		drop table #RptDetalle;
	    
	END
	ELSE
	BEGIN
	RAISERROR (N'[dbo].[gspTb_Rptcabecera_ReqProduccion]: SELECT Batch: 1.....VERIFICAR DATOS DE ENTRADA!', 10, 1) WITH NOWAIT;
	END 
END



