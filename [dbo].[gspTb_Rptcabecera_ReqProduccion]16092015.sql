USE [bapEmpresa02]
GO
/****** Object:  StoredProcedure [dbo].[gspTb_Rptcabecera_ReqProduccion]    Script Date: 16/09/2015 1:57:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*cabecera de reporte*/
/*
EXEC  gspTb_RptCabecera_ReqProduccion
 'OP'
,'140Q'		
,'0000000001'
,'B1'
,'CAB'
*/

ALTER PROCEDURE [dbo].[gspTb_Rptcabecera_ReqProduccion](
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
	SET @Idx    	='CAB'

	IF (@Idx='CAB')
	BEGIN
	select distinct 
		rqc.tipreq+'-'+rqc.serreq serierq,right(rqc.numreq,5)numreq,
		@tipop tipop,
		@serop serop,
		@numop numop,
		rqc.fechini,rqc.fechfin,
		--fa.fasename,sc.servcortename, 
		cl.ctactename destino,
		rqd.tipop+'-'+rqd.serop serieop,right(rqd.numop,5)numopr,
		ar.articidold,ar.articname
		from [dbo].[tb_pp_reqproddet] rqd
		inner join [dbo].[tb_pp_reqprodcab] rqc on
			rqd.tipreq =rqc.tipreq 
		and rqd.serreq =rqc.serreq 
		and rqd.numreq =rqc.numreq 
		inner join [dbo].[tb_pp_ordenprodfase] ofa on
				ofa.tipop =rqd.tipop
			and ofa.serop =rqd.serop
			and ofa.numop =rqd.numop
		inner join [dbo].[tb_cliente] cl on
			cl.ctacte=ofa.ctacte
		inner join [dbo].[tb_pp_fase] fa on
		fa.faseid=ofa.faseid
		inner join [dbo].[tb_pp_servcorte]sc on
			sc.servcorteid=rqc.servcorteid
		inner join [dbo].[tb_pp_ordenprodcab] op on
					op.tipop =rqd.tipop
				and op.serop =rqd.serop
				and op.numop =rqd.numop
		inner join [dbo].[tb_pt_articulo] ar on
		ar.articid= op.articid
		where 
			rqd.tipop =@tipop 
		and rqd.serop =@serop 
		and rqd.numop =@numop 
	END
	ELSE
	BEGIN
	RAISERROR (N'[dbo].[gspTb_Rptcabecera_ReqProduccion]: SELECT Batch: 1.....VERIFICAR DATOS DE ENTRADA!', 10, 1) WITH NOWAIT;
	END 
END